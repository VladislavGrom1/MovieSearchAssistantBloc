import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_listener.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

void main() {
  late FakeStatusSource source;
  late NetworkCubit cubit;

  Future<void> pumpListener(WidgetTester tester) async {
    source = FakeStatusSource();
    cubit = NetworkCubit(source);
    await tester.pumpWidget(
      BlocProvider<NetworkCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: NetworkListener(child: Scaffold(body: Text('экран'))),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> waitSnackBar(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> flushSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('старт без связи показывает снекбар сразу', (tester) async {
    await pumpListener(tester);

    source.emit(false);
    await waitSnackBar(tester);

    expect(find.text('Интернет-соединение потеряно'), findsOneWidget);
    await flushSnackBars(tester);
  });

  testWidgets('первый ответ «связь есть» не показывается', (tester) async {
    await pumpListener(tester);

    source.emit(true);
    await waitSnackBar(tester);

    expect(find.text('Интернет-соединение установлено'), findsNothing);
  });

  testWidgets('восстановление связи показывает снекбар и заменяет предыдущий',
      (tester) async {
    await pumpListener(tester);

    source.emit(false);
    await waitSnackBar(tester);
    expect(find.text('Интернет-соединение потеряно'), findsOneWidget);

    source.emit(true);
    await waitSnackBar(tester);

    expect(find.text('Интернет-соединение установлено'), findsOneWidget);
    expect(find.text('Интернет-соединение потеряно'), findsNothing);
    await flushSnackBars(tester);
  });

  testWidgets('возврат из фона перепроверяет связь', (tester) async {
    await pumpListener(tester);

    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.lifecycle.name,
      SystemChannels.lifecycle.codec.encodeMessage('AppLifecycleState.resumed'),
      (_) {},
    );
    await tester.pump();

    expect(source.refreshes, 1);
  });
}

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
}
