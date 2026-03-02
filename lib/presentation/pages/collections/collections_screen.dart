import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';

@RoutePage()
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final _collectionsBloc = getIt<CollectionsBloc>();

  @override
  void initState() {
    super.initState();
    _collectionsBloc.add(DisplayCollections());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Коллекции",
            style: TextStyle(
                color: Colors.white, overflow: TextOverflow.ellipsis)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: BlocConsumer<CollectionsBloc, CollectionsState>(
                bloc: _collectionsBloc,
                listener: (context, state) {
                  if(state is CollectionRemovedSuccessful){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Коллекция успешно удалена"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  if(state is CollectionAddedSuccessful){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Коллекция успешно добавлена"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  if(state is CollectionRemovedFailure){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Коллекцию не удалось удалить"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  if(state is CollectionAddedFailure){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Коллекцию не удалось добавить"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return BlocBuilder<CollectionsBloc, CollectionsState>(
                      bloc: _collectionsBloc,
                      builder: (context, state) {
                        if (state is CollectionsLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is CollectionsLoadedFailure) {
                          return Center(
                              child: Text(
                                  "${state.exceptionType} ${state.statusCode}"));
                        }

                        if (state is CollectionsLoadedSuccesful) {
                          return _buildCollections(state);
                        }

                        return SizedBox();
                      });
                },
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollections(CollectionsLoadedSuccesful state) {
    final collections = state.collections;

    return ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () {
                _showCreateCollectionDialog();
              },
              child: Card(
                color: Colors.grey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 120.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Новая коллекция",
                                overflow: TextOverflow.ellipsis, maxLines: 2),
                          ]),
                    ),
                  ],
                ),
              ),
            );
          }

          final collection = collections[index - 1];

          return InkWell(
            onTap: () {
              if (collection.name != null) {
                // TODO: Переход на экран списка фильмов в коллекции

                // context.router.push(FilmInformationRoute(filmId: savedFilm.kinopoiskId!));
              } else {
                // TODO: Реализовать отображение Toast
                log("collection.collectionName == null");
              }
            },
            child: Card(
              color: Colors.grey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.w),
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 5.h),
                          Text(collection.name ?? "Название отсутствует",
                              overflow: TextOverflow.ellipsis, maxLines: 2),
                          SizedBox(height: 10.h),
                          Text("${collection.filmCount} фильмов"),
                          SizedBox(height: 10.h),
                          Text(collection.createdAt.toString()),
                        ]),
                  ),
                  PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.purple),
                      onSelected: (value) {
                        switch (value) {
                          case ("removeCollection"):
                            {
                              _collectionsBloc.add(RemoveCollection(
                                  collectionId: collection.id!));
                            }
                          case ("clearCollection"):
                            {}
                        }
                      },
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 'removeCollection',
                                child: Text("Удалить коллекцию")),
                            PopupMenuItem(
                                value: 'clearCollection',
                                child: Text("Очистить коллекцию"))
                          ])
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: state.collections.length + 1);
  }

  void _showCreateCollectionDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Новая коллекция'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Придумайте название',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _collectionsBloc
                      .add(AddNewCollection(nameCollection: controller.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
