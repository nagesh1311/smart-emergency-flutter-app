import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';

class PatientEntryScreen extends StatefulWidget {
  const PatientEntryScreen({super.key});

  @override
  State<PatientEntryScreen> createState() => _PatientEntryScreenState();
}

class _PatientEntryScreenState extends State<PatientEntryScreen> {
  bool _loading = false;
  bool _fpCaptured1 = false;
  bool _fpCaptured2 = false;
  String? _fp1B64;
  String? _fp2B64;

  final Map<String, TextEditingController> _controllers = {};

  final List<(String, String)> _fields = [
    ('email', 'Patient Email *'),
    ('name', 'Full Name *'),
    ('phone', 'Phone *'),
    ('blood_group', 'Blood Group *'),
    ('emergency_contact', 'Emergency Contact *'),
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
    for (final f in _fields) {
      _controllers[f.$1] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _captureFingerprint(int idx) async {
    setState(() => _loading = true);
    try {
      final result = await ApiService().captureFingerprint();
      if (!mounted) return;
      if (result['success'] == true) {
        final b64 = result['template'];
        setState(() {
          if (idx == 1) {
            _fp1B64 = b64;
            _fpCaptured1 = true;
          } else {
            _fp2B64 = b64;
            _fpCaptured2 = true;
          }
        });
        AppWidgets.showSnack(context, 'Fingerprint $idx captured!');
      } else {
        AppWidgets.showSnack(context, result['message'] ?? 'Capture failed', isError: true);
      }
    } catch (e) {
      if (mounted) AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    // Required fields
    final required = ['email', 'name', 'phone', 'blood_group', 'emergency_contact'];
    for (final k in required) {
      if (_controllers[k]!.text.trim().isEmpty) {
        AppWidgets.showSnack(context, '${k.replaceAll('_', ' ')} is required', isError: true);
        return;
      }
    }
    if (!_fpCaptured1 || !_fpCaptured2) {
      AppWidgets.showSnack(context, 'Please capture both fingerprints', isError: true);
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthService>();

    final data = {
      for (final f in _fields) f.$1: _controllers[f.$1]!.text.trim(),
      'fingerprint1': _fp1B64,
      'fingerprint2': _fp2B64,
    };

    try {
      final result = await ApiService().enterPatient(data);
      if (!mounted) return;
      if (result['success'] == true) {
        AppWidgets.showSnack(context, 'Patient record saved successfully!');
        for (final c in _controllers.values) {
          c.clear();
        }
        setState(() {
          _fpCaptured1 = false;
          _fpCaptured2 = false;
          _fp1B64 = null;
          _fp2B64 = null;
        });
      } else {
        AppWidgets.showSnack(context, result['message'] ?? 'Failed', isError: true);
      }
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
          AppWidgets.sectionLabel('PATIENT INFORMATION'),
          const SizedBox(height: 16),

          // Fields
          ..._fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextField(
                  controller: _controllers[f.$1],
                  keyboardType: f.$1 == 'email'
                      ? TextInputType.emailAddress
                      : f.$1 == 'phone'
                          ? TextInputType.phone
                          : TextInputType.text,
                  style: const TextStyle(color: Color(0xFFE0E8F0)),
                  decoration: InputDecoration(labelText: f.$2),
                ),
              )),

          const SizedBox(height: 8),
          AppWidgets.sectionLabel('BIOMETRICS'),
          const SizedBox(height: 14),

          // Fingerprint 1
          _FingerprintCapture(
            label: 'Fingerprint 1',
            captured: _fpCaptured1,
            loading: _loading,
            onCapture: () => _captureFingerprint(1),
          ),
          const SizedBox(height: 12),

          // Fingerprint 2
          _FingerprintCapture(
            label: 'Fingerprint 2',
            captured: _fpCaptured2,
            loading: _loading,
            onCapture: () => _captureFingerprint(2),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4FC3F7)))
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_loading ? 'Saving...' : 'SAVE PATIENT RECORD'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FingerprintCapture extends StatelessWidget {
  final String label;
  final bool captured;
  final bool loading;
  final VoidCallback onCapture;

  const _FingerprintCapture({
    required this.label,
    required this.captured,
    required this.loading,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: captured ? const Color(0xFF66BB6A) : const Color(0xFF1E3050),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint,
            size: 32,
            color: captured ? const Color(0xFF66BB6A) : const Color(0xFF607D9A),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Color(0xFFE0E8F0), fontWeight: FontWeight.w500)),
                Text(
                  captured ? '✓ Captured' : 'Not captured',
                  style: TextStyle(
                      color: captured ? const Color(0xFF66BB6A) : const Color(0xFF607D9A),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: loading ? null : onCapture,
            style: ElevatedButton.styleFrom(
              backgroundColor: captured ? const Color(0xFF0D2A1A) : null,
              side: BorderSide(
                  color: captured ? const Color(0xFF66BB6A) : const Color(0xFF1E5070)),
            ),
            child: Text(captured ? 'Recapture' : 'Capture',
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
