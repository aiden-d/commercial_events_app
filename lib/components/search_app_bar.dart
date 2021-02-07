import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:amcham_app_v2/constants.dart';

class SearchAppbar extends PreferredSize {
  final Function(String string) searchFunction;
  final Function clearFunction;
  SearchAppbar({@required this.searchFunction, @required this.clearFunction});
  String searchString = '';
  bool isSearching = false;
  String getSearchString() {
    return searchString;
  }

  void setSearchString(String newStr) {
    searchString = newStr;
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0),
      child: AppBar(
        flexibleSpace: SafeArea(
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      controller: TextEditingController(text: searchString),
                      placeholder: 'Search anything...',
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onChanged: (value) {
                        searchString = value;
                      },
                      onSubmitted: (value) {
                        searchFunction(searchString);
                      },
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      CupertinoIcons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      searchFunction(searchString);
                    }),
                IconButton(
                    icon: Icon(
                      CupertinoIcons.xmark_circle,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      clearFunction();
                      isSearching = false;
                      searchString = '';
                      (context as Element).markNeedsBuild();
                    }),
              ],
            ),
          ),
        ),
        backgroundColor: Constants.blueThemeColor,
        actions: [],
      ),
    );
  }
}
