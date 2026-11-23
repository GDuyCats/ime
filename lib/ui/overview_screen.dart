import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/overview_repository.dart';
import '../l10n/app_localizations.dart';
import '../utils/dates.dart';
import '../utils/money.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';
import 'labels.dart';
import 'theme.dart';
import 'widgets.dart';

/// This month's money across every book, what needs handling, and the
/// list of books.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final OverviewRepository _overview = OverviewRepository();
  final DateTime _month = monthStart(DateTime.now());
  late Future<OverviewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _overview.load(_month);
  }

  void _reload() {
    setState(() {
      _future = _overview.load(_month);
    });
  }

  Future<void> _openBook(Book book) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
    if (mounted) _reload();
  }

  Future<void> _createBook() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BookFormScreen()),
    );
    if (created == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<OverviewData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        final data = snapshot.requireData;

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= AppTheme.wideBreakpoint;
            final side = wide ? 24.0 : 16.0;
            final toHandle = _ToHandleSection(dues: data.dues);
            final books = _BooksSection(
              books: data.books,
              onOpen: _openBook,
              onCreate: _createBook,
            );

            return PageBody(
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, 24, side, 32),
                children: [
                  SectionTitle(
                    l10n.monthTitle(_month.month, _month.year),
                    size: wide ? 36 : 30,
                  ),
                  const SizedBox(height: 16),
                  _MonthTotals(totals: data.totals, wide: wide),
                  const SizedBox(height: 28),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: toHandle),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: books),
                      ],
                    )
                  else ...[
                    toHandle,
                    const SizedBox(height: 28),
                    books,
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Received, spent and profit tiles, one row per currency used.
class _MonthTotals extends StatelessWidget {
  const _MonthTotals({required this.totals, required this.wide});

  final Map<String, MonthTotals> totals;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = StatusColors.of(context);
    final entries = totals.isEmpty
        ? {defaultCurrency: MonthTotals()}.entries.toList()
        : totals.entries.toList();
    final showCurrency = entries.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries) ...[
          if (showCurrency)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 4),
              child: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          _tilesFor(l10n, status, entry.key, entry.value),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _tilesFor(
    AppLocalizations l10n,
    StatusColors status,
    String currency,
    MonthTotals month,
  ) {
    final profit = month.profit;
    final tiles = [
      StatTile(
        label: l10n.statIncome,
        value: formatMoney(month.income, currency),
      ),
      StatTile(
        label: l10n.statExpense,
        value: formatMoney(month.expense, currency),
      ),
      StatTile(
        label: profit < 0 ? l10n.statLoss : l10n.statProfit,
        value: formatMoney(profit.abs(), currency),
        valueColor: profit > 0
            ? status.positive
            : profit < 0
                ? status.overdue
                : null,
      ),
    ];

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            tiles[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _ToHandleSection extends StatelessWidget {
  const _ToHandleSection({required this.dues});

  final List<PendingDue> dues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.toHandleTitle),
        const SizedBox(height: 10),
        BorderedList(
          children: dues.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.toHandleEmpty,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ]
              : [for (final due in dues) _DueRow(due: due)],
        ),
      ],
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({required this.due});

  final PendingDue due;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = StatusColors.of(context);
    final status = dueStatusFor(
      dueDate: due.dueDate,
      snoozedUntil: due.snoozedUntil,
      today: DateTime.now(),
    );
    final date = status.date;

    final (String label, Color color) = switch (status.state) {
      DueState.overdue => (l10n.badgeOverdue(status.days), colors.overdue),
      DueState.today => (l10n.badgeToday, colors.dueToday),
      DueState.promised =>
        (l10n.badgePromised(date == null ? '' : shortDate(date)), scheme.onSurface),
      DueState.upcoming =>
        (l10n.badgeDue(date == null ? '' : shortDate(date)), scheme.onSurfaceVariant),
    };

    return ListRow(
      title: due.title,
      subtitle:
          '${due.bookName} · ${due.isReceivable ? l10n.dueReceivable : l10n.duePayable}',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMoney(due.remaining, due.currency),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFeatures: tabularFigures,
            ),
          ),
          const SizedBox(height: 4),
          StatusBadge(label: label, color: color),
        ],
      ),
    );
  }
}

class _BooksSection extends StatelessWidget {
  const _BooksSection({
    required this.books,
    required this.onOpen,
    required this.onCreate,
  });

  final List<BookSummary> books;
  final ValueChanged<Book> onOpen;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.booksSection),
        const SizedBox(height: 10),
        if (books.isNotEmpty) ...[
          BorderedList(
            children: [
              for (final summary in books)
                ListRow(
                  leading: Icon(templateIcon(summary.book.template)),
                  title: summary.book.name,
                  subtitle: '${templateLabel(l10n, summary.book.template)}'
                      ' · ${l10n.itemCount(summary.itemCount)}',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpen(summary.book),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: Text(l10n.createBook),
        ),
      ],
    );
  }
}
