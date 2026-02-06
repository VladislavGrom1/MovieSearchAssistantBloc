import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationUseCase authenticationUseCase;
  AuthenticationBloc({required this.authenticationUseCase}) : super(AuthenticationInitial()) {
    on<TryAuthenticationEvent>(_tryAuthentication);
  }

  Future<void> _tryAuthentication(TryAuthenticationEvent event, Emitter emit) async {
    emit(AuthenticationLoading());
    try{
      final UserEntity? userInfo = await authenticationUseCase.call(apiKey: event.apiKey);
      if(userInfo == null){
        emit(AuthenticationFailure(exceptionType: "Информация об ApiKey отсутствует"));
      } else{
        emit(AuthenticationSuccess(userInfo: userInfo));
      }
    } on RemoteDataSourceException catch(e){
      emit(AuthenticationFailure(exceptionType: e.exceptionType.name, statusCode: e.statusCode));
    } on LocalDataSourceException catch(e) {
      emit(AuthenticationFailure(exceptionType: e.message));
    } catch(e){
      emit(AuthenticationFailure(exceptionType: "Неизвестная ошибка"));
    }
  }

}
