import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(
    this.data, {
    super.key,
    this.style,
    this.textAlign = TextAlign.right,
    this.maxLines,
    this.softWrap = true,
  });

  final String data;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final fontScale = context.watch<ThemeProvider>().arabicFontScale;
    final baseStyle = style ?? const TextStyle(fontSize: 24, height: 2);

    return Text(
      data,
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      softWrap: softWrap,
      style: baseStyle.copyWith(
        fontFamily: 'Amiri',
        fontSize: (baseStyle.fontSize ?? 24) * fontScale,
        letterSpacing: 0,
      ),
    );
  }
}
