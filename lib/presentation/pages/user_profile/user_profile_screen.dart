import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';

@RoutePage()
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => getIt<UserProfileBloc>()..add(GetUserProfileInfo()),
        child: _UserProfileView());
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    final userProfileBloc = context.read<UserProfileBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
         if(state is UserProfileActionSuccess){
           Fluttertoast.showToast(
            backgroundColor: Colors.green,
            msg: state.message
          );
         }
         if(state is UserProfileActionFailure){
           Fluttertoast.showToast(
            backgroundColor: Colors.red,
            msg: state.message
          );
         }
        },
        child: SafeArea(
            child: RefreshIndicator(
          onRefresh: () async {
            userProfileBloc.add(UpdateUserProfileInfo());
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text("API Key"),
                  SizedBox(height: 10.h),
                  BlocBuilder<UserProfileBloc, UserProfileState>(
                    builder: (context, state) {
                      if (state is UserProfileLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (state is UserProfileLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              color: Colors.grey,
                              child: SizedBox(
                                  height: 44.h,
                                  child: Center(
                                      child: Text(state.userEntity?.apiKey ??
                                          "API Key отсутствует"))),
                            ),
                            SizedBox(height: 10.h),
                            Card(
                              color: Colors.grey,
                              child: SizedBox(
                                height: 100.h,
                                width: double.maxFinite,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.h),
                                    Text(
                                        "Тип аккаунта: ${state.userEntity?.accountType}"),
                                    SizedBox(height: 10.h),
                                    Text(
                                        "Дневное количество запросов: ${state.userEntity?.limitCount}"),
                                    SizedBox(height: 10.h),
                                    Text(
                                        "Количество совершенных запросов: ${state.userEntity?.useCount}")
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return SizedBox();
                    },
                  ),
                  SizedBox(height: 10.h),
                  Text("Память"),
                  BlocBuilder<UserProfileBloc, UserProfileState>(
                    builder: (context, state) {
                      if (state is UserProfileLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (state is UserProfileLoaded) {
                        return Column(children: [
                          Text(
                              "Размер кэша: ${state.cacheSizeMB?.toStringAsFixed(1)} MB")
                        ]);
                      }

                      return SizedBox();
                    },
                  ),
                  Text("Настройки"),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final items = [
                        "Изменить API Key",
                        "Импорт фильмов",
                        "Экспорт фильмов",
                        "Очистить кэш",
                        "Очистить данные о фильмах",
                      ];
                      final icons = [
                        Icons.key,
                        Icons.file_download,
                        Icons.file_upload,
                        Icons.cleaning_services,
                        Icons.delete_sweep,
                      ];

                      return ListTile(
                          leading: Icon(icons[index]),
                          title: Text(items[index]),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16),
                          onTap: () {
                            switch (index) {
                              case 0:
                                _changeApiKey(context);
                                break;
                              case 1:
                                _importMovies(context);
                                break;
                              case 2:
                                _exportMovies(context);
                                break;
                              case 3:
                                _clearCacheDirectory(context);
                                break;
                              case 4:
                                _clearMoviesData(context);
                                break;
                            }
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  void _changeApiKey(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<UserProfileBloc>(),
          child: _UpdateApiKeyDialog(),
        );
      },
    );
  }

  void _importMovies(BuildContext context) {
    // TODO: реализовать импорт фильмов
  }

  void _exportMovies(BuildContext context) {
    // TODO: реализовать экспорт фильмов
  }

  void _clearCacheDirectory(BuildContext context) {
    context.read<UserProfileBloc>().add(ClearCacheDirectory());
  }

  void _clearMoviesData(BuildContext context) {
    // TODO: реализовать очистку данных о фильмах
  }
}

class _UpdateApiKeyDialog extends StatefulWidget {
  const _UpdateApiKeyDialog();

  @override
  State<_UpdateApiKeyDialog> createState() => _UpdateApiKeyDialogState();
}

class _UpdateApiKeyDialogState extends State<_UpdateApiKeyDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileBloc = context.read<UserProfileBloc>();

    return AlertDialog(
      title: Text('Изменение API Key'),
      content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Введите новый API Key',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onChanged: (_) => setState(() {})),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: controller.text.isEmpty
              ? null
              : () {
                  userProfileBloc.add(UpdateApiKey(updatedApiKey: controller.text));
                  Navigator.pop(context);
                },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}
