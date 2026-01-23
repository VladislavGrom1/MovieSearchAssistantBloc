part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();
  
  @override
  List<Object> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthenticationLoading extends AuthenticationState{}

final class AuthenticationSuccess extends AuthenticationState{
  final UserEntity userInfo;
  AuthenticationSuccess({required this.userInfo});
}

final class AuthenticationFailure extends AuthenticationState{
  final String exceptionType;
  final int? statusCode;
  AuthenticationFailure({required this.exceptionType, this.statusCode});
}