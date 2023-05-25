import 'package:biton_ai/common/models/category/woo_category_model.dart';
import 'package:biton_ai/common/models/user/woo_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';

class UniProvider with ChangeNotifier {
  WooUserModel currUser = const WooUserModel();
  double textstoreBarLoader = 0.0;
  List<WooCategoryModel> categories = [];
  List<WooPostModel> fullPromptList = [];
  List<WooPostModel> inUsePromptList = [];


  void updateWooUserModel(WooUserModel data, {bool notify = true}) {
    currUser = data;
    if (notify) notifyListeners();
  }

  void updateTextstoreBarLoader(double data, {bool notify = true}) {
    textstoreBarLoader = data;
    if (notify) notifyListeners();
  }

  void updateCategories(List<WooCategoryModel> data, {bool notify = true}) {
    categories = data;
    if (notify) notifyListeners();
  }

  void updateInUsePromptList(List<WooPostModel> data, {bool notify = true}) {
    inUsePromptList = data;
    if (notify) notifyListeners();
  }

  void updateFullPromptList(List<WooPostModel> data, {bool notify = true}) {
    fullPromptList = data;
    if (notify) notifyListeners();
  }

// NOT WORKS
// void updateValues<T>({required T value, required T newData, bool notify = true}) {
//   value = newData;
//   if (notify) notifyListeners();
// }
}
