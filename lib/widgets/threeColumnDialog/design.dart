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
import 'package:http/http.dart';

import '../../common/constants.dart';
import '../../common/extensions/widget_ext.dart';
import '../../common/models/category/woo_category_model.dart';
import '../../common/models/prompt/result_model.dart';
import '../customButton.dart';

var fieldTitleStyle = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 7),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    // enabledBorder: UnderlineInputBorder(
    //   borderRadius: BorderRadius.circular(4),
    //   borderSide: BorderSide(color: AppColors.greyUnavailable80, width: 1.5),
    // ),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
    ));

InputDecoration fieldPromptStyle(bool isDefault, {bool intlPhoneField = false}) =>
    InputDecoration(
        filled: isDefault,
        contentPadding: isDefault || intlPhoneField
            ? null
            : const EdgeInsets.symmetric(horizontal: 6),
        fillColor: AppColors.greyLight.withOpacity(0.40),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: AppColors.greyLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: AppColors.greyLight, width: 1.5),
        ));

Widget fieldTitle(String text) => text
    .toText(medium: true, color: AppColors.greyUnavailable80, fontSize: 14)
    .py(7)
    .px(5)
    .centerLeft;
