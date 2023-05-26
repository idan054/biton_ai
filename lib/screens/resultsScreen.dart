// ignore_for_file: no_leading_underscores_for_local_identifiers, curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/screens/homeScreen.dart';
import 'package:biton_ai/widgets/htmlEditorViewerWidget.dart';
import 'package:biton_ai/widgets/resultsCategoriesList.dart';
import 'package:collection/collection.dart';
import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/services/color_printer.dart';
import '../common/services/createProduct_service.dart';
import '../common/services/gpt_service.dart';
import '../common/themes/app_colors.dart';
import '../widgets/customButton.dart';
import '../widgets/resultsList.dart';
import '../widgets/threeColumnDialog/threeColumnDialog.dart';

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

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  bool isAdvancedSwitchOn = false;
  bool _isLoading = false;
  String? errorMessage;

  var inputController = TextEditingController();
  String exampleUrl = '';
  List<ResultModel> titlesResults = [];
  List<ResultModel> googleResults = [];
  List<ResultModel> shortDescResults = [];
  List<ResultModel> longDescResults = [];

  List<ResultModel> selectedResults = []; // Top List (Remove)
  // List<ResultModel> currentResults = []; // Bottom List (Add)

  AnimationController? _animationController;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    super.initState();
  }

  void autoFetchResults(ResultCategory type) async {
    // var n = type == ResultCategory.longDesc ? 1 : 3;
    print('START: autoFetchResults() ${type.name}');

    var _promptList = promptsByType(type, widget.input, widget.promptsBase);
    final results = await Gpt.getResults(
      context,
      type: type,
      input: widget.input,
      prompts: _promptList,
      gDescPrompts: _promptList,
    ).catchError((err) {
      printRed('My ERROR: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
      setState(() {});
    });

    // if (type == ResultCategory.gResults) googleResults = [...googleResults, ...results];
    if (type == ResultCategory.titles) titlesResults = results;
    if (type == ResultCategory.shortDesc) shortDescResults = results;
    if (type == ResultCategory.longDesc) longDescResults = results;
    setState(() {});
  }

  ResultModel? lastSelectedResult; // For restore when re-pick
  ResultCategory drawerCategory = ResultCategory.gResults;

  Timer? _timer; // 1 time run.
  double _longDescLoader = 0.0;

  Widget buildCardsRow(List<ResultModel> currList) {
    if (currList.isEmpty && errorMessage == null) {
      return StatefulBuilder(builder: (context, stfBuilder) {
        // var ratio = 15;
        // 1 time run.

        // _timer ??= Timer.periodic((1000 / ratio).milliseconds, (timer) {
        //   if (mounted) {
        //     _longDescLoader = (_longDescLoader + (1 / (60 * ratio)));
        //     stfBuilder(() {});
        //   }
        // });

        // if (drawerCategory == ResultCategory.longDesc) {
        //   print('START: Future.delayed(1.sec()');
        //   Future.delayed(1.seconds).then((_) => _animationController!.forward());
        //   print('_animationController ${_animationController}');
        // }

        return Column(
          children: [
            if (drawerCategory == ResultCategory.longDesc) ...[
              r'Finish writing sales article... (it can take up to 60 seconds)'
                  .toText(color: AppColors.greyText, fontSize: 18, medium: true)
                  .py(10)
                  .px(30)
                  .centerLeft
                  .appearAll,
              CurvedLinearProgressIndicator(
                // value: _longDescLoader,
                // value: _animationController!.value, // use the controller's value
                strokeWidth: 10,
                color: AppColors.primaryShiny,
                backgroundColor: AppColors.greyLight,
              ).sizedBox(500, null).pOnly(top: 10).px(35).centerLeft,
            ] else ...[
              const CircularProgressIndicator(
                strokeWidth: 7,
                color: AppColors.primaryShiny,
              ).pOnly(top: 100).center,
            ]
          ],
        );
      });
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
    double width = MediaQuery.of(context).size.width;
    print('width > 600 ${width > 600}');

    bool desktopMode = width > 850;

    return Scaffold(
      backgroundColor: AppColors.lightPrimaryBg,
      appBar: desktopMode
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 70,
              titleSpacing: 0,
              title: buildTextStoreBar(context).pOnly(top: 10).appearAll,
              leading: Builder(
                  builder: (context) => Icons.menu
                      .icon(color: AppColors.greyText, size: 24)
                      .pOnly(top: 10, left: 10)
                      .onTap(() => Scaffold.of(context).openDrawer(), radius: 10)),
            ),
      drawer: buildDrawer(),
      body: Row(
        children: [
          if (desktopMode) buildDrawer().appearAll,
          Column(
            children: [
              // buildUserInput().pOnly(top: 20),
              // Divider(color: AppColors.greyLight, thickness: 1, height: 0),

              // Todo make it works
              if (desktopMode) buildTextStoreBar(context).centerLeft.appearAll,
              const SizedBox(height: 10),

              buildCardsRow(googleResults),
              if (sCategoryItems.contains(ResultCategory.gResults))
                buildCardsRow(titlesResults),
              if (sCategoryItems.contains(ResultCategory.titles))
                buildCardsRow(shortDescResults),
              if (sCategoryItems.contains(ResultCategory.shortDesc))
                buildCardsRow(longDescResults),
              const SizedBox(height: 20)
            ],
          )
              .px(desktopMode ? 30 : 5)
              .singleChildScrollView
              .top
              .pOnly(top: desktopMode ? 30 : 10)
              .expanded(),
        ],
      ),
    );
  }

  Widget buildTextStoreBar(BuildContext context) {
    var uniModel = context.listenUniProvider;
    return Offstage(
      offstage: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textStoreBar(
            context,
            isLoading: _isLoading,
            searchController: inputController,
            onStart: () async => _handleOnSubmit(),
            onSubmitted: (val) async => _handleOnSubmit(),
            prefixIcon: Icons.tune
                .icon(color: AppColors.greyText, size: 25)
                .px(20)
                .py(12)
                .onTap(() async {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return ThreeColumnDialog(
                    promptsList: uniModel.fullPromptList,
                    selectedPrompts: uniModel.inUsePromptList,
                    categories: uniModel.categories,
                  );
                },
              );
              setState(() {}); // Update uniModel values
            }),
          ),
          if (errorMessage != null)
            errorMessage
                .toString()
                .toText(color: AppColors.errRed, fontSize: 16, maxLines: 5)
                .py(5)
                .px(20)
        ],
      ),
    );
  }

  void _handleOnSubmit() async {
    errorMessage = null;
    _isLoading = true;
    setState(() {});
    // startLoader(inputController.text);
    await createProductAction(context, inputController).catchError((err) {
      printRed('My ERROR: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
    });
    _isLoading = false;
    setState(() {});
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
                textStoreAi.toText(fontSize: 35, bold: true).px(25).centerLeft,
                20.verticalSpace,
              ],
            ).onTap(
                () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                radius: 5),
            Builder(builder: (context) {
              var color = AppColors.primaryShiny;
              return Card(
                // color: Colors.grey[100],
                // color: AppColors.lightShinyPrimary,
                color: AppColors.transparent,
                elevation: 0,
                shape: 10.roundedShape.copyWith(
                      side: BorderSide(color: color, width: 2),
                    ),
                child: ListTile(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  horizontalTitleGap: 0,
                  leading: Icons.shopping_bag.icon(color: color, size: 22),
                  title: 'Create new product'
                      .toString()
                      .toText(bold: true, color: color, fontSize: 15),
                ),
              ).pOnly(left: 3, right: 30);
            }),
            const SizedBox(height: 10),
            CategoryDrawerList(
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
            Builder(builder: (context) {
              var color =
                  isAdvancedSwitchOn ? AppColors.secondaryBlue : AppColors.greyText;
              return Card(
                color: Colors.grey[100],
                elevation: 0,
                shape: 10.roundedShape,
                child: ListTile(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ThreeColumnDialog(
                            promptsList: context.uniProvider.fullPromptList,
                            selectedPrompts: context.uniProvider.inUsePromptList,
                            categories: context.uniProvider.categories,
                          );
                        },
                      );
                      setState(() {}); // Update uniModel values
                    },
                    horizontalTitleGap: 0,
                    // trailing: Switch(
                    //   value: isAdvancedSwitchOn,
                    //   activeColor: AppColors.secondaryBlue,
                    //   onChanged: (bool value) {
                    //     isAdvancedSwitchOn = value;
                    //     setState(() {});
                    //   },
                    // ),
                    leading:
                        Icons.settings_suggest.icon(color: color, size: 22).pOnly(top: 5),
                    // title: (isAdvancedSwitchOn ? 'Custom mode' : 'Default mode')
                    title: 'Advanced mode'
                        .toString()
                        .toText(medium: true, color: color, fontSize: 15),
                    subtitle: 'Try for better results'
                        .toString()
                        .toText(color: color, fontSize: 13)
                    // onTap: () => onTap(category),
                    ),
              ).px(10);
            }),
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
