part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileInfo extends UserProfileEvent{}

class UpdateApiKey extends UserProfileEvent{
  final String updatedApiKey;

  const UpdateApiKey({required this.updatedApiKey});

  @override
  List<Object?> get props => [updatedApiKey];
}

class UseSharedApiKey extends UserProfileEvent{}

class ExportLibrary extends UserProfileEvent{}

class ShareLibrary extends UserProfileEvent{}

class ImportLibrary extends UserProfileEvent{}

class ImportOldLibrary extends UserProfileEvent{}

/// Пересчитать размеры кэша и библиотеки: пользователь вернулся на экран
/// профиля или данные на диске изменились.
class RefreshStorageUsage extends UserProfileEvent{}

class ClearCacheDirectory extends UserProfileEvent{}

class ClearLibrary extends UserProfileEvent{}

class LaunchApiKeyUrl extends UserProfileEvent{}

class GetAppInfo extends UserProfileEvent{}
