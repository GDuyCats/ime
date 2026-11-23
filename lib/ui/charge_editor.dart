import 'package:flutter/material.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import '../utils/numbers.dart';
import 'labels.dart';
import 'theme.dart';
import 'widgets.dart';

/// Editable list of extra charges (electricity, water, wifi, ...).
///
/// Used for a book's default charges and for one contract's charges.
/// Contracts also ask for the starting meter reading of metered charges.
class ChargeEditor extends StatelessWidget {
  const ChargeEditor({
    super.key,
    required this.charges,
    required this.currency,
    required this.onChanged,
    this.askMeterReading = false,
  });

  final List<ChargeInput> charges;
  final String currency;
  final ValueChanged<List<ChargeInput>> onChanged;
  final bool askMeterReading;

  Future<void> _edit(BuildContext context, [int? index]) async {
    final result = await showDialog<ChargeInput>(
      context: context,
      builder: (_) => _ChargeDialog(
        initial: index == null ? null : charges[index],
        currency: currency,
        askMeterReading: askMeterReading,
      ),
    );
    if (result == null) return;
    final next = [...charges];
    if (index == null) {
      next.add(result);
    } else {
      next[index] = result;
    }
    onChanged(next);
  }

  void _remove(int index) {
    onChanged([...charges]..removeAt(index));
  }

  String _subtitle(AppLocalizations l10n, ChargeInput charge) {
    final parts = [
      calcTypeLabel(l10n, charge.calcType),
      chargeSummary(l10n, charge, currency),
    ];
    final reading = charge.meterReading;
    if (askMeterReading &&
        charge.calcType == ChargeCalcType.meter &&
        reading != null) {
      parts.add(l10n.meterReadingValue(formatArea(reading)));
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BorderedList(
          children: charges.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noCharges,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ]
              : [
                  for (var i = 0; i < charges.length; i++)
                    ListRow(
                      title: charges[i].name,
                      subtitle: _subtitle(l10n, charges[i]),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.removeCharge,
                        onPressed: () => _remove(i),
                      ),
                      onTap: () => _edit(context, i),
                    ),
                ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.add),
          label: Text(l10n.addCharge),
        ),
      ],
    );
  }
}

class _ChargeDialog extends StatefulWidget {
  const _ChargeDialog({
    required this.initial,
    required this.currency,
    required this.askMeterReading,
  });

  final ChargeInput? initial;
  final String currency;
  final bool askMeterReading;

  @override
  State<_ChargeDialog> createState() => _ChargeDialogState();
}

class _ChargeDialogState extends State<_ChargeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _reading;
  late ChargeCalcType _calcType;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final reading = initial?.meterReading;
    _name = TextEditingController(text: initial?.name ?? '');
    _price = TextEditingController(
      text: initial == null || initial.calcType == ChargeCalcType.manual
          ? ''
          : formatMoneyPlain(initial.unitPrice, widget.currency),
    );
    _reading = TextEditingController(
      text: reading == null ? '' : formatArea(reading),
    );
    _calcType = initial?.calcType ?? ChargeCalcType.meter;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _reading.dispose();
    super.dispose();
  }

  bool get _hasPrice => _calcType != ChargeCalcType.manual;

  bool get _hasReading =>
      widget.askMeterReading && _calcType == ChargeCalcType.meter;

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    Navigator.of(context).pop(
      ChargeInput(
        name: _name.text.trim(),
        calcType: _calcType,
        unitPrice: _hasPrice ? (parseMoney(_price.text, widget.currency) ?? 0) : 0,
        meterReading: _hasReading ? parseArea(_reading.text) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.initial == null ? l10n.addCharge : l10n.editCharge,
        style: displayStyle(context, size: 22),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: widget.initial == null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.chargeName,
                    hintText: l10n.chargeNameHint,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChargeCalcType>(
                  initialValue: _calcType,
                  decoration: InputDecoration(labelText: l10n.calcType),
                  items: [
                    for (final type in ChargeCalcType.values)
                      DropdownMenuItem<ChargeCalcType>(
                        value: type,
                        child: Text(calcTypeLabel(l10n, type)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _calcType = value);
                  },
                ),
                if (_hasPrice) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: chargePriceLabel(l10n, _calcType),
                      suffixText: currencySymbol(widget.currency),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return parseMoney(value, widget.currency) == null
                          ? l10n.invalidNumber
                          : null;
                    },
                  ),
                ],
                if (_hasReading) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reading,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.meterStart),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      return parseArea(value) == null
                          ? l10n.invalidNumber
                          : null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
