import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'books_screen.dart';
import 'overview_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// The app frame: black top bar, then underline tabs on wide windows or a
/// bottom bar on phones.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _Destination {
  const _Destination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _select(int index) {
    if (index != _index) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final wide =
        MediaQuery.sizeOf(context).width >= AppTheme.wideBreakpoint;
    final destinations = [
      _Destination(l10n.navOverview, Icons.space_dashboard_outlined),
      _Destination(l10n.navBooks, Icons.menu_book_outlined),
    ];

    // A fresh page widget on every switch, so each tab shows current data.
    final Widget page = switch (_index) {
      0 => const OverviewScreen(),
      _ => const BooksScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Wordmark(showTagline: wide),
      ),
      body: wide
          ? Column(
              children: [
                _TabRow(
                  destinations: destinations,
                  selected: _index,
                  onSelect: _select,
                ),
                Expanded(child: page),
              ],
            )
          : page,
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _select,
                destinations: [
                  for (final destination in destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                ],
              ),
            ),
    );
  }
}

/// Tabs under the top bar with a thick underline on the selected one.
class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.destinations,
    required this.selected,
    required this.onSelect,
  });

  final List<_Destination> destinations;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      child: PageBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: InkWell(
                    onTap: () => onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: i == selected
                                ? scheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        destinations[i].label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: i == selected
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
