// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_final_fields

import 'dart:developer';

import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
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
import '../../screens/homeScreen.dart';
import '../customButton.dart';
import 'design.dart';

class ThreeColumnDialog extends StatefulWidget {
  final List<WooCategoryModel> categories;
  final List<WooPostModel> promptsList;
  final List<WooPostModel> selectedPrompts;

  const ThreeColumnDialog(
      {required this.categories,
      required this.promptsList,
      required this.selectedPrompts,
      Key? key})
      : super(key: key);

  @override
  _ThreeColumnDialogState createState() => _ThreeColumnDialogState();
}

class _ThreeColumnDialogState extends State<ThreeColumnDialog> {
  late List<WooCategoryModel> categories = [];

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
    selectedCategory = categories.first;

    _fullPromptList = widget.promptsList;
    _initWooSelection(); // SET _selectedPromptList & Default

    // Set Radio by category
    sRadioPost =
        _selectedPromptList.firstWhere((p) => p.category == selectedCategory!.type);
    super.initState();
  }

  void _initWooSelection() {
    _selectedPromptList = widget.selectedPrompts;

    var initPrompt =
        _selectedPromptList.firstWhere((p) => p.category == categories.first.type);
    onRadioChanged(initPrompt);
    print('DONE: _initWooSelection() [${_selectedPromptList.length} SELECTED!]');
  }

  void onRadioChanged(WooPostModel newPost) {
    print('START: onRadioChanged()');

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
    _createMode = false;
    selectedCategory = category;

    // Set Radio by category
    sRadioPost = _selectedPromptList.firstWhere((p) => p.category == category.type);
    onRadioChanged(sRadioPost!);
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
    _createMode = true;
    _isLoading = false;
    sRadioPost = null;
    _googleDescEditingController.clear();
    _contentEditingController.clear();
    _titleEditingController.text = 'My ${selectedCategory?.name} prompt';

    _titleFocusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var categorySize = 275.0;
    var promptListSize = 330.0;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: 15.roundedShape,
      child: SizedBox(
        width: 1100,
        height: 420,
        // padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDialogCategories(
              categorySize,
              categories,
              selectedCategory,
              onTap: (category) => _onCategoryChanged(category),
            ),
            SizedBox(
              width: promptListSize,
              child: Column(
                children: [
                  CustomButton(
                    shape: 4.roundedShape,
                    backgroundColor: AppColors.secondaryBlue,
                    title: 'Add new prompt',
                    // icon: Icons.add_circle_outline.icon(),
                    width: 160,
                    height: 45,
                    onPressed: () => reset4NewPrompt(),
                  ).centerLeft.pOnly(top: 25, bottom: 15, left: 15),
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
                                  onChanged: (_) => onRadioChanged(currPost),
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
                                ).py(5).onTap(() => onRadioChanged(currPost),
                                    radius: 5, tapColor: Colors.transparent),
                                if (!currPost.isDefault) ...[
                                  Icons.edit
                                      .icon(
                                          color: isSelected
                                              ? AppColors.secondaryBlue
                                              : AppColors.greyText)
                                      .pad(5)
                                      .onTap(
                                        () => onRadioChanged(currPost),
                                      ),
                                  Icons.remove_circle_outline_outlined
                                      .icon(color: AppColors.errRed)
                                      .pad(5)
                                      .onTap(() => _handleOnDeletePrompt(currPost)),
                                ]
                              ],
                            ).py(3),
                            Container(
                              height: 1.5,
                              color: AppColors.greyLight,
                            )
                          ],
                        ).px(10);
                      },
                    ),
                  ),
                ],
              ),
            ),
            verticalDivider,
            buildPromptForm().expanded(),
          ],
        ),
      ),
    );
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

                var color =
                    isYourInputIncluded ? AppColors.greyUnavailable80 : AppColors.errRed;

                // Hide when edit prompts if no .errRed
                if (isYourInputIncluded && !_createMode) return const Offstage();

                return Row(
                  children: [
                    Icons.tips_and_updates.icon(color: color).pOnly(right: 5),
                    // style: TextStyle(color: color, fontSize: 14),
                    'Use [YOUR_INPUT]  to make the prompt flexible'.toText(color: color)
                  ],
                ).pOnly(bottom: 10, top: 10);
              }),
            ],
            const Spacer(flex: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildCreateButton(_isLoading, createMode: _createMode,
                    onPressed: () async {
                  bool isYourInputIncluded =
                      (_contentEditingController.text.contains('[YOUR_INPUT]') &&
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
                buildCloseButton(context),
              ],
            ).bottom,
            const SizedBox(height: 20.0),
          ]
        ],
      ).pOnly(right: 20, left: 50);
    });
  }

  Future handleSave() async {
    final isGooglePrompt = selectedCategory!.type == ResultCategory.gResults;
    final title = _titleEditingController.text.trim();
    final googleDesc = _googleDescEditingController.text.trim();
    final mainContent = _contentEditingController.text;
    final content = isGooglePrompt ? '$mainContent googleDesc=$googleDesc' : mainContent;

    if (title.isNotEmpty && mainContent.isNotEmpty && selectedCategory != null) {
      // Remove old version
      if (!_createMode) _fullPromptList.removeWhere((post) => post.id == sRadioPost?.id);

      var newPost = WooPostModel(
        author: debugUid,
        title: title,
        content: content,
        category: selectedCategory!.type,
        categories: [selectedCategory!.id],
        isSelected: true,
      );
      _deselectOtherPrompts(newPost);

      newPost = await WooApi.updatePost(
        newPost,
        postId: _createMode ? null : sRadioPost!.id,
        isSelected: true,
      );

      onRadioChanged(newPost);
      _fullPromptList = setDefaultPromptFirst(_fullPromptList);
      _fullPromptList.insert(1, newPost); // Start of  list

    }
  }

  void _deselectOtherPrompts(WooPostModel newPost) {
    for (var post in _fullPromptList) {
      // deselect any other prompts in this category
      if (post.category == newPost.category && post.isSelected && post.id != newPost.id) {
        WooApi.updatePost(post, postId: post.id, isSelected: false);
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
