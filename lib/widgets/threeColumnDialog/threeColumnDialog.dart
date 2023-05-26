// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_final_fields

import 'dart:developer';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/models/user/woo_user_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/widgets/threeColumnDialog/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../common/constants.dart';
import '../../common/extensions/widget_ext.dart';
import '../../common/models/category/woo_category_model.dart';
import '../../common/models/prompt/result_model.dart';
import '../../common/services/color_printer.dart';
import '../../screens/homeScreen.dart';
import '../customButton.dart';
import 'design.dart';

class ThreeColumnDialog extends StatefulWidget {
  final WooCategoryModel? selectedCategory;
  final List<WooCategoryModel> categories;
  final List<WooPostModel> promptsList;
  final List<WooPostModel> selectedPrompts;

  const ThreeColumnDialog(
      {this.selectedCategory,
      required this.categories,
      required this.promptsList,
      required this.selectedPrompts,
      Key? key})
      : super(key: key);

  @override
  _ThreeColumnDialogState createState() => _ThreeColumnDialogState();
}

class _ThreeColumnDialogState extends State<ThreeColumnDialog> {
  late List<WooCategoryModel> categories = [];

  bool _isSaveActive = false;
  bool _isLoading = false;
  bool _createMode = false;
  WooCategoryModel? selectedCategory;

  WooPostModel? sRadioPost;
  List<WooPostModel> _fullPromptList = [];
  List<WooPostModel> _selectedPromptList = [];

  final _titleFocusNode = FocusNode();
  final _titleEditingController = TextEditingController();
  final _contentEditingController = TextEditingController();
  final _googleDescEditingController = TextEditingController();
  final _pageController = PageController(initialPage: 0); // Initialize the PageController

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    _googleDescEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    categories = widget.categories;
    selectedCategory = widget.selectedCategory ?? categories.first;

    _fullPromptList = widget.promptsList;
    _initWooSelection(); // SET _selectedPromptList & Default

    // Set Radio by category
    sRadioPost =
        _selectedPromptList.firstWhere((p) => p.category == selectedCategory!.type);
    super.initState();
  }

  void _initWooSelection() {
    _selectedPromptList = widget.selectedPrompts;
    print('_selectedPromptList ${_selectedPromptList.length}');
    print('_selectedPromptList ${_selectedPromptList}');
    var initPrompt =
        _selectedPromptList.firstWhere((p) => p.category == categories.first.type);
    onRadioChanged(initPrompt, fromCategory: true);
    print('DONE: _initWooSelection() [${_selectedPromptList.length} SELECTED!]');
  }

  void onRadioChanged(WooPostModel newPost, {bool fromCategory = false}) {
    print('START: onRadioChanged()');
    if (!fromCategory) _isSaveActive = true;

    _createMode = false;
    sRadioPost = newPost;
    _titleEditingController.text = newPost.title;
    _contentEditingController.text = newPost.content;
    _googleDescEditingController.text = newPost.subContent ?? '';
    updateSelectedList(newPost);

    setState(() {});
  }

  void updateSelectedList(WooPostModel newPrompt) {
    // print('START: addSelectedPrompt()');
    var oldPrompt =
        _selectedPromptList.firstWhereOrNull((p) => p.category == newPrompt.category);
    if (oldPrompt != null) _selectedPromptList.remove(oldPrompt);
    _selectedPromptList.add(newPrompt);
  }

  void _onCategoryChanged(WooCategoryModel category) async {
    if (_pageController.hasClients) _pageController.jumpToPage(1);

    _isSaveActive = false;
    _createMode = false;
    selectedCategory = category;

    // Set Radio by category
    sRadioPost = _selectedPromptList.firstWhere((p) => p.category == category.type);
    onRadioChanged(sRadioPost!, fromCategory: true);
  }

  void _handleOnDeletePrompt(WooPostModel post) {
    WooApi.deletePost(post.id!);
    _titleEditingController.clear();
    _contentEditingController.clear();
    _googleDescEditingController.clear();
    _fullPromptList.remove(post);

    var defaultPrompt =
        _fullPromptList.firstWhere((p) => p.isDefault && p.category == post.category);
    onRadioChanged(defaultPrompt);
  }

  void reset4NewPrompt() {
    if (_pageController.hasClients) _pageController.jumpToPage(2);
    _isSaveActive = true;
    _createMode = true;
    _isLoading = false;
    sRadioPost = null;
    _googleDescEditingController.clear();
    _contentEditingController.clear();
    _titleEditingController.text = 'My ${selectedCategory?.name} prompt';

    _titleFocusNode.requestFocus();
    setState(() {});
  }

  String? errMessage;

  @override
  Widget build(BuildContext context) {
    var categorySize = 275.0;
    var promptListSize = 330.0;
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 900;

    List<Widget> children = [
      buildDialogCategories(
        categorySize,
        categories,
        selectedCategory,
        onTap: (category) => _onCategoryChanged(category),
      ),
      buildEditPromptsList(promptListSize),
      if (desktopMode) verticalDivider,
      desktopMode ? buildPromptForm().expanded() : buildPromptForm(),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!desktopMode)
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: AppColors.secondaryBlue),
          )
              .onTap(
                  () => _pageController.page == 0
                      ? Navigator.pop(context)
                      : _pageController.hasClients
                          ? _pageController
                              .jumpToPage((_pageController.page! - 1).toInt())
                          : null,
                  tapColor: Colors.blue)
              .pOnly(left: 15, bottom: 10),
        //
        Dialog(
          backgroundColor: AppColors.white,
          shape: 15.roundedShape,
          insetPadding: EdgeInsets.symmetric(horizontal: desktopMode ? 40 : 15),
          child: SizedBox(
            width: 1100,
            height: 420,
            child: desktopMode
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: children)
                : PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: children),
          ),
        ),
      ],
    );
  }

  Widget buildEditPromptsList(double promptListSize) {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 900;

    return SizedBox(
      width: promptListSize,
      child: Column(
        children: [
          if (!desktopMode)
            '${selectedCategory!.name} prompts:'
                .toString()
                .toText(
                  bold: true,
                  color: AppColors.greyText,
                  fontSize: 16,
                )
                .centerLeft
                .pOnly(top: 20),
          CustomButton(
            shape: 4.roundedShape,
            backgroundColor: AppColors.secondaryBlue,
            title: 'Add new prompt',
            // icon: Icons.add_circle_outline.icon(),
            width: 160,
            height: 45,
            onPressed: () => reset4NewPrompt(),
          )
              .centerLeft
              .pOnly(top: desktopMode ? 25 : 15, bottom: 15, left: desktopMode ? 15 : 5),
          if (_isLoading)
            const CircularProgressIndicator(
                    strokeWidth: 5, color: AppColors.secondaryBlue)
                .pOnly(top: 20),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _fullPromptList.length,
              itemBuilder: (BuildContext context, int i) {
                final currPost = _fullPromptList[i];
                final isSelected = sRadioPost == currPost;

                if (selectedCategory == null ||
                    currPost.categories.contains(selectedCategory!.id) == false) {
                  return const Offstage();
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: currPost,
                          groupValue: sRadioPost,
                          onChanged: (_) {
                            if (_pageController.hasClients) _pageController.jumpToPage(2);
                            onRadioChanged(currPost);
                          },
                          activeColor: AppColors.secondaryBlue,
                        ),
                        SizedBox(
                          width: (promptListSize * 0.60),
                          child: currPost.title.toString().toText(
                              bold: true,
                              color: isSelected
                                  ? AppColors.secondaryBlue
                                  : AppColors.greyText,
                              maxLines: 1),
                        ).py(5).onTap(() {
                          if (_pageController.hasClients) _pageController.jumpToPage(2);
                          onRadioChanged(currPost);
                        }, radius: 5, tapColor: Colors.transparent),
                        const Spacer(),
                        if (!currPost.isDefault) ...[
                          Icons.edit
                              .icon(
                                  color: isSelected
                                      ? AppColors.secondaryBlue
                                      : AppColors.greyText)
                              .pad(5)
                              .onTap(
                            () {
                              if (_pageController.hasClients)
                                _pageController.jumpToPage(2);
                              onRadioChanged(currPost);
                            },
                          ),
                          Icons.remove_circle_outline_outlined
                              .icon(color: AppColors.errRed)
                              .pad(5)
                              .onTap(() => _handleOnDeletePrompt(currPost))
                        ]
                      ],
                    ).py(3),
                    Container(
                      height: 1.5,
                      color: AppColors.greyLight,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ).px(desktopMode ? 10 : 40);
  }

  Widget buildPromptForm() {
    bool isGoogleCategory = selectedCategory!.type == ResultCategory.gResults;
    bool isDefault =
        (sRadioPost != null && sRadioPost!.isDefault) && appConfig_hideDefault;

    // "TextStore team prompt: Great for most sellers, can't be edited"
    String defaultHint = "Great for most sellers, can't be edited";
    _setTemplatePromptsIfNeeded();
    StateSetter? bulbHintState;

    return Builder(builder: (context) {
      return Column(
        children: [
          const SizedBox(height: 20.0),
          TextField(
            focusNode: _titleFocusNode,
            controller: _titleEditingController,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.greyUnavailable,
              fontWeight: FontWeight.bold,
            ),
            decoration: fieldTitleStyle,
          ),
          // if (!isDefaultPrompt) ...[
          if (true) ...[
            const SizedBox(height: 4.0),
            if (!isGoogleCategory) const Spacer(flex: 3),
            fieldTitle(isGoogleCategory
                ? 'Google Title prompt'
                : '${selectedCategory?.name} prompt'),
            SizedBox(
              height: isGoogleCategory ? 95 : 140,
              child: TextField(
                enabled: !isDefault,
                maxLines: null,
                expands: true,
                style: TextStyle(
                    color: isDefault ? AppColors.greyUnavailable80 : Colors.black),
                controller: isDefault
                    ? TextEditingController(text: defaultHint)
                    : _contentEditingController,
                decoration: fieldPromptStyle(isDefault),
              ),
            ),
            if (isGoogleCategory) ...[
              const SizedBox(height: 5.0),
              fieldTitle('Google Description prompt'),
              SizedBox(
                height: 95,
                child: TextField(
                  enabled: !isDefault,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                      color: isDefault ? AppColors.greyUnavailable80 : Colors.black),
                  controller: isDefault
                      ? TextEditingController(text: defaultHint)
                      : _googleDescEditingController,
                  decoration: fieldPromptStyle(isDefault),
                ),
              ),
            ],
            if (sRadioPost != null && sRadioPost!.isDefault) ...[
              // Hide info Red bulb on default prompts
            ] else ...[
              StatefulBuilder(builder: (context, stfState) {
                bulbHintState = stfState;
                bool isYourInputIncluded =
                    (_contentEditingController.text.contains('[YOUR_INPUT]') &&
                        (isGoogleCategory
                            ? _googleDescEditingController.text.contains('[YOUR_INPUT]')
                            : true));

                var color = !isYourInputIncluded || errMessage != null
                    ? AppColors.errRed
                    : AppColors.greyUnavailable80;

                // Hide when edit prompts if no .errRed
                if (isYourInputIncluded && !_createMode) return const Offstage();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (errMessage != null ? Icons.warning : Icons.tips_and_updates)
                        .icon(color: color)
                        .pOnly(right: 5),

                    // style: TextStyle(color: color, fontSize: 14),
                    (errMessage ?? 'Use [YOUR_INPUT]  to make the prompt flexible')
                        .toText(color: color)
                        .expanded()
                  ],
                ).pOnly(bottom: 10, top: 10);
              }),
            ],
            const Spacer(flex: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildTextstoreButton(
                    title: _createMode ? 'Create' : 'Save',
                    isLoading: _isLoading,
                    createMode: _createMode,
                    isUnavailable: !_isSaveActive,
                    onPressed: () async {
                      bool isYourInputIncluded = (_contentEditingController.text
                              .contains('[YOUR_INPUT]') &&
                          (isGoogleCategory
                              ? _googleDescEditingController.text.contains('[YOUR_INPUT]')
                              : true));

                      print('isYourInputIncluded ${isYourInputIncluded} '
                          '\n ${_contentEditingController.text}'
                          '\n ${_googleDescEditingController.text}');

                      if ((sRadioPost?.isDefault ?? false) || isYourInputIncluded) {
                        _isLoading = true;
                        setState(() {});
                        await handleSave();
                        _createMode = false;
                        _isLoading = false;
                        setState(() {});
                      } else {
                        _createMode ? bulbHintState!(() {}) : setState(() {});
                      }
                    }),
                const SizedBox(width: 15),
                buildCloseButton(context, onPressed: () {
                  context.uniProvider.updateFullPromptList(_fullPromptList);
                  context.uniProvider.updateInUsePromptList(_selectedPromptList);
                  Navigator.pop(context);
                }),
              ],
            ).bottom,
            const SizedBox(height: 20.0),
          ]
        ],
      ).pOnly(right: 20, left: 50);
    });
  }

  Future handleSave() async {
    final currUser = context.uniProvider.currUser;
    final isGooglePrompt = selectedCategory!.type == ResultCategory.gResults;
    final title = _titleEditingController.text.trim();
    final googleDesc = _googleDescEditingController.text.trim();
    final mainContent = _contentEditingController.text;
    final content = isGooglePrompt ? '$mainContent googleDesc=$googleDesc' : mainContent;

    if (title.isNotEmpty && mainContent.isNotEmpty && selectedCategory != null) {
      // Remove old version
      if (!_createMode) _fullPromptList.removeWhere((post) => post.id == sRadioPost?.id);

      var newPost = WooPostModel(
        author: sRadioPost!.author,
        title: title,
        content: content,
        category: selectedCategory!.type,
        categories: [selectedCategory!.id],
        isSelected: true,
      );
      _deselectOtherPrompts(newPost, currUser);

      newPost = await WooApi.updatePost(
        currUser,
        newPost,
        postId: _createMode ? null : sRadioPost!.id,
        isSelected: true,
      ).catchError((err) {
        printRed('My ERROR: $err');
        _isLoading = false;
        errMessage = err.toString().replaceAll('Exception: ', '');
        setState(() {});
      });

      onRadioChanged(newPost);
      _fullPromptList = setDefaultPromptFirst(_fullPromptList);
      _fullPromptList.insert(1, newPost); // Start of  list

    }
  }

  void _deselectOtherPrompts(WooPostModel newPost, WooUserModel currUser) {
    print('START: _deselectOtherPrompts()');

    for (var post in _fullPromptList) {
      // deselect any other prompts in this category
      if (post.category == newPost.category && post.isSelected && post.id != newPost.id) {
        WooApi.updatePost(currUser, post, postId: post.id, isSelected: false);
      }
    }
  }

  void _setTemplatePromptsIfNeeded() {
    // prompt = 'Create a great google title for the product: [YOUR_INPUT]';
    // prompt = 'Create a great google description for the product: [YOUR_INPUT]';
    // prompt = 'Create a great product title of max 15 words for: [YOUR_INPUT]';
    // prompt = 'Create a short SEO description of max 45 words about[YOUR_INPUT]';
    // prompt = 'Create html example file of an article [YOUR_INPUT], add titles and sub titles';
    if (_createMode) {
      switch (selectedCategory?.type) {
        case ResultCategory.gResults:
          _contentEditingController.text =
              'Create a great google title for the product: [YOUR_INPUT]';
          _googleDescEditingController.text =
              'Create a great google description for the product: [YOUR_INPUT]';
          break;
        case ResultCategory.titles:
          _contentEditingController.text =
              'Create a great product title of max 15 words for: [YOUR_INPUT]';
          break;
        case ResultCategory.shortDesc:
          _contentEditingController.text =
              'Create a short SEO description of max 45 words about [YOUR_INPUT]';
          break;
        case ResultCategory.longDesc:
          _contentEditingController.text =
              'Create HTML file of a selling article about [YOUR_INPUT], add titles and sub titles';
          break;
        case ResultCategory.tags:
        default:
          break;
      }
    }
  }
}
