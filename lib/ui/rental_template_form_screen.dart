import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/rental_template_repository.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import 'charge_editor.dart';
import 'labels.dart';
import 'widgets.dart';

/// Creates or edits a rental template. Pops with `true` when changed.
class RentalTemplateFormScreen extends StatefulWidget {
  const RentalTemplateFormScreen({
    super.key,
    required this.book,
    this.template,
  });

  final Book book;
  final RentalTemplate? template;

  @override
  State<RentalTemplateFormScreen> createState() =>
      _RentalTemplateFormScreenState();
}

class _RentalTemplateFormScreenState extends State<RentalTemplateFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RentalTemplateRepository _templates = RentalTemplateRepository();
  late final TextEditingController _name;
  late final TextEditingController _rent;
  late final TextEditingController _occupants;
  late final TextEditingController _depositMonths;
  late BillingCycle _cycle;
  late bool _isDefault;
  late List<ChargeInput> _charges;
  bool _saving = false;

  String get _currency => widget.book.currency;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    final rent = template?.rentAmount;
    _name = TextEditingController(text: template?.name ?? '');
    _rent = TextEditingController(
      text: rent == null ? '' : formatMoneyPlain(rent, _currency),
    );
    _occupants = TextEditingController(text: '${template?.occupants ?? 1}');
    _depositMonths =
        TextEditingController(text: '${template?.depositMonths ?? 1}');
    _cycle = template?.cycle ?? BillingCycle.month;
    _isDefault = template?.isDefault ?? false;
    _charges = [...?template?.charges];
  }

  @override
  void dispose() {
    _name.dispose();
    _rent.dispose();
    _occupants.dispose();
    _depositMonths.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _saving = true);
    try {
      await _templates.saveTemplate(
        widget.book.id,
        RentalTemplateInput(
          name: _name.text.trim(),
          rentAmount: _rent.text.trim().isEmpty
              ? null
              : parseMoney(_rent.text, _currency),
          cycle: _cycle,
          occupants: int.parse(_occupants.text.trim()),
          depositMonths: int.parse(_depositMonths.text.trim()),
          isDefault: _isDefault,
          charges: _charges,
        ),
        id: widget.template?.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final template = widget.template;
    if (template == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteTemplateTitle,
      message: l10n.deleteTemplateBody,
    );
    if (!confirmed) return;
    await _templates.deleteTemplate(template.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String? _wholeNumber(AppLocalizations l10n, String? value, int min) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < min) return l10n.mustBeWholeNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isEditing = widget.template != null;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(isEditing ? l10n.editTemplate : l10n.addTemplate),
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
        child: PageBody(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              TextFormField(
                controller: _name,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.templateNameLabel,
                  hintText: l10n.templateNameHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.fieldRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rent,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.rentAmount,
                  helperText: l10n.templateRentHelper,
                  suffixText: currencySymbol(_currency),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return parseMoney(value, _currency) == null
                      ? l10n.invalidNumber
                      : null;
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
                      onTap: () => setState(() => _cycle = cycle),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupants,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.occupants),
                validator: (value) => _wholeNumber(l10n, value, 1),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _depositMonths,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.depositMonthsLabel),
                validator: (value) => _wholeNumber(l10n, value, 0),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: Text(
                  l10n.templateIsDefault,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  l10n.templateIsDefaultHint,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(l10n.extraCharges),
              const SizedBox(height: 10),
              ChargeEditor(
                charges: _charges,
                currency: _currency,
                onChanged: (next) => setState(() => _charges = next),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
