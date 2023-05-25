// ignore_for_file: no_leading_underscores_for_local_identifiers, curly_braces_in_flow_control_structures

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/widgets/threeColumnDialog/threeColumnDialog.dart';
import 'package:flutter/material.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/themes/app_colors.dart';

class CategoryDrawerList extends StatefulWidget {
  final List<String> categoriesNames;
  final List<IconData> icons;
  final List<ResultCategory> categories;
  final ResultCategory selectedCategory;
  final void Function(ResultCategory) onSelect;

  const CategoryDrawerList({
    super.key,
    required this.categoriesNames,
    required this.icons,
    required this.selectedCategory,
    required this.categories,
    required this.onSelect,
  });

  @override
  State<CategoryDrawerList> createState() => _CategoryDrawerListState();
}

class _CategoryDrawerListState extends State<CategoryDrawerList> {
  List<ResultCategory> customPromptCategories = [];

  @override
  void initState() {
    setCustomPromptsCategories();
    super.initState();
  }

  void setCustomPromptsCategories() {
    customPromptCategories = [];
    final selectedPrompts = context.uniProvider.inUsePromptList;
    for (var prompt in selectedPrompts) {
      prompt.isDefault ? null : customPromptCategories.add(prompt.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('START: CategoryDrawerList()');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.categories.length,
          itemBuilder: (BuildContext context, int i) {
            final category = widget.categories[i];
            final selectedCategory = widget.selectedCategory;
            bool isSelected = selectedCategory == category;
            return buildCategoryTile(i);

            return ChoiceChip(
              backgroundColor: AppColors.white,
              selectedColor: AppColors.white,
              pressElevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              label: buildCategoryTile(i),
              selected: isSelected,
              onSelected: (bool selected) {
                var _selectedCategory = category;
                // if (selected) {
                //   selectedCategory = _selectedCategory;
                // }
                // else {selectedResult = null;}
                // print('_selectedCategory $_selectedCategory');
                widget.onSelect(_selectedCategory);
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }

  Card buildCategoryTile(int i) {
    context.listenUniProvider.inUsePromptList; //? rebuilt on change
    setCustomPromptsCategories();

    final category = widget.categories[i];
    final selectedCategory = widget.selectedCategory;
    bool isSelected = selectedCategory == category;

    bool isCustomPrompt = customPromptCategories.contains(category);
    bool isGoogleCategory = category == ResultCategory.gResults;
    Color categoryColor = isSelected ? AppColors.primaryShiny : AppColors.greyText;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isSelected ? AppColors.lightShinyPrimary : AppColors.white,
      elevation: 0,
      child: ListTile(
        minLeadingWidth: 10,
        title: widget.categoriesNames[i]
            .toString()
            .toText(medium: true, color: categoryColor, fontSize: 16),
        subtitle: isGoogleCategory
            ? 'Title & Description'.toString().toText(color: categoryColor, fontSize: 14)
            : null,
        leading: widget.icons[i]
            .icon(color: categoryColor, size: 22)
            .pOnly(top: selectedCategory == ResultCategory.gResults ? 5 : 0),
        //
        trailing: isCustomPrompt
            ? Icons.manage_accounts
                .icon(color: categoryColor, size: 22)
                .px(10)
                .pOnly(bottom: 10, top: 10)
                .onTap(() async {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    var sWooCategory = context.uniProvider.categories
                        .firstWhere((cat) => cat.type == category);
                    print('sWooCategory.name ${sWooCategory.name}');

                    return ThreeColumnDialog(
                      selectedCategory: sWooCategory,
                      promptsList: context.uniProvider.fullPromptList,
                      selectedPrompts: context.uniProvider.inUsePromptList,
                      categories: context.uniProvider.categories,
                    );
                  },
                );
              }, radius: 5)
            : null,
      ),
    );
  }
}
