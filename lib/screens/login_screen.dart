import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'user';
  bool _isSignup = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      AppWidgets.showSnack(context, 'Please fill all fields', isError: true);
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final bool success = _isSignup
        ? await auth.signup(_emailCtrl.text.trim(), _passCtrl.text, _role)
        : await auth.login(_emailCtrl.text.trim(), _passCtrl.text, _role);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      if (_isSignup) {
        AppWidgets.showSnack(context, 'Signup successful! Please log in.');
        setState(() => _isSignup = false);
      }
    } else {
      AppWidgets.showSnack(context, auth.error ?? 'Failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo / Header
              const Icon(Icons.local_hospital, size: 64, color: Color(0xFF4FC3F7)),
              const SizedBox(height: 16),
              const Text(
                'EMERGENCY\nMEDICAL SYSTEM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSignup ? 'Create Account' : 'Sign In',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF607D9A), fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Role selector
              const Text('SELECT ROLE',
                  style: TextStyle(
                      color: Color(0xFF607D9A),
                      fontSize: 11,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              _RoleChips(
                selected: _role,
                onChanged: (r) => setState(() => _role = r),
              ),
              const SizedBox(height: 24),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFFE0E8F0)),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF607D9A), size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Color(0xFFE0E8F0)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF607D9A), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF607D9A),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4FC3F7)),
                        )
                      : Text(_isSignup ? 'SIGN UP' : 'SIGN IN',
                          style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Toggle signup/login
              TextButton(
                onPressed: () => setState(() => _isSignup = !_isSignup),
                child: Text(
                  _isSignup
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Sign Up",
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const roles = [
      ('user', 'Patient', Icons.person_outline),
      ('doctor', 'Doctor', Icons.medical_services_outlined),
      ('maintainer', 'Maintainer', Icons.manage_accounts_outlined),
    ];
    return Row(
      children: roles.map((r) {
        final isSelected = selected == r.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D3349) : const Color(0xFF0D1525),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFF1E3050),
                ),
              ),
              child: Column(
                children: [
                  Icon(r.$3,
                      size: 20,
                      color: isSelected
                          ? const Color(0xFF4FC3F7)
                          : const Color(0xFF607D9A)),
                  const SizedBox(height: 4),
                  Text(r.$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF607D9A),
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
