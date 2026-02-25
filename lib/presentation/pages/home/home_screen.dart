import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
          SearchFilmWrapperRoute(),
          LibraryRoute(),
          CollectionsRoute(),
          UserProfileRoute()
        ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.white,
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Поиск",
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow),
                label: "Библиотека",
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                label: "Коллекции",
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: "Профиль",
                backgroundColor: Colors.black
              ),
            ],
          ),
        );
      },
    );
  }
}
