import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationUseCase authenticationUseCase;
  AuthenticationBloc({required this.authenticationUseCase}) : super(AuthenticationInitial()) {
    on<TryAuthenticationEvent>((event, emit) => _tryAuthentication(event, emit));
  }

  Future<void> _tryAuthentication(TryAuthenticationEvent event, Emitter emit) async {
    emit(AuthenticationLoading());
    try{
      final UserEntity userInfo = await authenticationUseCase.call(apiKey: event.apiKey);
      emit(AuthenticationSuccess(userInfo: userInfo));
    } catch(e){
      emit(AuthenticationFailure(exception: e));
    }
  }

}
