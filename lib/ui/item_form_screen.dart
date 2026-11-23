import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import '../utils/numbers.dart';
import 'labels.dart';
import 'widgets.dart';

/// Adds an item to a book, or edits / deletes an existing one.
/// Pops with `true` when something changed.
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, required this.book, this.item});

  final Book book;
  final Item? item;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ItemRepository _items = ItemRepository();
  late final TextEditingController _name;
  late final TextEditingController _area;
  late final TextEditingController _price;
  late final TextEditingController _note;
  late ItemKind _kind;
  bool _saving = false;

  String get _currency => widget.book.currency;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final area = item?.areaM2;
    final price = item?.defaultPrice;
    _name = TextEditingController(text: item?.name ?? '');
    _area = TextEditingController(text: area == null ? '' : formatArea(area));
    _price = TextEditingController(
      text: price == null ? '' : formatMoneyPlain(price, _currency),
    );
    _note = TextEditingController(text: item?.note ?? '');
    _kind = item?.kind ?? defaultItemKind(widget.book.template);
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final name = _name.text.trim();
    final area = _kind.hasArea ? parseArea(_area.text) : null;
    final price = parseMoney(_price.text, _currency);
    final noteText = _note.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    setState(() => _saving = true);
    try {
      final item = widget.item;
      if (item == null) {
        await _items.createItem(
          bookId: widget.book.id,
          name: name,
          kind: _kind,
          areaM2: area,
          defaultPrice: price,
          note: note,
        );
      } else {
        await _items.updateItem(
          item.id,
          name: name,
          kind: _kind,
          areaM2: area,
          defaultPrice: price,
          note: note,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteItemTitle,
      message: l10n.deleteItemBody,
    );
    if (!confirmed) return;
    await _items.deleteItem(item.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editItem : l10n.addItem),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.delete,
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.itemName,
                hintText: l10n.itemNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ItemKind>(
              initialValue: _kind,
              decoration: InputDecoration(
                labelText: l10n.itemKind,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final kind in ItemKind.values)
                  DropdownMenuItem<ItemKind>(
                    value: kind,
                    child: Row(
                      children: [
                        Icon(itemKindIcon(kind), size: 20),
                        const SizedBox(width: 12),
                        Text(itemKindLabel(l10n, kind)),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _kind = value);
              },
            ),
            if (_kind.hasArea) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _area,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.area,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return parseArea(value) == null ? l10n.invalidNumber : null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.defaultPrice,
                suffixText: currencySymbol(_currency),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return parseMoney(value, _currency) == null
                    ? l10n.invalidNumber
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
