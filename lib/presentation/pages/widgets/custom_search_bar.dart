import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onSearchSubmitted,
    this.onFilterSubmitted,
    this.onAiAssistantSubmitted,
    required this.useFilterButton,
    required this.useRealTimeChange,
    this.onClear,
    this.textInputAction,
    this.focusNode,
  });

  final Function(String keyword, BuildContext context) onSearchSubmitted;
  final Function(BuildContext context)? onFilterSubmitted;
  final Function(BuildContext context)? onAiAssistantSubmitted;
  final bool useFilterButton;
  final bool useRealTimeChange;
  final VoidCallback? onClear;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  static const double _buttonSize = 40;
  static const Duration _animDuration = Duration(milliseconds: 200);

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

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _clearText() {
    _searchController.clear();
    _focusNode.unfocus();
    widget.onClear?.call();
  }

  Widget _buttonSlot({
    required bool visible,
    required Widget child,
    double? right,
  }) {
    return Positioned(
      right: right,
      top: 0,
      bottom: 0,
      width: _buttonSize,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: _animDuration,
          curve: Curves.easeOut,
          opacity: visible ? 1 : 0,
          child: AnimatedScale(
            duration: _animDuration,
            curve: Curves.easeOut,
            scale: visible ? 1 : 0.7,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primaryScheme),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: _buttonSize,
        height: _buttonSize,
      ),
    );
  }

  Widget _buildLeading() {
    return TextFieldTapRegion(
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: _animDuration,
                  opacity: _hasFocus ? 0 : 1,
                  child: AnimatedScale(
                    duration: _animDuration,
                    scale: _hasFocus ? 0.7 : 1,
                    child: Icon(
                      Icons.search,
                      color: AppColors.secondaryThemeGrey,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_hasFocus,
                child: AnimatedOpacity(
                  duration: _animDuration,
                  opacity: _hasFocus ? 1 : 0,
                  child: AnimatedScale(
                    duration: _animDuration,
                    scale: _hasFocus ? 1 : 0.7,
                    child: _iconButton(
                      icon: Icons.arrow_back,
                      onPressed: _focusNode.unfocus,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    final double width = widget.useFilterButton ? _buttonSize * 2 : _buttonSize;

    return TextFieldTapRegion(
      child: SizedBox(
        width: width,
        height: _buttonSize,
        child: Stack(
          children: [
            if (widget.useFilterButton) ...[
              _buttonSlot(
                right: _buttonSize,
                visible: !_hasFocus,
                child: _iconButton(
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    _clearText();
                    widget.onAiAssistantSubmitted?.call(context);
                  },
                ),
              ),
              _buttonSlot(
                right: 0,
                visible: !_hasFocus,
                child: _iconButton(
                  icon: Icons.filter_alt_outlined,
                  onPressed: () {
                    _clearText();
                    widget.onFilterSubmitted?.call(context);
                  },
                ),
              ),
            ],
            _buttonSlot(
              right: 0,
              visible: _hasFocus,
              child: _iconButton(
                icon: Icons.clear,
                onPressed: _clearText,
              ),
            ),
          ],
        ),
      ),
    );
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
          color: _hasFocus
              ? AppColors.primaryScheme
              : Colors.white.withValues(alpha: 0.12),
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
              _buildLeading(),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  textInputAction: widget.textInputAction,
                  onEditingComplete: () => _focusNode.unfocus(),
                  onTapOutside: (event) => _focusNode.unfocus(),
                  onSubmitted: (keyword) {
                    if (keyword.isEmpty) return;
                    _searchController.text = _searchController.text.trim();
                    widget.onSearchSubmitted(_searchController.text, context);
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
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }
}