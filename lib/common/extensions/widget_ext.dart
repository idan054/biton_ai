import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:entry/entry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/color_printer.dart';

var appearDuration = 650;
// var appearDuration = 1550;

extension IconDataX on IconData {
  Icon icon({Color color = Colors.white, double size = 20}) => Icon(
        this,
        color: color,
        size: size,
      );

// FaIcon iconAwesome({Color color = Colors.white, double size = 20}) => FaIcon(
//   this,
//   color: color,
//   size: size,
// );
}

extension CatchErrorExtension<T> on Future<T> {
  Future<T> catchSentryError({void Function(Object err, StackTrace trace)? onError}) {
    return catchError((error, stackTrace) async {
      printWhite('START: catchSentryError()'); // Default error handling action
      printRed('Error: $error');
      print('StackTrace: $stackTrace');
      if (!kDebugMode) await Sentry.captureException(error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error, stackTrace); // Call custom error handler if provided
      }
    });
  }
}

extension WidgetX on Widget {
  // My extension:
  Widget onTap(GestureTapCallback? onTap,
          {double radius = 99, bool longPressMode = false, Color? tapColor}) =>
      Theme(
        data: ThemeData(canvasColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              overlayColor: tapColor != null ? MaterialStateProperty.all(tapColor) : null,
              //   splashColor: Colors.yellow,
              //   focusColor: Colors.yellow,
              //   highlightColor: Colors.yellow,
              //   hoverColor: Colors.yellow,
              borderRadius: BorderRadius.circular(radius),
              onTap: longPressMode ? null : onTap,
              onLongPress: longPressMode ? onTap : null,
              child: this),
        ),
      );

  // Directionality isHebrewDirectionality(String text) => Directionality(
  //     textDirection: text.isHebrew ? TextDirection.rtl : TextDirection.ltr, child: this);

  Container get testContainer =>
      Container(color: Colors.green.withOpacity(0.30), child: this);

  Directionality get rtl => Directionality(textDirection: TextDirection.rtl, child: this);

  Directionality get ltr => Directionality(textDirection: TextDirection.ltr, child: this);

  ClipRRect get roundedFull =>
      ClipRRect(borderRadius: BorderRadius.circular(999), child: this);

  ClipRRect roundedOnly({
    required double bottomLeft,
    required double topLeft,
    required double topRight,
    required double bottomRight,
  }) =>
      ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(bottomLeft),
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomRight: Radius.circular(bottomRight),
          ),
          child: this);

  ClipRRect rounded({double? radius}) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius ?? 99), child: this);

  Entry get appearAll => Entry.all(
        duration: Duration(milliseconds: appearDuration),
        child: this,
      );

  Entry get appearScale => Entry.scale(
        duration: Duration(milliseconds: appearDuration),
        child: this,
      );

  Entry get appearOffset => Entry.offset(
        duration: Duration(milliseconds: appearDuration),
        child: this,
      );

  Entry get appearOpacity => Entry.opacity(
        duration: Duration(milliseconds: appearDuration),
        child: this,
      );

  // rest extension:
  Padding px(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );

  Padding py(double padding, {Key? key}) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        key: key,
        child: this,
      );

  Padding pOnly(
          {double top = 0,
          double right = 0,
          double bottom = 0,
          double left = 0,
          Key? key}) =>
      Padding(
        padding: EdgeInsets.only(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
        ),
        key: key,
        child: this,
      );

  Center get center => Center(child: this);

  Center get centerX => Center(child: this);

  Widget surround(double value) => CircleAvatar(
        backgroundColor: Colors.green,
        child: this,
      );

  Padding pad(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Align get top => Align(
        alignment: Alignment.topCenter,
        child: this,
      );

  Align get topRight => Align(
        alignment: Alignment.topRight,
        child: this,
      );

  Align get topLeft => Align(
        alignment: Alignment.topLeft,
        child: this,
      );

  Align get bottom => Align(
        alignment: Alignment.bottomCenter,
        child: this,
      );

  Align get centerLeft => Align(
        alignment: Alignment.centerLeft,
        child: this,
      );

  Align get centerRight => Align(
        alignment: Alignment.centerRight,
        child: this,
      );

  SizedBox sizedBox(
    double? width,
    double? height,
  ) =>
      SizedBox(
        width: width,
        height: height,
        child: this,
      );

  SizedBox advancedSizedBox(
    context, {
    double? width,
    double? height,
    bool maxWidth = false,
    bool maxHeight = false,
    double wRatio = 1.0,
    double hRatio = 1.0,
  }) {
    double maxHeightSize = MediaQuery.of(context).size.height;
    double maxWidthSize = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width ?? (maxWidth ? maxWidthSize * wRatio : null),
      height: height ?? (maxHeight ? maxHeightSize * hRatio : null),
      child: this,
    );
  }

  Widget offset(double x, double y) => Transform.translate(
        offset: Offset(x, y),
        child: this,
      );

  SliverToBoxAdapter get toSliverBox => SliverToBoxAdapter(child: this);

  Expanded expanded({int flex = 1}) => Expanded(
        flex: flex,
        child: this,
      );

  Flexible flexible({required int flex}) => Flexible(
        flex: flex,
        child: this,
      );

  Transform scale({required double scale}) => Transform.scale(
        scale: scale,
        child: this,
      );

  Padding get customRowPadding =>
      Padding(padding: const EdgeInsets.only(top: 15, bottom: 12), child: this);

  SingleChildScrollView get singleChildHorizScrollView => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: this,
      );

  SingleChildScrollView get singleChildScrollView => SingleChildScrollView(child: this);

// TweenAnimationBuilder<double> speed({required int seconds}) {
//   return TweenAnimationBuilder(
//       duration: Duration(seconds: seconds),
//       tween: Tween<double>(begin: 0, end: 1),
//       builder: (BuildContext context, double value, Widget? child) {
//         return this(value);
//       });
// }
}

Widget verticalDivider({double? height, Color? color}) => Container(
      width: 1.5,
      height: height ?? 1000,
      color: color ?? AppColors.greyLight,
    );
