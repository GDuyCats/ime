import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/item_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import '../utils/numbers.dart';
import 'book_form_screen.dart';
import 'item_form_screen.dart';
import 'labels.dart';
import 'widgets.dart';

/// One book and the items inside it.
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

enum _BookAction { edit, delete }

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookRepository _books = BookRepository();
  final ItemRepository _items = ItemRepository();
  late Book _book;
  late Future<List<Item>> _future;

  /// Null means "show every kind".
  ItemKind? _filter;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _future = _items.listItems(_book.id);
  }

  void _reload() {
    setState(() {
      _future = _items.listItems(_book.id);
    });
  }

  Future<void> _editBook() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookFormScreen(book: _book)),
    );
    if (saved != true) return;
    final fresh = await _books.getBook(_book.id);
    if (!mounted || fresh == null) return;
    setState(() => _book = fresh);
  }

  Future<void> _deleteBook() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteBookTitle,
      message: l10n.deleteBookBody,
    );
    if (!confirmed) return;
    await _books.deleteBook(_book.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openItemForm([Item? item]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(book: _book, item: item),
      ),
    );
    if (saved == true && mounted) _reload();
  }

  String _itemSubtitle(AppLocalizations l10n, Item item) {
    final parts = <String>[itemKindLabel(l10n, item.kind)];
    final area = item.areaM2;
    if (area != null) parts.add('${formatArea(area)} m²');
    final price = item.defaultPrice;
    if (price != null) parts.add(formatMoney(price, _book.currency));
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.name),
        actions: [
          PopupMenuButton<_BookAction>(
            onSelected: (action) {
              switch (action) {
                case _BookAction.edit:
                  _editBook();
                case _BookAction.delete:
                  _deleteBook();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: _BookAction.edit, child: Text(l10n.editBook)),
              PopupMenuItem(value: _BookAction.delete, child: Text(l10n.delete)),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(error: snapshot.error);
          }
          final items = snapshot.data ?? const <Item>[];
          if (items.isEmpty) {
            return EmptyState(
              icon: templateIcon(_book.template),
              message: l10n.noItems,
            );
          }

          final kinds = {for (final item in items) item.kind}.toList()
            ..sort((a, b) => a.index.compareTo(b.index));
          final filter = _filter;
          final visible = filter == null
              ? items
              : items.where((item) => item.kind == filter).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  itemsSectionLabel(l10n, _book.template),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (kinds.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.filterAll),
                        selected: filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                      for (final kind in kinds)
                        ChoiceChip(
                          label: Text(itemKindLabel(l10n, kind)),
                          selected: filter == kind,
                          onSelected: (_) => setState(() => _filter = kind),
                        ),
                    ],
                  ),
                ),
              for (final item in visible)
                ListTile(
                  leading: Icon(itemKindIcon(item.kind)),
                  title: Text(item.name),
                  subtitle: Text(_itemSubtitle(l10n, item)),
                  onTap: () => _openItemForm(item),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openItemForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }
}
