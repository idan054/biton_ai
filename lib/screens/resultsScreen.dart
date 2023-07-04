// ignore_for_file: no_leading_underscores_for_local_identifiers, curly_braces_in_flow_control_structures, empty_catches

import 'dart:async';
import 'dart:html';

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
import 'package:html_editor_enhanced/html_editor.dart';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/models/uniModel.dart';
import '../common/services/color_printer.dart';
import '../common/services/createProduct_service.dart';
import '../common/services/gpt_service.dart';
import '../common/services/wooApi.dart';
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
          item.category == type && (useSelected ? item.isSelected : item.isAdmin))
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateUserPoints({bool errMode = false}) async {
    final UniProvider uni = context.uniProvider;
    uni.updateWooUserModel(uni.currUser
        .copyWith(points: errMode ? uni.currUser.points + 1 : uni.currUser.points - 1));
    await WooApi.setUserPoints(uid: uni.currUser.id, points: uni.currUser.points)
        .catchSentryError();
  }

  @override
  void initState() {
    googleResults = [...widget.googleResults];
    updateUserPoints();
    setState(() {});

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

    // Future.delayed(1.seconds).then((value) => _scaffoldKey.currentState?.openDrawer());
    super.initState();
  }

  void autoFetchResults(ResultCategory type) async {
    // var n = type == ResultCategory.longDesc ? 1 : 3;
    printWhite('START: autoFetchResults() ${type.name}');

    var _promptList = promptsByType(type, widget.input, widget.promptsBase);
    final results = await Gpt.getResults(
      context,
      type: type,
      input: widget.input,
      prompts: _promptList,
      gDescPrompts: _promptList,
    ).catchError((err) {
      printRed('My ERROR getResults: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
      updateUserPoints(errMode: true);
      setState(() {});
      return <ResultModel>[];
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
  bool useTranslatedResult = false;
  bool showHtmlEditor = true;

  Widget buildCardsRow(List<ResultModel> currList) {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;

    if (currList.isEmpty && errorMessage == null) {
      return StatefulBuilder(builder: (context, stfBuilder) {
        return Column(
          children: [
            if (drawerCategory == ResultCategory.longDesc) ...[
              r'Finish writing sales article will take 1-2 minutes..'
                  .toText(
                      color: AppColors.greyText, fontSize: 18, medium: true, maxLines: 4)
                  .py(10)
                  .px(15)
                  .pOnly(top: 10)
                  .centerLeft
                  .appearAll,
              //
              TweenAnimationBuilder(
                  duration: 120.seconds,
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (BuildContext context, double value, Widget? child) {
                    return CurvedLinearProgressIndicator(
                      value: value,
                      // value: _longDescLoader,
                      // value: _animationController!.value, // use the controller's value
                      strokeWidth: 10,
                      // color: AppColors.primaryShiny,
                      color: AppColors.secondaryBlue,
                      backgroundColor: AppColors.greyLight,
                    ).sizedBox(500, null).pOnly(top: 10).px(20).centerLeft;
                  }),
              //
            ] else ...[
              const CircularProgressIndicator(
                strokeWidth: 7,
                // color: AppColors.primaryShiny,
                color: AppColors.secondaryBlue,
              ).pOnly(top: 100).center,
            ]
          ],
        );
      });
    }

    // When currList.isNotEmpty
    if (errorMessage == null &&
        currList.first.category == ResultCategory.longDesc &&
        showHtmlEditor) {
      // print('currList $currList');
      // print('currList.first.category ${currList.first.category}');
      String article;
      try {
        print('START: article = longDescResults.first.title;()');
        article = (kDebugMode && appConfig_fastHomeScreen)
            ? useTranslatedResult
                ? 'T'
                : googleResults.first.title
            : (useTranslatedResult
                ? longDescResults.first.translatedTitle
                : longDescResults.first.title);

        // print('article ${article}');
      } catch (e, s) {
        print('ERR: String? article()');
        print('e ${e}');
        print('s ${s}');
        article = "Sorry, we couldn't create your sale article: \n $longDescResults";
      }

      print('useTranslatedResult $useTranslatedResult');
      return useTranslatedResult
          ? SizedBox(
              key: UniqueKey(),
              height: 700,
              child: HtmlEditorViewer(article),
            ).pOnly(
              left: desktopMode ? 20 : 10,
              right: desktopMode ? 40 : 10,
              top: 20,
            )
          : SizedBox(key: UniqueKey(), height: 700, child: HtmlEditorViewer(article))
              .pOnly(
              left: desktopMode ? 20 : 10,
              right: desktopMode ? 40 : 10,
              top: 20,
            );
    }

    return ResultsList(
      useTranslatedResult: useTranslatedResult,
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

  bool _profileLoading = false;

  @override
  Widget build(BuildContext context) {
    var sCategoryItems =
        selectedResults.map((item) => item.category).toList(growable: true);
    double width = MediaQuery.of(context).size.width;
    // print('width > 600 ${width > 600}');
    bool desktopMode = width > 850;

    Widget inputAsTitle = SelectableText(widget.input,
            style: ''.toText(fontSize: 35, bold: true).style)
        // .onTap(() => Navigator.push( context, MaterialPageRoute(builder: (context) => const HomeScreen())), radius: 5)
        .px(10)
        .centerLeft;

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      key: _scaffoldKey,
      backgroundColor: AppColors.lightPrimaryBg,
      appBar:
          // desktopMode ? null :
          AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 90,
        titleSpacing: 0,
        // Removes the back button
        automaticallyImplyLeading: false,
        title: buildProductPageTitle(desktopMode, inputAsTitle, context)
            // .pOnly(left: 10)
            .appearAll,
        actions: [
          if (!desktopMode)
            Builder(
                builder: (context) => Icons.menu
                    .icon(color: AppColors.greyText, size: 24)
                    .pOnly(left: 10, right: 10)
                    .onTap(() => Scaffold.of(context).openDrawer(), radius: 10)
                    .pOnly(top: 10, right: 20))
        ],
      ),
      drawer: buildDrawer(),
      body: Row(
        children: [
          if (desktopMode) buildDrawer(miniMode: true).appearAll,
          Column(
            children: [
              // if (desktopMode) buildProductPageTitle(desktopMode, inputAsTitle, context),

              buildCardsRow(googleResults),
              if (sCategoryItems.contains(ResultCategory.gResults))
                buildCardsRow(titlesResults),
              if (sCategoryItems.contains(ResultCategory.titles))
                buildCardsRow(shortDescResults),

              if (errorMessage != null)
                errorMessage
                    .toString()
                    .toText(color: AppColors.errRed, fontSize: 16, maxLines: 3)
                    .py(5)
                    .px(20),
              if (sCategoryItems.contains(ResultCategory.shortDesc))
                buildCardsRow(longDescResults),
              const SizedBox(height: 20)
            ],
          )
              .px(desktopMode ? 30 : 5)
              .singleChildScrollView
              .top
              .pOnly(top: desktopMode ? 10 : 10)
              .expanded(),
        ],
      ),
    );
  }

  Widget buildProductPageTitle(
      bool desktopMode, Widget inputAsTitle, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        if (desktopMode)
          Container(
              height: 90,
              width: 90,
              color: Colors.white,
              child:
                  Image.asset('assets/FAVICON.png', height: 40).pad(15).pOnly(top: 15)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Product page for:'
                .toText(color: AppColors.greyText, fontSize: 18, medium: true)
                .pOnly(top: desktopMode ? 0 : 15, left: 10),
            Row(
              children: [
                if (desktopMode) Hero(tag: 'textStoreAi', child: inputAsTitle),
                if (googleResults.first.title != googleResults.first.translatedTitle)
                  Icons.g_translate
                      .icon(
                          color: useTranslatedResult
                              ? AppColors.secondaryBlue
                              : AppColors.secondaryBlue.withOpacity(0.5),
                          size: 28)
                      .px(10)
                      .pOnly(top: 10)
                      .onTap(() {
                    useTranslatedResult = !useTranslatedResult;
                    setState(() {});
                  }, radius: 10, tapColor: Colors.transparent),
                if (!desktopMode) Hero(tag: 'textStoreAi', child: inputAsTitle),
              ],
            )
            // .offset(0, desktopMode ? -15 : 0)
          ],
        ).px(30),
        const Spacer(),
        if (desktopMode)
          buildHomeMenu(context,
                  isAlignLeft: false,
                  // handleOnAdvanced is on Drawer on mobile
                  onTapAdvanced: desktopMode ? handleOnAdvanced : null)
              .px(5)
              .topRight,
      ],
    );
  }

  // Widget _buildTextStoreBar(BuildContext context) {
  //   var uniModel = context.listenUniProvider;
  //   return Offstage(
  //     offstage: true,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         textStoreBar(
  //           context,
  //           isLoading: _isLoading,
  //           searchController: inputController,
  //           onStart: () async => _handleOnSubmit(),
  //           onSubmitted: (val) async => _handleOnSubmit(),
  //           prefixIcon: Icons.tune
  //               .icon(color: AppColors.greyText, size: 25)
  //               .px(20)
  //               .py(12)
  //               .onTap(() async {
  //             await showDialog(
  //               context: context,
  //               barrierDismissible: false,
  //               builder: (BuildContext context) {
  //                 return ThreeColumnDialog(
  //                   promptsList: uniModel.fullPromptList,
  //                   selectedPrompts: uniModel.inUsePromptList,
  //                   categories: uniModel.categories,
  //                 );
  //               },
  //             );
  //             setState(() {}); // Update uniModel values
  //           }),
  //         ),
  //         if (errorMessage != null)
  //           errorMessage
  //               .toString()
  //               .toText(color: AppColors.errRed, fontSize: 16, maxLines: 5)
  //               .py(5)
  //               .px(20)
  //       ],
  //     ),
  //   );
  // }

  void _handleOnSubmit() async {
    errorMessage = null;
    _isLoading = true;
    setState(() {});
    // startLoader(inputController.text);
    await createProductAction(context, inputController).catchError((err) {
      printRed('My ERROR createProductAction 2: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
      updateUserPoints(errMode: true);
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

  Widget buildDrawer({bool miniMode = false}) {
    double width = MediaQuery.of(context).size.width;
    // print('width > 600 ${width > 600}');
    bool desktopMode = width > 850;

    return MouseRegion(
      onEnter: (_) => miniMode ? _scaffoldKey.currentState?.openDrawer() : null,
      onExit: (_) => miniMode ? null : _scaffoldKey.currentState?.closeDrawer(),
      child: SizedBox(
        width: miniMode ? 90 : null,
        child: GestureDetector(
          onTap: () {
            // if (miniMode) {
            //   _scaffoldKey.currentState?.openDrawer();
            // } else {
            //   _scaffoldKey.currentState?.closeDrawer();
            // }
          },
          child: Drawer(
              backgroundColor: AppColors.white,
              elevation: miniMode ? 0 : 5,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (!desktopMode && !miniMode)
                    buildHomeMenu(context, isAlignLeft: true).px(5).centerLeft,
                  const SizedBox(height: 20),
                  if (!miniMode) ...[
                    Image.asset('assets/DARK-LOGO.png', height: 55).onTap(
                        () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => const HomeScreen())),
                        radius: 5),
                    const SizedBox(height: 25),
                  ],
                  CategoryDrawerList(
                    miniMode: miniMode,
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
                      // Icons.search_rounded,
                      Icons.travel_explore,
                      Icons.title,
                      Icons.notes_rounded,
                      Icons.description_rounded, // subject_rounded
                    ],
                    onSelect: (category) {
                      // Clickable category:
                      // _changeListByCategory(category);
                    },
                  ),
                  const Spacer(),
                  if (!desktopMode) _buildAdvancedButton(miniMode),
                  10.verticalSpace,
                  _buildAddButton(miniMode),
                  20.verticalSpace,
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool miniMode) {
    var color = AppColors.whiteLight;
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;
    final icon = Icons.send
        .icon(color: color, size: 24)
        .pOnly(top: desktopMode ? 5 : 0, bottom: desktopMode ? 0 : 2);

    return Builder(builder: (context) {
      return SizedBox(
        height: miniMode ? 60 : null,
        // width: miniMode ? 60 : null,
        child: Card(
          color: AppColors.secondaryBlue,
          elevation: 0,
          shape: 10.roundedShape,
          child: ListTile(
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeScreen())),
            horizontalTitleGap: 0,
            minLeadingWidth: miniMode ? 0 : 40,
            contentPadding:
                miniMode ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
            leading: miniMode ? null : icon,
            title: miniMode
                ? icon
                : 'New product'
                    .toString()
                    .toText(medium: true, color: color, fontSize: 15),
            // subtitle: miniMode
            //     ? null
            //     : 'Try for better results'.toString().toText(color: color, fontSize: 13)
            // onTap: () => onTap(category),
          ),
        ),
      ).px(10);
    });
  }

  Widget _buildAdvancedButton(bool miniMode) {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;
    var color = isAdvancedSwitchOn ? AppColors.secondaryBlue : AppColors.greyText;
    final icon = Icons.settings_suggest
        .icon(color: color, size: 24)
        .pOnly(top: desktopMode ? 5 : 0, bottom: desktopMode ? 0 : 2);

    return Builder(builder: (context) {
      return SizedBox(
        height: miniMode ? 60 : null,
        // width: miniMode ? 60 : null,
        child: Card(
          color: Colors.grey[100],
          elevation: 0,
          shape: 10.roundedShape,
          child: ListTile(
              onTap: handleOnAdvanced,
              horizontalTitleGap: 0,
              minLeadingWidth: miniMode ? 0 : 40,
              contentPadding:
                  miniMode ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
              leading: miniMode ? null : icon,
              // title: (isAdvancedSwitchOn ? 'Custom mode' : 'Default mode')
              title: miniMode
                  ? icon
                  : 'Advanced mode'
                      .toString()
                      .toText(medium: true, color: color, fontSize: 15),
              subtitle: miniMode
                  ? null
                  : 'Try for better results'.toString().toText(color: color, fontSize: 13)
              // onTap: () => onTap(category),
              ),
        ),
      ).px(10);
    });
  }

  void handleOnAdvanced() async {
    showHtmlEditor = false;
    setState(() {});
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
    showHtmlEditor = true;
    setState(() {}); // Update uniModel values
  }

// TextField _buildUserInput() {
//   return TextField(
//     controller: inputController,
//     style:
//         const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
//     decoration: InputDecoration(
//         enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: AppColors.greyLight),
//           borderRadius: BorderRadius.circular(3),
//         ),
//         hintText: 'Full product name',
//         // hintStyle: const
//         suffixIcon: buildEditIcon().px(12).py(12)
//         // .onTap(() {}),
//         ),
//   );
// }
}

// CircleAvatar buildEditIcon() {
//   return CircleAvatar(
//       radius: 20,
//       backgroundColor: Colors.transparent,
//       child: Icons.border_color_rounded
//           .icon(color: AppColors.primaryShiny, size: 20)
//           .center);
// }
