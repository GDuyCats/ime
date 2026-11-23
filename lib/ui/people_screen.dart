import 'package:flutter/material.dart';

import '../data/contact_repository.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'contact_form_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// Everyone saved in the app, with what they currently rent.
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final ContactRepository _contacts = ContactRepository();
  late Future<List<ContactSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _contacts.listSummaries();
  }

  void _reload() {
    setState(() {
      _future = _contacts.listSummaries();
    });
  }

  Future<void> _openForm([Contact? contact]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ContactFormScreen(contact: contact)),
    );
    if (saved == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= AppTheme.wideBreakpoint;
    final side = wide ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<ContactSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return ErrorState(error: snapshot.error);
          final people = snapshot.data ?? const <ContactSummary>[];
          if (people.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.people_outline,
                title: l10n.noPeopleTitle,
                message: l10n.noPeopleBody,
              ),
            );
          }
          return PageBody(
            child: ListView(
              padding: EdgeInsets.fromLTRB(side, 24, side, 104),
              children: [
                SectionTitle(l10n.navPeople, size: wide ? 36 : 30),
                const SizedBox(height: 16),
                BorderedList(
                  children: [
                    for (final person in people)
                      ListRow(
                        leading: const Icon(Icons.person_outline),
                        title: person.contact.name,
                        subtitle: [
                          if (person.contact.phone != null)
                            person.contact.phone!,
                          if (person.rentals.isEmpty)
                            l10n.notRenting
                          else
                            person.rentals.join(', '),
                        ].join(' · '),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openForm(person.contact),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: Text(l10n.addPerson),
      ),
    );
  }
}
