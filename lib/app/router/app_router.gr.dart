// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:collection/collection.dart' as _i18;
import 'package:flutter/material.dart' as _i17;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/search_film/search_film_wrapper_screen.dart'
    as _i7;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/user_profile/user_profile_wrapper_screen.dart'
    as _i11;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/watched_collection/watched_collection_wrapper_screen.dart'
    as _i13;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/will_watch_collection/will_watch_collection_wrapper_screen.dart'
    as _i15;
import 'package:movie_search_assistant_bloc/presentation/pages/change_api_key/change_api_key_screen.dart'
    as _i1;
import 'package:movie_search_assistant_bloc/presentation/pages/film_information/film_information_screen.dart'
    as _i2;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_film/filter_film_screen.dart'
    as _i3;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_list/filter_list_screen.dart'
    as _i4;
import 'package:movie_search_assistant_bloc/presentation/pages/home/home_screen.dart'
    as _i5;
import 'package:movie_search_assistant_bloc/presentation/pages/search_films/search_film_screen.dart'
    as _i6;
import 'package:movie_search_assistant_bloc/presentation/pages/searched_films/searched_films_screen.dart'
    as _i8;
import 'package:movie_search_assistant_bloc/presentation/pages/user_authentication/user_authentication_screen.dart'
    as _i9;
import 'package:movie_search_assistant_bloc/presentation/pages/user_profile/user_profile_screen.dart'
    as _i10;
import 'package:movie_search_assistant_bloc/presentation/pages/watched_collection/watched_collection_screen.dart'
    as _i12;
import 'package:movie_search_assistant_bloc/presentation/pages/will_watch_collection/will_watch_collection_screen.dart'
    as _i14;

/// generated route for
/// [_i1.ChangeApiKeyScreen]
class ChangeApiKeyRoute extends _i16.PageRouteInfo<void> {
  const ChangeApiKeyRoute({List<_i16.PageRouteInfo>? children})
      : super(ChangeApiKeyRoute.name, initialChildren: children);

  static const String name = 'ChangeApiKeyRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i1.ChangeApiKeyScreen();
    },
  );
}

/// generated route for
/// [_i2.FilmInformationScreen]
class FilmInformationRoute
    extends _i16.PageRouteInfo<FilmInformationRouteArgs> {
  FilmInformationRoute({
    _i17.Key? key,
    required String filmId,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          FilmInformationRoute.name,
          args: FilmInformationRouteArgs(key: key, filmId: filmId),
          rawPathParams: {'filmId': filmId},
          initialChildren: children,
        );

  static const String name = 'FilmInformationRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilmInformationRouteArgs>(
        orElse: () =>
            FilmInformationRouteArgs(filmId: pathParams.getString('filmId')),
      );
      return _i2.FilmInformationScreen(key: args.key, filmId: args.filmId);
    },
  );
}

class FilmInformationRouteArgs {
  const FilmInformationRouteArgs({this.key, required this.filmId});

  final _i17.Key? key;

  final String filmId;

  @override
  String toString() {
    return 'FilmInformationRouteArgs{key: $key, filmId: $filmId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilmInformationRouteArgs) return false;
    return key == other.key && filmId == other.filmId;
  }

  @override
  int get hashCode => key.hashCode ^ filmId.hashCode;
}

/// generated route for
/// [_i3.FilterFilmScreen]
class FilterFilmRoute extends _i16.PageRouteInfo<void> {
  const FilterFilmRoute({List<_i16.PageRouteInfo>? children})
      : super(FilterFilmRoute.name, initialChildren: children);

  static const String name = 'FilterFilmRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i3.FilterFilmScreen();
    },
  );
}

/// generated route for
/// [_i4.FilterListScreen]
class FilterListRoute extends _i16.PageRouteInfo<FilterListRouteArgs> {
  FilterListRoute({
    _i17.Key? key,
    required String filterType,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          FilterListRoute.name,
          args: FilterListRouteArgs(key: key, filterType: filterType),
          rawPathParams: {'filterType': filterType},
          initialChildren: children,
        );

  static const String name = 'FilterListRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilterListRouteArgs>(
        orElse: () =>
            FilterListRouteArgs(filterType: pathParams.getString('filterType')),
      );
      return _i4.FilterListScreen(key: args.key, filterType: args.filterType);
    },
  );
}

class FilterListRouteArgs {
  const FilterListRouteArgs({this.key, required this.filterType});

  final _i17.Key? key;

  final String filterType;

  @override
  String toString() {
    return 'FilterListRouteArgs{key: $key, filterType: $filterType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterListRouteArgs) return false;
    return key == other.key && filterType == other.filterType;
  }

  @override
  int get hashCode => key.hashCode ^ filterType.hashCode;
}

/// generated route for
/// [_i5.HomeScreen]
class HomeRoute extends _i16.PageRouteInfo<void> {
  const HomeRoute({List<_i16.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomeScreen();
    },
  );
}

/// generated route for
/// [_i6.SearchFilmScreen]
class SearchFilmRoute extends _i16.PageRouteInfo<void> {
  const SearchFilmRoute({List<_i16.PageRouteInfo>? children})
      : super(SearchFilmRoute.name, initialChildren: children);

  static const String name = 'SearchFilmRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i6.SearchFilmScreen();
    },
  );
}

/// generated route for
/// [_i7.SearchFilmWrapperScreen]
class SearchFilmWrapperRoute extends _i16.PageRouteInfo<void> {
  const SearchFilmWrapperRoute({List<_i16.PageRouteInfo>? children})
      : super(SearchFilmWrapperRoute.name, initialChildren: children);

  static const String name = 'SearchFilmWrapperRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return _i16.WrappedRoute(child: const _i7.SearchFilmWrapperScreen());
    },
  );
}

/// generated route for
/// [_i8.SearchedFilmsScreen]
class SearchedFilmsRoute extends _i16.PageRouteInfo<SearchedFilmsRouteArgs> {
  SearchedFilmsRoute({
    _i17.Key? key,
    String? nameCollection,
    String? keyword,
    List<int>? countries,
    List<int>? genres,
    int? yearFrom,
    int? yearTo,
    required String appBarTitle,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          SearchedFilmsRoute.name,
          args: SearchedFilmsRouteArgs(
            key: key,
            nameCollection: nameCollection,
            keyword: keyword,
            countries: countries,
            genres: genres,
            yearFrom: yearFrom,
            yearTo: yearTo,
            appBarTitle: appBarTitle,
          ),
          initialChildren: children,
        );

  static const String name = 'SearchedFilmsRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchedFilmsRouteArgs>();
      return _i8.SearchedFilmsScreen(
        key: args.key,
        nameCollection: args.nameCollection,
        keyword: args.keyword,
        countries: args.countries,
        genres: args.genres,
        yearFrom: args.yearFrom,
        yearTo: args.yearTo,
        appBarTitle: args.appBarTitle,
      );
    },
  );
}

class SearchedFilmsRouteArgs {
  const SearchedFilmsRouteArgs({
    this.key,
    this.nameCollection,
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    required this.appBarTitle,
  });

  final _i17.Key? key;

  final String? nameCollection;

  final String? keyword;

  final List<int>? countries;

  final List<int>? genres;

  final int? yearFrom;

  final int? yearTo;

  final String appBarTitle;

  @override
  String toString() {
    return 'SearchedFilmsRouteArgs{key: $key, nameCollection: $nameCollection, keyword: $keyword, countries: $countries, genres: $genres, yearFrom: $yearFrom, yearTo: $yearTo, appBarTitle: $appBarTitle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchedFilmsRouteArgs) return false;
    return key == other.key &&
        nameCollection == other.nameCollection &&
        keyword == other.keyword &&
        const _i18.ListEquality<int>().equals(countries, other.countries) &&
        const _i18.ListEquality<int>().equals(genres, other.genres) &&
        yearFrom == other.yearFrom &&
        yearTo == other.yearTo &&
        appBarTitle == other.appBarTitle;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      nameCollection.hashCode ^
      keyword.hashCode ^
      const _i18.ListEquality<int>().hash(countries) ^
      const _i18.ListEquality<int>().hash(genres) ^
      yearFrom.hashCode ^
      yearTo.hashCode ^
      appBarTitle.hashCode;
}

/// generated route for
/// [_i9.UserAuthenticationScreen]
class UserAuthenticationRoute extends _i16.PageRouteInfo<void> {
  const UserAuthenticationRoute({List<_i16.PageRouteInfo>? children})
      : super(UserAuthenticationRoute.name, initialChildren: children);

  static const String name = 'UserAuthenticationRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i9.UserAuthenticationScreen();
    },
  );
}

/// generated route for
/// [_i10.UserProfileScreen]
class UserProfileRoute extends _i16.PageRouteInfo<void> {
  const UserProfileRoute({List<_i16.PageRouteInfo>? children})
      : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i10.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i11.UserProfileWrapperScreen]
class UserProfileWrapperRoute extends _i16.PageRouteInfo<void> {
  const UserProfileWrapperRoute({List<_i16.PageRouteInfo>? children})
      : super(UserProfileWrapperRoute.name, initialChildren: children);

  static const String name = 'UserProfileWrapperRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return _i16.WrappedRoute(child: const _i11.UserProfileWrapperScreen());
    },
  );
}

/// generated route for
/// [_i12.WatchedCollectionScreen]
class WatchedCollectionRoute extends _i16.PageRouteInfo<void> {
  const WatchedCollectionRoute({List<_i16.PageRouteInfo>? children})
      : super(WatchedCollectionRoute.name, initialChildren: children);

  static const String name = 'WatchedCollectionRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i12.WatchedCollectionScreen();
    },
  );
}

/// generated route for
/// [_i13.WatchedCollectionWrapperScreen]
class WatchedCollectionWrapperRoute extends _i16.PageRouteInfo<void> {
  const WatchedCollectionWrapperRoute({List<_i16.PageRouteInfo>? children})
      : super(WatchedCollectionWrapperRoute.name, initialChildren: children);

  static const String name = 'WatchedCollectionWrapperRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return _i16.WrappedRoute(
        child: const _i13.WatchedCollectionWrapperScreen(),
      );
    },
  );
}

/// generated route for
/// [_i14.WillWatchCollectionScreen]
class WillWatchCollectionRoute extends _i16.PageRouteInfo<void> {
  const WillWatchCollectionRoute({List<_i16.PageRouteInfo>? children})
      : super(WillWatchCollectionRoute.name, initialChildren: children);

  static const String name = 'WillWatchCollectionRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i14.WillWatchCollectionScreen();
    },
  );
}

/// generated route for
/// [_i15.WillWatchCollectionWrapperScreen]
class WillWatchCollectionWrapperRoute extends _i16.PageRouteInfo<void> {
  const WillWatchCollectionWrapperRoute({List<_i16.PageRouteInfo>? children})
      : super(WillWatchCollectionWrapperRoute.name, initialChildren: children);

  static const String name = 'WillWatchCollectionWrapperRoute';

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return _i16.WrappedRoute(
        child: const _i15.WillWatchCollectionWrapperScreen(),
      );
    },
  );
}
