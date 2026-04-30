import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';

class HistoryScreen extends StatefulWidget {
  final String type; // 'access', 'edit', 'entry'
  const HistoryScreen({super.key, required this.type});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    try {
      List<dynamic> rows;
      final api = ApiService();
      if (widget.type == 'entry') {
        final res = await api.dataEntryHistory(auth.email!);
        rows = List<dynamic>.from(res['rows'] ?? []);
      } else if (widget.type == 'access') {
        final res = await api.accessHistory(auth.email!, auth.role!);
        rows = List<dynamic>.from(res['rows'] ?? []);
      } else {
        final res = await api.editHistory(auth.email!, auth.role!);
        rows = List<dynamic>.from(res['rows'] ?? []);
      }
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  String get _title {
    return {'access': 'ACCESS HISTORY', 'edit': 'EDIT HISTORY', 'entry': 'DATA ENTRY HISTORY'}[
            widget.type] ??
        'HISTORY';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isUser = auth.role == 'user';

    return _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
        : RefreshIndicator(
            onRefresh: _load,
            color: const Color(0xFF4FC3F7),
            backgroundColor: const Color(0xFF0D1525),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      AppWidgets.sectionLabel(_title),
                      const SizedBox(height: 4),
                      Text(
                        '${_rows.length} record${_rows.length != 1 ? 's' : ''}  •  pull to refresh',
                        style: const TextStyle(color: Color(0xFF607D9A), fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                if (_rows.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No history yet.',
                          style: TextStyle(color: Color(0xFF607D9A))),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final row = _rows[i];
                          return _HistoryTile(
                            row: row,
                            type: widget.type,
                            isUser: isUser,
                          );
                        },
                        childCount: _rows.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic row;
  final String type;
  final bool isUser;

  const _HistoryTile({required this.row, required this.type, required this.isUser});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subtitle = '';
    IconData icon = Icons.history;
    Color iconColor = const Color(0xFF607D9A);

    if (type == 'access') {
      icon = Icons.visibility_outlined;
      iconColor = const Color(0xFF4FC3F7);
      if (isUser) {
        title = row['access_email'] ?? '';
        subtitle = '${row['access_role'] ?? ''}  ·  ${_fmt(row['access_time'])}';
      } else {
        title = row['patient_email'] ?? '';
        subtitle = _fmt(row['access_time']);
      }
    } else if (type == 'edit') {
      icon = Icons.edit_outlined;
      iconColor = const Color(0xFFFFA726);
      if (isUser) {
        title = row['editor_email'] ?? '';
        subtitle = '${row['editor_role'] ?? ''}  ·  ${_fmt(row['edit_time'])}';
      } else {
        title = row['patient_email'] ?? '';
        subtitle = _fmt(row['edit_time']);
      }
    } else {
      icon = Icons.assignment_outlined;
      iconColor = const Color(0xFF66BB6A);
      title = row['patient_email'] ?? '';
      subtitle = _fmt(row['entry_time']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E3050)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1020),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFFE0E8F0), fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Color(0xFF607D9A), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic ts) {
    if (ts == null) return '';
    return ts.toString().replaceFirst('T', ' ').split('.').first;
  }
}
