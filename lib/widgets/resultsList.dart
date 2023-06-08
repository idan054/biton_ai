import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/widgets/hoverFadeWidget.dart';
import 'package:flutter/material.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title += // 'Select' // ' Google Result';
          ' Google Display options';
      break;
    case ResultCategory.titles:
      title += // 'Select'
          ' Product Name';
      break;
    case ResultCategory.shortDesc:
      title += // 'Select'
          ' Short Description';
      break;
    case ResultCategory.longDesc:
      title += 'Long Description';
      break;
    case ResultCategory.tags:
      title += 'Tags';
      break;
  }
  return title;
}

class ResultsList extends StatefulWidget {
  final String exampleUrl;
  final List<ResultModel> results;
  final void Function(ResultModel result) onSelect;
  final void Function(List<ResultModel> results, ResultModel sResult) onChange;

  const ResultsList({
    super.key,
    required this.exampleUrl,
    required this.results,
    required this.onSelect,
    required this.onChange,
  });

  @override
  State<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  ResultModel? selectedResult; // AKA var
  List<ResultModel> results = [];
  final mainNode = FocusNode();

  @override
  void initState() {
    results = widget.results;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('START: ResultsList()');
    // print('${results.length} results: $results');
    // print('------');

    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;

    String resultsTitle = '';
    if (results.isNotEmpty) resultsTitle = titleByCategory(results.first.category!);
    return Column(
      children: [
        const SizedBox(height: 5),
        if (results.isNotEmpty)
          resultsTitle
              .toText(color: AppColors.greyText, fontSize: 18, medium: true)
              .px(15)
              .pOnly(top: desktopMode ? 30 : 15)
              .topLeft,
        SizedBox(height: desktopMode ? 10 : 5),
        desktopMode
            ? SizedBox(
                width: width,
                child: Row(
                  children: cardList(),
                ).singleChildHorizScrollView)
            : SizedBox(
                width: width,
                child: Column(
                  children: cardList(),
                ).singleChildScrollView,
              ),
      ],
    );
  }

  List<Widget> cardList() {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;

    List<Widget> list = [];
    // for (int i = 0; i < 3; i++) {
    for (var result in results) {
      var isSelected = (selectedResult == result);
      if (selectedResult != null && !isSelected && appConfig_collapseMode) {
        // Hide unselected items
      } else {
        list.add(buildChoiceChip(isSelected, result).appearAll);

        if (isSelected && appConfig_collapseMode) {
          final arrowIcon = RotatedBox(
            quarterTurns: desktopMode ? 3 : 4,
            child: Icons.expand_circle_down
                .icon(color: AppColors.greyUnavailable.withOpacity(0.40), size: 35)
                .pad(5)
                .onTap(() {
              // Deselect:
              selectedResult = null;

              widget.onSelect(result); // ?
              setState(() {});
            }).px(10),
          );
          list.add(arrowIcon);
        }
      }
    }
    return list;
  }

  Widget buildChoiceChip(bool isSelected, ResultModel result) {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;

    // This rebuild when user select choiceship()
    var mainTitleController = TextEditingController(text: result.title.toString());
    var gDescController = TextEditingController(text: result.desc.toString());
    // var wDrawer = 250;
    var wDrawer = desktopMode ? 50 : 0;
    bool isHovered = false;

    var cardWidth = result.category == ResultCategory.longDesc
        ? (width - wDrawer) * 0.9
        : (width - wDrawer) * (desktopMode ? 0.3 : 1.0);

    dynamic cardHeight = 0.0;
    if (results.isNotEmpty) {
      if (widget.results.first.category == ResultCategory.gResults) cardHeight = 200.0;
      if (widget.results.first.category == ResultCategory.titles) cardHeight = 115.0;
      if (widget.results.first.category == ResultCategory.shortDesc) cardHeight = 150.0;
      // if (widget.results.first.category == ResultCategory.longDesc) cardHeight = 350.0;
    }

    // print('cardHeight ${cardHeight} - isSelected ${isSelected}');

    if (isSelected) {
      return StatefulBuilder(builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Stack(
            children: [
              SizedBox(
                  width: cardWidth,
                  // height: cardHeight,
                  child: buildCardResult(
                      isSelected, result, mainTitleController, gDescController)),
              Positioned(
                bottom: 15,
                right: 45,
                child: buildCopyButton(
                    context,
                    isHovered,
                    '${mainTitleController.text}'
                    '${gDescController.text.isNotEmpty ? '\n${gDescController.text}' : ''} ',
                    Icons.create,
                    onEditTap: () => mainNode.requestFocus()),
              ),
              Positioned(
                bottom: 15,
                right: 5,
                child: buildCopyButton(
                  context,
                  isHovered,
                  '${mainTitleController.text}'
                  '${gDescController.text.isNotEmpty ? '\n${gDescController.text}' : ''} ',
                  Icons.content_copy,
                ),
              ),
            ],
          ),
        );
      });
    }

    return SizedBox(
      width: cardWidth,
      // height: cardHeight,
      child: ChoiceChip(
        backgroundColor: AppColors.lightPrimaryBg,
        // backgroundColor: AppColors.lightShinyPrimary,
        selectedColor: AppColors.lightPrimaryBg,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
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
        label: buildCardResult(isSelected, result, mainTitleController, gDescController)
            .px(desktopMode ? 8 : 4),
      ),
    ).py(desktopMode ? 0 : 5);
  }

  Widget buildCardResult(
    bool isSelected,
    ResultModel result,
    TextEditingController mainTitleController,
    TextEditingController gDescController,
  ) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    var isGoogleItem = result.category == ResultCategory.gResults;
    var isProductTitle = result.category == ResultCategory.titles;
    var isShortDesc = result.category == ResultCategory.shortDesc;
    var isLongDesc = result.category == ResultCategory.longDesc;

    ResultModel? oldResultChange;
    void onTextFieldChange() {
      var newResultChange = result.copyWith(
        title: mainTitleController.text,
        desc: gDescController.text,
      );
      selectedResult = newResultChange;
      var i = results.indexWhere((r) => r == (oldResultChange ?? result));
      results.remove(oldResultChange ?? result);
      oldResultChange = newResultChange;
      results.insert(i, newResultChange);
      widget.onChange(results, newResultChange);
    }

    const opacity = 0.50;
    final txtColor = (selectedResult == null || isSelected)
        ? AppColors.greyText
        : AppColors.greyText.withOpacity(opacity);

    return Card(
      // color: (selectedResult == null || isSelected) ? AppColors.white : Colors.grey[200],
      color: AppColors.white,
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.5),
        // side: isSelected && !isLongDesc && appConfig_highlightSelection
        //     ? const BorderSide(color: AppColors.primaryShiny, width: 2.0)
        //     : BorderSide.none
      ),
      child:
          // region LisTile
          ListTile(
        // minVerticalPadding: 30,
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
        title: Column(
          mainAxisSize: isGoogleItem ? MainAxisSize.min : MainAxisSize.max,
          // mainAxisSize: MainAxisSize.min,
          children: [
            // if (isGoogleItem)
            //   Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icons.travel_explore
            //           .icon(color: AppColors.greyUnavailable)
            //           .pOnly(right: 5),
            //       TextField(
            //         enabled: false,
            //         controller: TextEditingController(text: widget.exampleUrl),
            //         style:
            //             const TextStyle(fontSize: 15, color: AppColors.greyUnavailable),
            //         maxLines: 1,
            //         decoration: InputDecoration(
            //           isDense: true,
            //           contentPadding: EdgeInsets.zero,
            //           hintText: 'Add your Google Title',
            //           hintStyle: TextStyle(color: AppColors.greyText),
            //           border: InputBorder.none,
            //         ),
            //       ).pOnly(top: 5).expanded(),
            //     ],
            //   ),

            const SizedBox(height: 5),
            TextField(
              focusNode: mainNode,
              enabled: isSelected,
              controller: mainTitleController,
              style: TextStyle(
                height: 1.4, //line spacing
                fontSize: isProductTitle || isGoogleItem ? 18 : 15,
                fontWeight: isProductTitle || isGoogleItem ? FontWeight.bold : null,
                color: isGoogleItem
                    ? (selectedResult == null || isSelected
                        ? AppColors.googleTitleBlue
                        : AppColors.googleTitleBlue.withOpacity(opacity))
                    : txtColor,
              ),
              minLines: 1,
              maxLines: isShortDesc ? 20 : 3,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) => onTextFieldChange(),
            ),
            // .pOnly(right: isLongDesc ? width * 0.25 : 0),
          ],
        ),
        subtitle: (isGoogleItem && (result.desc ?? '').isNotEmpty)
            ? Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    enabled: isSelected,
                    controller: gDescController,
                    style: TextStyle(
                      fontSize: 15,
                      color: txtColor,
                      height: 1.2, //line spacing
                    ),
                    minLines: 1,
                    maxLines: 10,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) => onTextFieldChange(),
                  ),
                  // if (isGoogleItem) const Spacer(),
                ],
              )
            : null,
      ).px(isSelected ? 20 : 15),
      // endregion child
    );
  }
}

// Use it with Stack (needed) + below code for HoverOnly mode (optional)
// MouseRegion(
// onEnter: (_) => setState(() => isHovered = true),
// onExit: (_) => setState(() => isHovered = false),
// child:
Widget buildCopyButton(BuildContext context, bool showButton, String text, IconData icon,
    {VoidCallback? onEditTap, String? label}) {
  Color txtColor = label == null ? Colors.black.withOpacity(0.60) : AppColors.greyText;

  return AnimatedOpacity(
    opacity: showButton ? 1.0 : 1.0,
    duration: const Duration(milliseconds: 150),
    child: TextButton.icon(
      style: TextButton.styleFrom(
        elevation: 0,
        backgroundColor: label != null ? AppColors.lightShinyPrimary : Colors.white60,
        foregroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        disabledBackgroundColor: AppColors.transparent,
        disabledForegroundColor: AppColors.transparent,
        shape: 5.roundedShape,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      ),
      onPressed: icon == Icons.content_copy
          ? () {
              Clipboard.setData(ClipboardData(text: text)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Data successfully copied to clipboard")));
              });
            }
          : onEditTap,
      icon: icon.icon(size: 21, color: txtColor),
      // label: const Offstage(),
      label:
          label == null ? const Offstage() : label.toText(color: txtColor, medium: true),
      // label: ''.toText(),
    ),
  );
}
