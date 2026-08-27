import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/onboarding_screen/authentication_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthenticationBloc>(),
      child: _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isLoading = state is AuthenticationLoading;
        return CarouselWidget(
          onDone: () => _start(context)
        );
      },
    );
  }

  void _start(BuildContext context) {
    context.read<AuthenticationBloc>().add(StartWithSharedApiKey());
  }
}

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({
    super.key,
    required this.onDone
  });

  final Function? onDone;

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
        titleTextStyle: CustomTextStyles.m3Headline(color: AppColors.primaryScheme).copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 30,
          letterSpacing: 0.2,
          height: 1.2
        ),
        bodyTextStyle: CustomTextStyles.m3ActionText(color: AppColors.secondaryThemeGrey).copyWith(height: 1.35),
        bodyAlignment: Alignment.center,
        imageFlex: 1
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.transparent,
      // globalHeader: Align(
      //   alignment: AlignmentGeometry.topCenter,
      //   child: Padding(
      //       padding: const EdgeInsetsGeometry.only(top: 20),
      //       child: _GradientTitle(text: "Movie Search Assistant"),
      //     )
      // ),
      pages: [
        PageViewModel(
          titleWidget: _GradientTitle(text: "Добро пожаловать в Movie Search Assistant"),
          body: "Находите фильмы по вкусу, сохраняйте их в личные коллекции и возвращайтесь к ним в любое время — всё в одном приложении.",
          image: const _OnboardingIcon(icon: Icons.movie),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: _GradientTitle(text: "Планируйте свой просмотр"),
          body: "Ищите фильмы в готовых подборках, по названию или подбирайте их через фильтры — жанр, год, рейтинг.",
          image: const _OnboardingIcon(icon: Icons.search),
          decoration: pageDecoration
        ),
        PageViewModel(
          titleWidget: _GradientTitle(text: "Создавайте свои коллекции"),
          body: "Сохраняйте понравившиеся фильмы в коллекции, делитесь своей библиотекой с друзьями или переносите её на другое устройство.",
          image: const _OnboardingIcon(icon: Icons.collections_bookmark),
          decoration: pageDecoration
        ),
        PageViewModel(
          titleWidget: _GradientTitle(text: "Планы работы приложения"),
          body: "Стандартный план работает сразу, без каких-либо настроек. Индивидуальный план — это ваш личный API Key и собственный лимит запросов, независимый от нагрузки других пользователей. Переключиться можно в любой момент в профиле.",
          image: const _OnboardingIcon(icon: Icons.bolt),
          decoration: pageDecoration
        )
      ],
      onDone: () => widget.onDone?.call(),
      onSkip: () => widget.onDone?.call(),
      showSkipButton: true,
      allowImplicitScrolling: true,
      skip: Text('Пропустить', style: CustomTextStyles.m3Content(color: AppColors.primaryScheme).copyWith(fontSize: 14)),
      back: const Icon(Icons.arrow_back),
      done: Text('Начать', style: CustomTextStyles.m3Content(color: AppColors.primaryScheme).copyWith(fontSize: 14)),
      next: const Icon(Icons.arrow_forward, size: 20),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsPadding: const EdgeInsets.only(bottom: 20),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: AppColors.primaryScheme,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
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
      height: 1.2
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

class _OnboardingIcon extends StatelessWidget {
  const _OnboardingIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryScheme.withOpacity(0.25),
            const Color(0xFFd88ef0).withOpacity(0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryScheme.withOpacity(0.35),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 80, color: AppColors.primaryScheme),
    );
  }
}
