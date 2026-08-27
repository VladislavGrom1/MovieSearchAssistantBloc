// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:collection/collection.dart' as _i16;
import 'package:flutter/material.dart' as _i15;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/collections/collections_wrapper_screen.dart'
    as _i2;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/search_film/search_film_wrapper_screen.dart'
    as _i9;
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/user_profile/user_profile_wrapper_screen.dart'
    as _i13;
import 'package:movie_search_assistant_bloc/presentation/pages/collection_films_screen.dart'
    as _i1;
import 'package:movie_search_assistant_bloc/presentation/pages/collections_screen.dart'
    as _i3;
import 'package:movie_search_assistant_bloc/presentation/pages/film_information_screen.dart'
    as _i4;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_film_screen.dart'
    as _i5;
import 'package:movie_search_assistant_bloc/presentation/pages/filter_list_screen.dart'
    as _i6;
import 'package:movie_search_assistant_bloc/presentation/pages/home_screen.dart'
    as _i7;
import 'package:movie_search_assistant_bloc/presentation/pages/search_film_screen.dart'
    as _i8;
import 'package:movie_search_assistant_bloc/presentation/pages/searched_films_screen.dart'
    as _i10;
import 'package:movie_search_assistant_bloc/presentation/pages/user_authentication_screen.dart'
    as _i11;
import 'package:movie_search_assistant_bloc/presentation/pages/user_profile_screen.dart'
    as _i12;

/// generated route for
/// [_i1.CollectionFilmsScreen]
class CollectionFilmsRoute
    extends _i14.PageRouteInfo<CollectionFilmsRouteArgs> {
  CollectionFilmsRoute({
    _i15.Key? key,
    required String collectionId,
    required String collectionName,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          CollectionFilmsRoute.name,
          args: CollectionFilmsRouteArgs(
            key: key,
            collectionId: collectionId,
            collectionName: collectionName,
          ),
          rawPathParams: {
            'collectionId': collectionId,
            'collectionName': collectionName,
          },
          initialChildren: children,
        );

  static const String name = 'CollectionFilmsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CollectionFilmsRouteArgs>(
        orElse: () => CollectionFilmsRouteArgs(
          collectionId: pathParams.getString('collectionId'),
          collectionName: pathParams.getString('collectionName'),
        ),
      );
      return _i1.CollectionFilmsScreen(
        key: args.key,
        collectionId: args.collectionId,
        collectionName: args.collectionName,
      );
    },
  );
}

class CollectionFilmsRouteArgs {
  const CollectionFilmsRouteArgs({
    this.key,
    required this.collectionId,
    required this.collectionName,
  });

  final _i15.Key? key;

  final String collectionId;

  final String collectionName;

  @override
  String toString() {
    return 'CollectionFilmsRouteArgs{key: $key, collectionId: $collectionId, collectionName: $collectionName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CollectionFilmsRouteArgs) return false;
    return key == other.key &&
        collectionId == other.collectionId &&
        collectionName == other.collectionName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ collectionId.hashCode ^ collectionName.hashCode;
}

/// generated route for
/// [_i2.CollectionWrapperScreen]
class CollectionWrapperRoute extends _i14.PageRouteInfo<void> {
  const CollectionWrapperRoute({List<_i14.PageRouteInfo>? children})
      : super(CollectionWrapperRoute.name, initialChildren: children);

  static const String name = 'CollectionWrapperRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i2.CollectionWrapperScreen());
    },
  );
}

/// generated route for
/// [_i3.CollectionsScreen]
class CollectionsRoute extends _i14.PageRouteInfo<void> {
  const CollectionsRoute({List<_i14.PageRouteInfo>? children})
      : super(CollectionsRoute.name, initialChildren: children);

  static const String name = 'CollectionsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i3.CollectionsScreen();
    },
  );
}

/// generated route for
/// [_i4.FilmInformationScreen]
class FilmInformationRoute
    extends _i14.PageRouteInfo<FilmInformationRouteArgs> {
  FilmInformationRoute({
    _i15.Key? key,
    required int filmId,
    required String filmName,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          FilmInformationRoute.name,
          args: FilmInformationRouteArgs(
            key: key,
            filmId: filmId,
            filmName: filmName,
          ),
          rawPathParams: {'filmId': filmId, 'filmName': filmName},
          initialChildren: children,
        );

  static const String name = 'FilmInformationRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilmInformationRouteArgs>(
        orElse: () => FilmInformationRouteArgs(
          filmId: pathParams.getInt('filmId'),
          filmName: pathParams.getString('filmName'),
        ),
      );
      return _i4.FilmInformationScreen(
        key: args.key,
        filmId: args.filmId,
        filmName: args.filmName,
      );
    },
  );
}

class FilmInformationRouteArgs {
  const FilmInformationRouteArgs({
    this.key,
    required this.filmId,
    required this.filmName,
  });

  final _i15.Key? key;

  final int filmId;

  final String filmName;

  @override
  String toString() {
    return 'FilmInformationRouteArgs{key: $key, filmId: $filmId, filmName: $filmName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilmInformationRouteArgs) return false;
    return key == other.key &&
        filmId == other.filmId &&
        filmName == other.filmName;
  }

  @override
  int get hashCode => key.hashCode ^ filmId.hashCode ^ filmName.hashCode;
}

/// generated route for
/// [_i5.FilterFilmScreen]
class FilterFilmRoute extends _i14.PageRouteInfo<void> {
  const FilterFilmRoute({List<_i14.PageRouteInfo>? children})
      : super(FilterFilmRoute.name, initialChildren: children);

  static const String name = 'FilterFilmRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.FilterFilmScreen();
    },
  );
}

/// generated route for
/// [_i6.FilterListScreen]
class FilterListRoute extends _i14.PageRouteInfo<FilterListRouteArgs> {
  FilterListRoute({
    _i15.Key? key,
    required String filterType,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          FilterListRoute.name,
          args: FilterListRouteArgs(key: key, filterType: filterType),
          rawPathParams: {'filterType': filterType},
          initialChildren: children,
        );

  static const String name = 'FilterListRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FilterListRouteArgs>(
        orElse: () =>
            FilterListRouteArgs(filterType: pathParams.getString('filterType')),
      );
      return _i6.FilterListScreen(key: args.key, filterType: args.filterType);
    },
  );
}

class FilterListRouteArgs {
  const FilterListRouteArgs({this.key, required this.filterType});

  final _i15.Key? key;

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
/// [_i7.HomeScreen]
class HomeRoute extends _i14.PageRouteInfo<void> {
  const HomeRoute({List<_i14.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.HomeScreen();
    },
  );
}

/// generated route for
/// [_i8.SearchFilmScreen]
class SearchFilmRoute extends _i14.PageRouteInfo<void> {
  const SearchFilmRoute({List<_i14.PageRouteInfo>? children})
      : super(SearchFilmRoute.name, initialChildren: children);

  static const String name = 'SearchFilmRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i8.SearchFilmScreen();
    },
  );
}

/// generated route for
/// [_i9.SearchFilmWrapperScreen]
class SearchFilmWrapperRoute extends _i14.PageRouteInfo<void> {
  const SearchFilmWrapperRoute({List<_i14.PageRouteInfo>? children})
      : super(SearchFilmWrapperRoute.name, initialChildren: children);

  static const String name = 'SearchFilmWrapperRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i9.SearchFilmWrapperScreen());
    },
  );
}

/// generated route for
/// [_i10.SearchedFilmsScreen]
class SearchedFilmsRoute extends _i14.PageRouteInfo<SearchedFilmsRouteArgs> {
  SearchedFilmsRoute({
    _i15.Key? key,
    String? nameCollection,
    String? keyword,
    List<int>? countries,
    List<int>? genres,
    int? yearFrom,
    int? yearTo,
    required String appBarTitle,
    List<_i14.PageRouteInfo>? children,
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

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchedFilmsRouteArgs>();
      return _i10.SearchedFilmsScreen(
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

  final _i15.Key? key;

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
        const _i16.ListEquality<int>().equals(countries, other.countries) &&
        const _i16.ListEquality<int>().equals(genres, other.genres) &&
        yearFrom == other.yearFrom &&
        yearTo == other.yearTo &&
        appBarTitle == other.appBarTitle;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      nameCollection.hashCode ^
      keyword.hashCode ^
      const _i16.ListEquality<int>().hash(countries) ^
      const _i16.ListEquality<int>().hash(genres) ^
      yearFrom.hashCode ^
      yearTo.hashCode ^
      appBarTitle.hashCode;
}

/// generated route for
/// [_i11.OnboardingScreen]
class UserAuthenticationRoute extends _i14.PageRouteInfo<void> {
  const UserAuthenticationRoute({List<_i14.PageRouteInfo>? children})
      : super(UserAuthenticationRoute.name, initialChildren: children);

  static const String name = 'UserAuthenticationRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i12.UserProfileScreen]
class UserProfileRoute extends _i14.PageRouteInfo<void> {
  const UserProfileRoute({List<_i14.PageRouteInfo>? children})
      : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.UserProfileScreen();
    },
  );
}

/// generated route for
/// [_i13.UserProfileWrapperScreen]
class UserProfileWrapperRoute extends _i14.PageRouteInfo<void> {
  const UserProfileWrapperRoute({List<_i14.PageRouteInfo>? children})
      : super(UserProfileWrapperRoute.name, initialChildren: children);

  static const String name = 'UserProfileWrapperRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i13.UserProfileWrapperScreen());
    },
  );
}
