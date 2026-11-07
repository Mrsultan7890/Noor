import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ArabicLabel extends StatelessWidget {
  const ArabicLabel(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  static final _arabicRun = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+',
  );

  @override
  Widget build(BuildContext context) {
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    var offset = 0;
    for (final match in _arabicRun.allMatches(data)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: data.substring(offset, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(fontFamily: 'Amiri', letterSpacing: 0),
        ),
      );
      offset = match.end;
    }
    if (offset < data.length) {
      spans.add(TextSpan(text: data.substring(offset)));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      style: inheritedStyle.merge(style),
    );
  }

}

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
