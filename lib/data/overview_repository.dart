import '../utils/dates.dart';
import 'app_database.dart';
import 'book_repository.dart';
import 'models.dart';

/// Money in and out during one month, in one currency.
class MonthTotals {
  MonthTotals();

  int income = 0;
  int expense = 0;

  int get profit => income - expense;
}

/// A due that is not fully paid yet, as shown in "To handle".
class PendingDue {
  const PendingDue({
    required this.id,
    required this.bookName,
    required this.title,
    required this.isReceivable,
    required this.dueDate,
    required this.snoozedUntil,
    required this.currency,
    required this.remaining,
  });

  final String id;
  final String bookName;
  final String title;

  /// True for money to collect, false for money to pay.
  final bool isReceivable;
  final DateTime dueDate;
  final DateTime? snoozedUntil;
  final String currency;

  /// Amount still owed, in minor units.
  final int remaining;
}

class OverviewData {
  const OverviewData({
    required this.totals,
    required this.dues,
    required this.books,
  });

  /// Keyed by currency code; empty when nothing was recorded this month.
  final Map<String, MonthTotals> totals;
  final List<PendingDue> dues;
  final List<BookSummary> books;
}

class OverviewRepository {
  OverviewRepository([AppDatabase? database])
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<OverviewData> load(DateTime month) async {
    final db = await _database.database;

    final totalRows = await db.rawQuery(
      '''
      SELECT currency, direction, SUM(amount) AS total
      FROM transactions
      WHERE deleted_at IS NULL AND date >= ? AND date < ?
      GROUP BY currency, direction
      ''',
      [isoDate(monthStart(month)), isoDate(nextMonthStart(month))],
    );
    final totals = <String, MonthTotals>{};
    for (final row in totalRows) {
      final currency = row['currency']! as String;
      final amount = (row['total'] as num?)?.toInt() ?? 0;
      final entry = totals.putIfAbsent(currency, MonthTotals.new);
      if (row['direction'] == CategoryDirection.income.name) {
        entry.income += amount;
      } else {
        entry.expense += amount;
      }
    }

    final dueRows = await db.rawQuery('''
      SELECT d.id, d.title, d.direction, d.due_date, d.snoozed_until,
        d.currency, d.total_amount - d.paid_amount AS remaining,
        b.name AS book_name
      FROM dues d
      JOIN books b ON b.id = d.book_id
      WHERE d.deleted_at IS NULL AND b.deleted_at IS NULL
        AND d.status != 'paid'
      ORDER BY d.due_date ASC
      LIMIT 50
    ''');
    final dues = <PendingDue>[];
    for (final row in dueRows) {
      final dueDate = parseIsoDate(row['due_date'] as String?);
      if (dueDate == null) continue;
      dues.add(PendingDue(
        id: row['id']! as String,
        bookName: row['book_name']! as String,
        title: row['title']! as String,
        isReceivable: row['direction'] == 'receivable',
        dueDate: dueDate,
        snoozedUntil: parseIsoDate(row['snoozed_until'] as String?),
        currency: row['currency']! as String,
        remaining: (row['remaining'] as num?)?.toInt() ?? 0,
      ));
    }

    final books = await BookRepository(_database).listBooks();
    return OverviewData(totals: totals, dues: dues, books: books);
  }
}
