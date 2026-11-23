import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/models.dart';
import '../data/rental_template_repository.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';
import 'rental_template_form_screen.dart';
import 'widgets.dart';

/// Settings shared by every contract of a rental book (when rent is
/// collected, notice period) and its rental templates.
/// Pops with `true` when the settings were saved.
class BookSettingsScreen extends StatefulWidget {
  const BookSettingsScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookSettingsScreen> createState() => _BookSettingsScreenState();
}

class _BookSettingsScreenState extends State<BookSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BookRepository _books = BookRepository();
  final RentalTemplateRepository _templates = RentalTemplateRepository();
  late final TextEditingController _noticeDays;
  late RentTiming _rentTiming;
  late Future<List<RentalTemplate>> _templatesFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noticeDays = TextEditingController(text: '${widget.book.noticeDays}');
    _rentTiming = widget.book.rentTiming;
    _templatesFuture = _templates.listTemplates(widget.book.id);
  }

  @override
  void dispose() {
    _noticeDays.dispose();
    super.dispose();
  }

  Future<void> _openTemplate([RentalTemplate? template]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            RentalTemplateFormScreen(book: widget.book, template: template),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _templatesFuture = _templates.listTemplates(widget.book.id);
      });
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _saving = true);
    try {
      await _books.saveRentalSettings(
        widget.book.id,
        rentTiming: _rentTiming,
        noticeDays: int.parse(_noticeDays.text.trim()),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

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
              ChoiceTile(
                title: l10n.rentPostpaid,
                description: l10n.rentPostpaidDesc,
                selected: _rentTiming == RentTiming.postpaid,
                onTap: () => setState(() => _rentTiming = RentTiming.postpaid),
              ),
              ChoiceTile(
                title: l10n.rentPrepaid,
                description: l10n.rentPrepaidDesc,
                selected: _rentTiming == RentTiming.prepaid,
                onTap: () => setState(() => _rentTiming = RentTiming.prepaid),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noticeDays,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.noticeDaysLabel),
                validator: (value) {
                  final number = int.tryParse(value?.trim() ?? '');
                  if (number == null || number < 0) {
                    return l10n.mustBeWholeNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
              const SizedBox(height: 32),
              SectionTitle(l10n.templatesTitle),
              const SizedBox(height: 4),
              Text(
                l10n.templatesHint,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<RentalTemplate>>(
                future: _templatesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(error: snapshot.error);
                  }
                  final templates = snapshot.data ?? const <RentalTemplate>[];
                  if (templates.isEmpty) {
                    return BorderedList(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noTemplates,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    );
                  }
                  return BorderedList(
                    children: [
                      for (final template in templates)
                        ListRow(
                          title: templateName(l10n, template),
                          subtitle: templateSummary(
                            l10n,
                            template,
                            widget.book.currency,
                          ),
                          trailing: template.isDefault
                              ? StatusBadge(
                                  label: l10n.templateDefaultBadge,
                                  color: scheme.onSurface,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () => _openTemplate(template),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _openTemplate(),
                icon: const Icon(Icons.add),
                label: Text(l10n.addTemplate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
