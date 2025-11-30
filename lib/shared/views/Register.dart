import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../group/views/SearchGroup.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../models/sign_up_request.dart';
import 'Login.dart';
import 'home.dart';

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

  // Validación de email usando expresión regular simple
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validación de URL simple (http/https)
  bool _isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?' // protocolo opcional
      r'([\da-z\.-]+)\.([a-z\.]{2,6})' // dominio
      r'([\/\w \.-]*)*\/?$' // ruta
    );
    return urlRegex.hasMatch(url);
  }

  void _registerAndLogin(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (pass1Controller.text != pass2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.passwordMismatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación de correo electrónico
    if (!_isValidEmail(mailController.text)) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.invalidEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación de URL de foto de perfil (si no está vacío)
    if (urlPfpController.text.isNotEmpty && !_isValidUrl(urlPfpController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.invalidUrl),
          backgroundColor: Colors.red,
        ),
      );
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
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            context.read<AuthBloc>().add(
              SignInEvent(
                username: userController.text,
                password: pass1Controller.text,
              ),
            );
          } else if (state is SignInSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
              const SearchGroup()),
            );
          } else if (state is AuthFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    localizations.register,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: localizations.name,
                            hintText: localizations.name,
                            prefixIcon: const Icon(Icons.abc, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: surnameController,
                          decoration: InputDecoration(
                            labelText: localizations.surname,
                            hintText: localizations.surname,
                            prefixIcon: const Icon(Icons.abc, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      labelText: localizations.user,
                      hintText: localizations.user,
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: mailController,
                    decoration: InputDecoration(
                      labelText: localizations.mail,
                      hintText: localizations.mail,
                      prefixIcon: const Icon(Icons.mail, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: urlPfpController,
                    decoration: InputDecoration(
                      labelText: localizations.urlPfp,
                      hintText: localizations.urlPfp,
                      prefixIcon: const Icon(Icons.link, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pass1Controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localizations.password,
                      hintText: localizations.password,
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pass2Controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localizations.confirmPassword,
                      hintText: localizations.confirmPassword,
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => _registerAndLogin(context),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        localizations.register,
                        style: const TextStyle(
                          fontSize: 20,
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
        ),
      ),
    );
  }
}
