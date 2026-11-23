import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'widgets.dart';

/// Adds a person, or edits / deletes one. Pops with `true` when changed.
class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key, this.contact});

  final Contact? contact;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ContactRepository _contacts = ContactRepository();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _idNumber;
  late final TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _name = TextEditingController(text: contact?.name ?? '');
    _phone = TextEditingController(text: contact?.phone ?? '');
    _idNumber = TextEditingController(text: contact?.idNumber ?? '');
    _note = TextEditingController(text: contact?.note ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _idNumber.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _saving = true);
    try {
      final contact = widget.contact;
      if (contact == null) {
        await _contacts.createContact(
          name: _name.text.trim(),
          phone: _optional(_phone),
          idNumber: _optional(_idNumber),
          note: _optional(_note),
        );
      } else {
        await _contacts.updateContact(
          contact.id,
          name: _name.text.trim(),
          phone: _optional(_phone),
          idNumber: _optional(_idNumber),
          note: _optional(_note),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final contact = widget.contact;
    if (contact == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (await _contacts.hasActiveContract(contact.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cannotDeleteRenting)));
      return;
    }
    if (!mounted) return;
    final confirmed = await confirmDelete(
      context,
      title: l10n.deletePersonTitle,
      message: l10n.deletePersonBody,
    );
    if (!confirmed) return;
    await _contacts.deleteContact(contact.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(isEditing ? l10n.editPerson : l10n.addPerson),
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
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idNumber,
                decoration: InputDecoration(labelText: l10n.idNumber),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.note),
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
