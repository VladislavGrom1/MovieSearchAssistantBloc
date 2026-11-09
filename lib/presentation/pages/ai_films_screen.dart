import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_films/ai_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/ai_film_result_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

const List<String> _exampleQueries = [
  'Фильм про ограбление казино',
  'Добрая комедия на вечер',
  'Аниме про путешествия',
  'Триллер с неожиданной развязкой',
];

@RoutePage()
class AiFilmsScreen extends StatelessWidget {
  const AiFilmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AiFilmsBloc>()),
        BlocProvider(create: (_) => getIt<WatchSavedFilmsStatusCubit>()),
      ],
      child: const _AiFilmsView(),
    );
  }
}

class _AiFilmsView extends StatefulWidget {
  const _AiFilmsView();

  @override
  State<_AiFilmsView> createState() => _AiFilmsViewState();
}

class _AiFilmsViewState extends State<_AiFilmsView> {
  static const int _maxQueryLength = 200;

  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {});
  }

  String get _query => _queryController.text.trim();

  bool get _canSubmit => _query.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;

    _queryFocusNode.unfocus();
    context.read<AiFilmsBloc>().add(AiFilmsRequested(_query));
  }

  void _retry() {
    context.read<AiFilmsBloc>().add(const AiFilmsRetryRequested());
  }

  void _fillQuery(String query) {
    _queryController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _queryFocusNode.requestFocus();
  }

  /// Возвращает экран к исходному виду: чистое поле и чипы-примеры.
  /// Сброс идёт через BLoC, чтобы ответ ещё летящего запроса не вернул
  /// старые результаты.
  void _reset() {
    _queryController.clear();
    _queryFocusNode.unfocus();
    context.read<AiFilmsBloc>().add(const AiFilmsResetRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      body: SafeArea(
        child: BlocBuilder<AiFilmsBloc, AiFilmsState>(
          builder: (context, state) {
            final isLoading = state is AiFilmsLoading;
            final isBusy = isLoading || state.isRetrying;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  onReset: state is AiFilmsInitial && _query.isEmpty
                      ? null
                      : _reset,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _QueryField(
                    controller: _queryController,
                    focusNode: _queryFocusNode,
                    maxLength: _maxQueryLength,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SubmitButton(
                    isLoading: isLoading,
                    onPressed: _canSubmit && !isBusy ? _submit : null,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _Results(
                    state: state,
                    onRetry: _retry,
                    onExampleTap: _fillQuery,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  /// null — сбрасывать нечего, кнопка не показывается.
  final VoidCallback? onReset;

  const _Header({this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'AI-подбор',
                  style: CustomTextStyles.m3Headline(color: AppColors.textWhite),
                ),
              ),
              if (onReset != null) _ResetButton(onPressed: onReset!),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Опишите настроение, сюжет или жанр — подберём пять фильмов.',
            style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey)
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ResetButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.restart_alt, size: 18),
      label: const Text('Сбросить'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryScheme,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: CustomTextStyles.m3ActionText(),
      ),
    );
  }
}

class _QueryField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;

  const _QueryField({
    required this.controller,
    required this.focusNode,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final hasFocus = focusNode.hasFocus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.primaryThemeGrey.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFocus
                  ? AppColors.primaryScheme
                  : Colors.white.withValues(alpha: 0.12),
              width: hasFocus ? 1.4 : 1,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primaryScheme.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 2,
            maxLines: 4,
            maxLength: maxLength,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            cursorColor: AppColors.primaryScheme,
            style: CustomTextStyles.m3Content(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: 'Например: «что-нибудь как Интерстеллар, но полегче»',
              hintStyle: CustomTextStyles.m3Content(color: AppColors.textDarkGrey)
                  .copyWith(fontWeight: FontWeight.w400),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              counterStyle: CustomTextStyles.m3Body(color: AppColors.textDarkGrey)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryScheme,
          disabledBackgroundColor: AppColors.primaryThemeGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite,
                ),
              )
            : Text(
                'Подобрать',
                style: CustomTextStyles.m3ActionText(color: AppColors.textWhite),
              ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final AiFilmsState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onExampleTap;

  const _Results({
    required this.state,
    required this.onRetry,
    required this.onExampleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state is AiFilmsLoading) {
      return const _SkeletonResults();
    }

    if (state is AiFilmsLoaded) {
      final recommendations = (state as AiFilmsLoaded).recommendations;

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => AiFilmResultCard(
          recommendation: recommendations[index],
        ),
      );
    }

    if (state is AiFilmsFailure) {
      final failure = state as AiFilmsFailure;

      return _MessageArea(
        icon: Icons.error_outline,
        title: 'Не получилось подобрать',
        message: failure.message,
        actionText: 'Повторить',
        onAction: onRetry,
        isRetrying: failure.isRetrying,
      );
    }

    if (state is AiFilmsEmpty) {
      final empty = state as AiFilmsEmpty;

      return _MessageArea(
        icon: Icons.search_off,
        title: 'Ничего не нашлось',
        message:
            'Попробуйте описать иначе: другими словами, шире или через похожий фильм.',
        actionText: 'Повторить',
        onAction: onRetry,
        isRetrying: empty.isRetrying,
      );
    }

    return _ExampleQueries(onExampleTap: onExampleTap);
  }
}

class _MessageArea extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;
  final bool isRetrying;

  const _MessageArea({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Icon(icon, color: AppColors.primaryScheme, size: 44),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: CustomTextStyles.m3Title(color: AppColors.textWhite)
                .copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey)
                .copyWith(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          if (isRetrying)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryScheme,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryScheme,
              ),
              child: Text(
                actionText,
                style:
                    CustomTextStyles.m3ActionText(color: AppColors.primaryScheme),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExampleQueries extends StatelessWidget {
  final ValueChanged<String> onExampleTap;

  const _ExampleQueries({required this.onExampleTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'С чего начать',
            style: CustomTextStyles.m3Title(color: AppColors.textWhite)
                .copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in _exampleQueries)
                ActionChip(
                  onPressed: () => onExampleTap(query),
                  label: Text(
                    query,
                    style: CustomTextStyles.m3Body(color: AppColors.textWhite)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                  backgroundColor: AppColors.primaryThemeGrey.withValues(alpha: 0.55),
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonResults extends StatelessWidget {
  const _SkeletonResults();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: AppColors.primaryThemeBlack,
        highlightColor: AppColors.primaryThemeGrey,
        duration: Duration(seconds: 4),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryThemeGrey,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 120, height: 14, color: Colors.white),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 10, color: Colors.white),
          const SizedBox(height: 6),
          Container(width: double.infinity, height: 10, color: Colors.white),
        ],
      ),
    );
  }
}
