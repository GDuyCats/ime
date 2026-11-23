import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';
import 'labels.dart';
import 'theme.dart';
import 'widgets.dart';

/// Every book, with a button to create a new one.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final BookRepository _books = BookRepository();
  late Future<List<BookSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _books.listBooks();
  }

  void _reload() {
    setState(() {
      _future = _books.listBooks();
    });
  }

  Future<void> _createBook() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BookFormScreen()),
    );
    if (created == true && mounted) _reload();
  }

  Future<void> _openBook(Book book) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
    // The book may have been renamed or deleted inside.
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= AppTheme.wideBreakpoint;
    final side = wide ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<BookSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return ErrorState(error: snapshot.error);
          final books = snapshot.data ?? const <BookSummary>[];
          if (books.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: l10n.noBooksTitle,
                message: l10n.noBooksBody,
              ),
            );
          }
          return PageBody(
            child: ListView(
              padding: EdgeInsets.fromLTRB(side, 24, side, 104),
              children: [
                SectionTitle(l10n.booksSection, size: wide ? 36 : 30),
                const SizedBox(height: 16),
                BorderedList(
                  children: [
                    for (final summary in books)
                      ListRow(
                        leading: Icon(templateIcon(summary.book.template)),
                        title: summary.book.name,
                        subtitle: '${templateLabel(l10n, summary.book.template)}'
                            ' · ${l10n.itemCount(summary.itemCount)}',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openBook(summary.book),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBook,
        icon: const Icon(Icons.add),
        label: Text(l10n.createBook),
      ),
    );
  }
}
