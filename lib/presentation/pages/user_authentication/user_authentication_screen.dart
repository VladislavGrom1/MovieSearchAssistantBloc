import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/bloc/authentication_bloc.dart';

@RoutePage()
class UserAuthenticationScreen extends StatefulWidget {
  const UserAuthenticationScreen({super.key});

  @override
  State<UserAuthenticationScreen> createState() =>
      _UserAuthenticationScreenState();
}

class _UserAuthenticationScreenState extends State<UserAuthenticationScreen> {
  final _authBloc = getIt<AuthenticationBloc>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
            bloc: _authBloc,
            listener: (context, state) {
              if (state is AuthenticationSuccess) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Успешный вход")));
                context.router.replace(HomeRoute());
              } else if (state is AuthenticationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Не удалось выполнить вход: ${state.exceptionType}, ${state.statusCode}")));
              }
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "UserAuthentication",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(controller: _textEditingController),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: () {
                      _authBloc.add(TryAuthenticationEvent(
                          apiKey: _textEditingController.text));
                    },
                    child: Text(
                      "Перейти на SearchFilmScreen",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )));
  }
}
