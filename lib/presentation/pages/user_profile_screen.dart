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
        _PlanOptionCard(
          icon: Icons.public_rounded,
          title: "Стандартный",
          priceLabel: "Бесплатно",
          selected: !_hasOwnApiKey,
          features: const [
            "Доступен сразу, без настройки",
            "Общий лимит запросов на всех пользователей",
            "Возможны задержки в часы пиковой нагрузки",
          ],
          onTap: () {
            if (!_hasOwnApiKey) return;
            _showConfirmActionDialog(
              context,
              "Вернуться на стандартный план?",
              Text.rich(
                TextSpan(
                  style: CustomTextStyles.m3Content(),
                  children: [
                    const TextSpan(text: "Приложение перестанет использовать ваш "),
                    TextSpan(text: "API Key", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: " и переключится на "),
                    TextSpan(text: "стандартный план", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: ". В часы пиковой нагрузки запросы могут обрабатываться дольше. "
                        "Вернуться к "),
                    TextSpan(text: "индивидуальному плану", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: " можно в любой момент."),
                  ],
                ),
              ),
              "Вернуться",
              () => _useSharedApiKey(context),
            );
          }
        ),
        const SizedBox(height: 12),
        _PlanOptionCard(
          icon: Icons.bolt_rounded,
          title: "Индивидуальный",
          priceLabel: "Свой API Key",
          badgeLabel: "Быстрее",
          selected: _hasOwnApiKey,
          features: const [
            "Персональный лимит запросов в сутки",
            "Ответы сервера без задержек",
            "Бесплатный API Key",
          ],
          onTap: () {
            if (_hasOwnApiKey) return;
            _showChangeApiKeyDialog(context);
          },
          footer: _hasOwnApiKey
              ? _ApiKeyCard(
                  apiKey: userEntity?.apiKey ?? "",
                  onEdit: () => _showChangeApiKeyDialog(context),
                )
              : _ApiKeyHint(onTap: () => _launchApiKeyUrl(context)),
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
        Text.rich(
          TextSpan(
            style: CustomTextStyles.m3Content(),
            children: [
              const TextSpan(text: "Вы уверены, что хотите "),
              TextSpan(text: "очистить библиотеку", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
              const TextSpan(text: "? Будут "),
              TextSpan(text: "удалены", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
              const TextSpan(text: " все коллекции и сохранённые фильмы."),
            ],
          ),
        ),
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
            description: _hasOwnApiKey
                ? null
                : Text.rich(
                    TextSpan(
                      style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
                      children: [
                        const TextSpan(text: "Собственный "),
                        TextSpan(text: "API Key", style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                        const TextSpan(text: " даёт личный лимит запросов и ответы "),
                        TextSpan(text: "без задержек", style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                        const TextSpan(text: ". Получить бесплатно "),
                        TextSpan(text: "API Key", style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                        const TextSpan(text: " можно после регистрации на "),
                        TextSpan(
                          text: "kinopoiskapiunofficial.tech",
                          style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryScheme,
                            decorationThickness: 2,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.read<UserProfileBloc>().add(LaunchApiKeyUrl()),
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
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
    Widget content,
    String actionText,
    VoidCallback actionFunc,
    ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ConfirmAlertDialog(
          titleText: titleText,
          content: content,
          actionText: actionText,
          actionFunc: actionFunc,
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

class _PlanOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String priceLabel;
  final String? badgeLabel;
  final bool selected;
  final List<String> features;
  final VoidCallback onTap;
  final Widget? footer;

  const _PlanOptionCard({
    required this.icon,
    required this.title,
    required this.priceLabel,
    this.badgeLabel,
    required this.selected,
    required this.features,
    required this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(AppColors.primaryScheme.withOpacity(0.12), AppColors.primaryThemeGrey)
            : AppColors.primaryThemeGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primaryScheme : Colors.white.withOpacity(0.06),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primaryScheme.withOpacity(0.18),
                  blurRadius: 18,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: AppColors.primaryScheme.withOpacity(0.08),
          highlightColor: AppColors.primaryScheme.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryScheme
                            : AppColors.primaryThemeBlack,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 20,
                        color: selected ? AppColors.primaryThemeBlack : AppColors.primaryScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: CustomTextStyles.m3ActionText(color: AppColors.textWhite)
                                      .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (badgeLabel != null) ...[
                                const SizedBox(width: 8),
                                _Chip(label: badgeLabel!),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            priceLabel,
                            style: CustomTextStyles.m3Body(color: AppColors.ratingGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SelectionIndicator(selected: selected),
                  ],
                ),
                const SizedBox(height: 14),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: selected ? AppColors.primaryScheme : AppColors.ratingGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: CustomTextStyles.m3Body(color: AppColors.secondaryThemeGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (footer != null && selected) ...[
                  const SizedBox(height: 4),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primaryScheme : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primaryScheme : AppColors.ratingGrey,
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Icon(Icons.check_rounded, size: 14, color: AppColors.primaryThemeBlack)
          : null,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryScheme.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: CustomTextStyles.m3FilmTitle(color: AppColors.primaryScheme).copyWith(fontSize: 11),
      ),
    );
  }
}

class _ApiKeyCard extends StatefulWidget {
  final String apiKey;
  final VoidCallback onEdit;

  const _ApiKeyCard({required this.apiKey, required this.onEdit});

  @override
  State<_ApiKeyCard> createState() => _ApiKeyCardState();
}

class _ApiKeyCardState extends State<_ApiKeyCard> {
  bool _revealed = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _maskedKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _maskedKey {
    final key = widget.apiKey;
    if (key.length <= 8) return "•" * key.length;
    return "${key.substring(0, 4)}${"•" * 8}${key.substring(key.length - 4)}";
  }

  void _toggleReveal() {
    setState(() {
      _revealed = !_revealed;
      _controller.text = _revealed ? widget.apiKey : _maskedKey;
    });
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.apiKey));
    CustomSnackBar(message: "API Key скопирован в буфер обмена").show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryScheme.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_rounded, size: 15, color: AppColors.primaryScheme),
              const SizedBox(width: 6),
              Text("Ваш API Key", style: CustomTextStyles.m3Body(color: AppColors.ratingGrey)),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    "Изменить",
                    style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 22,
                  child: TextField(
                    controller: _controller,
                    readOnly: true,
                    showCursor: false,
                    maxLines: 1,
                    scrollPhysics: const BouncingScrollPhysics(),
                    style: CustomTextStyles.m3Content(color: AppColors.textWhite).copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: _revealed ? 0.5 : 2,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleReveal,
                icon: Icon(
                  _revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18,
                  color: AppColors.ratingGrey,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                splashRadius: 18,
              ),
              IconButton(
                onPressed: () => _copy(context),
                icon: Icon(Icons.copy_rounded, size: 17, color: AppColors.primaryScheme),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                splashRadius: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApiKeyHint extends StatelessWidget {
  final VoidCallback onTap;

  const _ApiKeyHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.ratingGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: CustomTextStyles.m3Body(color: AppColors.ratingGrey).copyWith(fontSize: 13),
                children: [
                  const TextSpan(text: "Бесплатный API Key можно получить после регистрации на "),
                  TextSpan(
                    text: "kinopoiskapiunofficial.tech",
                    style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryScheme,
                      decorationThickness: 2,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTap,
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}