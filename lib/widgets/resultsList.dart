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
import '../common/models/prompt/result_model.dart';
import '../common/themes/app_colors.dart';
import '../screens/resultsScreen.dart';

String titleByCategory(ResultCategory resultsCategory) {
  var title = '';
  switch (resultsCategory) {
    case ResultCategory.googleResults:
      title += // '1/4 '
          'Select Google Result';
      break;
    case ResultCategory.titles:
      title += // '2/4 '
          'Select product name';
      break;
    case ResultCategory.shortDesc:
      title += // '3/4 '
          'Select short description';
      break;
    case ResultCategory.longDesc:
      title += // '4/4 '
          'Long Description';
      break;
  }
  return title;
}

class ResultsList extends StatefulWidget {
  final List<ResultModel> results;
  final bool horizontalView;
  final bool removeMode; // Remove items from [selectedResults] resultsScreen.dart
  final void Function(ResultModel result) onSelect;

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
  ResultModel? selectedResult; // AKA var

  @override
  Widget build(BuildContext context) {
    bool horizontalView = widget.horizontalView;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String resultsTitle = '';

    if (widget.results.isNotEmpty) {
      var resultsCategory = widget.results.first.category;
      resultsTitle = titleByCategory(resultsCategory!);
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        if (widget.results.isNotEmpty && !(widget.horizontalView))
          resultsTitle
              .toText(fontSize: 20, bold: true, color: AppColors.greyText)
              .px(15)
              .py(10)
              .centerLeft,
        SizedBox(
          height: horizontalView ? (widget.results.isEmpty ? 10 : 250) : null,
          width: horizontalView ? width : null,
          child: ListView.builder(
            scrollDirection: horizontalView ? Axis.horizontal : Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.results.length,
            itemBuilder: (BuildContext context, int i) {
              var result = widget.results[i];
              var isSelected = widget.removeMode || selectedResult == result;

              return widget.removeMode
                  ? buildChoiceChip(isSelected, result, width).appearOpacity
                  : buildChoiceChip(isSelected, result, width).appearAll;
            },
          ),
        ),
      ],
    );
  }

  Widget buildChoiceChip(bool isSelected, ResultModel result, double width) {
    bool horizontalView = widget.horizontalView;
    var isGoogleItem = result.category == ResultCategory.googleResults;
    var isProductTitle = result.category == ResultCategory.titles;
    var horizTitle = titleByCategory(result.category!);

    var cardWidth = horizontalView
        ? isGoogleItem
            ? 700.0
            : 500.0
        : null;

    var maxLines = horizontalView
        ? isGoogleItem
            ? 4
            : 6
        : 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (horizontalView)
          horizTitle.toCapitalized()
              .replaceAll('Select ', '')
              .toText(color: AppColors.greyUnavailable)
              .topLeft
              .px(10)
              .py(5),
        SizedBox(
          width: cardWidth,
          child: Stack(
            children: [
              ChoiceChip(
                backgroundColor: AppColors.lightPrimaryBg,
                selectedColor: AppColors.lightPrimaryBg,
                pressElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
                label: SizedBox(
                  width: cardWidth,
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.5)),
                      title: result.title
                          .toString()
                          .toText(
                            bold: isProductTitle || isGoogleItem,
                            // medium: !isGoogleItem,
                            fontSize: isGoogleItem ? 18 : 15,
                            color: isGoogleItem
                                ? AppColors.blueOld
                                :
                                // isSelected ? AppColors.primaryShiny :
                                AppColors.greyText,
                            maxLines: maxLines,
                          )
                          .pOnly(right: widget.horizontalView ? 0 : width * 0.25),
                      subtitle: (isGoogleItem && (result.desc ?? '').isNotEmpty)
                          ? result.desc
                              .toString()
                              .toText(
                                fontSize: 15,
                                // medium: true,
                                color:
                                    // isSelected ? AppColors.primaryShiny :
                                    AppColors.greyText,
                                maxLines: maxLines,
                              )
                              .pOnly(
                                  right: widget.horizontalView ? 0 : width * 0.25,
                                  top: 10)
                          : null,
                    ).px(15),
                    // endregion child
                  ),
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
              if (isSelected && appConfig_highlightSelection)
                Icons.check_circle_rounded
                    .icon(color: AppColors.primaryShiny, size: 30)
                    .pad(20)
                    .px(10)
                    .topRight,

              // if (widget.removeMode)
              //   buildEditIcon()
              //       .pad(20)
              //       .onTap(() {
              //         print('START: onTap()');
              //       })
              //       .pOnly(right: 10)
              //       .topRight,
            ],
          ),
        ),
      ],
    );
  }
}
