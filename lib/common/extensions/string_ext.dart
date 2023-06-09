// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension StringNullX on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullNotEmpty => this != null && this!.isNotEmpty;
}

extension StringX on String {
  bool get isDigitsOnly {
    for (var char in codeUnits) if (char < 48 || char > 57) return false;
    return true;
  }

  String get sentenceCase => split(' ')
      .map((e) => e.replaceAll('-', ' '))
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join(' ');

  bool get isEmail => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this);

  bool get isPassword =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$')
          .hasMatch(this);

  String get firstWordUpper {
    final words = split(' ');
    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      if (i == 0) {
        buffer.write(words[i]);
      } else {
        buffer.write('\t');
        buffer.write(words[i][0].toLowerCase() + words[i].substring(1));
      }
    }
    return buffer.toString();
  }

  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';

  DateTime get toDate => DateTime.parse(this).toLocal();

  // My:
  Widget toTextButton(
      {Color color = Colors.black,
      double? fontSize,
      TextAlign? textAlign,
      TextStyle? style,
      bool medium = false,
      int? maxLines = 2,
      bool bold = false,
      bool autoRemove = true,
      bool underline = false,
      bool softWrap = false,
      // Bottom params
      IconData? icon,
      GestureTapCallback? onTap,
      Color? tapColor,
      double? px,
      double? py}) {
    var txt = this;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) icon.icon(color: color).pOnly(right: 7),
        txt.toText(
          color: color,
          textAlign: textAlign,
          maxLines: maxLines,
          medium: medium,
          fontSize: fontSize,
          bold: bold,
          underline: underline,
          style: style,
          softWrap: softWrap,
          autoRemove: autoRemove,
        )
      ],
    )
        .px(px ?? 0)
        .py(py ?? 0)
        .onTap(onTap, radius: 5, tapColor: tapColor); // line spacing}
  }

  Text toText({
    Color color = Colors.black,
    double? fontSize,
    TextAlign? textAlign,
    TextStyle? style,
    bool medium = false,
    int? maxLines = 2,
    bool bold = false,
    bool autoRemove = true,
    bool underline = false,
    bool softWrap = false,
  }) {
    var txt = this;
    if (autoRemove) txt = replaceAll(', ישראל', '');

    var defaultStyle = TextStyle(
        color: color,
        fontWeight: FontWeight.normal,
        fontSize: fontSize ?? 14,
        decoration: underline ? TextDecoration.underline : null);

    return Text(txt,
        softWrap: softWrap,
        maxLines: maxLines,
        textAlign: textAlign ?? (txt.isHebrew ? TextAlign.right : TextAlign.left),
        textDirection: txt.isHebrew ? TextDirection.rtl : TextDirection.ltr,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.openSans(
          textStyle: style ??
              (bold
                  ? defaultStyle.copyWith(fontWeight: FontWeight.bold)
                  : medium
                      ? defaultStyle.copyWith(fontWeight: FontWeight.w600)
                      : defaultStyle),
        )); // line spacing}
  }

  // ExpandableText toTextExpanded( // String text,
  //         {
  //       TextStyle? style,
  //       TextAlign? textAlign,
  //       TextDirection? textDirection,
  //       int? maxLines,
  //       Color? linkColor,
  //       ValueChanged<bool>? onChanged,
  //       bool autoExpanded = false,
  //     }) =>
  //     buildExpandableText(
  //       this,
  //       style: style,
  //       linkColor: linkColor ?? AppColors.greyLight,
  //       textAlign: textAlign,
  //       autoExpanded: autoExpanded,
  //       textDirection: textDirection,
  //       maxLines: maxLines,
  //       onChanged: onChanged,
  //     ); // line spacing
  //
  // Text get testText => Text(
  //   this,
  //   style: AppStyles.text18PxSemiBold.white,
  // );

  bool get isEnglish {
    // 'Hello' // true
    // 'Hello אני עידן' // false
    final regex = RegExp(r"^[A-Za-z0-9\s\.,!?':\-]+$");
    return regex.hasMatch(this);
  }

  bool get isHebrew {
    var heb = [
      'א',
      'ב',
      'ג',
      'ד',
      'ה',
      'ו',
      'ז',
      'ח',
      'ט',
      'י',
      'כ',
      'ל',
      'מ',
      'נ',
      'ס',
      'ע',
      'פ',
      'צ',
      'ק',
      'ר',
      'ש',
      'ת',
      'ם',
      'ך',
      'ץ'
    ];

    // if (heb.any((item) => contains(item))) {
    //   // Lists have at least one common element
    //   return true;
    // } else {
    //   // Lists DON'T have any common element
    //   return false;
    // }

    // OLD VERSION
    // ----------
    // actually needs to be map.
    for (var l in heb) {
      if (contains(l)) {
        return true;
      }
    }
    // print('START:  return false;()');
    return false;
  }
}
