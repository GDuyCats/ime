import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';
import 'labels.dart';
import 'widgets.dart';

/// First screen: the list of books. The money overview and the
/// "to handle" list will be added here once dues exist.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: FutureBuilder<List<BookSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(error: snapshot.error);
          }
          final books = snapshot.data ?? const <BookSummary>[];
          if (books.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.noBooksTitle,
              message: l10n.noBooksBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.booksTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final summary in books)
                ListTile(
                  leading: Icon(templateIcon(summary.book.template)),
                  title: Text(summary.book.name),
                  subtitle: Text(
                    '${templateLabel(l10n, summary.book.template)}'
                    ' · ${l10n.itemCount(summary.itemCount)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openBook(summary.book),
                ),
            ],
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
