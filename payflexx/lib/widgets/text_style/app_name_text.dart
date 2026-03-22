import 'package:flutter/material.dart';
import 'package:payflexx/widgets/text_style/title_text.dart';
import 'package:shimmer/shimmer.dart';

class AppNameTextWidget extends StatelessWidget {
  const AppNameTextWidget({super.key, this.fontSize = 30});
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(seconds: 10),
      baseColor: const Color.fromARGB(255, 19, 68, 94),
      highlightColor: const Color.fromARGB(255, 198, 211, 0),
      child: TitlesTextWidget(
        label: "Payflex",
        fontSize: fontSize,
      ),
    );
  }
}
