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
    // if (widget.results.length == 1) {
    //   var tempResult = const ResultModel(
    //     category: ResultCategory.gResults,
    //     title: 'tempResult',
    //   );
    //   results = [...widget.results, tempResult, tempResult];
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('START: ResultsList()');
    print('removeMode ${widget.removeMode}');
    print('results ${results.length}');
    print('results ${results}');
    print('------');

    bool horizontalView = widget.horizontalView;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String resultsTitle = '';

    var cardHeight = 0.0;
    if (results.isNotEmpty) {
      var resultsCategory = results.first.category;
      resultsTitle = titleByCategory(resultsCategory!);
      if (widget.results.first.category == ResultCategory.gResults) cardHeight = 230.0;
      if (widget.results.first.category == ResultCategory.titles) cardHeight = 155.0;
      if (widget.results.first.category == ResultCategory.shortDesc) cardHeight = 200.0;
      if (widget.results.first.category == ResultCategory.longDesc) cardHeight = 350.0;
    }

    return Column(
      children: [
        // const SizedBox(height: 15),
        if (results.isNotEmpty && (widget.horizontalView))
          resultsTitle.toText(color: AppColors.greyUnavailable).px(15).py(10).topLeft,
        SizedBox(
          height: horizontalView ? cardHeight : null,
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
        ).top
        // .testContainer,
      ],
    );
  }

  Widget buildChoiceChip(bool isSelected, ResultModel result, double width) {
    bool horizontalView = widget.horizontalView;
    var isTempResult = result.title == 'tempResult';

    var wDrawer = 250;
    var cardWidth = result.category == ResultCategory.longDesc
        ? (width - wDrawer) * 0.9
        : (width - wDrawer) * 0.3;

    if (isSelected) {
      return Stack(
        children: [
          SizedBox(width: cardWidth, child: buildCardResult(isSelected, result)),
          // Positioned(top: 30, right: 10, child: buildEditIcon()),

          if (isSelected)
            Positioned(
                top: 20,
                right: 20,
                child: Icons.check_circle_rounded
                    .icon(color: AppColors.primaryShiny, size: 30)),
        ],
      );
    }

    return SizedBox(
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
          child: buildCardResult(isSelected, result),
        ),
      ),
    );
  }

  Widget buildCardResult(bool isSelected, ResultModel result) {
    bool horizontalView = widget.horizontalView;
    var isGoogleItem = result.category == ResultCategory.gResults;
    var isShortDesc = result.category == ResultCategory.shortDesc;
    var isProductTitle = result.category == ResultCategory.titles;
    var isTempResult = result.title == 'tempResult';

    return Card(
      color: selectedResult == null || isSelected ? AppColors.white : Colors.grey[200],
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
                fontSize: isProductTitle || isGoogleItem ? 19 : 15,
                fontWeight: isProductTitle || isGoogleItem ? FontWeight.bold : null,
                color: isGoogleItem ? AppColors.blueOld : AppColors.greyText,
              ),
              minLines: 1,
              maxLines: isGoogleItem ? 3 : (isShortDesc ? 6 : 999),
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
                maxLines: 3,
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
