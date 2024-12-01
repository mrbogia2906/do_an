import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final Map<String, HighlightStyle> words;
  final TextStyle textStyle;
  final int? maxLines; // Thêm tham số maxLines
  final TextOverflow overflow; // Thêm tham số overflow

  const HighlightText({
    required this.text,
    required this.words,
    required this.textStyle,
    this.maxLines = 3,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final highlightedText = _highlightWords(text);
    return Text.rich(
      TextSpan(children: highlightedText),
      style: textStyle,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<TextSpan> _highlightWords(String text) {
    List<TextSpan> spans = [];
    int start = 0;

    // Loại bỏ dấu của từ khóa và văn bản
    String normalizedText = removeDiacritics(text);

    words.forEach((keyword, highlightStyle) {
      final normalizedKeyword =
          removeDiacritics(keyword); // Loại bỏ dấu của từ khóa

      // Tạo regex tìm kiếm chính xác cụm từ khóa liền nhau
      final regex = RegExp(r'\b' + RegExp.escape(normalizedKeyword) + r'\b',
          caseSensitive: false);
      Iterable<Match> matches = regex.allMatches(normalizedText);

      for (var match in matches) {
        if (match.start > start) {
          spans.add(TextSpan(text: text.substring(start, match.start)));
        }

        spans.add(TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle.textStyle,
        ));
        start = match.end;
      }
    });

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  String removeDiacritics(String text) {
    const diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };

    return text.split('').map((char) {
      return diacriticsMap[char] ?? char;
    }).join('');
  }
}

class HighlightStyle {
  final TextStyle textStyle;
  final Color backgroundColor;

  HighlightStyle({required this.textStyle, required this.backgroundColor});
}
