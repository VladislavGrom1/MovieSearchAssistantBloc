import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/util/network_service/cubit/internet_cubit.dart';

class NetworkListener extends StatelessWidget {
  final Widget child;

  const NetworkListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkStatus>(
      listener: (context, state) {
        if (state == NetworkStatus.disconnected) {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            msg: "Интернет-соединение потеряно"
          );
        }
        if (state == NetworkStatus.connected) {
          Fluttertoast.showToast(
            backgroundColor: Colors.green,
            msg: "Интернет-соединение установлено"
          );
        }
      },
      child: child,
    );
  }
}