import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';
import 'patient_edit_screen.dart';

class PatientLookupScreen extends StatefulWidget {
  final String mode; // 'view', 'edit', 'view_self'
  const PatientLookupScreen({super.key, required this.mode});

  @override
  State<PatientLookupScreen> createState() => _PatientLookupScreenState();
}

class _PatientLookupScreenState extends State<PatientLookupScreen> {
  final _emailCtrl = TextEditingController();
  Map<String, dynamic>? _patientData;
  bool _loading = false;
  String _lookupMethod = 'email';

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'view_self') _loadSelf();
  }

  Future<void> _loadSelf() async {
    final email = context.read<AuthService>().email!;
    setState(() => _loading = true);
    try {
      final result = await ApiService().getPatient(email);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() => _patientData = result['data']);
      } else {
        AppWidgets.showSnack(context, result['message'] ?? 'No record found', isError: true);
      }
    } catch (e) {
      AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _lookup() async {
    setState(() => _loading = true);
    try {
      Map<String, dynamic> result;
      if (_lookupMethod == 'email') {
        if (_emailCtrl.text.isEmpty) {
          AppWidgets.showSnack(context, 'Enter patient email', isError: true);
          setState(() => _loading = false);
          return;
        }
        result = await ApiService().getPatient(_emailCtrl.text.trim());
      } else if (_lookupMethod == 'face') {
        result = await ApiService().findByFace();
      } else {
        result = await ApiService().findByFingerprint();
      }
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() => _patientData = result['data']);
        if (widget.mode == 'edit') _goEdit();
      } else {
        AppWidgets.showSnack(context, result['message'] ?? 'Not found', isError: true);
      }
    } catch (e) {
      if (mounted) AppWidgets.showSnack(context, 'Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _goEdit() {
    if (_patientData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientEditScreen(
          patientEmail: _patientData!['email'],
          data: Map<String, dynamic>.from(_patientData!),
        ),
      ),
    );
  }

  Future<void> _logAccess(String patientEmail) async {
    final auth = context.read<AuthService>();
    await ApiService().accessHistory(auth.email!, auth.role!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'view_self') {
      return _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : _patientData == null
              ? const Center(
                  child: Text('No record found.',
                      style: TextStyle(color: Color(0xFF607D9A))))
              : _PatientCard(data: _patientData!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lookup method
          AppWidgets.sectionLabel('LOOKUP METHOD'),
          const SizedBox(height: 10),
          _MethodSelector(
            selected: _lookupMethod,
            onChanged: (m) => setState(() {
              _lookupMethod = m;
              _patientData = null;
            }),
          ),
          const SizedBox(height: 20),

          // Email input
          if (_lookupMethod == 'email') ...[
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFFE0E8F0)),
              decoration: const InputDecoration(
                labelText: 'Patient Email',
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF607D9A), size: 20),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1525),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3050)),
              ),
              child: Row(
                children: [
                  Icon(
                    _lookupMethod == 'face' ? Icons.face_outlined : Icons.fingerprint,
                    color: const Color(0xFF4FC3F7),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _lookupMethod == 'face'
                          ? 'Camera will open on the server to capture face'
                          : 'Place finger on the scanner when prompted',
                      style: const TextStyle(color: Color(0xFF607D9A), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _lookup,
              icon: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4FC3F7)))
                  : Icon(widget.mode == 'edit' ? Icons.edit_outlined : Icons.search_outlined, size: 18),
              label: Text(_loading
                  ? 'Searching...'
                  : widget.mode == 'edit'
                      ? 'FIND & EDIT'
                      : 'SEARCH PATIENT'),
            ),
          ),

          // Patient data
          if (_patientData != null && widget.mode != 'edit') ...[
            const SizedBox(height: 24),
            _PatientCard(data: _patientData!),
          ],
        ],
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _MethodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const methods = [
      ('email', 'Email', Icons.email_outlined),
      ('face', 'Face', Icons.face_outlined),
      ('fingerprint', 'Fingerprint', Icons.fingerprint),
    ];
    return Row(
      children: methods.map((m) {
        final sel = selected == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(m.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF0D3349) : const Color(0xFF0D1525),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: sel ? const Color(0xFF4FC3F7) : const Color(0xFF1E3050)),
              ),
              child: Column(
                children: [
                  Icon(m.$3,
                      size: 18,
                      color: sel ? const Color(0xFF4FC3F7) : const Color(0xFF607D9A)),
                  const SizedBox(height: 4),
                  Text(m.$2,
                      style: TextStyle(
                          fontSize: 11,
                          color: sel
                              ? const Color(0xFF4FC3F7)
                              : const Color(0xFF607D9A))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PatientCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('name', 'Full Name'), ('phone', 'Phone'), ('blood_group', 'Blood Group'),
      ('emergency_contact', 'Emergency Contact'), ('asthma', 'Asthma'),
      ('diabetes', 'Diabetes'), ('heart_issues', 'Heart Issues'),
      ('hypertension', 'Hypertension'), ('thyroid', 'Thyroid'), ('hiv', 'HIV'),
      ('recent_heart_attack', 'Recent Heart Attack'), ('past_surgery', 'Past Surgery'),
      ('ongoing_medications', 'Ongoing Medications'),
      ('mental_medications', 'Mental Medications'),
      ('inheritance_diseases', 'Inheritance Diseases'),
      ('genetic_disorders', 'Genetic Disorders'), ('smoke_alcohol', 'Smoke/Alcohol'),
      ('allergies', 'Allergies'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppWidgets.sectionLabel('PATIENT RECORD'),
        const SizedBox(height: 10),
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
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1E3050))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Color(0xFF4FC3F7), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['email'] ?? '',
                        style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              // Fields
              ...fields.map((f) {
                final val = data[f.$1]?.toString() ?? '—';
                return _DataRow(label: f.$2, value: val);
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF111D2E))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(color: Color(0xFF607D9A), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Color(0xFFE0E8F0), fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
