import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';

class PatientEditScreen extends StatefulWidget {
  final String patientEmail;
  final Map<String, dynamic> data;

  const PatientEditScreen({
    super.key,
    required this.patientEmail,
    required this.data,
  });

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  bool _loading = false;
  late final Map<String, TextEditingController> _controllers;

  final List<(String, String)> _fields = [
    ('name', 'Full Name'),
    ('phone', 'Phone'),
    ('blood_group', 'Blood Group'),
    ('emergency_contact', 'Emergency Contact'),
    ('asthma', 'Asthma'),
    ('diabetes', 'Diabetes'),
    ('heart_issues', 'Heart Issues'),
    ('hypertension', 'Hypertension'),
    ('thyroid', 'Thyroid'),
    ('hiv', 'HIV'),
    ('recent_heart_attack', 'Recent Heart Attack'),
    ('past_surgery', 'Past Surgery'),
    ('ongoing_medications', 'Ongoing Medications'),
    ('mental_medications', 'Mental Medications'),
    ('inheritance_diseases', 'Inheritance Diseases'),
    ('genetic_disorders', 'Genetic Disorders'),
    ('smoke_alcohol', 'Smoke/Alcohol'),
    ('allergies', 'Allergies'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in _fields)
        f.$1: TextEditingController(text: widget.data[f.$1]?.toString() ?? '')
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final empty =
        _fields.where((f) => _controllers[f.$1]!.text.trim().isEmpty).toList();
    if (empty.isNotEmpty) {
      AppWidgets.showSnack(context,
          '${empty.first.$2} cannot be blank', isError: true);
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final newData = {
      for (final f in _fields) f.$1: _controllers[f.$1]!.text.trim()
    };

    try {
      final result = await ApiService().editPatient(widget.patientEmail, newData);
      if (!mounted) return;
      if (result['success'] == true) {
        AppWidgets.showSnack(context, 'Record updated successfully!');
        Navigator.pop(context);
      } else {
        AppWidgets.showSnack(context, result['message'] ?? 'Update failed',
            isError: true);
      }
    } catch (e) {
      if (mounted) AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT PATIENT',
            style: TextStyle(fontSize: 14, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1525),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3050)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: Color(0xFF4FC3F7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.patientEmail,
                        style: const TextStyle(
                            color: Color(0xFF4FC3F7), fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppWidgets.sectionLabel('EDIT FIELDS'),
            const SizedBox(height: 14),
            ..._fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextField(
                    controller: _controllers[f.$1],
                    style: const TextStyle(color: Color(0xFFE0E8F0)),
                    decoration: InputDecoration(labelText: f.$2),
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF4FC3F7)))
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_loading ? 'Saving...' : 'SAVE CHANGES'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
