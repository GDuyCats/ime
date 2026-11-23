import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/contract_repository.dart';
import '../data/item_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import '../utils/numbers.dart';
import 'book_form_screen.dart';
import 'book_settings_screen.dart';
import 'item_detail_screen.dart';
import 'item_form_screen.dart';
import 'labels.dart';
import 'theme.dart';
import 'widgets.dart';

/// One book and the items inside it.
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

enum _BookAction { edit, settings, delete }

/// Items of a book plus, for rentals, who rents each one.
class _BookItems {
  const _BookItems(this.items, this.tenants);

  final List<Item> items;

  /// Tenant name by item id; missing means vacant.
  final Map<String, String> tenants;
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookRepository _books = BookRepository();
  final ItemRepository _items = ItemRepository();
  late Book _book;
  late Future<_BookItems> _future;

  /// Null means "show every kind".
  ItemKind? _filter;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _future = _load();
  }

  bool get _isRental => _book.template == BookTemplate.rental;

  Future<_BookItems> _load() async {
    final items = await _items.listItems(_book.id);
    final tenants = _isRental
        ? await ContractRepository().tenantNamesForBook(_book.id)
        : const <String, String>{};
    return _BookItems(items, tenants);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openSettings() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookSettingsScreen(book: _book)),
    );
    if (saved != true) return;
    final fresh = await _books.getBook(_book.id);
    if (!mounted || fresh == null) return;
    setState(() => _book = fresh);
  }

  /// Rentals open the item page (contract); other books edit the item.
  Future<void> _openItem(Item item) async {
    if (!_isRental) return _openItemForm(item);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(book: _book, item: item),
      ),
    );
    if (mounted) _reload();
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

  String _itemSubtitle(AppLocalizations l10n, Item item, String? tenant) {
    final parts = <String>[
      if (_isRental) tenant ?? l10n.roomVacant,
      itemKindLabel(l10n, item.kind),
    ];
    final area = item.areaM2;
    if (area != null) parts.add('${formatArea(area)} m²');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= AppTheme.wideBreakpoint;
    final side = wide ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(_book.name),
        actions: [
          PopupMenuButton<_BookAction>(
            onSelected: (action) {
              switch (action) {
                case _BookAction.edit:
                  _editBook();
                case _BookAction.settings:
                  _openSettings();
                case _BookAction.delete:
                  _deleteBook();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: _BookAction.edit, child: Text(l10n.editBook)),
              if (_isRental)
                PopupMenuItem(
                  value: _BookAction.settings,
                  child: Text(l10n.bookSettings),
                ),
              PopupMenuItem(value: _BookAction.delete, child: Text(l10n.delete)),
            ],
          ),
        ],
      ),
      body: FutureBuilder<_BookItems>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return ErrorState(error: snapshot.error);
          final data = snapshot.requireData;
          final items = data.items;
          if (items.isEmpty) {
            return Center(
              child: EmptyState(
                icon: templateIcon(_book.template),
                message: l10n.noItems,
              ),
            );
          }

          final kinds = {for (final item in items) item.kind}.toList()
            ..sort((a, b) => a.index.compareTo(b.index));
          final filter = _filter;
          final visible = filter == null
              ? items
              : items.where((item) => item.kind == filter).toList();

          return PageBody(
            child: ListView(
              padding: EdgeInsets.fromLTRB(side, 24, side, 104),
              children: [
                SectionTitle(
                  itemsSectionLabel(l10n, _book.template),
                  size: wide ? 36 : 30,
                ),
                const SizedBox(height: 16),
                if (kinds.length > 1) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SelectableTag(
                        label: l10n.filterAll,
                        selected: filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final kind in kinds)
                        SelectableTag(
                          label: itemKindLabel(l10n, kind),
                          selected: filter == kind,
                          onTap: () => setState(() => _filter = kind),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                BorderedList(
                  children: [
                    for (final item in visible)
                      ListRow(
                        leading: Icon(itemKindIcon(item.kind)),
                        title: item.name,
                        subtitle: _itemSubtitle(l10n, item, data.tenants[item.id]),
                        trailing: _PriceText(
                          price: item.defaultPrice,
                          currency: _book.currency,
                        ),
                        onTap: () => _openItem(item),
                      ),
                  ],
                ),
              ],
            ),
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

/// Right-aligned price, or nothing when the item has no default price.
class _PriceText extends StatelessWidget {
  const _PriceText({required this.price, required this.currency});

  final int? price;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final value = price;
    if (value == null) return const SizedBox.shrink();
    return Text(
      formatMoney(value, currency),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontFeatures: tabularFigures,
      ),
    );
  }
}
