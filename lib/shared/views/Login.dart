import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../group/views/SearchGroup.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/member/member_bloc.dart';
import '../services/auth_service.dart';
import '../services/member_service.dart';
import 'Register.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePostLogin() async {
    final memberService = MemberService();
    try {
      final response = await memberService.getMemberGroup();
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => MemberBloc(memberService: MemberService()),
              child: const Home(),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchGroup()));
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchGroup()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => AuthBloc(authService: AuthService(), memberService: MemberService()),
      child: Scaffold(
        backgroundColor: t.scaffoldBackgroundColor,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is SignInSuccess) _handlePostLogin();
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'SynHub',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: Image.asset('images/synhub_logo_transparent.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.login,
                    style: TextStyle(
                      fontSize: 20,
                      color: cs.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Username
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: localizations.insertUsername,
                      hintText: localizations.username,
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: cs.surfaceVariant,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localizations.insertPassword,
                      hintText: localizations.password,
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: cs.surfaceVariant,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  if (state is AuthFailure)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(state.error, style: TextStyle(color: cs.error)),
                    ),

                  const SizedBox(height: 20),

                  // Sign in
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        context.read<AuthBloc>().add(
                          SignInEvent(
                            username: _usernameController.text,
                            password: _passwordController.text,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator()
                          : Text(localizations.login, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Go to register
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<AuthBloc>(),
                              child: const Register(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.cardColor,         // se adapta claro/oscuro
                        foregroundColor: cs.onSurface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(localizations.register, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
