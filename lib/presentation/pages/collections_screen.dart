import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/image_path_resolver.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_search_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/text_field_alert_dialog.dart';

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
          padding: EdgeInsetsGeometry.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
                        return _SearchCollectionContent(collections: state.collections);
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

class _SearchCollectionContent extends StatefulWidget {
  final List<CollectionEntity> collections;

  const _SearchCollectionContent({required this.collections});

  @override
  State<_SearchCollectionContent> createState() => _SearchCollectionContentState();
}

class _SearchCollectionContentState extends State<_SearchCollectionContent> {
  String _searchKeyword = '';

  void onSearchSubmitted(String keyword, BuildContext context) {
    setState(() {
      _searchKeyword = keyword.toLowerCase();
    });
  }

  List<CollectionEntity> _getFilteredCollections(List<CollectionEntity> collections) {
    if (_searchKeyword.isEmpty) {
      return collections;
    }
    return collections.where((collection) {
      final collectionName = collection.name?.toLowerCase() ?? '';
      return collectionName.contains(_searchKeyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        List<CollectionEntity> displayedCollections = [];
        
        if (state is CollectionsLoaded) {
          displayedCollections = _getFilteredCollections(state.collections);
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSearchBar(
              onSearchSubmitted: onSearchSubmitted,
              useFilterButton: false,
              useRealTimeChange: true,
              onClear: () {
                setState(() {
                  _searchKeyword = '';
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _CollectionsList(collections: displayedCollections)
            ),
          ],
        );
      },
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
      separatorBuilder: (_, __) => const SizedBox(height: 12), 
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
                child: TextFieldAlertDialog(
                  titleText: 'Переименовать коллекцию', 
                  hintText: 'Новое название коллекции', 
                  maxLenght: 24,
                  maxLines: 1, 
                  actionText: "Сохранить", 
                  actionFunc: (controllerText) => context.read<CollectionsBloc>().add(RenameCollection(collection: collection, updatedName: controllerText))
                )
              );
            }
          ),
          onClear: () => _showConfirmActionDialog(
            context,
            "Очищение коллекции",
            Text.rich(
                TextSpan(
                  style: CustomTextStyles.m3Content(),
                  children: [
                    const TextSpan(text: "Вы действительно хотите "),
                    TextSpan(text: "очистить", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: " коллекцию? Содержимое коллекции будет "),
                    TextSpan(text: "удалено.", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                  ],
                ),
              ),
            "Очистить",
            () => _clearCollection(context, collection.id!)
          ),
          onUpload: () => _uploadCollectionImage(context, collection),
          onRemoveImage: () => _showConfirmActionDialog(
            context,
            "Удаление обложки",
            Text.rich(
                TextSpan(
                  style: CustomTextStyles.m3Content(),
                  children: [
                    const TextSpan(text: "Вы действительно хотите "),
                    TextSpan(text: "удалить", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: " обложку коллекции?"),
                  ],
                ),
              ),
            "Удалить",
            () => _removeCollectionImage(context, collection)
          ),
          onRemove: () => _showConfirmActionDialog(
            context, 
            "Удаление коллекции",
            Text.rich(
                TextSpan(
                  style: CustomTextStyles.m3Content(),
                  children: [
                    const TextSpan(text: "Вы действительно хотите"),
                    TextSpan(text: "удалить", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: " коллекцию? Коллекция и её содержимое будут "),
                    TextSpan(text: "удалены", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                    const TextSpan(text: "."),
                  ],
                ),
              ),  
            "Удалить", 
            () => _removeCollection(context, collection.id!)
          ),
        );
      },
    );
  }

  void _clearCollection(BuildContext context, String collectionId){
    context.read<CollectionsBloc>().add(ClearCollection(collectionId: collectionId));  
  }

  void _uploadCollectionImage(BuildContext context, CollectionEntity collection){
    context.read<CollectionsBloc>().add(UploadCollectionImage(collection: collection));
  }

  void _removeCollectionImage(BuildContext context, CollectionEntity collection){
    context.read<CollectionsBloc>().add(RemoveCollectionImage(collection: collection));
  }

  void _removeCollection(BuildContext context, String collectionId){
    context.read<CollectionsBloc>().add(RemoveCollection(collectionId: collectionId));
  }

  void _showConfirmActionDialog(
    BuildContext context, 
    String titleText, 
    Widget content, 
    String actionText, 
    VoidCallback actionFunc
    ){
    showDialog(
      context: context, 
      builder: (dialogContext) {
        return ConfirmAlertDialog(
          titleText: titleText, 
          content: content, 
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
  final Function onUpload;
  final VoidCallback onRemoveImage;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  const _CollectionCard({
    required this.collection,
    required this.onRename,
    required this.onUpload,
    required this.onRemoveImage,
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
                  _CollectionCoverImage(imagePath: collection.imagePath),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          collection.name ?? "Название отсутствует", 
                          overflow: TextOverflow.ellipsis, 
                          maxLines: 2,
                          style: CustomTextStyles.m3Title().copyWith(
                            fontSize: 17
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(DataFormatter.formatFilmWordDeclension(collection.filmCount ?? 0), style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
                        const SizedBox(height: 10),
                        Text("Дата создания: ${DataFormatter.formatDateTime(date)}", style: CustomTextStyles.m3Body()),
                        ]
                      ),
                  ),
                  PopupMenuButton(
                    color: AppColors.primaryThemeGrey,
                    icon: Icon(Icons.more_vert, color: AppColors.primaryScheme),
                    enableFeedback: false,
                    onSelected: (value) {
                      if(value == "renameCollection") onRename(collection);
                      if(value == "uploadImage") onUpload();
                      if(value == "removeImage") onRemoveImage();
                      if(value == "removeCollection") onRemove();
                      if(value == "clearCollection") onClear();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'renameCollection', child: Text("Переименовать коллекцию", style: CustomTextStyles.m3Body())),
                        PopupMenuItem(value: 'uploadImage', child: Text("Поменять обложку", style: CustomTextStyles.m3Body())),
                        if (collection.imagePath != null && collection.imagePath!.isNotEmpty)
                          PopupMenuItem(value: 'removeImage', child: Text("Удалить обложку", style: CustomTextStyles.m3Body())),
                        PopupMenuItem(value: 'removeCollection', child: Text("Удалить коллекцию", style: CustomTextStyles.m3Body())),
                        PopupMenuItem(value: 'clearCollection',child: Text("Очистить коллекцию", style: CustomTextStyles.m3Body()))] 
                        )
                      ],
              ),
            ),
          );
  }
}

class _CollectionCoverImage extends StatelessWidget {
  final String? imagePath;

  const _CollectionCoverImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _placeholder();
    }

    final file = File(ImagePathResolver.resolveCollection(imagePath!));

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        key: ValueKey(imagePath),
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.primaryScheme,
      ),
      child: Icon(
        Icons.image_not_supported,
        color: AppColors.primaryThemeGrey,
        size: 60,
      ),
    );
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
              child: TextFieldAlertDialog(
                titleText: 'Новая коллекция', 
                hintText: 'Придумайте название', 
                maxLenght: 24,
                maxLines: 1, 
                actionText: "Сохранить", 
                actionFunc: (controllerText) => context.read<CollectionsBloc>().add(AddNewCollection(collectionName: controllerText))
              )
            );
          },
        ),
        child: Card(
            color: AppColors.primaryThemeGrey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primaryScheme,
                    ),
                  child: Icon(Icons.add, color: AppColors.primaryThemeGrey, size: 60),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Text("Новая коллекция", style: CustomTextStyles.m3Title().copyWith(fontSize: 17)),
                        ]
                      ),
                  ),
                ],
              ),
            ),
    );
  }
}
