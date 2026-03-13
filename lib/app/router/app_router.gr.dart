// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:collection/collection.dart' as _i17;
import 'package:flutter/material.dart' as _i16;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/collections/collections_wrapper_screen.dart'
    as _i3;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/search_film/search_film_wrapper_screen.dart'
    as _i10;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/user_profile/user_profile_wrapper_screen.dart'
    as _i14;
import 'package:movie_search_assistant_bloc/presentation/pages/change_api_key/change_api_key_screen.dart'
    as _i1;
import 'package:movie_search_assistant_bloc/presentation/pages/collection_films/collection_films_screen.dart'
    as _i2;
import 'package:movie_search_assistant_bloc/presentation/pages/collections/collections_screen.dart'
    as _i4;
import 'package:movie_search_assistant_bloc/presentation/pages/film_information/film_information_screen.dart'
    as _i5;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_film/filter_film_screen.dart'
    as _i6;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_list/filter_list_screen.dart'
    as _i7;
import 'package:movie_search_assistant_bloc/presentation/pages/home/home_screen.dart'
    as _i8;
import 'package:movie_search_assistant_bloc/presentation/pages/search_films/search_film_screen.dart'
    as _i9;
import 'package:movie_search_assistant_bloc/presentation/pages/searched_films/searched_films_screen.dart'
    as _i11;
import 'package:movie_search_assistant_bloc/presentation/pages/user_authentication/user_authentication_screen.dart'
    as _i12;
import 'package:movie_search_assistant_bloc/presentation/pages/user_profile/user_profile_screen.dart'
    as _i13;

/// generated route for
/// [_i1.ChangeApiKeyScreen]
class ChangeApiKeyRoute extends _i15.PageRouteInfo<void> {
  const ChangeApiKeyRoute({List<_i15.PageRouteInfo>? children})
      : super(ChangeApiKeyRoute.name, initialChildren: children);

  static const String name = 'ChangeApiKeyRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i1.ChangeApiKeyScreen();
    },
  );
}

/// generated route for
/// [_i2.CollectionFilmsScreen]
class CollectionFilmsRoute
    extends _i15.PageRouteInfo<CollectionFilmsRouteArgs> {
  CollectionFilmsRoute({
    _i16.Key? key,
    required String collectionId,
    List<_i15.PageRouteInfo>? children,
  }) : super(
          CollectionFilmsRoute.name,
          args: CollectionFilmsRouteArgs(key: key, collectionId: collectionId),
          rawPathParams: {'collectionId': collectionId},
          initialChildren: children,
        );

  static const String name = 'CollectionFilmsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CollectionFilmsRouteArgs>(
        orElse: () => CollectionFilmsRouteArgs(
          collectionId: pathParams.getString('collectionId'),
        ),
      );
      return _i2.CollectionFilmsScreen(
        key: args.key,
        collectionId: args.collectionId,
      );
    },
  );
}

class CollectionFilmsRouteArgs {
  const CollectionFilmsRouteArgs({this.key, required this.collectionId});

  final _i16.Key? key;

  final String collectionId;

  @override
  String toString() {
    return 'CollectionFilmsRouteArgs{key: $key, collectionId: $collectionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CollectionFilmsRouteArgs) return false;
    return key == other.key && collectionId == other.collectionId;
  }

  @override
  int get hashCode => key.hashCode ^ collectionId.hashCode;
}

/// generated route for
/// [_i3.CollectionWrapperScreen]
class CollectionWrapperRoute extends _i15.PageRouteInfo<void> {
  const CollectionWrapperRoute({List<_i15.PageRouteInfo>? children})
      : super(CollectionWrapperRoute.name, initialChildren: children);

  static const String name = 'CollectionWrapperRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return _i15.WrappedRoute(child: const _i3.CollectionWrapperScreen());
    },
  );
}

/// generated route for
/// [_i4.CollectionsScreen]
class CollectionsRoute extends _i15.PageRouteInfo<void> {
  const CollectionsRoute({List<_i15.PageRouteInfo>? children})
      : super(CollectionsRoute.name, initialChildren: children);

  static const String name = 'CollectionsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i4.CollectionsScreen();
    },
  );
}

/// generated route for
/// [_i5.FilmInformationScreen]
class FilmInformationRoute
    extends _i15.PageRouteInfo<FilmInformationRouteArgs> {
  FilmInformationRoute({
    _i16.Key? key,
    required int filmId,
    List<_i15.PageRouteInfo>? children,
  }) : super(
          FilmInformationRoute.name,
          args: FilmInformationRouteArgs(key: key, filmId: filmId),
          rawPathParams: {'filmId': filmId},
          initialChildren: children,
        );

  static const String name = 'FilmInformationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilmInformationRouteArgs>(
        orElse: () =>
            FilmInformationRouteArgs(filmId: pathParams.getInt('filmId')),
      );
      return _i5.FilmInformationScreen(key: args.key, filmId: args.filmId);
    },
  );
}

class FilmInformationRouteArgs {
  const FilmInformationRouteArgs({this.key, required this.filmId});

  final _i16.Key? key;

  final int filmId;

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
/// [_i6.FilterFilmScreen]
class FilterFilmRoute extends _i15.PageRouteInfo<void> {
  const FilterFilmRoute({List<_i15.PageRouteInfo>? children})
      : super(FilterFilmRoute.name, initialChildren: children);

  static const String name = 'FilterFilmRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i6.FilterFilmScreen();
    },
  );
}

/// generated route for
/// [_i7.FilterListScreen]
class FilterListRoute extends _i15.PageRouteInfo<FilterListRouteArgs> {
  FilterListRoute({
    _i16.Key? key,
    required String filterType,
    List<_i15.PageRouteInfo>? children,
  }) : super(
          FilterListRoute.name,
          args: FilterListRouteArgs(key: key, filterType: filterType),
          rawPathParams: {'filterType': filterType},
          initialChildren: children,
        );

  static const String name = 'FilterListRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilterListRouteArgs>(
        orElse: () =>
            FilterListRouteArgs(filterType: pathParams.getString('filterType')),
      );
      return _i7.FilterListScreen(key: args.key, filterType: args.filterType);
    },
  );
}

class FilterListRouteArgs {
  const FilterListRouteArgs({this.key, required this.filterType});

  final _i16.Key? key;

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
/// [_i8.HomeScreen]
class HomeRoute extends _i15.PageRouteInfo<void> {
  const HomeRoute({List<_i15.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.HomeScreen();
    },
  );
}

/// generated route for
/// [_i9.SearchFilmScreen]
class SearchFilmRoute extends _i15.PageRouteInfo<void> {
  const SearchFilmRoute({List<_i15.PageRouteInfo>? children})
      : super(SearchFilmRoute.name, initialChildren: children);

  static const String name = 'SearchFilmRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.SearchFilmScreen();
    },
  );
}

/// generated route for
/// [_i10.SearchFilmWrapperScreen]
class SearchFilmWrapperRoute extends _i15.PageRouteInfo<void> {
  const SearchFilmWrapperRoute({List<_i15.PageRouteInfo>? children})
      : super(SearchFilmWrapperRoute.name, initialChildren: children);

  static const String name = 'SearchFilmWrapperRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return _i15.WrappedRoute(child: const _i10.SearchFilmWrapperScreen());
    },
  );
}

/// generated route for
/// [_i11.SearchedFilmsScreen]
class SearchedFilmsRoute extends _i15.PageRouteInfo<SearchedFilmsRouteArgs> {
  SearchedFilmsRoute({
    _i16.Key? key,
    String? nameCollection,
    String? keyword,
    List<int>? countries,
    List<int>? genres,
    int? yearFrom,
    int? yearTo,
    required String appBarTitle,
    List<_i15.PageRouteInfo>? children,
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

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchedFilmsRouteArgs>();
      return _i11.SearchedFilmsScreen(
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

  final _i16.Key? key;

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
        const _i17.ListEquality<int>().equals(countries, other.countries) &&
        const _i17.ListEquality<int>().equals(genres, other.genres) &&
        yearFrom == other.yearFrom &&
        yearTo == other.yearTo &&
        appBarTitle == other.appBarTitle;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      nameCollection.hashCode ^
      keyword.hashCode ^
      const _i17.ListEquality<int>().hash(countries) ^
      const _i17.ListEquality<int>().hash(genres) ^
      yearFrom.hashCode ^
      yearTo.hashCode ^
      appBarTitle.hashCode;
}

/// generated route for
/// [_i12.UserAuthenticationScreen]
class UserAuthenticationRoute extends _i15.PageRouteInfo<void> {
  const UserAuthenticationRoute({List<_i15.PageRouteInfo>? children})
      : super(UserAuthenticationRoute.name, initialChildren: children);

  static const String name = 'UserAuthenticationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i12.UserAuthenticationScreen();
    },
  );
}

/// generated route for
/// [_i13.UserProfileScreen]
class UserProfileRoute extends _i15.PageRouteInfo<void> {
  const UserProfileRoute({List<_i15.PageRouteInfo>? children})
      : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i13.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i14.UserProfileWrapperScreen]
class UserProfileWrapperRoute extends _i15.PageRouteInfo<void> {
  const UserProfileWrapperRoute({List<_i15.PageRouteInfo>? children})
      : super(UserProfileWrapperRoute.name, initialChildren: children);

  static const String name = 'UserProfileWrapperRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return _i15.WrappedRoute(child: const _i14.UserProfileWrapperScreen());
    },
  );
}
