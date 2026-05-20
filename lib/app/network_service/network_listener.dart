import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';

class NetworkListener extends StatelessWidget {
  final Widget child;

  const NetworkListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkStatus>(
      listener: (context, state) {
        if (state == NetworkStatus.disconnected) {
          CustomSnackBar(
            message: "Интернет-соединение потеряно", 
            color: AppColors.snackRed
          ).show(context);
        }
        if (state == NetworkStatus.connected) {
          CustomSnackBar(
            message: "Интернет-соединение установлено", 
            color: AppColors.snackGreen
          ).show(context);
        }
      },
      child: child,
    );
  }
}