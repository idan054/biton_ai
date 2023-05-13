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
  // if(resultsCategory == null) return '';
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
  final void Function(ResultModel result) onSelect;

  const ResultsList({
    super.key,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('START: ResultsList()');
    print('${results.length} results: $results');
    print('------');

    double width = MediaQuery.of(context).size.width;

    String resultsTitle = '';
    if (results.isNotEmpty) resultsTitle = titleByCategory(results.first.category!);
    return Column(
      children: [
        if (results.isNotEmpty)
          resultsTitle
              .toText(color: AppColors.greyUnavailable, fontSize: 16)
              .px(15)
              .py(5)
              .topLeft,
        SizedBox(
            width: width,
            child: Row(children: cardList(width)).singleChildScrollViewHoriz),
      ],
    );
  }

  List<Widget> cardList(double width) {
    List<Widget> list = [];
    // for (int i = 0; i < 3; i++) {
    for (var result in results) {
      var isSelected = selectedResult == result;
      list.add(buildChoiceChip(isSelected, result, width).appearAll);
    }
    return list;
  }

  Widget buildChoiceChip(bool isSelected, ResultModel result, double width) {
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
