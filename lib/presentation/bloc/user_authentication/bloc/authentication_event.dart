part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class TryAuthenticationEvent extends AuthenticationEvent{
  final String apiKey;
  const TryAuthenticationEvent({required this.apiKey});
}