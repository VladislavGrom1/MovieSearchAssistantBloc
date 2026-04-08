import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_listener.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = AppRouter();
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 927),
      child: BlocProvider(
        create: (_) => getIt<NetworkCubit>(),
        child: MaterialApp.router(
          builder: (context, child) {
            return NetworkListener(child: child!);
          },
          title: 'Flutter Demo',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.primaryThemeBlack,
              iconTheme: IconThemeData(
              color: AppColors.primaryScheme
              ),
            ),
            splashColor: AppColors.primaryScheme,
            scaffoldBackgroundColor: Colors.black,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryScheme),
          ),
          routerConfig: _router.config(),
        ),
      ),
    );
  }
}


