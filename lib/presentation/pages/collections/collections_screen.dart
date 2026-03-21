import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';

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
      appBar: AppBar(
        title: Text("Коллекции", style: TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis)),
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
                listener: _collectionBlocListener,
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

  void _collectionBlocListener(BuildContext context, CollectionsState state){
    if(state is CollectionActionFailure){
      _showSnackBar(context, state.message, Colors.red);
    }

    if(state is CollectionAddedSuccess ||
       state is CollectionRemovedSuccess ||
       state is CollectionClearedSuccess) {
      final message = (state as dynamic).message;
      _showSnackBar(context, message, Colors.green);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _CollectionsList extends StatelessWidget {
  final List<CollectionEntity> collections;
  const _CollectionsList({required this.collections});

  @override
  Widget build(BuildContext context) {
    final collectionBloc = context.read<CollectionsBloc>();

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
          onClear: () => collectionBloc.add(ClearCollection(collectionId: collection.id!)),
          onRemove: () => collectionBloc.add(RemoveCollection(collectionId: collection.id!)),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionEntity collection;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  const _CollectionCard({
    required this.collection,
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
                      if(value == "removeCollection") onRemove();
                      if(value == "clearCollection") onClear();
                      },
                      itemBuilder: (_) => const [
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
