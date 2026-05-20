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
  final double? cacheSizeMB;
  final Map<String, String>? appInfo;

  const UserProfileLoaded({this.userEntity, this.cacheSizeMB, this.appInfo});

  UserProfileLoaded copyWith({
    UserEntity? userEntity,
    double? cacheSizeMB,
    Map<String, String>? appInfo
  }) {
    return UserProfileLoaded(
      userEntity: userEntity ?? this.userEntity,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
      appInfo: appInfo ?? this.appInfo
    );
  }

  @override
  List<Object?> get props => [userEntity, cacheSizeMB, appInfo];
}

final class CacheSizeLoaded extends UserProfileState{
  final double sizeMB;

  const CacheSizeLoaded({required this.sizeMB});

  @override
  List<Object> get props => [sizeMB];
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
