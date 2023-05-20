// ignore_for_file: no_leading_underscores_for_local_identifiers, curly_braces_in_flow_control_structures

import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/screens/homeScreen.dart';
import 'package:biton_ai/widgets/htmlEditorViewerWidget.dart';
import 'package:biton_ai/widgets/resultsCategoriesList.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/services/gpt_service.dart';
import '../common/themes/app_colors.dart';
import '../widgets/customButton.dart';
import '../widgets/resultsList.dart';

List<String> promptsByType(
    ResultCategory type, String input, List<WooPostModel> promptsBase) {
  var promptList = <String>[];
  int limit = 0;
  // useSelected if available
  bool useSelected = promptsBase.any((item) => item.category == type && item.isSelected);
  String prompt = promptsBase
      .firstWhere((item) =>
          item.category == type && (useSelected ? item.isSelected : item.isDefault))
      .content;
  if (type == ResultCategory.gResults) limit = 3;
  if (type == ResultCategory.titles) limit = 3;
  if (type == ResultCategory.shortDesc) limit = 3;
  if (type == ResultCategory.longDesc) limit = 1;
  for (int i = 0; i < limit; i++) promptList.add(prompt);
  return promptList;
}

class ResultsScreen extends StatefulWidget {
  final String input;
  final List<ResultModel> googleResults;
  final List<WooPostModel> promptsBase;

  const ResultsScreen(this.input, this.googleResults, this.promptsBase, {Key? key})
      : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isAdvancedSwitchOn = false;

  var inputController = TextEditingController();
  String exampleUrl = '';
  List<ResultModel> titlesResults = [];
  List<ResultModel> googleResults = [];
  List<ResultModel> shortDescResults = [];
  List<ResultModel> longDescResults = [];

  List<ResultModel> selectedResults = []; // Top List (Remove)
  // List<ResultModel> currentResults = []; // Bottom List (Add)

  @override
  void initState() {
    googleResults = [...widget.googleResults];
    // currentResults = googleResults;
    // autoFetchResults(ResultCategory.gResults);
    autoFetchResults(ResultCategory.longDesc);
    autoFetchResults(ResultCategory.titles);
    autoFetchResults(ResultCategory.shortDesc);

    exampleUrl = _getUrl(widget.input);
    inputController.text = widget.input;
    super.initState();
  }

  void autoFetchResults(ResultCategory type) async {
    // var n = type == ResultCategory.longDesc ? 1 : 3;
    print('START: autoFetchResults() ${type.name}');

    var _promptList = promptsByType(type, widget.input, widget.promptsBase);
    final results = await Gpt.getResults(
        type: type, input: widget.input, prompts: _promptList, gDescPrompts: _promptList);

    // if (type == ResultCategory.gResults) googleResults = [...googleResults, ...results];
    if (type == ResultCategory.titles) titlesResults = results;
    if (type == ResultCategory.shortDesc) shortDescResults = results;
    if (type == ResultCategory.longDesc) longDescResults = results;
    setState(() {});
  }

  ResultModel? lastSelectedResult; // For restore when re-pick
  ResultCategory drawerCategory = ResultCategory.gResults;

  Widget buildCardsRow(List<ResultModel> currList) {
    if (currList.isEmpty) {
      return Column(
        children: [
          if (drawerCategory == ResultCategory.longDesc)
            'Finish writing product article... (it can take up to 60 seconds)'
                .toText(color: AppColors.greyText, fontSize: 18)
                .py(10)
                .px(30)
                .centerLeft
                .appearAll,
          const CircularProgressIndicator(
            strokeWidth: 7,
            color: AppColors.primaryShiny,
          ).pOnly(top: 100).center,
        ],
      );
    }

    if (currList.first.category == ResultCategory.longDesc) {
      return SizedBox(
        height: 600,
        child: HtmlEditorViewer(kDebugMode && appConfig_fastHomeScreen
            ? googleResults.first.title
            : longDescResults.first.title),
      ).pOnly(left: 20, right: 40, top: 20);
    }

    return ResultsList(
      exampleUrl: exampleUrl,
      results: currList,
      onChange: (results, sResult) {
        _updateNeededList(currList, results, sResult);
      },
      onSelect: (result) {
        selectedResults.add(result);
        _nextAvailableList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var sCategoryItems =
        selectedResults.map((item) => item.category).toList(growable: true);

    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      body: Stack(
        children: [
          Row(
            children: [
              buildDrawer().appearAll,

              Column(
                children: [
                  // buildUserInput().pOnly(top: 20),
                  // Divider(color: AppColors.greyLight, thickness: 1, height: 0),

                  buildCardsRow(googleResults),
                  if (sCategoryItems.contains(ResultCategory.gResults))
                    buildCardsRow(titlesResults),
                  if (sCategoryItems.contains(ResultCategory.titles))
                    buildCardsRow(shortDescResults),
                  if (sCategoryItems.contains(ResultCategory.shortDesc))
                    buildCardsRow(longDescResults),
                  const SizedBox(height: 20)
                ],
              ).px(30).singleChildScrollView.top.pOnly(top: 80).expanded(),
            ],
          ),

          //~ DEMO BAR - BETA
          TweenAnimationBuilder(
              duration: const Duration(milliseconds: 850),
              tween:
                  // Tween(begin: const Offset(00.0, 420.0), end: const Offset(0.0, 420.0)),
                  Tween(begin: const Offset(00.0, 420.0), end: const Offset(110.0, 20.0)),
              builder: (BuildContext context, Offset value, Widget? child) {
                return Transform.translate(
                  offset: value,
                  child: buildMainBar(context,
                          isLoading: false,
                          searchController: inputController,
                          suffixIcon: 'Create'
                              .toText(
                                  color: AppColors.primaryShiny.withOpacity(0.40),
                                  medium: true,
                                  fontSize: 14)
                              .px(20)
                              .py(15),
                          prefixIcon: Icons.tune
                              .icon(color: AppColors.greyText.withOpacity(0.30)))
                      .top,
                );
              }),
        ],
      ),
    );
  }

  // void _removeIfAlreadySelected(ResultModel result) {
  //   var sItem =
  //       selectedResults.firstWhereOrNull((item) => item.category == result.category);
  //   if (sItem != null) selectedResults.remove(sItem);
  // }

  void _changeListByCategory(ResultCategory? category) {
    print('START: _changeListByCategory()');
    if (category == ResultCategory.gResults) {
      drawerCategory = ResultCategory.gResults;
      // currentResults = googleResults;
    } else if (category == ResultCategory.titles) {
      drawerCategory = ResultCategory.titles;
      // currentResults = titlesResults;
    } else if (category == ResultCategory.shortDesc) {
      drawerCategory = ResultCategory.shortDesc;
      // currentResults = shortDescResults;
    } else if (category == ResultCategory.longDesc) {
      drawerCategory = ResultCategory.longDesc;
      // currentResults = longDescResults;
    }

    setState(() {});
  }

  void _nextAvailableList() {
    var selectedCategories =
        selectedResults.map((item) => item.category).toList(growable: true);

    if (!selectedCategories.contains(ResultCategory.gResults)) {
      drawerCategory = ResultCategory.gResults;
      // currentResults = googleResults;
    } else if (!selectedCategories.contains(ResultCategory.titles)) {
      drawerCategory = ResultCategory.titles;
      // currentResults = titlesResults;
    } else if (!selectedCategories.contains(ResultCategory.shortDesc)) {
      drawerCategory = ResultCategory.shortDesc;
      // currentResults = shortDescResults;
    } else if (!selectedCategories.contains(ResultCategory.longDesc)) {
      drawerCategory = ResultCategory.longDesc;
      // currentResults = longDescResults;
    }
    // print('currentResults ${currentResults}');
    setState(() {});
  }

  void _updateNeededList(
      List<ResultModel> currList, List<ResultModel> results, ResultModel sResult) {
    var currCategory = currList.first.category;
    print('START: _updateNeededList() [${currCategory?.name.toString().toUpperCase()}]');

    if (currCategory == ResultCategory.gResults) {
      googleResults = results;
      var oldSResult =
          selectedResults.firstWhere((r) => r.category == ResultCategory.gResults);
      selectedResults.remove(oldSResult);
      selectedResults.add(sResult);
      //
    } else if (currCategory == ResultCategory.titles) {
      titlesResults = results;
      var oldSResult =
          selectedResults.firstWhere((r) => r.category == ResultCategory.titles);
      selectedResults.remove(oldSResult);
      selectedResults.add(sResult);
      //
    } else if (currCategory == ResultCategory.shortDesc) {
      shortDescResults = results;
      var oldSResult =
          selectedResults.firstWhere((r) => r.category == ResultCategory.shortDesc);
      selectedResults.remove(oldSResult);
      selectedResults.add(sResult);
      //
    } else if (currCategory == ResultCategory.longDesc) {
      longDescResults = results;
      var oldSResult =
          selectedResults.firstWhere((r) => r.category == ResultCategory.longDesc);
      selectedResults.remove(oldSResult);
      selectedResults.add(sResult);
    }
    // print('currentResults ${currentResults}');
    // setState(() {});
  }

  String _getUrl(String input) {
    final formattedInput = input.toLowerCase().replaceAll(' ', '-');
    final url = 'www.example.com/$formattedInput';
    return url;
  }

  Widget buildDrawer() {
    return Drawer(
        backgroundColor: AppColors.white,
        elevation: 0,
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                20.verticalSpace,
                textStoreAi.toText(fontSize: 25, bold: true).px(25).centerLeft,
                20.verticalSpace,
              ],
            ).onTap(
                () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                radius: 5),
            ResultsCategoriesList(
              categories: const [
                ResultCategory.gResults,
                ResultCategory.titles,
                ResultCategory.shortDesc,
                ResultCategory.longDesc,
              ],
              categoriesNames: const [
                'Google result',
                'Product name',
                'Short Description',
                'Long Description',
              ],
              selectedCategory: drawerCategory,
              icons: const [
                Icons.search_rounded,
                Icons.title_rounded,
                Icons.notes_rounded,
                Icons.description_rounded, // subject_rounded
              ],
              onSelect: (category) {
                // Clickable category:
                // _changeListByCategory(category);
              },
            ),
            const Spacer(),

            //? todo UI Ready But not works yet!
            // Builder(builder: (context) {
            //   var color = isAdvancedSwitchOn
            //       ? AppColors.secondaryBlue
            //       : AppColors.greyUnavailable80;
            //   return Card(
            //     color: Colors.grey[100],
            //     elevation: 0,
            //     shape: 10.roundedShape,
            //     child: ListTile(
            //         onTap: () {},
            //         horizontalTitleGap: 0,
            //         trailing: Switch(
            //           value: isAdvancedSwitchOn,
            //           activeColor: AppColors.secondaryBlue,
            //           onChanged: (bool value) {
            //             isAdvancedSwitchOn = value;
            //             setState(() {});
            //           },
            //         ),
            //         leading:
            //             Icons.settings_suggest.icon(color: color, size: 22).pOnly(top: 5),
            //         // 'Advanced mode'
            //         title: (isAdvancedSwitchOn ? 'Custom mode' : 'Default mode')
            //             .toString()
            //             .toText(medium: true, color: color, fontSize: 15),
            //         subtitle: 'Try for better results'
            //             // subtitle: 'Your prompts for better results'
            //             .toString()
            //             .toText(color: color, fontSize: 13)
            //         // onTap: () => onTap(category),
            //         ),
            //   ).px(10);
            // }),

            20.verticalSpace,
          ],
        ));
  }

  TextField buildUserInput() {
    return TextField(
      controller: inputController,
      style:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
      decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyLight),
            borderRadius: BorderRadius.circular(3),
          ),
          hintText: 'Enter full product name',
          // hintStyle: const
          suffixIcon: buildEditIcon().px(12).py(12)
          // .onTap(() {}),
          ),
    );
  }
}

CircleAvatar buildEditIcon() {
  return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.transparent,
      child: Icons.border_color_rounded
          .icon(color: AppColors.primaryShiny, size: 20)
          .center);
}
