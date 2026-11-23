import 'package:flutter/material.dart';

import '../data/contract_repository.dart';
import '../data/item_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/dates.dart';
import '../utils/money.dart';
import '../utils/numbers.dart';
import 'contract_form_screen.dart';
import 'item_form_screen.dart';
import 'labels.dart';
import 'theme.dart';
import 'widgets.dart';

/// A rented item (room, house, vehicle): its details and current contract.
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.book, required this.item});

  final Book book;
  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ContractRepository _contracts = ContractRepository();
  late Item _item;
  late Future<ContractDetail?> _future;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _future = _contracts.activeForItem(_item.id);
  }

  void _reload() {
    setState(() {
      _future = _contracts.activeForItem(_item.id);
    });
  }

  Future<void> _editItem() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(book: widget.book, item: _item),
      ),
    );
    if (saved != true || !mounted) return;
    final items = await ItemRepository().listItems(widget.book.id);
    if (!mounted) return;
    Item? fresh;
    for (final item in items) {
      if (item.id == _item.id) fresh = item;
    }
    if (fresh == null) {
      // The item was deleted in the form.
      Navigator.of(context).pop();
      return;
    }
    final updated = fresh;
    setState(() => _item = updated);
  }

  Future<void> _openContractForm([ContractDetail? existing]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ContractFormScreen(
          book: widget.book,
          item: _item,
          existing: existing,
        ),
      ),
    );
    if (saved == true && mounted) _reload();
  }

  String _itemInfo(AppLocalizations l10n) {
    final parts = <String>[itemKindLabel(l10n, _item.kind)];
    final area = _item.areaM2;
    if (area != null) parts.add('${formatArea(area)} m²');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= AppTheme.wideBreakpoint;
    final side = wide ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(_item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editItem,
            onPressed: _editItem,
          ),
        ],
      ),
      body: FutureBuilder<ContractDetail?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return ErrorState(error: snapshot.error);
          final detail = snapshot.data;

          return PageBody(
            maxWidth: 760,
            child: ListView(
              padding: EdgeInsets.fromLTRB(side, 24, side, 32),
              children: [
                Text(
                  '${_itemInfo(l10n)} · ${widget.book.name}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                SectionTitle(_item.name, size: wide ? 36 : 30),
                const SizedBox(height: 20),
                if (detail == null)
                  _VacantPanel(onRentOut: () => _openContractForm())
                else
                  _ContractPanel(
                    detail: detail,
                    onEdit: () => _openContractForm(detail),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VacantPanel extends StatelessWidget {
  const _VacantPanel({required this.onRentOut});

  final VoidCallback onRentOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l10n.roomVacant, size: 22),
          const SizedBox(height: 4),
          Text(
            l10n.roomVacantBody,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRentOut,
            icon: const Icon(Icons.key_outlined),
            label: Text(l10n.rentOut),
          ),
        ],
      ),
    );
  }
}

class _ContractPanel extends StatelessWidget {
  const _ContractPanel({required this.detail, required this.onEdit});

  final ContractDetail detail;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contract = detail.contract;
    final contact = detail.contact;
    final currency = contract.currency;
    final phone = contact.phone;

    final depositText = contract.depositAmount > 0
        ? '${formatMoney(contract.depositAmount, currency)} · ${l10n.depositHeld}'
        : l10n.depositNone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.currentContract),
        const SizedBox(height: 10),
        BorderedList(
          children: [
            _InfoRow(
              label: l10n.tenant,
              value: phone == null ? contact.name : '${contact.name} · $phone',
            ),
            _InfoRow(
              label: l10n.rentAmount,
              value: rentPerCycle(
                l10n,
                contract.rentAmount,
                currency,
                contract.cycle,
              ),
            ),
            _InfoRow(
              label: l10n.moveInDate,
              value: fullDate(contract.startDate),
            ),
            _InfoRow(
              label: l10n.nextDue,
              value: fullDate(contract.nextDueDate),
            ),
            _InfoRow(label: l10n.occupants, value: '${contract.occupants}'),
            _InfoRow(label: l10n.deposit, value: depositText),
            if (contract.note != null)
              _InfoRow(label: l10n.note, value: contract.note!),
          ],
        ),
        const SizedBox(height: 28),
        SectionTitle(l10n.extraCharges),
        const SizedBox(height: 10),
        BorderedList(
          children: detail.charges.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noCharges),
                  ),
                ]
              : [
                  for (final charge in detail.charges)
                    _InfoRow(
                      label: charge.name,
                      value: chargeSummary(l10n, charge.toInput(), currency),
                    ),
                ],
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.editContract),
        ),
      ],
    );
  }
}

/// Label on the left, value in bold on the right.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
