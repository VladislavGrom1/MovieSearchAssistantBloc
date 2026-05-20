import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/text_field_alert_dialog.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => getIt<UserProfileBloc>()..add(GetUserProfileInfo()),
        child: _UserProfileView());
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileActionSuccess) {
            CustomSnackBar(message: state.message, color: AppColors.snackGreen).show(context);
          }
          if (state is UserProfileActionFailure) {
            CustomSnackBar(message: state.message, color: AppColors.snackRed).show(context);
          }
        },
        child: SafeArea(
          child: BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ExportInProgress) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Экспорт библиотеки", style: CustomTextStyles.m3Headline()),
                      SizedBox(height: 16.h),
                      Text("Пожалуйста, подождите завершения операции", 
                        style: CustomTextStyles.m3Body(color: AppColors.primaryScheme), 
                        textAlign: TextAlign.center),
                      SizedBox(height: 20.h),
                      CircularProgressIndicator(),
                      ],
                    ),
                  );
              }
              if (state is ImportInProgress) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Импорт библиотеки", style: CustomTextStyles.m3Headline()),
                      SizedBox(height: 16.h),
                      Text("Пожалуйста, подождите завершения операции", 
                        style: CustomTextStyles.m3Body(color: AppColors.primaryScheme), 
                        textAlign: TextAlign.center),
                      SizedBox(height: 20.h),
                      CircularProgressIndicator(value: state.progress, color: AppColors.primaryScheme,),
                      SizedBox(height: 16.h),
                      Text("${state.current} / ${state.total}", style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                      SizedBox(height: 10.h),
                    ],
                  ),
                );
              }
              if (state is UserProfileLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: _UserProfileContent(
                        userEntity: state.userEntity,
                        cacheSizeMB: state.cacheSizeMB,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  final UserEntity? userEntity;
  final double? cacheSizeMB;

  const _UserProfileContent({
    required this.userEntity,
    required this.cacheSizeMB,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      "Изменить API Key",
      "Импорт библиотеки",
      "Экспорт библиотеки",
      "Поделиться библиотекой",
      "Очистить кэш",
      "Очистить библиотеку",
    ];

    final icons = [
      Icons.key,
      Icons.file_download,
      Icons.file_upload,
      Icons.share,
      Icons.cleaning_services,
      Icons.delete_sweep,
    ];

    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            Text("API Key", style: CustomTextStyles.m3Title()),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userEntity?.apiKey ?? ""));
                CustomSnackBar(
                  message: "API Key скопирован в буфер обмена",
                  color: AppColors.ratingGreen,
                ).show(context);
              }, 
              icon: Icon(Icons.copy, color: AppColors.primaryScheme, size: 20)
            )
          ],
        ),
        SizedBox(height: 5.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          color: AppColors.primaryThemeGrey,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.w),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: userEntity?.apiKey ?? ""));
              CustomSnackBar(
                message: "API Key скопирован в буфер обмена",
                color: AppColors.ratingGreen,
              ).show(context);
            },
            child: SizedBox(
              height: 44.h,
              child: Center(
                child: Text(
                  userEntity?.apiKey ?? "API Key отсутствует",
                  style: CustomTextStyles.m3Content(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text.rich(
          TextSpan(
            style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
            children: [
              TextSpan(text: "Для получения дополнительной информации об API Key перейдите на "),
              TextSpan(
                text: "kinopoiskapiunofficial.tech",
                style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryScheme,
                  decorationThickness: 2
                ),
                recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchApiKeyUrl(context);
                  },
                  ),
                  TextSpan(text: "."),
                  ],
              ),
        ),
        SizedBox(height: 20.h),
        Text("Память", style: CustomTextStyles.m3Title()),
        SizedBox(height: 10.h),
        Card(
          color: AppColors.primaryThemeGrey,
          child: Container(
            height: 44.h,
            padding: EdgeInsets.only(left: 20.w),
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: CustomTextStyles.m3Content(),
                children: [
                  TextSpan(text: "Размер кэша: "),
                  TextSpan(text: "${cacheSizeMB?.toStringAsFixed(1)} МБ", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
          ),
        ),
        SizedBox(height: 20.h),
        Text("Настройки", style: CustomTextStyles.m3Title()),
        SizedBox(height: 20.h),
        ...List.generate(
          items.length, (index) {
          return Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(icons[index], color: AppColors.primaryScheme, size: 20),
                  title: Text(items[index], style: CustomTextStyles.m3ActionText()),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    switch (index) {
                      case 0:
                        _showChangeApiKeyDialog(context);
                        break;
                      case 1:
                        _importLibrary(context);
                        break;
                      case 2:
                        _exportLibrary(context);
                        break;
                      case 3:
                        _shareLibrary(context);
                        break;
                      case 4:
                        _clearCacheDirectory(context);
                        break;
                      case 5:
                        _showConfirmActionDialog(
                          context,
                          "Очищение библиотеки",
                          "Вы уверены, что хотите очистить библиотеку? В случае очищения все коллекции и сохранённые фильмы будут удалены.",
                          "Очистить",
                          () => _clearLibrary(context),
                        );
                        break;
                    }
                  },
                ),
              ),
              Divider(color: AppColors.primaryThemeGrey),
            ],
          );
        }),
        SizedBox(height: 20.h),
        BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if(state is UserProfileLoaded){
              return Center(
                child: Text(
                  "${state.appInfo?["appName"]} для Android ${state.appInfo?["appVersion"]} (${state.appInfo?["appBuild"]})",
                  maxLines: 2,
                  style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
                  textAlign: TextAlign.center,
                  ),
              );
            }
            return const SizedBox();
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // TODO: добавить Share библиотеки при экспорте, изменить версию 1.1.0+2, 

  void _showChangeApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<UserProfileBloc>(),
          child: TextFieldAlertDialog(
            titleText: 'Изменение API Key', 
            hintText: 'Введите новый API Key',
            maxLenght: 40,
            maxLines: 1,
            actionText: "Сохранить", 
            actionFunc: (controllerText) => context.read<UserProfileBloc>().add(UpdateApiKey(updatedApiKey: controllerText))
          ),
        );
      },
    );
  }

  void _showConfirmActionDialog(
    BuildContext context, 
    String titleText, 
    String contentText, 
    String actionText, 
    VoidCallback actionFunc
    ){
    showDialog(
      context: context, 
      builder: (dialogContext) {
        return ConfirmAlertDialog(
          titleText: titleText, 
          contentText: contentText, 
          actionText: actionText, 
          actionFunc: actionFunc
        );
      }
    );
  }

  void _importLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ImportLibrary());
  }

  // void _importOldLibrary(BuildContext context) {
  //   context.read<UserProfileBloc>().add(ImportOldLibrary());
  // }

  void _exportLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ExportLibrary());
  }

  void _shareLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ShareLibrary());
  }

  void _clearCacheDirectory(BuildContext context) {
    context.read<UserProfileBloc>().add(ClearCacheDirectory());
  }

  void _clearLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ClearLibrary());
  }

  void _launchApiKeyUrl(BuildContext context) {
    context.read<UserProfileBloc>().add(LaunchApiKeyUrl());
  }
}


