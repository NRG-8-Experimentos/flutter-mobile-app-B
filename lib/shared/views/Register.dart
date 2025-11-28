import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../group/views/SearchGroup.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../models/sign_up_request.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController urlPfpController = TextEditingController();
  final TextEditingController pass1Controller = TextEditingController();
  final TextEditingController pass2Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    userController.dispose();
    mailController.dispose();
    urlPfpController.dispose();
    pass1Controller.dispose();
    pass2Controller.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidUrl(String url) {
    final urlRegex = RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');
    return urlRegex.hasMatch(url);
  }

  void _registerAndLogin(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (pass1Controller.text != pass2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.passwordMismatch), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }
    if (!_isValidEmail(mailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.invalidEmail), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }
    if (urlPfpController.text.isNotEmpty && !_isValidUrl(urlPfpController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.invalidUrl), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }

    setState(() => _isLoading = true);
    final request = SignUpRequest(
      username: userController.text,
      name: nameController.text,
      surname: surnameController.text,
      imgUrl: urlPfpController.text,
      email: mailController.text,
      password: pass1Controller.text,
    );
    context.read<AuthBloc>().add(SignUpEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            context.read<AuthBloc>().add(SignInEvent(username: userController.text, password: pass1Controller.text));
          } else if (state is SignInSuccess) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchGroup()));
          } else if (state is AuthFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: cs.error));
          }
        },
        child: Scaffold(
          backgroundColor: t.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    localizations.register,
                    style: TextStyle(
                      fontSize: 60,
                      color: cs.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: _textField(localizations.name, localizations.name, Icons.abc, nameController, cs)),
                      const SizedBox(width: 20),
                      Expanded(child: _textField(localizations.surname, localizations.surname, Icons.abc, surnameController, cs)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _textField(localizations.user, localizations.user, Icons.person, userController, cs),
                  const SizedBox(height: 20),
                  _textField(localizations.mail, localizations.mail, Icons.mail, mailController, cs),
                  const SizedBox(height: 20),
                  _textField(localizations.urlPfp, localizations.urlPfp, Icons.link, urlPfpController, cs),
                  const SizedBox(height: 20),
                  _textField(localizations.password, localizations.password, Icons.lock, pass1Controller, cs, obscure: true),
                  const SizedBox(height: 20),
                  _textField(localizations.confirmPassword, localizations.confirmPassword, Icons.lock, pass2Controller, cs, obscure: true),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : () => _registerAndLogin(context),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(localizations.register, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, String hint, IconData icon, TextEditingController controller, ColorScheme cs, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: cs.surfaceVariant,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
