import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
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
      backgroundColor: AppColors.primaryThemeBlack,
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
      physics: BouncingScrollPhysics(),
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
    final date = collection.createdAt;

    return InkWell(
      enableFeedback: false,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        context.router.push(CollectionFilmsRoute(
          collectionId: collection.id!,
          collectionName: collection.name!
          ));
        },
          child: Card(
            color: AppColors.primaryThemeGrey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    color: AppColors.primaryScheme,
                    ),
                  child: Icon(Icons.image_not_supported, color: AppColors.primaryThemeGrey, size: 60.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 5.h),
                        Text(
                          collection.name ?? "Название отсутствует", 
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 2,
                          style: CustomTextStyles.m3TitleLarge2(),
                        ),
                        SizedBox(height: 10.h),
                        Text(DataFormatter.formatFilmWordDeclension(collection.filmCount ?? 0), style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme)),
                        SizedBox(height: 10.h),
                        Text("Дата создания: ${_formatDateTime(date)}", style: CustomTextStyles.m3BodyMedium()),
                        ]
                      ),
                  ),
                  PopupMenuButton(
                    color: AppColors.primaryThemeGrey,
                    icon: Icon(Icons.more_vert, color: AppColors.primaryScheme),
                    enableFeedback: false,
                    onSelected: (value) {
                      if(value == "renameCollection") onRename(collection);
                      if(value == "removeCollection") onRemove();
                      if(value == "clearCollection") onClear();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'renameCollection', child: Text("Переименовать коллекцию", style: CustomTextStyles.m3BodyMedium())),
                        PopupMenuItem(value: 'removeCollection', child: Text("Удалить коллекцию", style: CustomTextStyles.m3BodyMedium())),
                        PopupMenuItem(value: 'clearCollection',child: Text("Очистить коллекцию", style: CustomTextStyles.m3BodyMedium()))]
                        )
                      ],
              ),
            ),
          );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Дата не указана';
    
    // Форматируем дату и время
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day.$month.$year $hour:$minute';
  }
}

class _CreateCollectionCard extends StatelessWidget {
  const _CreateCollectionCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        enableFeedback: false,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
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
            color: AppColors.primaryThemeGrey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    color: AppColors.primaryScheme,
                    ),
                  child: Icon(Icons.add, color: AppColors.primaryThemeGrey, size: 60.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 5.h),
                        Text("Новая коллекция", style: CustomTextStyles.m3TitleLarge2()),
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
          backgroundColor: AppColors.primaryThemeBlack,
          title: Text('Новая коллекция', style: CustomTextStyles.m3TitleLarge()),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              maxLength: 24,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Придумайте название',
                border: OutlineInputBorder(),
              ),
              style: CustomTextStyles.m3TitleMedium(),
              autofocus: true,
              onChanged: (_) => setState(() {})
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: CustomTextStyles.m3BodyMedium()),
            ),
            TextButton(
              onPressed: controller.text.isEmpty
              ? null
              : () {
                collectionBloc.add(AddNewCollection(collectionName: controller.text));
                Navigator.pop(context);
              },
              child: Text(
                "Сохранить",
                style: controller.text.isEmpty
                ? CustomTextStyles.m3BodyMedium(color: AppColors.primaryThemeGrey)
                : CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme)
              )
            )
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
          backgroundColor: AppColors.primaryThemeBlack,
          title: Text('Переименовать коллекцию', style: CustomTextStyles.m3TitleLarge()),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              maxLength: 24,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Новое название коллекции',
                border: OutlineInputBorder(),
              ),
              style: CustomTextStyles.m3TitleMedium(),
              autofocus: true,
              onChanged: (_) => setState(() {})
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: CustomTextStyles.m3BodyMedium()),
            ),
            TextButton(
              onPressed: controller.text.isEmpty 
              ? null 
              : () {
                collectionBloc.add(RenameCollection(collection: widget.collection, updatedName: controller.text));
                Navigator.pop(context);
              }, 
              child: Text(
                "Сохранить", 
                style: controller.text.isEmpty 
                ? CustomTextStyles.m3BodyMedium(color: AppColors.primaryThemeGrey)
                : CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme)
              )
            ),
          ],
        );
  }
}
