import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
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
        backgroundColor: AppColors.primaryThemeBlack,
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
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Center(
            child: Text(
              "Movie Search Assistant", 
              style: CustomTextStyles.m3HeadlineLarge(color: AppColors.primaryScheme))
            ),
          SizedBox(height: 20.h),
          Center(
            child: Text.rich(
              TextSpan(
                style: CustomTextStyles.m3BodyLarge(),
                children: [
                  TextSpan(text: "Для использования возможностей приложения Вам потребуется зарегистрироваться на сайте "),
                  TextSpan(
                    text: "kinopoiskapiunofficial.tech",
                    style: CustomTextStyles.m3BodyLarge(color: AppColors.primaryScheme),
                    recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchApiKeyUrl(context);
                      },
                    ),
                  TextSpan(text: " и получить API Key"),
                  ],
                ),
                textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _textEditingController,
            maxLength: 40,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Введите API Key',
              border: OutlineInputBorder(),
            ),
            style: CustomTextStyles.m3TitleMedium(),
            autofocus: true,
            onChanged: (_) => setState(() {})),
          SizedBox(height: 10.h),
          ElevatedButton(
            style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40.h)),
                alignment: AlignmentGeometry.center,
                backgroundColor: _textEditingController.text.isEmpty 
                ? WidgetStatePropertyAll(AppColors.primaryThemeGrey)
                : WidgetStatePropertyAll(AppColors.primaryScheme)),
            onPressed: _textEditingController.text.isEmpty 
            ? null 
            : () {
              _tryAuthenticationEvent(context, _textEditingController.text);
            },
            child: Text(
              "Войти", 
              style: CustomTextStyles.m3BodyLarge(
                color: _textEditingController.text.isEmpty ? AppColors.textDarkGrey : AppColors.textWhite
              )),
          ),
        ],
      ),
    );
  }

  void _launchApiKeyUrl(BuildContext context){
    context.read<AuthenticationBloc>().add(LaunchApiKeyUrl());
  }

  void _tryAuthenticationEvent(BuildContext context, String apiKey) {
    context.read<AuthenticationBloc>().add(TryAuthenticationEvent(apiKey: apiKey));
  }

}
