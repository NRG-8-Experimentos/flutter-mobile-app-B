import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synhub_flutter/l10n/app_localizations.dart';
import 'package:synhub_flutter/requests/bloc/request_bloc.dart';
import 'package:synhub_flutter/requests/services/request_service.dart';
import 'package:synhub_flutter/shared/bloc/auth/auth_bloc.dart';
import 'package:synhub_flutter/shared/bloc/locale/locale_bloc.dart';
import 'package:synhub_flutter/shared/bloc/member/member_bloc.dart';
import 'package:synhub_flutter/shared/bloc/theme/theme_cubit.dart';
import 'package:synhub_flutter/shared/services/auth_service.dart';
import 'package:synhub_flutter/shared/services/member_service.dart';
import 'package:synhub_flutter/shared/views/Login.dart';
import 'package:synhub_flutter/tasks/bloc/task/task_bloc.dart';
import 'package:synhub_flutter/tasks/services/task_service.dart';
import 'package:synhub_flutter/shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthBloc(authService: AuthService(), memberService: MemberService())),
        BlocProvider(create: (_) => MemberBloc(memberService: MemberService())),
        BlocProvider(create: (_) => TaskBloc(taskService: TaskService())),
        BlocProvider(create: (_) => RequestBloc(requestService: RequestService())),
      ],
      child: BlocBuilder<LocaleBloc, Locale>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                locale: localeState,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                title: 'SynHub',
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                home: const Login(),
              );
            },
          );
        },
      ),
    );
  }
}
