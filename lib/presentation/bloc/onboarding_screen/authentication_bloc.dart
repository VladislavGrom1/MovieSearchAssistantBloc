import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/use_shared_api_key_use_case.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UseSharedApiKeyUseCase useSharedApiKeyUseCase;

  AuthenticationBloc({
    required this.useSharedApiKeyUseCase,
  }) : super(AuthenticationInitial()) {
    on<StartWithSharedApiKey>(_startWithSharedApiKey);
  }

  Future<void> _startWithSharedApiKey(StartWithSharedApiKey event, Emitter emit) async {
    emit(AuthenticationLoading());
    try{
      final UserEntity userInfo = await useSharedApiKeyUseCase.call();
      emit(AuthenticationSuccess(userInfo: userInfo));
    } on LocalDataSourceException catch(e){
      emit(AuthenticationFailure(message: e.message));
    } catch(e){
      emit(AuthenticationFailure(message: "Неизвестная ошибка"));
    }
  }
}
