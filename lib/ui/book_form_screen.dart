import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../utils/money.dart';
import 'category_seeds.dart';
import 'labels.dart';
import 'widgets.dart';

/// Creates a new book, or edits the name and note of an existing one.
/// Pops with `true` when something was saved.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BookRepository _books = BookRepository();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late BookTemplate _template;
  late String _currency;
  bool _saving = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _name = TextEditingController(text: book?.name ?? '');
    _note = TextEditingController(text: book?.note ?? '');
    _template = book?.template ?? BookTemplate.rental;
    _currency = book?.currency ?? defaultCurrency;
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final noteText = _note.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    setState(() => _saving = true);
    try {
      final book = widget.book;
      if (book == null) {
        await _books.createBook(
          name: name,
          template: _template,
          currency: _currency,
          note: note,
          categories: categorySeedsFor(_template, l10n),
        );
      } else {
        await _books.updateBook(book.id, name: name, note: note);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final templates = _isEditing ? [_template] : BookTemplate.values;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editBook : l10n.createBook)),
      body: Form(
        key: _formKey,
        child: PageBody(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              TextFormField(
                controller: _name,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.bookName,
                  hintText: l10n.bookNameHint,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.fieldRequired
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.bookTemplate,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final template in templates)
                _TemplateTile(
                  template: template,
                  selected: template == _template,
                  onTap: _isEditing
                      ? null
                      : () => setState(() => _template = template),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: InputDecoration(
                  labelText: l10n.currency,
                ),
                items: [
                  for (final code in supportedCurrencies)
                    DropdownMenuItem<String>(
                      value: code,
                      child: Text('$code (${currencySymbol(code)})'),
                    ),
                ],
                onChanged: _isEditing
                    ? null
                    : (value) {
                        if (value != null) setState(() => _currency = value);
                      },
              ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.templateLocked,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.note,
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
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final BookTemplate template;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                Icon(templateIcon(template)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        templateLabel(l10n, template),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        templateDescription(l10n, template),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.check, color: scheme.onSurface),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
