import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';

@RoutePage()
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CollectionsBloc>()..add(GetCollections()),
      child: _CollectionsView(),
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Expanded(
                  child: BlocBuilder<CollectionsBloc, CollectionsState>(
                    builder: (context, state) {
                      if (state is CollectionsLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (state is CollectionsFailure) {
                        return Center(child: Text(state.message));
                      }

                      if (state is CollectionsLoaded) {
                        return _CollectionsList(collections: state.collections);
                      }
                      return const SizedBox();
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionsList extends StatelessWidget {
  final List<CollectionEntity> collections;
  const _CollectionsList({required this.collections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: collections.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h), 
      itemBuilder: (context, index) {
        if(index == 0){
          return _CreateCollectionCard();
        }
        final collection = collections[index - 1];
        return _CollectionCard(
          collection: collection,
          onRename: (CollectionEntity collection) => showDialog(
            context: context, 
            builder: (dialogContext) {
              return BlocProvider.value(
                value: context.read<CollectionsBloc>(),
                child: _RenameCollectionDialog(collection: collection)
              );
            }
          ),
          onClear: () => _showConfirmActionDialog(
            context,
            "Очищение коллекции",
            "Вы действительно хотите очистить коллекцию? Содержимое коллекции будет удалено.",
            "Очистить",
            () => _clearCollection(context, collection.id!)
          ),
          onRemove: () => _showConfirmActionDialog(
            context, 
            "Удаление коллекции", 
            "Вы действительно хотите удалить коллекцию? Коллекция и её содержимое будут удалены.", 
            "Удалить", 
            () => _removeCollection(context, collection.id!)
          )
        );
      },
    );
  }

  void _clearCollection(BuildContext context, String collectionId){
    context.read<CollectionsBloc>().add(ClearCollection(collectionId: collectionId));  
  }

  void _removeCollection(BuildContext context, String collectionId){
    context.read<CollectionsBloc>().add(RemoveCollection(collectionId: collectionId));
  }

  void _showConfirmActionDialog(
    BuildContext context, 
    String titleText, 
    String contentText, 
    String actionText, 
    VoidCallback actionFunc
    ){
    showDialog(
      context: context, 
      builder: (dialogContext) {
        return ConfirmAlertDialog(
          titleText: titleText, 
          contentText: contentText, 
          actionText: actionText, 
          actionFunc: actionFunc
        );
      }
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionEntity collection;
  final Function onRename;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  const _CollectionCard({
    required this.collection,
    required this.onRename,
    required this.onRemove,
    required this.onClear
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.router.push(CollectionFilmsRoute(
          collectionId: collection.id!,
          collectionName: collection.name!
          ));
        },
          child: Card(
            color: Colors.white,
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
                        Text(collection.name ?? "Название отсутствует", overflow: TextOverflow.ellipsis, maxLines: 2),
                        SizedBox(height: 10.h),
                        Text("${collection.filmCount} фильмов"),
                        SizedBox(height: 10.h),
                        Text(collection.createdAt.toString()),
                        ]
                      ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.purple),
                    onSelected: (value) {
                      if(value == "renameCollection") onRename(collection);
                      if(value == "removeCollection") onRemove();
                      if(value == "clearCollection") onClear();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'renameCollection', child: Text("Переименовать коллекцию")),
                        PopupMenuItem(value: 'removeCollection', child: Text("Удалить коллекцию")),
                        PopupMenuItem(value: 'clearCollection',child: Text("Очистить коллекцию"))]
                        )
                      ],
              ),
            ),
          );
  }
}

class _CreateCollectionCard extends StatelessWidget {
  const _CreateCollectionCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (dialogContext) {
            return BlocProvider.value(
              value: context.read<CollectionsBloc>(),
              child: const _CreateCollectionDialog()
            );
          },
        ),
        child: Card(
            color: Colors.white,
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
                        SizedBox(height: 5.h),
                        Text("Новая коллекция"),
                        ]
                      ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionBloc = context.read<CollectionsBloc>();

    return AlertDialog(
          title: Text('Новая коллекция'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Придумайте название',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (_) => setState(() {})
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: controller.text.isEmpty
                  ? null
                  : () {
                      collectionBloc.add(AddNewCollection(collectionName: controller.text));
                      Navigator.pop(context);
                    },
              child: Text('Сохранить'),
            ),
          ],
        );
  }
}


class _RenameCollectionDialog extends StatefulWidget {
  const _RenameCollectionDialog({required this.collection});

  final CollectionEntity collection;

  @override
  State<_RenameCollectionDialog> createState() => _RenameCollectionDialogState();
}

class _RenameCollectionDialogState extends State<_RenameCollectionDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionBloc = context.read<CollectionsBloc>();

    return AlertDialog(
          title: Text('Переименовать коллекцию'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Новое название коллекции',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (_) => setState(() {})
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: controller.text.isEmpty
                  ? null
                  : () {
                      collectionBloc.add(RenameCollection(collection: widget.collection, updatedName: controller.text));
                      Navigator.pop(context);
                    },
              child: Text('Сохранить'),
            ),
          ],
        );
  }
}
