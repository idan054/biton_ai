import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    this.title,
    this.onPressed,
    this.titleStyle,
    this.backgroundColor = AppColors.primaryShiny,
    this.shape,
    this.invert = false,
    this.width = 140,
    this.height = 45,
    this.loading = false,
    this.isDisabled = false,
    this.icon,
    this.elevation = 0,
    this.gap = 17,
    this.splashColor,
  }) : super(key: key);

  final String? title;
  final Widget? icon;
  final double gap;
  final double elevation;
  final VoidCallback? onPressed;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final ShapeBorder? shape;
  final double width;
  final double height;
  final bool invert;
  final bool loading;
  final bool isDisabled;
  final Color? splashColor;

  ShapeBorder get _shape =>
      shape ??
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side:
              invert ? BorderSide(color: backgroundColor, width: 2.0) : BorderSide.none);

  BoxConstraints get _constraints =>
      BoxConstraints.tightFor(width: width, height: height);

  Color get _splashColor => AppColors.white.withOpacity(0.4);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      color: invert
          ? Colors.transparent
          : isDisabled
              ? AppColors.greyUnavailable
              : backgroundColor,
      shape: _shape,
      elevation: elevation,
      child: InkWell(
        splashColor: _splashColor,
        onTap: isDisabled || loading ? null : onPressed,
        child: ConstrainedBox(
          constraints: _constraints,
          child: Ink(
            decoration: ShapeDecoration(
              shape: _shape,
              color: invert
                  ? Colors.transparent
                  : isDisabled
                      ? AppColors.greyText
                      : backgroundColor,
            ),
            child: loading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: backgroundColor == AppColors.white ||
                                backgroundColor == AppColors.transparent
                            ? AppColors.primaryShiny
                            : AppColors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        if (title != null) 3.horizontalSpace,
                      ],
                      if (title != null)
                        title!.toText(
                          medium: invert,
                          color: invert ? backgroundColor : Colors.white,
                          fontSize: 15,
                        )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
