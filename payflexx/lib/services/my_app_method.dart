// ignore_for_file: prefer_const_constructors, non_constant_identifier_names



import 'package:flutter/material.dart';

import '../widgets/text_style/subtitle_text.dart';
import '../widgets/text_style/title_text.dart';

class MyAppMethods {
  Future<void> ShowErrorWarningDialog(
      {required BuildContext context,
      required String subtitle,
      required Function Fct,
      bool isError = true}) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               
                const SizedBox(
                  height: 16,
                ),
                SubtitleTextWidget(label: subtitle),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !isError,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: SubtitleTextWidget(
                          label: "Cancel",
                          color: Colors.green,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Fct();
                        Navigator.pop(context);
                      },
                      child: SubtitleTextWidget(
                        label: "Ok",
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  static Future<void> ImagePickerDialog({
    required BuildContext Context,
    required Function CameraFCT,
    required Function galleryFCT,
    required Function removeFCT,
  }) async {
    await showDialog(
        context: Context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Center(
              child: TitlesTextWidget(label: "Choose Option"),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      CameraFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.camera),
                    label: Text("Camera"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      galleryFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.image,
                    ),
                    label: Text("Gallery"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      removeFCT();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    label: Text("Remove"),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
