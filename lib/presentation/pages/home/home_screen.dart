import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
          SearchFilmWrapperRoute(),
          CollectionsRoute(),
          UserProfileRoute()
        ],
      builder: (context, child) { 
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
              enableFeedback: false,
              type: BottomNavigationBarType.shifting,
              backgroundColor: AppColors.primaryThemeBlack,
              selectedItemColor: AppColors.primaryScheme,
              unselectedItemColor: AppColors.primaryThemeGrey,
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              selectedLabelStyle: CustomTextStyles.m3ActionText().copyWith(height: 1.2),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Поиск",
                  backgroundColor: AppColors.primaryThemeBlack
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books_outlined),
                  label: "Коллекции",
                  backgroundColor: AppColors.primaryThemeBlack
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: "Профиль",
                  backgroundColor: AppColors.primaryThemeBlack
                ),
              ],
            ),
        );
      },
    );
  }
}
