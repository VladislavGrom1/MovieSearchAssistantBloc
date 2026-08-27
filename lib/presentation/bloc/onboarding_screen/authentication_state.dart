part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();
  
  @override
  List<Object?> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthenticationLoading extends AuthenticationState{}

final class AuthenticationSuccess extends AuthenticationState{
  final UserEntity userInfo;
  const AuthenticationSuccess({required this.userInfo});

  @override
  List<Object> get props => [userInfo];
}

final class AuthenticationFailure extends AuthenticationState{
  final String message;  
  const AuthenticationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}