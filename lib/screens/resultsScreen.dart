import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/widgets/resultsCategoriesList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants.dart';
import '../common/themes/app_colors.dart';
import '../widgets/customButton.dart';
import '../widgets/resultsList.dart';

List<ResultItem> googleResults = [
  ResultItem(
      title: 'A A great google result title will appear here',
      desc:
          'A A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.googleResults),
  ResultItem(
      title: 'B A great google result title will appear here',
      desc:
          'B A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.googleResults),
  ResultItem(
      title: 'C A great google result title will appear here',
      desc:
          'C A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.googleResults),
];

List<ResultItem> titlesResults = [
  ResultItem(
      title: 'A This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles),
  ResultItem(
      title: 'B This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles),
  ResultItem(
      title: 'C This is just a product title example for Nike Air Max 90',
      category: ResultCategory.titles)
];

List<ResultItem> shortDescResults = [
  ResultItem(
      title:
          'A This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
  ResultItem(
      title:
          'B This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
  ResultItem(
      title:
          'C This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
      category: ResultCategory.shortDesc),
];

List<ResultItem> longDescResults = [
  ResultItem(
      title:
          'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. '
          'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. ',
      category: ResultCategory.longDesc),
];

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  var categoryList = const [
    ResultCategory.googleResults,
    ResultCategory.titles,
    ResultCategory.shortDesc,
    ResultCategory.longDesc,
  ];
  var selectedCategory = ResultCategory.googleResults;

  bool isFinish = false;
  bool reSelectMode = false; // When user deselect to choose again
  var inputController = TextEditingController(text: 'Nike Air Max 90');

  List<ResultItem> selectedResults = [];
  List<ResultItem> currentResults = [...googleResults];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      body: Row(
        children: [
          buildDrawer(),
          Column(
            children: [
              // 'listTitle'.toText(fontSize: 22, bold: true).px(15).py(5).centerLeft,
              TextField(
                controller: inputController,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    hintText: 'Enter full product name',
                    // hintStyle: const
                    suffixIcon: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.greyLight,
                            child: Icons.border_color_rounded
                                .icon(color: AppColors.primaryShiny, size: 20)
                                .center)
                        .px(12)
                        .py(12)
                    // .onTap(() {}),
                    ),
              ).pOnly(top: 20),
              Divider(color: AppColors.greyLight, thickness: 1, height: 0),

              // Summarize
              // ResultsList(
              //     resultsMode: true,
              //     results: selectedResults,
              //     onSelect: (result) {
              //       if (reSelectMode) return; // When already in
              //
              //       reSelectMode = true;
              //       var i = categoryList.indexWhere((cat) => cat == selectedCategory);
              //       var previousCategory = categoryList[i - 1];
              //       selectedCategory = previousCategory;
              //       selectedResults.remove(result);
              //       _handleUpdateResultsList(result, reverse: true);
              //       setState(() {});
              //     }),

              ResultsList(
                results: titlesResults,
                onSelect: (result) {
                  // reSelectMode = false;
                  // _handleUpdateResultsList(result);
                  // // Before done
                  // if (result.category != ResultCategory.longDesc) {
                  //   var i = categoryList.indexWhere((cat) => cat == result.category);
                  //   var nextCategory = categoryList[i + 1];
                  //   selectedCategory = nextCategory;
                  //   selectedResults.add(result);
                  // }
                  //
                  // setState(() {});
                },
              ),
            ],
          ).px(30).singleChildScrollView.top.expanded(),
        ],
      ),
    );
  }

  void _handleUpdateResultsList(
    ResultItem result, {
    bool reverse = false,
  }) {
    if (result.category == ResultCategory.googleResults) {
      currentResults = reverse ? googleResults : titlesResults;
    } else if (result.category == ResultCategory.titles) {
      currentResults = reverse ? titlesResults : shortDescResults;
    } else if (result.category == ResultCategory.shortDesc) {
      currentResults = reverse ? shortDescResults : longDescResults;
    } else if (result.category == ResultCategory.longDesc) {}
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
              categories: categoryList,
              selectedCategory: selectedCategory,
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
                selectedCategory = category;
                setState(() {});
                // resultCategory
              },
            ),
            20.verticalSpace,

            // Builder(builder: (context) {
            //   var i = categories.indexWhere((cat) => cat == selectedCategory);
            //   var title = i == 3 ? 'Finish' : "(${i + 1}/4) Next";
            //   return CustomButton(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //     backgroundColor: AppColors.primaryShiny,
            //     title: title,
            //     width: 240,
            //     height: 50,
            //     onPressed: () {
            //       if (i != 3) {
            //         selectedCategory = categories[i + 1];
            //       } else {}
            //       setState(() {});
            //     },
            //   );
            // }),
          ],
        ).singleChildScrollView);
  }
}
