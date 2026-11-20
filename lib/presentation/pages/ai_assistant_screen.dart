import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_event.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_state.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/ai_film_result_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/soft_gradient_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/tap_scale.dart';
import 'package:skeletonizer/skeletonizer.dart';

const List<String> _startQueries = <String>[
  'Добрая комедия на вечер',
  'Аниме про путешествия',
  'Фильмы про ограбления банков',
  'Триллер с неожиданной развязкой',
  'Мультик для всей семьи',
  'Лёгкое кино после работы',
];

const String _emptyHint = 'Запрос на поиск фильмов...';
const String _feedHint = 'Запрос на поиск фильмов...';

@RoutePage()
class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AiAssistantBloc>()),
        BlocProvider(create: (_) => getIt<WatchSavedFilmsStatusCubit>()),
      ],
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView();

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView> {
  static const int _maxQueryLength = 200;

  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  final ScrollController _feedScrollController = ScrollController();

  bool _canSubmit = false;
  bool _onlyNew = false;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
    context.read<AiAssistantBloc>().add(const AiAssistantHistoryRequested());
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _queryFocusNode.dispose();
    _feedScrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final bool canSubmit = _queryController.text.trim().isNotEmpty;

    if (canSubmit == _canSubmit) {
      return;
    }

    setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    final String query = _queryController.text.trim();

    if (query.isEmpty) {
      return;
    }

    context.read<AiAssistantBloc>().add(
          AiAssistantRequested(query, onlyNew: _onlyNew),
        );
    _queryController.clear();
    _queryFocusNode.unfocus();
  }

  void _toggleOnlyNew() {
    setState(() => _onlyNew = !_onlyNew);
  }

  void _fillQuery(String query) {
    _queryController.text = query;
    _queryController.selection = TextSelection.collapsed(offset: query.length);
    _queryFocusNode.requestFocus();
  }

  void _retry(int searchId) {
    context.read<AiAssistantBloc>().add(AiAssistantRetryRequested(searchId));
  }

  void _expand(int searchId) {
    context.read<AiAssistantBloc>().add(AiAssistantSearchExpanded(searchId));
  }

  void _deleteSession(int sessionId) {
    context.read<AiAssistantBloc>().add(
          AiAssistantSessionDeleteRequested(sessionId),
        );
  }

  Future<void> _confirmDeleteSession(int sessionId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ConfirmAlertDialog(
        titleText: 'Удалить сессию?',
        content: Text(
          'Запрос и рекомендации исчезнут из истории.',
          style: CustomTextStyles.m3Body(color: AppColors.textGrey),
        ),
        actionText: 'Удалить',
        actionFunc: () => _deleteSession(sessionId),
      ),
    );
  }

  Future<void> _confirmClearSessions() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ConfirmAlertDialog(
        titleText: 'Очистить все сессии?',
        content: Text(
          'Все сохранённые запросы и рекомендации будут удалены.',
          style: CustomTextStyles.m3Body(color: AppColors.textGrey),
        ),
        actionText: 'Очистить',
        actionFunc: () => context
            .read<AiAssistantBloc>()
            .add(const AiAssistantSessionsClearRequested()),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_feedScrollController.hasClients) {
        return;
      }

      _feedScrollController.animateTo(
        _feedScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _shouldScrollToBottom(
    AiAssistantState previous,
    AiAssistantState current,
  ) {
    if (current is! AiAssistantFeed) {
      return false;
    }

    if (previous is! AiAssistantFeed) {
      return true;
    }

    if (previous.expanded is AiFilmSearchFailure &&
        current.expanded is AiFilmSearchLoading) {
      return false;
    }

    return previous.searches.length != current.searches.length ||
        previous.expandedSearchId != current.expandedSearchId ||
        previous.expanded?.runtimeType != current.expanded?.runtimeType;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiAssistantBloc, AiAssistantState>(
      listenWhen: _shouldScrollToBottom,
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryThemeBlack,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'AI Ассистент',
              style: CustomTextStyles.m3ActionText(color: AppColors.textGrey),
            ),
            actions: [
              if (state is AiAssistantFeed && state.searches.isNotEmpty)
                IconButton(
                  onPressed: _confirmClearSessions,
                  tooltip: 'Очистить все сессии',
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: switch (state) {
                    AiAssistantInitial() => _EmptyState(
                        onQueryTap: _fillQuery,
                      ),
                    AiAssistantHistoryLoading() => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryScheme,
                        ),
                      ),
                    AiAssistantFeed(
                      :final searches,
                      :final expandedSearchId,
                    ) =>
                      _Feed(
                        searches: searches,
                        expandedSearchId: expandedSearchId,
                        scrollController: _feedScrollController,
                        onExpand: _expand,
                        onRetry: _retry,
                        onDelete: _confirmDeleteSession,
                      ),
                  },
                ),
                _Composer(
                  controller: _queryController,
                  focusNode: _queryFocusNode,
                  canSubmit: _canSubmit,
                  onlyNew: _onlyNew,
                  hint: state is AiAssistantInitial ? _emptyHint : _feedHint,
                  maxLength: _maxQueryLength,
                  onSubmit: _submit,
                  onToggleOnlyNew: _toggleOnlyNew,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onQueryTap;

  const _EmptyState({required this.onQueryTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        Text(
          'Что хочется посмотреть?',
          style: CustomTextStyles.m3Title(color: AppColors.textGrey),
        ),
        const SizedBox(height: 8),
        Text(
          'Опишите настроение, жанр или фильм-ориентир.',
          style: CustomTextStyles.m3Body(color: AppColors.textGrey),
        ),
        const SizedBox(height: 20),
        Text(
          'С чего начать',
          style: CustomTextStyles.m3FilmTitle(color: AppColors.textDarkGrey),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final query in _startQueries)
              _StartQueryPill(text: query, onTap: () => onQueryTap(query)),
          ],
        ),
      ],
    );
  }
}

class _StartQueryPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _StartQueryPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: SoftGradientCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style:
                CustomTextStyles.m3ActionText(color: AppColors.cardAccentText),
          ),
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  final List<AiFilmSearchState> searches;
  final int? expandedSearchId;
  final ScrollController scrollController;
  final ValueChanged<int> onExpand;
  final ValueChanged<int> onRetry;
  final ValueChanged<int> onDelete;

  const _Feed({
    required this.searches,
    required this.expandedSearchId,
    required this.scrollController,
    required this.onExpand,
    required this.onRetry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: searches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final AiFilmSearchState search = searches[index];

        if (search.id == expandedSearchId) {
          return _ExpandedSearch(
            search: search,
            onRetry: () => onRetry(search.id),
            onDelete: () => onDelete(search.id),
          );
        }

        return _SearchPill(
          search: search,
          onTap: () => onExpand(search.id),
          onDelete: () => onDelete(search.id),
        );
      },
    );
  }
}

class _SearchPill extends StatelessWidget {
  final AiFilmSearchState search;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SearchPill({
    required this.search,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String trailing =
        '${DataFormatter.formatRelativeDay(search.createdAt)} · '
        '${_searchCountLabel(search)}';

    return TapScale(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.only(left: 16, right: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryThemeGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                search.query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.m3ActionText(
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              trailing,
              style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey),
            ),
            _SessionMenu(onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _SessionMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const _SessionMenu({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: AppColors.primaryThemeGrey,
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: AppColors.textDarkGrey,
      ),
      enableFeedback: false,
      onSelected: (value) {
        if (value == "delete") onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Удалить сессию', style: CustomTextStyles.m3Body()),
        )
      ],
    );
  }
}

class _ExpandedSearch extends StatelessWidget {
  final AiFilmSearchState search;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  const _ExpandedSearch({
    required this.search,
    required this.onRetry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DataFormatter.formatRelativeDayTime(search.createdAt),
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.m3FilmTitle(
                        color: AppColors.textDarkGrey,
                      ),
                    ),
                    if (search.onlyNew) ...[
                      const SizedBox(width: 8),
                      const _OnlyNewBadge(),
                    ],
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _SessionMenu(onDelete: onDelete),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _UserBubble(text: search.query),
        const SizedBox(height: 12),
        _SearchAnswer(search: search, onRetry: onRetry),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryScheme,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: CustomTextStyles.m3ActionText(color: AppColors.textWhite),
          ),
        ),
      ),
    );
  }
}

class _SearchAnswer extends StatelessWidget {
  final AiFilmSearchState search;
  final VoidCallback onRetry;

  const _SearchAnswer({required this.search, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return switch (search) {
      AiFilmSearchLoading() => const _LoadingAnswer(),
      AiFilmSearchLoaded(:final films) => _LoadedAnswer(films: films),
      AiFilmSearchEmpty() => const _PlainAnswer(
          text:
              'По вашему запросу не удалось подобрать подходящие фильмы. Попробуйте изменить запрос.',
        ),
      AiFilmSearchFailure(:final message) => _SearchFailureWidget(
          message: message,
          onRetry: onRetry,
        ),
    };
  }
}

class _SearchFailureWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SearchFailureWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Image.asset(
            width: 350,
            "assets/icons/errorIcon.png",
            fit: BoxFit.cover,
          ),
          Text(
            "Что-то пошло не так",
            style: CustomTextStyles.m3Title(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: CustomTextStyles.m3Body(),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.primaryScheme,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onRetry,
                  child: Center(
                    child: Text(
                      "Повторить",
                      style: CustomTextStyles.m3Content(
                        color: Colors.white,
                      ).copyWith(
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingAnswer extends StatelessWidget {
  const _LoadingAnswer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryScheme,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Подбираю фильмы под ваш запрос...',
                style: CustomTextStyles.m3Body(color: AppColors.textGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _SkeletonResults(),
      ],
    );
  }
}

class _LoadedAnswer extends StatelessWidget {
  final List<AiFilmRecommendation> films;

  const _LoadedAnswer({required this.films});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Нашёл ${DataFormatter.formatFilmWordDeclension(films.length)}.',
          style: CustomTextStyles.m3Body(color: AppColors.textGrey),
        ),
        for (final recommendation in films) ...[
          const SizedBox(height: 12),
          AiFilmResultCard(recommendation: recommendation),
        ],
      ],
    );
  }
}

class _PlainAnswer extends StatelessWidget {
  final String text;

  const _PlainAnswer({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: CustomTextStyles.m3Body(color: AppColors.textGrey),
    );
  }
}

class _SkeletonResults extends StatelessWidget {
  const _SkeletonResults();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      key: const Key('aiSkeletonResults'),
      effect: const ShimmerEffect(
        baseColor: AppColors.primaryThemeBlack,
        highlightColor: AppColors.primaryThemeGrey,
        duration: Duration(seconds: 4),
      ),
      child: const Column(
        children: [
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone(width: 100, height: 140),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 160, height: 16),
                SizedBox(height: 8),
                Bone(width: 110, height: 12),
                SizedBox(height: 14),
                Bone(width: 70, height: 12),
                SizedBox(height: 6),
                Bone(width: double.infinity, height: 12),
                SizedBox(height: 6),
                Bone(width: double.infinity, height: 12),
                SizedBox(height: 6),
                Bone(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSubmit;
  final bool onlyNew;
  final String hint;
  final int maxLength;
  final VoidCallback onSubmit;
  final VoidCallback onToggleOnlyNew;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.canSubmit,
    required this.onlyNew,
    required this.hint,
    required this.maxLength,
    required this.onSubmit,
    required this.onToggleOnlyNew,
  });

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  static const Duration _animDuration = Duration(milliseconds: 220);

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    final bool hasFocus = widget.focusNode.hasFocus;

    if (hasFocus == _hasFocus) {
      return;
    }

    setState(() => _hasFocus = hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeOut,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.primaryThemeGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasFocus
              ? AppColors.primaryScheme
              : Colors.white.withValues(alpha: 0.12),
          width: _hasFocus ? 1.4 : 1,
        ),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryScheme.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldTapRegion(
            child: _OnlyNewToggle(
              enabled: widget.onlyNew,
              onTap: widget.onToggleOnlyNew,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: widget.maxLength,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.go,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: AppColors.primaryScheme,
                  onTapOutside: (event) => widget.focusNode.unfocus(),
                  onSubmitted: (_) => widget.onSubmit(),
                  style: CustomTextStyles.m3Content(
                    color: AppColors.textWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: CustomTextStyles.m3Content(
                      color: AppColors.textDarkGrey,
                    ).copyWith(fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterStyle: CustomTextStyles.m3Body(
                      color: AppColors.textDarkGrey,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextFieldTapRegion(
                child: _SendButton(
                  enabled: widget.canSubmit,
                  onPressed: widget.onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnlyNewToggle extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _OnlyNewToggle({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        enabled ? AppColors.textWhite : AppColors.textDarkGrey;

    return Semantics(
      toggled: enabled,
      button: true,
      label: 'Не рекомендовать сохранённые фильмы',
      child: Tooltip(
        message: 'Не рекомендовать фильмы, которые уже есть в библиотеке',
        child: TapScale(
          key: const Key('aiOnlyNewToggle'),
          animateOnTap: false,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primaryScheme
                  : AppColors.primaryThemeGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: enabled
                    ? AppColors.primaryScheme
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  enabled
                      ? Icons.check_circle_outline
                      : Icons.filter_alt_outlined,
                  size: 14,
                  color: foreground,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Не рекомендовать сохранённые фильмы',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.m3FilmTitle(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnlyNewBadge extends StatelessWidget {
  const _OnlyNewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('aiOnlyNewBadge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryScheme.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 11,
            color: AppColors.cardAccentText,
          ),
          const SizedBox(width: 4),
          Text(
            'Без сохранённых фильмов',
            style: CustomTextStyles.m3FilmTitle(
              color: AppColors.cardAccentText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _SendButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primaryScheme
          : Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_upward,
            size: 20,
            color: enabled ? AppColors.textWhite : AppColors.textDarkGrey,
          ),
        ),
      ),
    );
  }
}

String _searchCountLabel(AiFilmSearchState search) {
  return switch (search) {
    AiFilmSearchLoading() => 'загружается',
    AiFilmSearchLoaded(:final filmCount) =>
      DataFormatter.formatFilmWordDeclension(filmCount),
    AiFilmSearchEmpty() => '0 фильмов',
    AiFilmSearchFailure() => 'ошибка',
  };
}
