import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/extensions/widget_ext.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/prompt/prompt_model.dart';

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

  List<WooPostModel> _postList = [];
  WooCategoryModel? selectedCategory;
  WooPostModel? selectedPost;
  final _titleEditingController = TextEditingController();
  final _contentEditingController = TextEditingController();

  @override
  void dispose() {
    _titleEditingController.dispose();
    _contentEditingController.dispose();
    super.dispose();
  }

  void getUserPosts() async {
    _postList = await WooApi.getPosts(userId: debugUid.toString());
    print('_posts ${_postList.length}');
    setState(() {});
  }

  @override
  void initState() {
    getUserPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final categories = widget.categories;
    bool updatePostMode = selectedPost != null;

    return Dialog(
      backgroundColor: Colors.grey[100],
      child: Container(
        width: selectedCategory == null ? 300 : width * 0.5,
        height: 350,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                'Choose type:'.toText(color: Colors.black, fontSize: 18).px(5).centerLeft,
                ListView.builder(
                  shrinkWrap: true,
                  // itemCount: CategoryType.values.length,
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int i) {
                    // final categoryType = CategoryType.values[i];
                    final category = categories[i];
                    return Card(
                      elevation: category == selectedCategory ? 0 : 1,
                      color: category == selectedCategory ? Colors.grey[300] : null,
                      child: ListTile(
                        title: category.name.toString().toText(bold: true),
                        subtitle: 'ID: ${category.id}'.toText(),
                        onTap: () async {
                          selectedCategory = category;
                          selectedPost = null;
                          _titleEditingController.text = '';
                          _contentEditingController.text = '';
                          // await WooApi.getPosts(userId: '$debugUid');
                          setState(() {});
                        },
                      ),
                    );
                  },
                ).expanded(),
              ],
            ).expanded(),
            // verticalDivider,

            // if (_isLoading)
            // ListTile(title: const CircularProgressIndicator(strokeWidth: 5).center),
            if (selectedCategory != null)
              Column(
                children: [
                  'Your prompts:'
                      .toText(color: Colors.black, fontSize: 18)
                      .px(5)
                      .centerLeft,
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: _postList.length,
                      itemBuilder: (BuildContext context, int i) {
                        final post = _postList[i];

                        if (selectedCategory == null ||
                            post.categories.contains(selectedCategory!.id) == false) {
                          return const Offstage();
                        }

                        var catId = post.categories
                            .firstWhere((cat) => cat == selectedCategory!.id);

                        return Card(
                          elevation: post == selectedPost ? 0 : 1,
                          color: post == selectedPost ? Colors.grey[300] : null,
                          child: ListTile(
                            title: post.title.toString().toText(bold: true),
                            subtitle: 'CatId: $catId ID: ${post.id} DESC: ${post.content}'
                                .toText(),
                            onTap: () async {
                              if (selectedPost == post) {
                                selectedPost = null;
                                _titleEditingController.text = '';
                                _contentEditingController.text = '';
                              } else {
                                selectedPost = post;
                                _titleEditingController.text = post.title;
                                _contentEditingController.text = post.content;
                              }
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).expanded(),

            // if (selectedCategory != null)
            // verticalDivider,
            if (selectedCategory != null)
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _titleEditingController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Prompt name',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: 150,
                      child: TextField(
                        maxLines: null,
                        expands: true,
                        controller: _contentEditingController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Your prompt',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        final title = _titleEditingController.text.trim();
                        final content = _contentEditingController.text;
                        if (title.isNotEmpty &&
                            content.isNotEmpty &&
                            selectedCategory != null) {
                          var newPost = WooPostModel(
                            author: debugUid,
                            title: title,
                            content: content,
                            categories: [selectedCategory!.id],
                          );

                          WooApi.createPost(newPost,
                              updatePostById: updatePostMode ? selectedPost!.id : null);

                          // Remove old version
                          if (updatePostMode) {
                            _postList
                                .removeWhere((post) => post.title == selectedPost?.title);
                          }

                          _postList.insert(0, newPost); // Start of  list
                          _titleEditingController.clear();
                          _contentEditingController.clear();
                          setState(() {});
                        }
                      },
                      child: Text(updatePostMode ? 'Update' : '+ Add'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
