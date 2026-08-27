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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasFocus ? AppColors.primaryScheme : Colors.white.withValues(alpha: 0.12),
          width: _hasFocus ? 1.4 : 1,
        ),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryScheme.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryThemeGrey.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasFocus
                      ? IconButton(
                          key: const ValueKey('back'),
                          onPressed: () {
                            _focusNode.unfocus();
                          },
                          icon: Icon(Icons.arrow_back, color: AppColors.primaryScheme),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : Center(
                          key: const ValueKey('search_icon'),
                          child: Icon(
                            Icons.search,
                            color: _hasFocus ? AppColors.primaryScheme : AppColors.secondaryThemeGrey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
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
                    if (widget.useRealTimeChange) {
                      widget.onSearchSubmitted(_searchController.text, context);
                    }
                  },
                  cursorColor: AppColors.primaryScheme,
                  style: CustomTextStyles.m3ActionText(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintStyle: CustomTextStyles.m3ActionText(color: AppColors.textDarkGrey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: widget.useFilterButton
                      ? _hasFocus
                          ? IconButton(
                              key: const ValueKey('clear'),
                              onPressed: () {
                                _clearText();
                              },
                              icon: Icon(Icons.clear, color: AppColors.primaryScheme),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : IconButton(
                              key: const ValueKey('filter'),
                              onPressed: () {
                                _clearText();
                                if (widget.useFilterButton) {
                                  widget.onFilterSubmitted!(context);
                                }
                              },
                              icon: Icon(Icons.filter_alt_outlined, color: AppColors.primaryScheme),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                      : _hasFocus
                          ? IconButton(
                              key: const ValueKey('clear'),
                              onPressed: () {
                                _clearText();
                              },
                              icon: Icon(Icons.clear, color: AppColors.primaryScheme),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}