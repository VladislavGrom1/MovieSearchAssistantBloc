import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/open_url_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UpdateUserApiKeyInfoUseCase authenticationUseCase;
  final OpenUrlUseCase openUrlUseCase;
  AuthenticationBloc({
    required this.authenticationUseCase,
    required this.openUrlUseCase
  }) : super(AuthenticationInitial()) {
    on<TryAuthenticationEvent>(_tryAuthentication);
    on<LaunchApiKeyUrl>(_launchApiKeyUrl);
  }

  Future<void> _tryAuthentication(TryAuthenticationEvent event, Emitter emit) async {
    final currentState = state;
    emit(AuthenticationLoading());
    try{
      final UserEntity? userInfo = await authenticationUseCase.call(apiKey: event.apiKey);
      if(userInfo == null){
        emit(AuthenticationFailure(message: "API ключ отсутствует"));
        emit(currentState);
      } else{
        emit(AuthenticationSuccess(userInfo: userInfo));
        emit(currentState);
      }
    } on RemoteDataSourceException catch(e){
      emit(AuthenticationFailure(message: e.message));
      emit(currentState);
    } on LocalDataSourceException catch(e) {
      emit(AuthenticationFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(AuthenticationFailure(message: "Неизвестная ошибка"));
      emit(currentState);
    }
  }

  Future<void> _launchApiKeyUrl(LaunchApiKeyUrl event, Emitter emit) async {
    final currentState = state;
    try{
      final isSuccess = await openUrlUseCase.call("https://kinopoiskapiunofficial.tech/?ysclid=mo5wqs4v48720285068");
      if(!isSuccess){
        emit(AuthenticationActionFailure(message: "Не удалось перейти по ссылке"));
        emit(currentState);
      }
    } catch(e){
      AuthenticationActionFailure(message: "Не удалось перейти по ссылке");
      emit(currentState);
    }
  }

}
