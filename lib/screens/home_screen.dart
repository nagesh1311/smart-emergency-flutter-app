import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'patient_lookup_screen.dart';
import 'patient_entry_screen.dart';
import 'drug_interaction_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<_NavItem> _navItems(String role) {
    final common = [
      _NavItem('Dashboard', Icons.dashboard_outlined, const DashboardScreen()),
    ];

    if (role == 'user') {
      return [
        ...common,
        _NavItem('My Record', Icons.folder_open_outlined, const PatientLookupScreen(mode: 'view_self')),
        _NavItem('Access History', Icons.history_outlined, const HistoryScreen(type: 'access')),
        _NavItem('Edit History', Icons.edit_note_outlined, const HistoryScreen(type: 'edit')),
      ];
    } else {
      return [
        ...common,
        _NavItem('View Patient', Icons.search_outlined, const PatientLookupScreen(mode: 'view')),
        _NavItem('Enter Patient', Icons.person_add_outlined, const PatientEntryScreen()),
        _NavItem('Edit Patient', Icons.edit_outlined, const PatientLookupScreen(mode: 'edit')),
        _NavItem('Drug Interactions', Icons.medication_outlined, const DrugInteractionScreen()),
        _NavItem('Access History', Icons.history_outlined, const HistoryScreen(type: 'access')),
        _NavItem('Edit History', Icons.edit_note_outlined, const HistoryScreen(type: 'edit')),
        _NavItem('Entry History', Icons.assignment_outlined, const HistoryScreen(type: 'entry')),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final items = _navItems(auth.role ?? 'user');
    if (_selectedIndex >= items.length) _selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          items[_selectedIndex].label.toUpperCase(),
          style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, auth, items),
      body: IndexedStack(
        index: _selectedIndex,
        children: items.map((i) => i.screen).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService auth, List<_NavItem> items) {
    final roleLabel = {
      'user': 'Patient',
      'doctor': 'Doctor',
      'maintainer': 'Maintainer',
    }[auth.role ?? 'user']!;

    return Drawer(
      backgroundColor: const Color(0xFF0D1525),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E3050))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3349),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_hospital, color: Color(0xFF4FC3F7), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.email ?? '',
                          style: const TextStyle(
                              color: Color(0xFFE0E8F0), fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2A1A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            roleLabel.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF66BB6A), fontSize: 10, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final isSelected = i == _selectedIndex;
                  return ListTile(
                    leading: Icon(
                      items[i].icon,
                      color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFF607D9A),
                      size: 20,
                    ),
                    title: Text(
                      items[i].label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFFE0E8F0),
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF0D3349),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5350),
                    side: const BorderSide(color: Color(0xFF3D1010)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Widget screen;
  const _NavItem(this.label, this.icon, this.screen);
}
