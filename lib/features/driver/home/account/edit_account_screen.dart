import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import 'provider/account_provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});
  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name, _email, _phone;

  @override
  void initState() {
    super.initState();
    final u = context.read<AccountProvider>().account;
    _name = TextEditingController(text: u?.name ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final token = context.read<AuthProvider>().token;
    final prov = context.read<AccountProvider>();
    if (token == null) return;
    final ok = await prov.updateAccount(
      token: token,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updated!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prov = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: Text(t.editProfile),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _f(
                _name,
                t.fullName,
                Icons.person_outline,
                (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _f(
                _email,
                t.email,
                Icons.mail_outline,
                (v) => v!.contains('@') ? null : 'Invalid email',
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _f(
                _phone,
                t.phone,
                Icons.phone_outlined,
                (v) => v!.length < 8 ? 'Invalid' : null,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: prov.isSaving ? null : _save,
                  child: prov.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          t.saveChanges ?? 'Save',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  Widget _f(
    TextEditingController c,
    String label,
    IconData icon,
    String? Function(String?) v, {
    TextInputType type = TextInputType.text,
  }) => TextFormField(
    controller: c,
    validator: v,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    ),
  );
}
