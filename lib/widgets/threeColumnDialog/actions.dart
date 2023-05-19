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

List<WooCategoryModel> sortCategories(List<WooCategoryModel> list) {
  dynamic googleItem;
  dynamic productName;
  dynamic shortDesc;
  dynamic longDesc;
  dynamic tag;
  for (var cat in list) {
    if (cat.slug.contains('google')) googleItem = cat;
    if (cat.slug.contains('product-name')) productName = cat;
    if (cat.slug.contains('short')) shortDesc = cat;
    if (cat.slug.contains('long')) longDesc = cat;
    if (cat.slug.contains('tag')) tag = cat;
  }
  // Todo add "Tags" support
  // return [googleItem, productName, shortDesc, longDesc, tag];
  return [googleItem, productName, shortDesc, longDesc];
}