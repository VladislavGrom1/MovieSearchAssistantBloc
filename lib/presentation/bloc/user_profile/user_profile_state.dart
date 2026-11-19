part of 'user_profile_bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();
  
  @override
  List<Object?> get props => [];
}

final class UserProfileInitial extends UserProfileState {}

final class UserProfileLoading extends UserProfileState {}

final class UserProfileLoaded extends UserProfileState{
  final UserEntity? userEntity;

  /// Размер кэша сетевых постеров в байтах; `null` — ещё не посчитан.
  final int? cacheBytes;

  /// Размер библиотеки фильмов в байтах; `null` — ещё не посчитан.
  final int? libraryBytes;

  final Map<String, String>? appInfo;

  const UserProfileLoaded({
    this.userEntity,
    this.cacheBytes,
    this.libraryBytes,
    this.appInfo,
  });

  UserProfileLoaded copyWith({
    UserEntity? userEntity,
    int? cacheBytes,
    int? libraryBytes,
    Map<String, String>? appInfo
  }) {
    return UserProfileLoaded(
      userEntity: userEntity ?? this.userEntity,
      cacheBytes: cacheBytes ?? this.cacheBytes,
      libraryBytes: libraryBytes ?? this.libraryBytes,
      appInfo: appInfo ?? this.appInfo
    );
  }

  @override
  List<Object?> get props => [userEntity, cacheBytes, libraryBytes, appInfo];
}

final class UserProfileActionFailure extends UserProfileState{
  final String message;

  const UserProfileActionFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ExportInProgress extends UserProfileState{}

class ImportInProgress extends UserProfileState{
  final int current;
  final int total;

  const ImportInProgress({required this.current, required this.total});

  double get progress => total == 0 ? 0 : current/total;

  @override
  List<Object> get props => [current, total];
}

final class UserProfileActionSuccess extends UserProfileState{
  final String message;

  const UserProfileActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
