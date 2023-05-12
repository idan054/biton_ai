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
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import '../common/constants.dart';
import '../common/models/prompt/result_model.dart';
import '../common/themes/app_colors.dart';
import '../screens/resultsScreen.dart';

String titleByCategory(ResultCategory resultsCategory) {
  var title = '';
  switch (resultsCategory) {
    case ResultCategory.gResults:
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
  final String exampleUrl;
  final List<ResultModel> results;
  final bool horizontalView;
  final bool removeMode; // Remove items from [selectedResults] resultsScreen.dart
  final void Function(ResultModel result) onSelect;

  const ResultsList({
    super.key,
    this.removeMode = false,
    this.horizontalView = false,
    required this.exampleUrl,
    required this.results,
    required this.onSelect,
  });

  @override
  State<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  ResultModel? selectedResult; // AKA var
  List<ResultModel> results = [];

  @override
  void initState() {
    results = widget.results;
    if (widget.results.length == 1) {
      var tempResult = const ResultModel(
        category: ResultCategory.gResults,
        title: 'tempResult',
      );
      results = [...widget.results, tempResult, tempResult];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool horizontalView = widget.horizontalView;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String resultsTitle = '';

    if (results.isNotEmpty) {
      var resultsCategory = results.first.category;
      resultsTitle = titleByCategory(resultsCategory!);
    }

    return Column(
      children: [
        const SizedBox(height: 15),
        if (results.isNotEmpty && !(widget.horizontalView))
          resultsTitle
              .toText(fontSize: 20, bold: true, color: AppColors.greyText)
              .px(15)
              .py(10)
              .centerLeft,
        SizedBox(
          height: horizontalView ? (results.isEmpty ? 10 : 240) : null,
          width: horizontalView ? width : null,
          child: ListView.builder(
            scrollDirection: horizontalView ? Axis.horizontal : Axis.vertical,
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (BuildContext context, int i) {
              var result = results[i];
              var isSelected = widget.removeMode || selectedResult == result;

              return buildChoiceChip(isSelected, result, width).appearAll;
            },
          ),
        ),
      ],
    );
  }

  Widget buildChoiceChip(bool isSelected, ResultModel result, double width) {
    bool horizontalView = widget.horizontalView;
    var isTempResult = result.title == 'tempResult';
    var cardWidth = horizontalView ? 400.0 : null;

    if (isSelected) {
      return Stack(
        children: [
          SizedBox(width: cardWidth, child: buildCardResult(isSelected, result)),
          if (widget.removeMode) Positioned(top: 10, right: 10, child: buildEditIcon()),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (horizontalView)
        //   horizTitle
        //       .toCapitalized()
        //       .replaceAll('Select ', '')
        //       .toText(color: AppColors.greyUnavailable)
        //       .topLeft
        //       .px(10)
        //       .py(5),
        SizedBox(
          width: cardWidth,
          child: ChoiceChip(
            backgroundColor: AppColors.lightPrimaryBg,
            selectedColor: AppColors.lightPrimaryBg,
            pressElevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
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
            label: SizedBox(
              width: cardWidth,
              height: isTempResult ? 220 : null,
              child: buildCardResult(isSelected, result),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCardResult(bool isSelected, ResultModel result) {
    bool horizontalView = widget.horizontalView;
    var isGoogleItem = result.category == ResultCategory.gResults;
    var isProductTitle = result.category == ResultCategory.titles;
    var horizTitle = titleByCategory(result.category!);
    var isTempResult = result.title == 'tempResult';

    var maxLines = horizontalView
        ? isGoogleItem
            ? 4
            : 6
        : 100;

    return Card(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGoogleItem)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icons.travel_explore
                      .icon(color: AppColors.greyUnavailable)
                      .pOnly(right: 5),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: widget.exampleUrl),
                    style:
                        const TextStyle(fontSize: 15, color: AppColors.greyUnavailable),
                    maxLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Add your Google Title',
                      hintStyle: TextStyle(color: AppColors.greyText),
                      border: InputBorder.none,
                    ),
                  ).expanded(),
                ],
              ),
            const SizedBox(height: 5),
            TextField(
              enabled: isSelected,
              controller: TextEditingController(text: result.title.toString()),
              style: TextStyle(
                fontSize: isGoogleItem ? 19 : 15,
                fontWeight: isProductTitle || isGoogleItem ? FontWeight.bold : null,
                color: isGoogleItem ? AppColors.blueOld : AppColors.greyText,
              ),
              minLines: 1,
              maxLines: maxLines,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Add your Google Title',
                hintStyle: TextStyle(color: AppColors.greyText),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        subtitle: (isGoogleItem && (result.desc ?? '').isNotEmpty)
            ? TextField(
                enabled: isSelected,
                controller: TextEditingController(text: result.desc.toString()),
                style: TextStyle(fontSize: 15, color: AppColors.greyText),
                minLines: 1,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: 'Add your Google Description',
                  hintStyle: TextStyle(color: AppColors.greyText),
                  border: InputBorder.none,
                ),
              )
            // .pOnly(right: widget.horizontalView ? 0 : width * 0.25, top: 10)
            : null,
      ).px(15),
      // endregion child
    );
  }
}
