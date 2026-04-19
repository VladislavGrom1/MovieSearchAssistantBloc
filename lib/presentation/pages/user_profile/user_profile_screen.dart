import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_refresh_indicator.dart';

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
    final userProfileBloc = context.read<UserProfileBloc>();

    return Scaffold(
        backgroundColor: AppColors.primaryThemeBlack,
        body: BlocListener<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is UserProfileActionSuccess) {
              Fluttertoast.showToast(
                  backgroundColor: Colors.green, msg: state.message);
            }
            if (state is UserProfileActionFailure) {
              Fluttertoast.showToast(
                  backgroundColor: Colors.red, msg: state.message);
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Expanded(
                    child: CustomRefreshIndicator(
                      onRefresh: () async {
                        userProfileBloc.add(UpdateUserProfileInfo());
                      },
                      child: BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          if (state is UserProfileLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (state is ExportInProgress){
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Экспорт библиотеки", style: CustomTextStyles.m3HeadlineMedium()),
                                  SizedBox(height: 16.h),
                                  Text("Пожалуйста, подождите завершения операции", 
                                      style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme), 
                                      textAlign: TextAlign.center),
                                  SizedBox(height: 20.h),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            );
                          }

                          if (state is ImportInProgress){
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Импорт библиотеки", style: CustomTextStyles.m3HeadlineMedium()),
                                  SizedBox(height: 16.h),
                                  Text("Пожалуйста, подождите завершения операции", 
                                    style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme), 
                                    textAlign: TextAlign.center),
                                  SizedBox(height: 20.h),
                                  CircularProgressIndicator(value: state.progress, color: AppColors.primaryScheme,),
                                  SizedBox(height: 16.h),
                                  Text("${state.current} / ${state.total}", style: CustomTextStyles.m3BodyLarge(color: AppColors.primaryScheme)),
                                  SizedBox(height: 10.h),
                                  
                                ],
                              ),
                            );
                          }

                          if (state is UserProfileLoaded) {
                            return _UserProfileContent(
                                userEntity: state.userEntity,
                                cacheSizeMB: state.cacheSizeMB);
                          }

                          return SizedBox();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _UserProfileContent extends StatelessWidget {
  final UserEntity? userEntity;
  final double? cacheSizeMB;

  const _UserProfileContent(
      {required this.userEntity, required this.cacheSizeMB});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text("API Key", style: CustomTextStyles.m3TitleLarge()),
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.primaryThemeGrey,
                child: SizedBox(
                    height: 44.h,
                    child: Center(
                        child: Text(userEntity?.apiKey ?? "API Key отсутствует", style: CustomTextStyles.m3TitleMedium()))),
              ),
              SizedBox(height: 10.h),
              Text.rich(
                TextSpan(
                  style: CustomTextStyles.m3BodyMedium(color: AppColors.ratingGrey),
                  children: [
                    TextSpan(text: "Для получения дополнительной информации об API Key перейдите на "),
                    TextSpan(
                      text: "kinopoiskapiunofficial.tech",
                      style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme),
                      recognizer: TapGestureRecognizer()
                      ..onTap = () {
                          _launchApiKeyUrl(context);
                          },
                        ),
                        TextSpan(text: "."),
                      ],
                    ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Text("Память", style: CustomTextStyles.m3TitleLarge()),
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.primaryThemeGrey,
                child: Container(
                  height: 44.h,
                  padding: EdgeInsets.only(left: 20.w),
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text.rich(
                            TextSpan(
                              style: CustomTextStyles.m3BodyLarge(),
                              children: [
                                TextSpan(text: "Размер кэша: "),
                                TextSpan(text: "${cacheSizeMB?.toStringAsFixed(1)} МБ", style: CustomTextStyles.m3BodyLarge(color: AppColors.primaryScheme)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                          ),
                ),
              ),
            ] 
          ),
          SizedBox(height: 20.h),
          Text("Настройки", style: CustomTextStyles.m3TitleLarge()),
          SizedBox(height: 10.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primaryThemeGrey,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final items = [
                "Изменить API Key",
                "Импорт библиотеки",
                "Импорт старой библиотеки",
                "Экспорт библиотеки",
                "Очистить кэш",
                "Очистить библиотеку",
              ];
              final icons = [
                Icons.key,
                Icons.file_download,
                Icons.file_download,
                Icons.file_upload,
                Icons.cleaning_services,
                Icons.delete_sweep,
              ];

              return ListTile(
                  leading: Icon(icons[index], color: AppColors.primaryScheme),
                  title: Text(items[index], style: CustomTextStyles.m3BodyLarge()),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryScheme),
                  onTap: () {
                    switch (index) {
                      case 0:
                        _showChangeApiKeyDialog(context);
                        break;
                      case 1:
                        _importLibrary(context);
                        break;
                      case 2:
                        _importOldLibrary(context);
                        break;
                      case 3:
                        _exportLibrary(context);
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
                          () => _clearLibrary(context)
                        );
                        break;
                    }
                  });
            },
          ),
        ],
      ),
    );
  }

  void _showChangeApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<UserProfileBloc>(),
          child: _UpdateApiKeyDialog(),
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

  void _importOldLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ImportOldLibrary());
  }

  void _exportLibrary(BuildContext context) {
    context.read<UserProfileBloc>().add(ExportLibrary());
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

class _UpdateApiKeyDialog extends StatefulWidget {
  const _UpdateApiKeyDialog();

  @override
  State<_UpdateApiKeyDialog> createState() => _UpdateApiKeyDialogState();
}

class _UpdateApiKeyDialogState extends State<_UpdateApiKeyDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileBloc = context.read<UserProfileBloc>();

    return AlertDialog(
      backgroundColor: AppColors.primaryThemeBlack,
      title: Text('Изменение API Key', style: CustomTextStyles.m3TitleLarge()),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
            controller: controller,
            maxLength: 40,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Введите новый API Key',
              border: OutlineInputBorder(),
            ),
            style: CustomTextStyles.m3TitleMedium(),
            autofocus: true,
            onChanged: (_) => setState(() {})),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: CustomTextStyles.m3BodyMedium()),
        ),
        TextButton(
            onPressed: controller.text.isEmpty
            ? null
            : () {
              userProfileBloc.add(UpdateApiKey(updatedApiKey: controller.text));
              Navigator.pop(context);
            },
            child: Text(
              "Сохранить",
              style: controller.text.isEmpty
                ? CustomTextStyles.m3BodyMedium(color: AppColors.primaryThemeGrey)
                : CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme)
              )
            ),
      ],
    );
  }
}


