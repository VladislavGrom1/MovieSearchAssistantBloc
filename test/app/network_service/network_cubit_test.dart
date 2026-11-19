import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

void main() {
  late FakeStatusSource source;
  late NetworkCubit cubit;

  setUp(() {
    source = FakeStatusSource();
    cubit = NetworkCubit(source);
  });

  tearDown(() async {
    await cubit.close();
    await source.dispose();
  });

  test('стартует в unknown, а не в connected', () {
    expect(cubit.state, NetworkStatus.unknown);
  });

  test('переводит ответ источника в состояние', () async {
    source.emit(true);
    await settle();
    expect(cubit.state, NetworkStatus.connected);

    source.emit(false);
    await settle();
    expect(cubit.state, NetworkStatus.disconnected);
  });

  test('refresh перепроверяет связь в источнике', () async {
    await cubit.refresh();
    expect(source.refreshes, 1);
  });
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

class FakeStatusSource implements NetworkStatusSource {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  int refreshes = 0;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<void> refresh() async {
    refreshes++;
  }

  void emit(bool isConnected) => _controller.add(isConnected);

  Future<void> dispose() => _controller.close();
}
