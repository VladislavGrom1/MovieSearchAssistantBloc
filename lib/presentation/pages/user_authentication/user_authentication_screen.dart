import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/authentication_bloc.dart';

@RoutePage()
class UserAuthenticationScreen extends StatelessWidget {
  const UserAuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthenticationBloc>(),
      child: _UserAuthenticationView(),
    );
  }
}

class _UserAuthenticationView extends StatelessWidget {
  const _UserAuthenticationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: _userAuthenticationBlocListener,
                child: _UserAuthenticationContent()),
          ),
        ));
  }

  void _userAuthenticationBlocListener(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationSuccess) {
      _showToast(context, "Успешный вход", Colors.green);
      context.router.replace(HomeRoute());
    }

    if (state is AuthenticationFailure) {
      _showToast(context, "Не удалось выполнить вход: ${state.message}", Colors.red);
    }
  }

  void _showToast(BuildContext context, String message, Color color) {
    Fluttertoast.showToast(
      backgroundColor: color,
      msg: message
    );
  }
}

class _UserAuthenticationContent extends StatefulWidget {
  const _UserAuthenticationContent();

  @override
  State<_UserAuthenticationContent> createState() => _UserAuthenticationContentState();
}

class _UserAuthenticationContentState extends State<_UserAuthenticationContent> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = context.read<AuthenticationBloc>();

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "UserAuthentication",
            style: TextStyle(color: Colors.purple),
          ),
          SizedBox(height: 20.h),
          TextFormField(controller: _textEditingController),
          SizedBox(height: 20.h),
          TextButton(
            onPressed: () {
              authenticationBloc.add(TryAuthenticationEvent(apiKey: _textEditingController.text));
            },
            child: Text(
              "Перейти на SearchFilmScreen",
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
