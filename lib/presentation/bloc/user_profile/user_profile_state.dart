part of 'user_profile_bloc.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();
  
  @override
  List<Object> get props => [];
}

final class UserProfileInitial extends UserProfileState {}

final class UserProfileLoading extends UserProfileState {}

final class CacheSizeLoaded extends UserProfileState{
  final double sizeMB;

  const CacheSizeLoaded({required this.sizeMB});

  @override
  List<Object> get props => [sizeMB];
}
