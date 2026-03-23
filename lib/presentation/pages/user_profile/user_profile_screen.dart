import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';

@RoutePage()
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => getIt<UserProfileBloc>(), child: _UserProfileView());
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {

              if(state is UserProfileLoading){
                return Center(child: CircularProgressIndicator());
              }

              if(state is CacheSizeLoaded){
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("UserProfileScreen", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10.h),
                      Text(state.sizeMB.toString()),
                      SizedBox(height: 10.h),
                      TextButton(onPressed: () {
                        context.read<UserProfileBloc>().add(GetCacheSize());
                      },
                      child: Text("Получить размер кэша",style: TextStyle(color: Colors.white))),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: () {
                          context.router.push(ChangeApiKeyRoute());
                        },
                        child: Text("Изменить ApiKey", style: TextStyle(color: Colors.white))),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: () {
                          context.read<UserProfileBloc>().add(ClearCacheDirectory());
                        },
                        child: Text("Очистить кэш", style: TextStyle(color: Colors.white))),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("UserProfileScreen", style: TextStyle(color: Colors.white))),
                  SizedBox(height: 10.h),
                  TextButton(
                      onPressed: () {
                        context.read<UserProfileBloc>().add(GetCacheSize());
                      },
                      child: Text("Получить размер кэша", style: TextStyle(color: Colors.white))),
                  TextButton(
                      onPressed: () {
                        context.router.push(ChangeApiKeyRoute());
                      },
                      child: Text("Изменить ApiKey", style: TextStyle(color: Colors.white))),
                ],
              );
            },
          ),
        ));
  }
}
