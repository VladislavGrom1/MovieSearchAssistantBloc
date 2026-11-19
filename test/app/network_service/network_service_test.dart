import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/network_service/connectivity_events.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_probe.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

/// Проверки `NetworkService` идут обычным `test()`, без фейковых часов:
/// отмена подписки внутри `testWidgets` вешает следующий `tester.pump()`.
void main() {
  late FakeConnectivityEvents events;
  late FakeNetworkProbe probe;
  late NetworkService service;
  late List<bool> statuses;

  Future<void> start({
    List<ConnectivityResult> transport = const [ConnectivityResult.wifi],
    bool reachable = true,
    bool holdProbe = false,
    Duration retryInterval = const Duration(minutes: 1),
  }) async {
    events = FakeConnectivityEvents(transport: transport);
    probe = FakeNetworkProbe(answer: reachable)..hold = holdProbe;
    statuses = [];
    service = NetworkService(
      connectivity: events,
      probe: probe,
      retryInterval: retryInterval,
    );
    service.onStatusChange.listen(statuses.add);
    await settle();
  }

  tearDown(() async {
    await service.dispose();
    await events.dispose();
  });

  test('на старте одна проверка, а дальше поллинга нет', () async {
    await start();

    expect(probe.calls, 1);
    expect(statuses, [true]);

    await settle(milliseconds: 500);

    expect(probe.calls, 1, reason: 'при связи проверок по таймеру быть не должно');
    expect(statuses, [true], reason: 'дубликатов в потоке быть не должно');
  });

  test('старт без транспорта даёт «связи нет» без пробы', () async {
    await start(transport: const [ConnectivityResult.none], reachable: true);

    expect(probe.calls, 0, reason: 'нет смысла ходить в сеть, если радио говорит «нет»');
    expect(statuses, [false]);
  });

  test('событие «транспорта нет» публикует потерю связи сразу, без пробы', () async {
    await start();
    expect(statuses, [true]);

    events.emit(const [ConnectivityResult.none]);
    await settle();

    expect(statuses, [true, false]);
    expect(probe.calls, 1, reason: 'проверять нечем — сети нет на уровне радио');
  });

  test('появление транспорта перепроверяет связь и публикует восстановление', () async {
    await start(transport: const [ConnectivityResult.none], reachable: true);
    expect(statuses, [false]);

    events.emit(const [ConnectivityResult.wifi]);
    await settle();

    expect(probe.calls, 1);
    expect(statuses, [false, true]);
  });

  test('событие во время проверки не публикует устаревший ответ', () async {
    await start(holdProbe: true);
    expect(probe.calls, 1);
    expect(statuses, isEmpty);

    events.emit(const [ConnectivityResult.mobile]);
    await settle();

    expect(probe.calls, 1, reason: 'вторая проверка ждёт, пока закончится первая');

    probe.completeNext(false);
    await settle();
    expect(probe.calls, 2, reason: 'устаревший результат отбрасывается, нужна новая проба');

    probe.completeNext(true);
    await settle();

    expect(statuses, [true], reason: 'устаревшее «связи нет» не должно попасть в поток');
  });

  test('refresh во время проверки заставляет проверить заново', () async {
    await start(holdProbe: true);
    expect(probe.calls, 1);

    service.refresh();
    await settle();
    expect(probe.calls, 1, reason: 'вторая проба ждёт, пока закончится первая');

    probe.completeNext(false);
    await settle();
    expect(probe.calls, 2, reason: 'ответ на устаревшую проверку не публикуется');

    probe.completeNext(true);
    await settle();

    expect(statuses, [true]);
  });

  test('пока связи нет, работает ретрай; в connected он выключается', () async {
    await start(
      transport: const [ConnectivityResult.none],
      reachable: false,
      retryInterval: const Duration(milliseconds: 40),
    );
    expect(statuses, [false]);

    probe.answer = true;
    await settle(milliseconds: 150);
    expect(statuses, [false, true]);
    expect(probe.calls, greaterThan(0));

    final callsAfterRecovery = probe.calls;
    await settle(milliseconds: 200);
    expect(probe.calls, callsAfterRecovery, reason: 'после восстановления ретрай не нужен');
  });

  test('dispose останавливает ретрай и закрывает поток', () async {
    await start(
      transport: const [ConnectivityResult.none],
      retryInterval: const Duration(milliseconds: 30),
    );

    await service.dispose();
    final callsAtDispose = probe.calls;
    await settle(milliseconds: 150);

    expect(probe.calls, callsAtDispose);
    expect(await service.onStatusChange.isEmpty, isTrue);
  });

  test('ошибка потока транспорта не роняет сервис', () async {
    await start();

    events.fail(StateError('платформа молчит'));
    await settle();

    expect(statuses, [true]);
  });
}

Future<void> settle({int milliseconds = 50}) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

class FakeConnectivityEvents implements ConnectivityEvents {
  FakeConnectivityEvents({required this.transport});

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> transport;
  int checks = 0;

  @override
  Stream<List<ConnectivityResult>> get onChanged => _controller.stream;

  @override
  Future<List<ConnectivityResult>> check() async {
    checks++;
    return transport;
  }

  void emit(List<ConnectivityResult> results) {
    transport = results;
    _controller.add(results);
  }

  void fail(Object error) => _controller.addError(error);

  Future<void> dispose() => _controller.close();
}

class FakeNetworkProbe implements NetworkProbe {
  FakeNetworkProbe({required this.answer});

  bool answer;
  int calls = 0;
  bool hold = false;
  final List<Completer<bool>> _pending = [];

  @override
  Future<bool> isReachable() {
    calls++;
    if (!hold) return Future<bool>.value(answer);
    final completer = Completer<bool>();
    _pending.add(completer);
    return completer.future;
  }

  void completeNext(bool result) {
    if (_pending.isEmpty) throw StateError('нет ожидающих проб');
    _pending.removeAt(0).complete(result);
  }
}
