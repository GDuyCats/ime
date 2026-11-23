import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/contact_repository.dart';
import '../data/contract_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/billing.dart';
import '../utils/dates.dart';
import '../utils/money.dart';
import 'charge_editor.dart';
import 'labels.dart';
import 'widgets.dart';

enum _TenantMode { existing, newPerson }

/// Rents out an item (new contract) or edits the running contract.
/// Pops with `true` when saved.
class ContractFormScreen extends StatefulWidget {
  const ContractFormScreen({
    super.key,
    required this.book,
    required this.item,
    this.existing,
  });

  final Book book;
  final Item item;
  final ContractDetail? existing;

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ContractRepository _contracts = ContractRepository();
  late final TextEditingController _tenantName;
  late final TextEditingController _tenantPhone;
  late final TextEditingController _rent;
  late final TextEditingController _occupants;
  late final TextEditingController _deposit;
  late final TextEditingController _note;

  _TenantMode _tenantMode = _TenantMode.newPerson;
  String? _contactId;
  BillingCycle _cycle = BillingCycle.month;
  DateTime _startDate = dateOnly(DateTime.now());

  /// Once the user types a deposit, changing the rent no longer
  /// overwrites it.
  bool _depositEdited = false;

  List<Contact> _contacts = const [];
  List<ChargeInput>? _charges;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;
  String get _currency => widget.book.currency;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final contract = existing?.contract;
    final rent = contract?.rentAmount ?? widget.item.defaultPrice;

    _tenantName = TextEditingController();
    _tenantPhone = TextEditingController();
    _rent = TextEditingController(
      text: rent == null ? '' : formatMoneyPlain(rent, _currency),
    );
    _occupants = TextEditingController(text: '${contract?.occupants ?? 1}');
    _deposit = TextEditingController(
      text: contract != null
          ? formatMoneyPlain(contract.depositAmount, _currency)
          : rent == null
              ? ''
              : formatMoneyPlain(
                  suggestedDeposit(rent, widget.book.depositMonths),
                  _currency,
                ),
    );
    _note = TextEditingController(text: contract?.note ?? '');
    if (contract != null) {
      _cycle = contract.cycle;
      _startDate = contract.startDate;
      _depositEdited = true;
    }
    _rent.addListener(_syncDeposit);
    _load();
  }

  Future<void> _load() async {
    final existing = widget.existing;
    final contacts = await ContactRepository().listContacts();
    final charges = existing != null
        ? [for (final c in existing.charges) c.toInput()]
        : [
            for (final c
                in await BookRepository().listDefaultCharges(widget.book.id))
              c.toInput(),
          ];
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _charges = charges;
    });
  }

  void _syncDeposit() {
    if (_depositEdited || _isEditing) return;
    final rent = parseMoney(_rent.text, _currency);
    _deposit.text = rent == null
        ? ''
        : formatMoneyPlain(
            suggestedDeposit(rent, widget.book.depositMonths),
            _currency,
          );
  }

  @override
  void dispose() {
    _rent.removeListener(_syncDeposit);
    _tenantName.dispose();
    _tenantPhone.dispose();
    _rent.dispose();
    _occupants.dispose();
    _deposit.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = dateOnly(picked));
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    final charges = _charges;
    if (form == null || !form.validate() || charges == null) return;
    // "Saved person" with nobody saved yet: nothing to pick from.
    if (!_isEditing &&
        _tenantMode == _TenantMode.existing &&
        _contactId == null) {
      return;
    }

    final rent = parseMoney(_rent.text, _currency)!;
    final occupants = int.parse(_occupants.text.trim());
    final deposit = parseMoney(_deposit.text, _currency) ?? 0;
    final noteText = _note.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    setState(() => _saving = true);
    try {
      final existing = widget.existing;
      if (existing != null) {
        await _contracts.updateContract(
          existing.contract.id,
          rentAmount: rent,
          occupants: occupants,
          depositAmount: deposit,
          note: note,
          charges: charges,
        );
      } else {
        final phone = _tenantPhone.text.trim();
        final tenant = _tenantMode == _TenantMode.existing
            ? TenantInput.existing(_contactId!)
            : TenantInput.newContact(
                name: _tenantName.text.trim(),
                phone: phone.isEmpty ? null : phone,
              );
        await _contracts.createContract(
          book: widget.book,
          item: widget.item,
          tenant: tenant,
          rentAmount: rent,
          cycle: _cycle,
          startDate: _startDate,
          occupants: occupants,
          depositAmount: deposit,
          note: note,
          charges: charges,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Widget> _tenantFields(AppLocalizations l10n) {
    final existing = widget.existing;
    if (existing != null) {
      return [
        BorderedList(
          children: [
            ListRow(
              leading: const Icon(Icons.person_outline),
              title: existing.contact.name,
              subtitle: existing.contact.phone,
            ),
          ],
        ),
      ];
    }

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SelectableTag(
            label: l10n.tenantNew,
            selected: _tenantMode == _TenantMode.newPerson,
            onTap: () => setState(() => _tenantMode = _TenantMode.newPerson),
          ),
          SelectableTag(
            label: l10n.tenantExisting,
            selected: _tenantMode == _TenantMode.existing,
            onTap: () => setState(() => _tenantMode = _TenantMode.existing),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (_tenantMode == _TenantMode.newPerson) ...[
        TextFormField(
          controller: _tenantName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.personName,
            hintText: l10n.personNameHint,
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? l10n.fieldRequired
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tenantPhone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.phone),
        ),
      ] else if (_contacts.isEmpty)
        Text(l10n.noContactsYet)
      else
        DropdownButtonFormField<String>(
          initialValue: _contactId,
          decoration: InputDecoration(labelText: l10n.chooseTenant),
          items: [
            for (final contact in _contacts)
              DropdownMenuItem<String>(
                value: contact.id,
                child: Text(
                  contact.phone == null
                      ? contact.name
                      : '${contact.name} · ${contact.phone}',
                ),
              ),
          ],
          onChanged: (value) => setState(() => _contactId = value),
          validator: (value) => value == null ? l10n.fieldRequired : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final charges = _charges;
    final firstDue = firstDueDate(_startDate, _cycle, widget.book.rentTiming);
    final hintStyle = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(_isEditing ? l10n.editContract : l10n.rentOut),
      ),
      body: Form(
        key: _formKey,
        child: PageBody(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Text(
                '${widget.item.name} · ${widget.book.name}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              SectionTitle(l10n.tenant),
              const SizedBox(height: 10),
              ..._tenantFields(l10n),
              const SizedBox(height: 28),
              SectionTitle(l10n.currentContract),
              const SizedBox(height: 10),
              TextFormField(
                controller: _rent,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.rentAmount,
                  suffixText: currencySymbol(_currency),
                ),
                validator: (value) {
                  final amount = parseMoney(value ?? '', _currency);
                  if (amount == null || amount <= 0) return l10n.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cycle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cycle in BillingCycle.values)
                    SelectableTag(
                      label: cycleLabel(l10n, cycle),
                      selected: _cycle == cycle,
                      onTap: _isEditing
                          ? () {}
                          : () => setState(() => _cycle = cycle),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isEditing ? null : _pickStartDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('${l10n.moveInDate}: ${fullDate(_startDate)}'),
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing
                    ? l10n.contractLocked
                    : l10n.firstDueInfo(fullDate(firstDue)),
                style: hintStyle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupants,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.occupants),
                validator: (value) {
                  final number = int.tryParse(value?.trim() ?? '');
                  if (number == null || number < 1) {
                    return l10n.mustBeWholeNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deposit,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.deposit,
                  suffixText: currencySymbol(_currency),
                ),
                onChanged: (_) => _depositEdited = true,
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
                decoration: InputDecoration(labelText: l10n.note),
              ),
              const SizedBox(height: 28),
              SectionTitle(l10n.extraCharges),
              const SizedBox(height: 10),
              if (charges == null)
                const Center(child: CircularProgressIndicator())
              else
                ChargeEditor(
                  charges: charges,
                  currency: _currency,
                  askMeterReading: true,
                  onChanged: (next) => setState(() => _charges = next),
                ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving || charges == null ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
