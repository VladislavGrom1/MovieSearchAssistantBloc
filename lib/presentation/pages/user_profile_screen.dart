import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/text_field_alert_dialog.dart';

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
            CustomSnackBar(message: state.message).show(context);
          }
          if (state is UserProfileActionFailure) {
            CustomSnackBar(message: state.message).show(context);
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
                      const SizedBox(height: 16),
                      Text("Пожалуйста, подождите завершения операции", 
                        style: CustomTextStyles.m3Body(color: AppColors.primaryScheme), 
                        textAlign: TextAlign.center),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
                      Text("Пожалуйста, подождите завершения операции", 
                        style: CustomTextStyles.m3Body(color: AppColors.primaryScheme), 
                        textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      CircularProgressIndicator(value: state.progress, color: AppColors.primaryScheme,),
                      const SizedBox(height: 16),
                      Text("${state.current} / ${state.total}", style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                      const SizedBox(height: 10),
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

  bool get _hasOwnApiKey => (userEntity?.apiKey ?? "").isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final items = [
      "Импорт библиотеки",
      "Экспорт библиотеки",
      "Поделиться библиотекой",
      "Очистить кэш",
      "Очистить библиотеку",
    ];

    final icons = [
      Icons.file_download,
      Icons.file_upload,
      Icons.share,
      Icons.cleaning_services,
      Icons.delete_sweep,
    ];

    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 20),
        Text("Текущий план", style: CustomTextStyles.m3Title()),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.primaryThemeGrey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanSegmentedControl(
                  isIndividual: _hasOwnApiKey,
                  onSelectStandard: () {
                    if (!_hasOwnApiKey) return;
                    _showConfirmActionDialog(
                      context,
                      "Вернуться на стандартный план?",
                      "Приложение перестанет использовать ваш личный API Key и вернётся "
                          "к стандартному плану. В часы пиковой нагрузки запросы к серверу могут "
                          "выполняться немного дольше. Индивидуальный план можно "
                          "подключить снова в любой момент.",
                      "Вернуться",
                      () => _useSharedApiKey(context),
                    );
                  },
                  onSelectIndividual: () {
                    if (_hasOwnApiKey) return;
                    _showChangeApiKeyDialog(context);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _hasOwnApiKey
                      ? "Используется ваш личный API Key и индивидуальный лимит запросов в сутки."
                      : "Стандартный план для всех пользователей приложения. Неограниченный лимит запросов в сутки. В часы пиковой нагрузки возможны задержки получения данных от сервера.",
                  style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
                ),
                if (_hasOwnApiKey) ...[
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: userEntity?.apiKey ?? ""));
                      CustomSnackBar(
                        message: "API Key скопирован в буфер обмена",
                      ).show(context);
                    },
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Ваш API Key", style: CustomTextStyles.m3Body(color: AppColors.ratingGrey))
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryThemeBlack,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userEntity!.apiKey!,
                                  overflow: TextOverflow.ellipsis,
                                  style: CustomTextStyles.m3Content(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.copy, color: AppColors.primaryScheme, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => _showChangeApiKeyDialog(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Изменить API Key",
                        style: CustomTextStyles.m3Body(color: AppColors.primaryScheme),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          textAlign: TextAlign.left,
          TextSpan(
            style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
            children: [
              TextSpan(text: "Бесплатный API Key для индивидуального плана можно получить после регистрации на "),
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
        const SizedBox(height: 20),
        Text("Память", style: CustomTextStyles.m3Title()),
        const SizedBox(height: 10),
        Card(
          color: AppColors.primaryThemeGrey,
          child: Container(
            height: 44,
            padding: EdgeInsets.only(left: 20),
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
        const SizedBox(height: 20),
        Text("Настройки", style: CustomTextStyles.m3Title()),
        const SizedBox(height: 20),
        ...List.generate(
          items.length, (index) {
          final VoidCallback onTap = _buildSettingsAction(context, items[index]);
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
                  onTap: onTap,
                ),
              ),
              Divider(color: AppColors.primaryThemeGrey),
            ],
          );
        }),
        const SizedBox(height: 20),
        BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if(state is UserProfileLoaded){
              return Center(
                child: Text(
                  "${state.appInfo?["appName"]} для Android v${state.appInfo?["appVersion"]}",
                  maxLines: 2,
                  style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
                  textAlign: TextAlign.center,
                  ),
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
 
  VoidCallback _buildSettingsAction(BuildContext context, String label) {
    switch (label) {
      case "Импорт библиотеки":
        return () => _importLibrary(context);
      case "Экспорт библиотеки":
        return () => _exportLibrary(context);
      case "Поделиться библиотекой":
        return () => _shareLibrary(context);
      case "Очистить кэш":
        return () => _clearCacheDirectory(context);
      case "Очистить библиотеку":
        return () => _showConfirmActionDialog(
              context,
              "Очищение библиотеки",
              "Вы уверены, что хотите очистить библиотеку? В случае очищения все коллекции и сохранённые фильмы будут удалены.",
              "Очистить",
              () => _clearLibrary(context),
            );
      default:
        return () {};
    }
  }

  void _showChangeApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<UserProfileBloc>(),
          child: TextFieldAlertDialog(
            titleText: _hasOwnApiKey ? 'Изменение API Key' : 'Индивидуальный план',
            descriptionText: _hasOwnApiKey
                ? null
                : "При индивидуальном плане приложение использует Ваш личный API Key со своим лимитом использования. "
                  "Получение данных от сервера происходит без задержек. "
                  "Бесплатный API Key можно получить после регистрации на kinopoiskapiunofficial.tech.",
            hintText: 'Введите ваш API Key',
            maxLenght: 40,
            maxLines: 1,
            actionText: "Подключить",
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

  void _useSharedApiKey(BuildContext context) {
    context.read<UserProfileBloc>().add(UseSharedApiKey());
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

class _PlanSegmentedControl extends StatelessWidget {
  final bool isIndividual;
  final VoidCallback onSelectStandard;
  final VoidCallback onSelectIndividual;

  const _PlanSegmentedControl({
    required this.isIndividual,
    required this.onSelectStandard,
    required this.onSelectIndividual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeBlack,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlanSegment(
              label: "Стандартный",
              selected: !isIndividual,
              onTap: onSelectStandard,
            ),
          ),
          Expanded(
            child: _PlanSegment(
              label: "Индивидуальный",
              selected: isIndividual,
              onTap: onSelectIndividual,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PlanSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryScheme : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: CustomTextStyles.m3ActionText(
            color: selected ? AppColors.primaryThemeBlack : AppColors.ratingGrey,
          ).copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }
}