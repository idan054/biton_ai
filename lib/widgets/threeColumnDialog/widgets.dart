// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names

import 'dart:developer';

import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

import '../../common/constants.dart';
import '../../common/extensions/widget_ext.dart';
import '../../common/models/category/woo_category_model.dart';
import '../../common/models/prompt/result_model.dart';
import '../customButton.dart';
import '../resultsCategoriesList.dart';

Widget buildCloseButton(BuildContext context, {required VoidCallback onPressed}) {
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
      onPressed: onPressed,
      child: 'Close'.toText(
        color: AppColors.greyText,
        fontSize: 15,
      ),
    ),
  );
}

Widget buildTextstoreButton({
  bool isLoading = false,
  bool createMode = true,
  bool invert = false,
  Widget? icon,
  double? width,
  required String title,
  bool isUnavailable = false,
  VoidCallback? onPressed,
}) {
  // bool defaultSelected = sRadioPost != null && sRadioPost!.isAdmin && !_createMode;
  // if (defaultSelected) return const Offstage();

  return CustomButton(
    width: width ?? 105,
    height: 45,
    invert: invert,
    icon: icon,
    title: isLoading ? 'Loading...' : title,
    backgroundColor: isLoading
        ? AppColors.greyUnavailable80
        : (AppColors.secondaryBlue.withOpacity(isUnavailable ? 0.3 : 1.0)),
    onPressed: isLoading || isUnavailable ? null : onPressed,
  );
}

Container buildDialogCategories(
  BuildContext context,
  double categorySize,
  List<WooCategoryModel> categories,
  WooCategoryModel? selectedCategory, {
  required Function(WooCategoryModel category) onTap,
}) {
  return Container(
    width: categorySize,
    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
    decoration: BoxDecoration(
      color: AppColors.lightPrimaryBg,
      borderRadius: BorderRadius.only(topLeft: 15.circular, bottomLeft: 15.circular),
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
              Icons.travel_explore,
              Icons.title,
              Icons.notes_rounded,
              Icons.description_rounded,
              Icons.tag,
            ];

            final sIcon = icons[i];
            final isSelected = category == selectedCategory;
            final isGoogleCategory = categories.first == categories[i];
            final color = isSelected ? AppColors.secondaryBlue : AppColors.greyText;

            List<ResultCategory> customPromptCategories =
                setCustomPromptsCategories(context);
            bool isCustomPrompt = customPromptCategories.contains(category.type);

            return Card(
              color: isSelected ? AppColors.lightShinyPrimary : AppColors.lightPrimaryBg,
              elevation: 0,
              shape: 5.roundedShape,
              child: ListTile(
                horizontalTitleGap: 0,
                leading: sIcon
                    .icon(color: color, size: 22)
                    .pOnly(top: isGoogleCategory ? 5 : 0),
                trailing: isCustomPrompt
                    ? Icons.manage_accounts.icon(color: color, size: 22)
                    : null,
                title: category.name.toString().toText(
                      medium: true,
                      color: color,
                      fontSize: 15,
                    ),
                // subtitle: kDebugMode ? 'ID: ${category.id}'
                subtitle: isGoogleCategory
                    ? 'Title & Description'.toString().toText(color: color, fontSize: 13)
                    : null,
                onTap: () => onTap(category),
              ),
            );
          },
        ).expanded(),
      ],
    ),
  );
}
