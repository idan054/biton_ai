import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../common/themes/app_colors.dart';

enum ResultCategory { titles, googleResults, shortDesc, longDesc }

class ResultItem {
  final String title;
  final String? desc;
  final ResultCategory category;

  ResultItem({
    required this.title,
    this.desc,
    required this.category,
  });
}

class ResultsList extends StatefulWidget {
  final List<ResultItem> results;
  final bool horizontalView;
  final bool removeMode; // Remove items from [selectedResults] resultsScreen.dart
  final void Function(ResultItem result) onSelect;

  const ResultsList({
    super.key,
    this.removeMode = false,
    this.horizontalView = false,
    required this.results,
    required this.onSelect,
  });

  @override
  State<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  ResultItem? selectedResult; // AKA var

  @override
  Widget build(BuildContext context) {
    bool horizontalView = widget.horizontalView;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String listTitle = 'Choose your favorite ';

    if (widget.results.isNotEmpty) {
      var resultsCategory = widget.results.first.category;
      // Colors titleColor // SET BY SWITCH

      switch (resultsCategory) {
        case ResultCategory.titles:
          listTitle += 'title:';
          break;
        case ResultCategory.googleResults:
          listTitle += 'Google Result:';
          break;
        case ResultCategory.shortDesc:
          listTitle += 'Product short Description:';
          break;
        case ResultCategory.longDesc:
          listTitle += 'Product long Description:';
          break;
      }
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        if (widget.results.isNotEmpty && !(widget.horizontalView))
          listTitle.toText(fontSize: 22, bold: true).px(15).py(5).centerLeft,
        SizedBox(
          height: horizontalView ? 150 : null,
          width: horizontalView ? width : null,
          child: ListView.builder(
            scrollDirection: horizontalView ? Axis.horizontal : Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.results.length,
            itemBuilder: (BuildContext context, int i) {
              var result = widget.results[i];
              var isSelected = widget.removeMode || selectedResult == result;
              var isGoogleItem = result.category == ResultCategory.googleResults;

              return widget.removeMode
                  ? buildChoiceChip(isSelected, result, isGoogleItem, width).appearOpacity
                  : buildChoiceChip(isSelected, result, isGoogleItem, width).appearAll;
            },
          ),
        ),
      ],
    );
  }

  Widget buildChoiceChip(
      bool isSelected, ResultItem result, bool isGoogleItem, double width) {
    bool horizontalView = widget.horizontalView;

    return SizedBox(
      width: horizontalView ? 450 : null,
      child: ChoiceChip(
        backgroundColor: AppColors.lightPrimaryBg,
        selectedColor: AppColors.lightPrimaryBg,
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
        label: Stack(
          children: [
            SizedBox(
              width: horizontalView ? 450 : null,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.5),
                    side: isSelected && appConfig_highlightSelection
                        ? const BorderSide(color: AppColors.primaryShiny, width: 3.0)
                        : BorderSide.none),
                child:
                    // region LisTile
                    ListTile(
                  minVerticalPadding: 30,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
                  title: result.title.toString().toText(
                        bold: true,
                        fontSize: 16,
                        color: isGoogleItem
                            ? AppColors.blueOld
                            :
                            // isSelected ? AppColors.primaryShiny :
                            AppColors.greyText,
                        maxLines: 100,
                      )
                  // .pOnly(right: width * 0.25)
                  ,
                  subtitle: (isGoogleItem && (result.desc ?? '').isNotEmpty)
                      ? result.desc
                          .toString()
                          .toText(
                            fontSize: 14,
                            medium: true,
                            color:
                                // isSelected ? AppColors.primaryShiny :
                                AppColors.greyText,
                            maxLines: 100,
                          )
                          .pOnly(right: width * 0.25, top: 10)
                      : null,
                ).px(15),
                // endregion child
              ),
            ),
            if (isSelected && appConfig_highlightSelection)
              Icons.check_circle_rounded
                  .icon(color: AppColors.primaryShiny, size: 30)
                  .pad(20)
                  .topRight,
          ],
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            selectedResult = result;
          } else {
            selectedResult = null;
          }
          widget.onSelect(result);
          setState(() {});
        },
      ),
    );
  }
}
