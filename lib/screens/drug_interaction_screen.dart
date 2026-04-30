import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';

class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  final _ctrl = TextEditingController();
  List<String> _interactions = [];
  bool _loading = false;
  bool _searched = false;
  String _lastDrug = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_ctrl.text.trim().isEmpty) {
      AppWidgets.showSnack(context, 'Enter a drug name', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _searched = false;
    });
    try {
      final result = await ApiService().drugInteractions(_ctrl.text.trim());
      if (!mounted) return;
      setState(() {
        _interactions = List<String>.from(result['interactions'] ?? result['data'] ?? []);
        _lastDrug = _ctrl.text.trim();
        _searched = true;
      });
    } catch (e) {
      if (mounted) AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A2E),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFF4FC3F7), width: 3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF81D4FA), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter a drug name to check known interactions from the database.',
                    style: TextStyle(color: Color(0xFF81D4FA), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppWidgets.sectionLabel('DRUG NAME'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Color(0xFFE0E8F0)),
                  textCapitalization: TextCapitalization.none,
                  decoration: const InputDecoration(
                    labelText: 'e.g. aspirin, warfarin...',
                    prefixIcon: Icon(Icons.medication_outlined,
                        color: Color(0xFF607D9A), size: 20),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _search,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF4FC3F7)))
                      : const Icon(Icons.search, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_searched) ...[
            AppWidgets.sectionLabel('INTERACTIONS FOR "${_lastDrug.toUpperCase()}"'),
            const SizedBox(height: 10),
            if (_interactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2A0A),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                      left: BorderSide(color: Color(0xFF66BB6A), width: 3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFFA5D6A7), size: 20),
                    SizedBox(width: 10),
                    Text('No interactions found in database.',
                        style: TextStyle(color: Color(0xFFA5D6A7))),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1525),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E3050)),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A1A2E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_outlined,
                              color: Color(0xFFFFA726), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_interactions.length} Interaction${_interactions.length != 1 ? 's' : ''} Found',
                            style: const TextStyle(
                                color: Color(0xFFFFA726),
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Interaction rows
                    ..._interactions.asMap().entries.map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: e.key < _interactions.length - 1
                                ? const Border(
                                    bottom: BorderSide(color: Color(0xFF1E3050)))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A1A0A),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                        color: Color(0xFFFFCC80), fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                e.value.toLowerCase(),
                                style: const TextStyle(
                                    color: Color(0xFFE0E8F0), fontSize: 14),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
