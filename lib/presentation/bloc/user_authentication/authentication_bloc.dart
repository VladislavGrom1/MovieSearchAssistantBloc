import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UpdateUserApiKeyInfoUseCase authenticationUseCase;
  AuthenticationBloc({required this.authenticationUseCase}) : super(AuthenticationInitial()) {
    on<TryAuthenticationEvent>(_tryAuthentication);
  }

  Future<void> _tryAuthentication(TryAuthenticationEvent event, Emitter emit) async {
    emit(AuthenticationLoading());
    try{
      final UserEntity? userInfo = await authenticationUseCase.call(apiKey: event.apiKey);
      if(userInfo == null){
        emit(AuthenticationFailure(message: "API ключ отсутствует"));
      } else{
        emit(AuthenticationSuccess(userInfo: userInfo));
      }
    } on RemoteDataSourceException catch(e){
      emit(AuthenticationFailure(message: e.message));
    } on LocalDataSourceException catch(e) {
      emit(AuthenticationFailure(message: e.message));
    } catch(e){
      emit(AuthenticationFailure(message: "Неизвестная ошибка"));
    }
  }

}
