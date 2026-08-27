import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/onboarding_screen/authentication_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/gradient_button.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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

  static const String _backgroundAsset = 'assets/background/movie_background.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.primaryThemeBlack),

          const _FadeInBackground(assetPath: _backgroundAsset),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xCC000000),
                  Color(0xF2000000),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: _userAuthenticationBlocListener,
                child: const _UserAuthenticationContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _userAuthenticationBlocListener(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationSuccess) {
      CustomSnackBar(message: "Добро пожаловать!").show(context);
      context.router.replace(HomeRoute());
    }

    if (state is AuthenticationFailure) {
      CustomSnackBar(message: "Не удалось выполнить вход. ${state.message}").show(context);
    }
  }
}

class _FadeInBackground extends StatefulWidget {
  const _FadeInBackground({required this.assetPath});

  final String assetPath;

  @override
  State<_FadeInBackground> createState() => _FadeInBackgroundState();
}

class _FadeInBackgroundState extends State<_FadeInBackground> {
  late final ImageProvider _provider;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _provider = AssetImage(widget.assetPath);
  }

  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (MediaQuery.of(context).size.width * dpr).round();

    final resizedProvider = ResizeImage(_provider, width: targetWidth);
    final stream = resizedProvider.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (_, __) {
          if (mounted && !_loaded) {
            setState(() => _loaded = true);
          }
        },
        onError: (exception, stackTrace) {
          debugPrint('Auth background failed to load: $exception');
          if (mounted && !_failed) {
            setState(() => _failed = true);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();

    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (MediaQuery.of(context).size.width * dpr).round();

    return AnimatedOpacity(
      opacity: _loaded ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Image(
        image: ResizeImage(_provider, width: targetWidth),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Auth background errorBuilder: $error');
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserAuthenticationContent extends StatelessWidget {
  const _UserAuthenticationContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GradientTitle(text: "Movie Search Assistant"),
          const SizedBox(height: 6),
          Container(
            width: 46,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryScheme, Color(0xFFd88ef0)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            "Вы начнёте со стандартного плана — он не требует настройки. "
            "Индивидуальный план с собственным ключом Kinopoisk можно "
            "подключить позже в профиле.",
            textAlign: TextAlign.center,
            style: CustomTextStyles.m3ActionText(color: AppColors.secondaryThemeGrey).copyWith(height: 1.35),
          ),
          const SizedBox(height: 28),
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final isLoading = state is AuthenticationLoading;
              return GradientButton(
                enabled: !isLoading,
                textButton: isLoading ? "Подождите..." : "Начать",
                onPressed: isLoading ? null : () => _start(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context) {
    context.read<AuthenticationBloc>().add(StartWithSharedApiKey());
  }
}

class _GradientTitle extends StatelessWidget {
  const _GradientTitle({required this.text});

  final String text;

  static const _gradientColors = [
    AppColors.primaryScheme,
    Color(0xFFc48af6),
    Color(0xFFe6a6e0),
  ];

  @override
  Widget build(BuildContext context) {
    final style = CustomTextStyles.m3Headline().copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 30,
      letterSpacing: 0.2,
    );

    final glowStyle = style.copyWith(
      color: Colors.white,
      shadows: [
        Shadow(color: AppColors.primaryScheme.withOpacity(0.8), blurRadius: 18),
        Shadow(color: AppColors.primaryScheme.withOpacity(0.5), blurRadius: 36),
      ],
    );

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: _gradientColors,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: glowStyle,
      ),
    );
  }
}
