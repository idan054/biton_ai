// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:biton_ai/common/extensions/string_ext.dart';
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

class ResultsCategoriesList extends StatefulWidget {
  final List<String> categoriesNames;
  final List<IconData> icons;
  final List<ResultCategory> categories;
  final ResultCategory selectedCategory;
  final void Function(ResultCategory) onSelect;

  const ResultsCategoriesList({
    super.key,
    required this.categoriesNames,
    required this.icons,
    required this.selectedCategory,
    required this.categories,
    required this.onSelect,
  });

  @override
  State<ResultsCategoriesList> createState() => _ResultsCategoriesListState();
}

class _ResultsCategoriesListState extends State<ResultsCategoriesList> {
  @override
  Widget build(BuildContext context) {
    var selectedCategory = widget.selectedCategory;

    return Column(
      children: [
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.categories.length,
          itemBuilder: (BuildContext context, int i) {
            bool isSelected = selectedCategory == widget.categories[i];
            var categoryColor = isSelected ? AppColors.primaryShiny : AppColors.greyText;

            bool isGoogleCategory = widget.categories[i] == ResultCategory.gResults;
            return ChoiceChip(
              backgroundColor: AppColors.white,
              selectedColor: AppColors.white,
              pressElevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              label: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: isSelected ? AppColors.lightShinyPrimary : AppColors.white,
                elevation: 0,
                child: ListTile(
                  minLeadingWidth: 10,
                  title: widget.categoriesNames[i]
                      .toString()
                      .toText(medium: true, color: categoryColor, fontSize: 16),
                  subtitle: isGoogleCategory
                      ? 'Title & Description'
                          .toString()
                          .toText(color: categoryColor, fontSize: 14)
                      : null,
                  leading: widget.icons[i].icon(color: categoryColor, size: 22),
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                var _selectedCategory = widget.categories[i];

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
}
