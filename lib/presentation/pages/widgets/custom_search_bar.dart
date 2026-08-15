import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onSearchSubmitted,
    this.onFilterSubmitted,
    required this.useFilterButton,
    required this.useRealTimeChange,
    this.onClear,
    this.textInputAction,
    this.focusNode
  });

  final Function(String keyword, BuildContext context) onSearchSubmitted;
  final Function(BuildContext context)? onFilterSubmitted;
  final bool useFilterButton;
  final bool useRealTimeChange;
  final VoidCallback? onClear;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange(){
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _clearText() {
    _searchController.clear();
    _focusNode.unfocus();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryThemeGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
                child: _hasFocus
                  ? IconButton(
                    onPressed: () {
                      _focusNode.unfocus();
                    }, 
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryScheme))
                  : Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, color: AppColors.secondaryThemeGrey),
                  )
            ),
            Expanded(
                child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textInputAction: widget.textInputAction,
              onEditingComplete: () {
                _focusNode.unfocus();
              },
              onTapOutside: (event) {
                _focusNode.unfocus();
              },
              onSubmitted: (keyword) {
                if (keyword == "") {
                  return;
                } else {
                  widget.onSearchSubmitted(_searchController.text, context);
                  //_clearText();
                }
              },
              onChanged: (keyword) {
                if(widget.useRealTimeChange) {
                  widget.onSearchSubmitted(_searchController.text, context);
                }
              },
              cursorColor: AppColors.primaryScheme,
              style: CustomTextStyles.m3ActionText(),
              decoration: InputDecoration(border: InputBorder.none),
            )),
            Padding(
                padding: EdgeInsets.only(left: 5, right: 0),
                child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 100),
                    child: widget.useFilterButton
                    ? _hasFocus
                      ? IconButton(
                          key: ValueKey('clear'),
                          onPressed: () {
                            _clearText();
                          },
                          icon: Icon(Icons.clear, color: AppColors.primaryScheme)
                        )
                      : IconButton(
                          key: ValueKey('filter'),
                          onPressed: () {
                            _clearText();
                            if(widget.useFilterButton){
                              widget.onFilterSubmitted!(context);
                            }
                          },
                          icon: Icon(Icons.filter_alt_outlined, color: AppColors.primaryScheme)
                        )
                    : _hasFocus 
                      ? IconButton(
                          key: ValueKey('clear'),
                          onPressed: () {
                            _clearText();
                          },
                          icon: Icon(Icons.clear, color: AppColors.primaryScheme)
                        )
                      : const SizedBox()
            ))
          ],
        ),
      ),
    );
  }
}

