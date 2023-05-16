import 'dart:developer';

import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/extensions/widget_ext.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/prompt/result_model.dart';
import 'customButton.dart';

class ThreeColumnDialog extends StatefulWidget {
  final List<WooCategoryModel> categories;

  const ThreeColumnDialog(this.categories, {Key? key}) : super(key: key);

  @override
  _ThreeColumnDialogState createState() => _ThreeColumnDialogState();
}

class _ThreeColumnDialogState extends State<ThreeColumnDialog> {
  // final _foods = [
  //   WooPostModel(
  //     title: "my title",
  //     content: "my content",
  //     author: debugUid,
  //     categories: [28],
  //     id: 99,
  //   ),
  // ];

  bool _isLoading = false;
  List<WooPostModel> _postList = [];
  WooCategoryModel? selectedCategory;
  WooPostModel? selectedPost;
  final _titleFocusNode = FocusNode();
  final _promptFocusNode = FocusNode();
  final _titleEditingController = TextEditingController();
  final _contentEditingController = TextEditingController();
  final _googleDescEditingController = TextEditingController();
  List<WooCategoryModel> categories = [];

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    _googleDescEditingController.dispose();
    super.dispose();
  }

  void getUserPosts() async {
    _isLoading = true;
    setState(() {});
    _postList = await WooApi.getPosts(userId: debugUid.toString());
    print('_posts ${_postList.length}');
    _isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    categories = sortCategories(widget.categories);
    selectedCategory ??= categories.first;
    _titleEditingController.text = 'My ${selectedCategory?.name} prompt';

    getUserPosts();
    super.initState();
  }

  // @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    double height = MediaQuery.of(context).size.height;
    bool updatePostMode = selectedPost != null;

    var categorySize = 275.0;
    var promptListSize = 300.0;

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
            Container(
              width: categorySize,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryBg,
                borderRadius:
                    BorderRadius.only(topLeft: 15.circular, bottomLeft: 15.circular),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    // itemCount: CategoryType.values.length,
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int i) {
                      // final categoryType = CategoryType.values[i];
                      final category = categories[i];
                      List<IconData> icons = [
                        Icons.search_rounded,
                        Icons.title_rounded,
                        Icons.notes_rounded,
                        Icons.description_rounded,
                        Icons.tag,
                      ];

                      final sIcon = icons[i];
                      final isSelected = category == selectedCategory;
                      final isGoogleCategory = categories.first == categories[i];
                      final color =
                          isSelected ? AppColors.secondaryBlue : AppColors.greyText;

                      return Card(
                        color: isSelected
                            ? AppColors.lightShinyPrimary
                            : AppColors.lightPrimaryBg,
                        elevation: 0,
                        shape: 5.roundedShape,
                        child: ListTile(
                          horizontalTitleGap: 0,
                          leading: sIcon
                              .icon(color: color, size: 22)
                              .pOnly(top: isGoogleCategory ? 5 : 0),
                          title: category.name.toString().toText(
                                medium: true,
                                color: color,
                                fontSize: 15,
                              ),
                          // subtitle: kDebugMode ? 'ID: ${category.id}'
                          subtitle: isGoogleCategory
                              ? 'Title & Description'
                                  .toString()
                                  .toText(color: color, fontSize: 13)
                              : null,
                          onTap: () async {
                            selectedCategory = category;
                            selectedPost = null;
                            _titleEditingController.text =
                                'My ${selectedCategory?.name} prompt';
                            _contentEditingController.text = '';
                            _googleDescEditingController.text = '';
                            // await WooApi.getPosts(userId: '$debugUid');
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ).expanded(),
                ],
              ),
            ),
            SizedBox(
              width: promptListSize,
              child: Column(
                children: [
                  CustomButton(
                    shape: 4.roundedShape,
                    backgroundColor: AppColors.secondaryBlue,
                    title: 'Add new prompt',
                    width: 160,
                    height: 45,
                    onPressed: () {
                      _googleDescEditingController.clear();
                      _contentEditingController.clear();
                      _titleEditingController.text =
                          'My ${selectedCategory?.name} prompt';
                      selectedPost = null;
                      // _titleFocusNode.requestFocus();
                      _titleFocusNode.requestFocus();
                      setState(() {});
                    },
                  ).centerLeft.pOnly(top: 25, bottom: 15, left: 30),
                  if (_isLoading)
                    const CircularProgressIndicator(
                            strokeWidth: 5, color: AppColors.secondaryBlue)
                        .pOnly(top: 20),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: _postList.length,
                      itemBuilder: (BuildContext context, int i) {
                        final post = _postList[i];
                        final isSelected = selectedPost == post;

                        if (selectedCategory == null ||
                            post.categories.contains(selectedCategory!.id) == false) {
                          return const Offstage();
                        }

                        var catId = post.categories
                            .firstWhere((cat) => cat == selectedCategory!.id);

                        void handleOnEdit() {
                          selectedPost = post;
                          _titleEditingController.text = post.title;
                          _contentEditingController.text = post.content;
                          _googleDescEditingController.text = post.content;
                          setState(() {});
                        }

                        return Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icons.delete_outline_rounded
                                    .icon(color: AppColors.errRed)
                                    .pad(10)
                                    .onTap(() => handleOnDeletePrompt(post)),
                                SizedBox(
                                  width: promptListSize * 0.50,
                                  child: post.title.toString().toText(
                                      bold: true,
                                      color: isSelected
                                          ? AppColors.secondaryBlue
                                          : AppColors.greyText,
                                      maxLines: 1),
                                ).py(5).onTap(() => handleOnEdit(),
                                    radius: 5, tapColor: Colors.transparent),
                                Icons.edit
                                    .icon(color: AppColors.greyText)
                                    .pad(10)
                                    .onTap(() => handleOnEdit()),
                              ],
                            ).py(3),
                            Container(
                              height: 1.5,
                              color: AppColors.greyLight,
                            )
                          ],
                        ).px(30);
                      },
                    ),
                  ),
                ],
              ),
            ),
            verticalDivider,
            buildPromptForm(updatePostMode).expanded(),
          ],
        ),
      ),
    );
  }

  Builder buildPromptForm(bool updatePostMode) {
    bool isGoogleCategory = selectedCategory!.slug.contains('google');

    return Builder(builder: (context) {
      var fieldTitleStyle = InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 7),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
          ));

      var fieldPromptStyle = InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: AppColors.greyLight, width: 1.5),
          ));

      Widget fieldTitle(String text) => text
          .toText(
              medium: true,
              color: AppColors.greyUnavailable.withOpacity(0.80),
              fontSize: 14)
          .py(7)
          .px(5)
          .centerLeft;

      return Column(
        children: [
          const SizedBox(height: 25.0),
          SizedBox(
            child: TextField(
              focusNode: _titleFocusNode,
              controller: _titleEditingController,
              // 'My ${selectedCategory?.name} prompt',
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.greyUnavailable,
                fontWeight: FontWeight.bold,
              ),
              decoration: fieldTitleStyle,
            ),
          ),
          const SizedBox(height: 4.0),
          if (!isGoogleCategory) const Spacer(flex: 3),
          fieldTitle(isGoogleCategory
              ? 'Google Title prompt'
              : '${selectedCategory?.name} prompt'),
          SizedBox(
            height: isGoogleCategory ? 95 : 140,
            child: TextField(
              maxLines: null,
              expands: true,
              controller: _contentEditingController,
              decoration: fieldPromptStyle,
            ),
          ),
          if (isGoogleCategory) ...[
            const SizedBox(height: 10.0),
            fieldTitle('Google Description prompt'),
            SizedBox(
              height: 95,
              child: TextField(
                maxLines: null,
                expands: true,
                controller: _googleDescEditingController,
                decoration: fieldPromptStyle,
              ),
            ),
          ],
          const Spacer(flex: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildCancelButton(updatePostMode),
              const SizedBox(width: 15),
              buildAddButton(updatePostMode),
            ],
          ).bottom,
          const SizedBox(height: 30.0),
        ],
      ).pOnly(right: 30, left: 70);
    });
  }

  void handleOnDeletePrompt(WooPostModel post) {
    WooApi.deletePost(post.id!);
    // // Remove old version
    // if (updatePostMode) {
    //   _postList.removeWhere((post) => post.title == selectedPost?.title);
    // }
    _titleEditingController.clear();
    _contentEditingController.clear();
    _googleDescEditingController.clear();
    _postList.remove(post);
    setState(() {});
  }

  Widget buildAddButton(bool updatePostMode) {
    return CustomButton(
        width: 105,
        height: 45,
        shape: 6.roundedShape,
        backgroundColor:
            _isLoading ? AppColors.greyUnavailable80 : AppColors.secondaryBlue,
        title: _isLoading
            ? 'Loading...'
            // : 'Save',
            : updatePostMode
                ? 'Update'
                : 'Create',
        onPressed: () async {
          final title = _titleEditingController.text.trim();
          // Todo add & fetch google results posts
          final googleDesc = _googleDescEditingController.text.trim();
          final content = _contentEditingController.text;
          if (title.isNotEmpty && content.isNotEmpty && selectedCategory != null) {
            var newPost = WooPostModel(
              author: debugUid,
              title: title,
              content: content,
              categories: [selectedCategory!.id],
            );

            // Add post ID
            _isLoading = true;
            setState(() {});
            // Remove old version
            if (updatePostMode) {
              _postList.removeWhere((post) => post.title == selectedPost?.title);
            }

            newPost = await WooApi.createPost(newPost,
                postId: updatePostMode ? selectedPost!.id : null);
            selectedPost = newPost;
            _postList.insert(0, newPost); // Start of  list
            _isLoading = false;
            setState(() {});
          }
        });
  }

  Widget buildCancelButton(bool updatePostMode) {
    return SizedBox(
      width: 105,
      height: 45,
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: 6.rounded,
              side: BorderSide(color: AppColors.greyUnavailable80, width: 1.5),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: 'Cancel'.toText(
          color: AppColors.greyText,
          fontSize: 15,
        ),
      ),
    );
  }
}

List<WooCategoryModel> sortCategories(List<WooCategoryModel> list) {
  dynamic googleItem;
  dynamic productName;
  dynamic shortDesc;
  dynamic longDesc;
  dynamic tag;
  for (var cat in list) {
    if (cat.slug.contains('google')) googleItem = cat;
    if (cat.slug.contains('product-name')) productName = cat;
    if (cat.slug.contains('short')) shortDesc = cat;
    if (cat.slug.contains('long')) longDesc = cat;
    if (cat.slug.contains('tag')) tag = cat;
  }
  return [googleItem, productName, shortDesc, longDesc, tag];
}
