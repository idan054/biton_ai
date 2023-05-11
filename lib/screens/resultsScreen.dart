import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/widgets/resultsCategoriesList.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/themes/app_colors.dart';
import '../widgets/customButton.dart';
import '../widgets/resultsList.dart';

// List<ResultItem> googleResults = [
//   ResultItem(
//       title: 'A A great google result title will appear here',
//       desc:
//       'A A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.googleResults),
//   ResultItem(
//       title: 'B A great google result title will appear here',
//       desc:
//       'B A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.googleResults),
//   ResultItem(
//       title: 'C A great google result title will appear here',
//       desc:
//       'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.googleResults),
// ];

List<ResultModel> titlesResults = [
  ResultModel(
      title: 'A This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles),
  ResultModel(
      title: 'B This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles),
  ResultModel(
      title: 'C This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles)
];

List<ResultModel> shortDescResults = [
  ResultModel(
      title:
          'A This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
  ResultModel(
      title:
          'B This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
  ResultModel(
      title:
          'C This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
];

List<ResultModel> longDescResults = [
  ResultModel(
      title:
          'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. '
          'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. ',
      category: ResultCategory.longDesc),
];

class ResultsScreen extends StatefulWidget {
  final List<ResultModel> googleResults;

  const ResultsScreen(this.googleResults, {Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  var inputController = TextEditingController(text: 'Nike Air Max 90');

  List<ResultModel> selectedResults = [];
  List<ResultModel> currentResults = [];

  ResultModel? lastSelectedResult; // For restore when re-pick

  @override
  void initState() {
    currentResults = [...widget.googleResults];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var googleResult = selectedResults
    //     .firstWhereOrNull((item) => item.category == ResultCategory.googleResults);
    //
    // var horizontalList = selectedResults;
    // if (googleResult != null) horizontalList.remove(googleResult);

    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      body: Row(
        children: [
          buildDrawer(),
          Column(
            children: [
              // 'listTitle'.toText(fontSize: 22, bold: true).px(15).py(5).centerLeft,
              buildUserInput().pOnly(top: 20),
              Divider(color: AppColors.greyLight, thickness: 1, height: 0),

              Builder(builder: (context) {
                return Column(
                  //~ Remove results:
                  children: [
                    // if (googleResult != null)
                    //   ResultsList(
                    //       removeMode: true,
                    //       results: [googleResult],
                    //       onSelect: (result) {
                    //         selectedResults.remove(result);
                    //         _nextAvailableList();
                    //       }),
                    ResultsList(
                        horizontalView: appConfig_horizontalSummery,
                        removeMode: true,
                        results: selectedResults,
                        onSelect: (result) {
                          selectedResults.remove(result);
                          _nextAvailableList();
                        }),
                  ],
                );
              }),

              //~  Add results:
              ResultsList(
                results: currentResults,
                onSelect: (result) {
                  // if (googleResult != null) selectedResults.add(googleResult);

                  _removeIfAlreadySelected(result);
                  selectedResults.add(result);
                  _nextAvailableList();
                },
              ),
            ],
          ).px(30).singleChildScrollView.top.expanded(),
        ],
      ),
    );
  }

  void _removeIfAlreadySelected(ResultModel result) {
    var sItem =
        selectedResults.firstWhereOrNull((item) => item.category == result.category);
    if (sItem != null) selectedResults.remove(sItem);
  }

  void _changeListByCategory(ResultCategory? category) {
    if (category == ResultCategory.googleResults) {
      currentResults = widget.googleResults;
    } else if (category == ResultCategory.titles) {
      currentResults = titlesResults;
    } else if (category == ResultCategory.shortDesc) {
      currentResults = shortDescResults;
    } else if (category == ResultCategory.longDesc) {
      currentResults = longDescResults;
    }

    setState(() {});
  }

  void _nextAvailableList() {
    var selectedCategories =
        selectedResults.map((item) => item.category).toList(growable: true);

    if (!selectedCategories.contains(ResultCategory.googleResults)) {
      currentResults = widget.googleResults;
    } else if (!selectedCategories.contains(ResultCategory.titles)) {
      currentResults = titlesResults;
    } else if (!selectedCategories.contains(ResultCategory.shortDesc)) {
      currentResults = shortDescResults;
    } else if (!selectedCategories.contains(ResultCategory.longDesc)) {
      currentResults = longDescResults;
    }

    setState(() {});
  }

  Drawer buildDrawer() {
    return Drawer(
        backgroundColor: AppColors.white,
        elevation: 0,
        child: Column(
          children: [
            20.verticalSpace,
            betterSeller.toText(fontSize: 25, bold: true).px(25).centerLeft,
            20.verticalSpace,
            ResultsCategoriesList(
              categories: const [
                ResultCategory.googleResults,
                ResultCategory.titles,
                ResultCategory.shortDesc,
                ResultCategory.longDesc,
              ],
              selectedCategory: currentResults.first.category!,
              categoriesNames: const [
                'Google result',
                'Product name',
                'Short Description',
                'Long Description',
              ],
              icons: const [
                Icons.search_rounded,
                Icons.title_rounded,
                Icons.notes_rounded,
                Icons.description_rounded, // subject_rounded
              ],
              onSelect: (category) {
                _changeListByCategory(category);
              },
            ),
            20.verticalSpace,

            // Builder(builder: (context) {
            //   // var i = categories.indexWhere((cat) => cat == selectedCategory);
            //   // var title = i == 3 ? 'Finish' : "(${i + 1}/4) Next";
            //   var title = 'Create Another Product';
            //   return CustomButton(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //     backgroundColor: AppColors.primaryShiny,
            //     title: title,
            //     width: 240,
            //     height: 50,
            //     onPressed: () {
            //       // if (i != 3) {
            //       //   selectedCategory = categories[i + 1];
            //       // } else {}
            //       // setState(() {});
            //     },
            //   );
            // }),
          ],
        ).singleChildScrollView);
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
      backgroundColor: AppColors.greyLight,
      child: Icons.border_color_rounded
          .icon(color: AppColors.primaryShiny, size: 20)
          .center);
}
