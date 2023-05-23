// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:html';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/post/woo_post_model.dart';
import '../common/models/prompt/result_model.dart';
import '../common/models/user/woo_user_model.dart';
import '../common/services/createProduct_service.dart';
import '../common/services/gpt_service.dart';
import '../widgets/threeColumnDialog/actions.dart';
import '../widgets/threeColumnDialog/threeColumnDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController =
      TextEditingController(text: kDebugMode ? 'Nike Air Max 90' : null);
  List<WooCategoryModel> _categories = [];
  List<WooPostModel> _promptsList = [];
  List<WooPostModel> _inUsePrompts = [];
  WooUserModel? currUser;
  String? errorMessage;

  @override
  void initState() {
    print('START: initState()');
    getUser();
    getPrompts();
    getCategories();
    super.initState();
  }

  void getUser() async {
    if (currUser == null) {
      currUser = await WooApi.getUserByToken(userJwt).catchError((err) {
        printRed('My ERROR: $err');
        errorMessage = err.toString().replaceAll('Exception: ', '');
        setState(() {});
      });
      setState(() {});
    }
  }

  void getPrompts() async {
    _promptsList = [];
    _inUsePrompts = [];
    setState(() {});

    _promptsList = await getAllUserPrompts();
    _inUsePrompts = setSelectedList(_promptsList);

    context.uniProvider.updateFullPromptList(_promptsList);
    context.uniProvider.updateInUsePromptList(_inUsePrompts);
    setState(() {});
  }

  void getCategories() async {
    if (_categories.isEmpty) {
      _categories = await WooApi.getCategories();
      _categories = sortCategories(_categories);
      context.uniProvider.updateCategories(_categories);
      setState(() {});
    }
  }

  bool _isLoading = false;

  // var loadingSeconds = 0;

  Timer? _timer; // 1 time run.
  String? loadingText;

  int loadingIndex = 0;

  void startLoader(String input) {
    List loaderActivities = [
      // '',
      'Get info about $input...',
      'Summery info about $input...',
      'Create 3 Google Titles...',
      'Create 3 Google Descriptions...',
      'Improve Google Titles & Descriptions SEO...',
      'Generate 3 Amazing Titles for your Product page...',
      'Generate 3 Short Descriptions (3-5 lines) for your Product page...',
      'Create a sales article for your Product page...',
    ];
    loadingText ??= loaderActivities.first;
    if (_isLoading && _timer == null) {
      _timer = Timer.periodic(4000.milliseconds, (timer) {
        // > Cycle loaderActivities list:
        // loadingIndex = (loadingIndex + 1) % loaderActivities.length;

        //> Stop at end loaderActivities list:
        if (loadingIndex < loaderActivities.length - 1) loadingIndex++;

        loadingText = loaderActivities[loadingIndex];
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // var loader = context.listenUniProvider.textstoreBarLoader;
    _isLoading = _isLoading && errorMessage == null;

    return Scaffold(
        backgroundColor: AppColors.lightPrimaryBg,
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildUserButton(currUser),
            const SizedBox(height: 230),

            textStoreAi.toText(fontSize: 50, bold: true),
            const SizedBox(height: 10),
            // 'Sell more by Ai Text for your store'.toText(fontSize: 20).px(25),
            // 'Fast | Create product | SEO'.toText(fontSize: 20).px(25),
            'Best Ai text maker for your store.'.toText(fontSize: 20).px(25),
            const SizedBox(height: 20),
            //~ Search TextField
            textStoreBar(
              context,
              isLoading: _isLoading,
              searchController: searchController,
              onStart: _inUsePrompts.isEmpty || currUser == null
                  ? null
                  : () async => _handleOnSubmit(),
              onSubmitted: _inUsePrompts.isEmpty || currUser == null
                  ? null
                  : (val) async => _handleOnSubmit(),
              prefixIcon: Icons.settings_suggest
                  .icon(
                      color: _categories.isEmpty || _promptsList.isEmpty
                          ? AppColors.greyText.withOpacity(0.30)
                          : AppColors.greyText,
                      size: 25)
                  .px(20)
                  .py(12)
                  .onTap((_categories.isEmpty || _promptsList.isEmpty)
                      ? null
                      : () async {
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return ThreeColumnDialog(
                                promptsList: _promptsList,
                                selectedPrompts: _inUsePrompts,
                                categories: _categories,
                              );
                            },
                          );
                          setState(() {}); // Update uniModel values
                        }),
            ),

            if (errorMessage != null)
              // 'This can take up to 15 seconds...'
              SizedBox(
                width: 800,
                child: errorMessage
                    .toString()
                    .toText(
                        color: (errorMessage != null &&
                                errorMessage!.contains('we need details'))
                            ? AppColors.greyText
                            : AppColors.errRed,
                        fontSize: 16,
                        maxLines: 5)
                    .py(10)
                    .px(30)
                    .appearAll,
              ),

            if (_isLoading)
              // 'This can take up to 15 seconds...'
              SizedBox(
                width: 800,
                child: '$loadingText'
                    .toText(color: AppColors.greyText, fontSize: 18)
                    .py(5)
                    .px(30)
                    .appearAll,
              ),
            const Spacer(),
            appVersion.toText(fontSize: 12).pad(10).centerLeft,
          ],
        )
        // .center,
        );
  }

  void _handleOnSubmit() async {
    errorMessage = null;
    _isLoading = true;
    setState(() {});
    startLoader(searchController.text);
    await createProductAction(context, searchController).catchError((err) {
      printRed('My ERROR: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
    });
    _isLoading = false;
    setState(() {});
  }
}

List<WooPostModel> setSelectedList(List<WooPostModel> _fullPromptList) {
  List<WooPostModel> _selectedPromptList = [];

  //1) Add user selected prompts
  for (var prompt in _fullPromptList) {
    if (prompt.isSelected) _selectedPromptList.add(prompt);
  }

  //2) Add default ONLY where needed
  for (var prompt in _fullPromptList) {
    if (_selectedPromptList.any((p) => p.category == prompt.category)) {
      // Do nothing, prompt.isSelected added for this category
    } else {
      if (prompt.isDefault) _selectedPromptList.add(prompt);
    }
  }
  return _selectedPromptList;
}

List<WooPostModel> setDefaultPromptFirst(List<WooPostModel> postList) {
  var _postList = postList;
  // Set the Default prompt on Top
  for (var post in [..._postList]) {
    if (post.isDefault) {
      _postList.remove(post);
      _postList.insert(0, post);
    }
  }
  return _postList;
}

Widget buildUserButton(WooUserModel? currUser) {
  var color = AppColors.greyText.withOpacity(currUser == null ? 0.5 : 1);
  var style = ''.toText(fontSize: 15, medium: true, color: color).style;
  return SizedBox(
    height: 50,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icons.account_circle.icon(color: color, size: 24),
        (currUser?.name ?? 'Your profile')
            .toText(style: style)
            .pOnly(right: 10, left: 10),
        ('| ').toText(style: style).pOnly(right: 10),
        Icons.offline_bolt.icon(color: color, size: 24).pOnly(right: 10),
        ('10 Tokens').toText(style: style).pOnly(right: 10),
      ],
    ).px(10).onTap(() {
      window.open('https://www.textstore.ai/my-account/', '_blank');
    }, radius: 5),
  ).appearOpacity.centerLeft;
}

Widget textStoreBar(
  BuildContext context, {
  required bool isLoading,
  required TextEditingController searchController,
  required Widget prefixIcon,
  required ValueChanged<String>? onSubmitted,
  required GestureTapCallback? onStart,
}) {
  var _inUsePrompts = context.uniProvider.inUsePromptList;
  var hLoaderRatio = 1.2;
  var width = 800.0;

  return Hero(
    tag: 'buildMainBar',
    child: Stack(
      children: [
        if (isLoading)
          SizedBox(
            width: width - 14,
            height: 50 + (10 * hLoaderRatio),
            child: const LinearProgressIndicator(
              // value: context.listenUniProvider.textstoreBarLoader,
              // color: AppColors.primaryShiny,
              color: AppColors.lightShinyPrimary,

              // color: AppColors.primaryShiny.withOpacity(0.20),
              backgroundColor: Colors.transparent,
            ),
          ).roundedFull.offset(7, -5 * hLoaderRatio),
        SizedBox(
          width: width,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(99),
            child: TextField(
              controller: searchController,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                hoverColor: AppColors.greyLight.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(99),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(99),
                ),
                hintText: 'Enter full product name',
                hintStyle: const TextStyle(color: Colors.grey),
                // suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                suffixIcon: Stack(
                  // Use Stack to overlay prefixIcon and CircularProgressIndicator
                  alignment: Alignment.center,
                  children: [
                    if (isLoading)
                      CurvedCircularProgressIndicator(
                        value: context.listenUniProvider.textstoreBarLoader,
                        color: AppColors.primaryShiny,
                        strokeWidth: 8,
                        backgroundColor: AppColors.greyLight,
                        animationDuration: 1500.milliseconds,
                      ).sizedBox(30, 30).px(10).py(5),
                    if (!isLoading)
                      // Icons.search_rounded.icon(color: Colors.blueAccent, size: 30)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icons.insights.icon(
                              size: 30,
                              color: _inUsePrompts.isEmpty
                                  ? AppColors.primaryShiny.withOpacity(0.40)
                                  : AppColors.primaryShiny),

                          // 'Create'.toText(
                          //     color: _inUsePrompts.isEmpty
                          //         ? AppColors.primaryShiny.withOpacity(0.40)
                          //         : AppColors.primaryShiny,
                          //     medium: true,
                          //     fontSize: 14)
                        ],
                      )
                          .px(15)
                          .py(10)
                          // .py(15)
                          .onTap(onStart,
                              tapColor: AppColors.primaryShiny.withOpacity(0.1)),
                  ],
                ),
              ),
            ),
          ).px(15),
        ),
      ],
    ),
  );
}
