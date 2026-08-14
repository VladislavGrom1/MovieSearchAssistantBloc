import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';

class NetworkListener extends StatelessWidget {
  final Widget child;

  const NetworkListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkStatus>(
      listenWhen: (previous, current) =>
          previous != NetworkStatus.initial && previous != current,
      listener: (context, state) {
        if (state == NetworkStatus.disconnected) {
          CustomSnackBar(
            message: "Интернет-соединение потеряно", 
          ).show(context);
        }
        if (state == NetworkStatus.connected) {
          CustomSnackBar(
            message: "Интернет-соединение установлено", 
          ).show(context);
        }
      },
      child: child,
    );
  }
}