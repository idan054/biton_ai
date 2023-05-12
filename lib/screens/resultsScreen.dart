import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/widgets/resultsCategoriesList.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/services/gpt_service.dart';
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

// List<ResultModel> titlesResults = [
// ResultModel(
//     title: 'A This is just a product title example for Nike Air Max 90',
//     category: ResultCategory.titles),
// ResultModel(
//     title: 'B This is just a product title example for Nike Air Max 90',
//     category: ResultCategory.titles),
// ResultModel(
//     title: 'C This is just a product title example for Nike Air Max 90',
//     category: ResultCategory.titles)
// ];

// List<ResultModel> shortDescResults = [
//   ResultModel(
//       title:
//           'A This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.shortDesc),
//   ResultModel(
//       title:
//           'B This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.shortDesc),
//   ResultModel(
//       title:
//           'C This is just a product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence.',
//       category: ResultCategory.shortDesc),
// ];

// List<ResultModel> longDescResults = [
//   ResultModel(
//       title:
//           'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. '
//           'This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. This is a very long product desc example for Nike Air Max 90, A great desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. A great google result desc will appear here, the average length is about 2 to 3 lines, that the reason i duplicate this sentence. ',
//       category: ResultCategory.longDesc),
// ];

List<String> promptsByType(ResultCategory type, String input) {
  var prompts = <String>[];
  if (type == ResultCategory.gResults) {
    prompts = [
      // 1st already from homeScreen.dart
      // 'Create a great google title for the product: $input',
      'Create a great google title for the product: $input',
      'Create a great google title for the product: $input',
    ];
  }
  if (type == ResultCategory.titles) {
    prompts = [
      'Create a great product title of 1-2 lines for: $input',
      'Create a great product title of 1-2 lines for: $input',
      'Create a great product title of 1-2 lines for: $input',
    ];
  }
  if (type == ResultCategory.shortDesc) {
    prompts = [
      'Create a short SEO description of 3-5 lines about: $input',
      'Create a short SEO description of 3-5 lines about: $input',
      'Create a short SEO description of 3-5 lines about: $input',
    ];
  }
  if (type == ResultCategory.longDesc) {
    prompts = [
      'Create a long SEO description of 20-30 lines about: $input',
      'Create a long SEO description of 20-30 lines about: $input',
      'Create a long SEO description of 20-30 lines about: $input',
    ];
  }
  return prompts;
}

class ResultsScreen extends StatefulWidget {
  final String input;
  final List<ResultModel> googleResults;

  const ResultsScreen(this.input, this.googleResults, {Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  var inputController = TextEditingController(text: 'Nike Air Max 90');
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
    autoFetchResults(ResultCategory.titles);
    autoFetchResults(ResultCategory.shortDesc);
    autoFetchResults(ResultCategory.longDesc);

    exampleUrl = _getUrl(widget.input);
    super.initState();
  }

  void autoFetchResults(ResultCategory type) async {
    // var n = type == ResultCategory.longDesc ? 1 : 3;
    print('START: autoFetchResults() ${type.name}');

    var prompts = promptsByType(type, widget.input);
    final results = await Gpt.getResults(
        type: type, input: widget.input, prompts: prompts, gDescPrompts: prompts);

    // if (type == ResultCategory.gResults) googleResults = [...googleResults, ...results];
    if (type == ResultCategory.titles) titlesResults = results;
    if (type == ResultCategory.shortDesc) shortDescResults = results;
    if (type == ResultCategory.longDesc) longDescResults = results;

    //> Auto deploy on [currentResults] if needed:
    //  auto add 2 missing results after homeScreen.dart
    // if (currentResults.length == 1) currentResults = googleResults;

    // if (currentResults.isEmpty) {
    //   print('START: currentResults.isEmpty()');
    //
    //   //  only if user chose gResults
    //   if (selectedResults.any((result) => result.category == ResultCategory.gResults)) {
    //     currentResults = titlesResults;
    //   }
    //   //  only if user chose titles
    //   if (selectedResults.any((result) => result.category == ResultCategory.titles)) {
    //     currentResults = shortDescResults;
    //   }
    //   //  only if user chose shortDesc
    //   if (selectedResults.any((result) => result.category == ResultCategory.shortDesc)) {
    //     currentResults = longDescResults;
    //   }
    // }

    setState(() {});
  }

  ResultModel? lastSelectedResult; // For restore when re-pick
  ResultCategory drawerCategory = ResultCategory.gResults;

  Widget buildCardsRow(List<ResultModel> list) {
    if (list.isEmpty) {
      return const CircularProgressIndicator(
        strokeWidth: 7,
        color: AppColors.primaryShiny,
      ).pOnly(top: 100).center;
    }

    return ResultsList(
      exampleUrl: exampleUrl,
      horizontalView: appConfig_horizontalSummery,
      results: list,
      onSelect: (result) {
        // _removeIfAlreadySelected(result);
        selectedResults.add(result);
        _nextAvailableList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      body: Row(
        children: [
          buildDrawer(),
          Column(
            children: [
              buildUserInput().pOnly(top: 20),
              Divider(color: AppColors.greyLight, thickness: 1, height: 0),
              buildCardsRow(googleResults),
              buildCardsRow(titlesResults),
              buildCardsRow(shortDescResults),
              buildCardsRow(longDescResults),
              const SizedBox(height: 20)
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
    print('START: _nextAvailableList()');
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

  String _getUrl(String input) {
    final formattedInput = input.toLowerCase().replaceAll(' ', '-');
    final url = 'www.example.com/$formattedInput';
    return url;
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
                _changeListByCategory(category);
              },
            ),
            20.verticalSpace,
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
      backgroundColor: Colors.transparent,
      child: Icons.border_color_rounded
          .icon(color: AppColors.primaryShiny, size: 20)
          .center);
}
