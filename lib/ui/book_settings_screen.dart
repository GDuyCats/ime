import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'charge_editor.dart';
import 'widgets.dart';

/// Defaults of a rental book: when rent is collected, the usual deposit,
/// the notice period and the extra charges every new contract starts with.
/// Pops with `true` when saved.
class BookSettingsScreen extends StatefulWidget {
  const BookSettingsScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookSettingsScreen> createState() => _BookSettingsScreenState();
}

class _BookSettingsScreenState extends State<BookSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BookRepository _books = BookRepository();
  late final TextEditingController _depositMonths;
  late final TextEditingController _noticeDays;
  late RentTiming _rentTiming;
  List<ChargeInput>? _charges;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _depositMonths = TextEditingController(text: '${book.depositMonths}');
    _noticeDays = TextEditingController(text: '${book.noticeDays}');
    _rentTiming = book.rentTiming;
    _loadCharges();
  }

  Future<void> _loadCharges() async {
    final charges = await _books.listDefaultCharges(widget.book.id);
    if (!mounted) return;
    setState(() => _charges = [for (final c in charges) c.toInput()]);
  }

  @override
  void dispose() {
    _depositMonths.dispose();
    _noticeDays.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    final charges = _charges;
    if (form == null || !form.validate() || charges == null) return;

    setState(() => _saving = true);
    try {
      await _books.saveRentalSettings(
        widget.book.id,
        rentTiming: _rentTiming,
        depositMonths: int.parse(_depositMonths.text.trim()),
        noticeDays: int.parse(_noticeDays.text.trim()),
        charges: charges,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateWholeNumber(AppLocalizations l10n, String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) return l10n.mustBeWholeNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final charges = _charges;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 60, title: Text(l10n.bookSettings)),
      body: Form(
        key: _formKey,
        child: PageBody(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Text(
                widget.book.name,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              SectionTitle(l10n.rentTimingLabel),
              const SizedBox(height: 10),
              _ChoiceTile(
                title: l10n.rentPostpaid,
                description: l10n.rentPostpaidDesc,
                selected: _rentTiming == RentTiming.postpaid,
                onTap: () => setState(() => _rentTiming = RentTiming.postpaid),
              ),
              _ChoiceTile(
                title: l10n.rentPrepaid,
                description: l10n.rentPrepaidDesc,
                selected: _rentTiming == RentTiming.prepaid,
                onTap: () => setState(() => _rentTiming = RentTiming.prepaid),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _depositMonths,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.depositMonthsLabel),
                validator: (value) => _validateWholeNumber(l10n, value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noticeDays,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.noticeDaysLabel),
                validator: (value) => _validateWholeNumber(l10n, value),
              ),
              const SizedBox(height: 28),
              SectionTitle(l10n.defaultChargesTitle),
              const SizedBox(height: 4),
              Text(
                l10n.defaultChargesHint,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              if (charges == null)
                const Center(child: CircularProgressIndicator())
              else
                ChargeEditor(
                  charges: charges,
                  currency: widget.book.currency,
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

/// A bordered option with a title and description; black border when
/// selected.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? scheme.onSurface : scheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check, color: scheme.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
