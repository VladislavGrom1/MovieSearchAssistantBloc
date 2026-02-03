import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onSearchSubmitted,
    required this.onFilterSubmitted
  });

  final Function(String keyword) onSearchSubmitted;
  final Function() onFilterSubmitted;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8.w),
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
                    icon: Icon(Icons.arrow_back, color: Colors.purple))
                  : Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Icon(Icons.search, color: Colors.black),
                  )
            ),
            Expanded(
                child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
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
                  widget.onSearchSubmitted(_searchController.text);
                  _clearText();
                }
              },
              cursorColor: Colors.black,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              decoration: InputDecoration(border: InputBorder.none),
            )),
            Padding(
                padding: EdgeInsets.only(left: 5.w, right: 0.w),
                child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 100),
                    child: _hasFocus
                    ? IconButton(
                        key: ValueKey('clear'),
                        onPressed: () {
                          _clearText();
                        },
                        icon: Icon(Icons.clear, color: Colors.purple)
                      )
                    : IconButton(
                        key: ValueKey('filter'),
                        onPressed: () {
                          _clearText();
                          widget.onFilterSubmitted();
                        },
                        icon: Icon(Icons.filter_alt_outlined, color: Colors.purple)
                      )
            ))
          ],
        ),
      ),
    );
  }
}