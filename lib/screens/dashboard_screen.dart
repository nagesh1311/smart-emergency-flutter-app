import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final role = auth.role ?? 'user';
    final roleLabel = {'user': 'Patient', 'doctor': 'Doctor', 'maintainer': 'Maintainer'}[role]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1525),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E3050)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_hospital, color: Color(0xFF4FC3F7), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'EMERGENCY MEDICAL',
                      style: TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Welcome back,',
                    style: TextStyle(color: Color(0xFF607D9A), fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? '',
                  style: const TextStyle(color: Color(0xFFE0E8F0), fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A1A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleLabel.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF66BB6A), fontSize: 11, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('QUICK ACCESS'),
          const SizedBox(height: 12),
          _quickAccessGrid(role, context),
          const SizedBox(height: 24),
          const _SectionLabel('SYSTEM INFO'),
          const SizedBox(height: 12),
          _InfoTile('Authentication', 'Face + Fingerprint biometrics', Icons.fingerprint),
          _InfoTile('Encryption', 'AES-256-GCM encrypted records', Icons.lock_outline),
          _InfoTile('Database', 'PostgreSQL with access logging', Icons.storage_outlined),
        ],
      ),
    );
  }

  Widget _quickAccessGrid(String role, BuildContext context) {
    final List<_QuickTile> tiles = role == 'user'
        ? [
            _QuickTile('My Record', Icons.folder_open_outlined, const Color(0xFF4FC3F7)),
            _QuickTile('Access History', Icons.history_outlined, const Color(0xFF66BB6A)),
            _QuickTile('Edit History', Icons.edit_note_outlined, const Color(0xFFFFA726)),
          ]
        : [
            _QuickTile('View Patient', Icons.search_outlined, const Color(0xFF4FC3F7)),
            _QuickTile('Enter Patient', Icons.person_add_outlined, const Color(0xFF66BB6A)),
            _QuickTile('Drug Interactions', Icons.medication_outlined, const Color(0xFFEF5350)),
            _QuickTile('Edit Patient', Icons.edit_outlined, const Color(0xFFFFA726)),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: tiles.map((t) => _QuickCard(tile: t)).toList(),
    );
  }

  Widget _InfoTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1525),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1E3050)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF607D9A), size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFE0E8F0), fontSize: 13)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF607D9A), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickTile(this.label, this.icon, this.color);
}

class _QuickCard extends StatelessWidget {
  final _QuickTile tile;
  const _QuickCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tile.icon, color: tile.color, size: 24),
          const SizedBox(height: 8),
          Text(tile.label,
              style: const TextStyle(color: Color(0xFFE0E8F0), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Color(0xFF607D9A), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
    );
  }
}
