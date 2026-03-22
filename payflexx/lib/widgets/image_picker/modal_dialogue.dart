// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import '../../Colors/global_Colors.dart';

void imagePickerModal(BuildContext context,
    {VoidCallback? onCameraTap, VoidCallback? onGalleryTap}) {
  showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(12.0),
          height: 220,
          child: Column(
            children: [
              GestureDetector(
                onTap: onCameraTap,
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(color: PColor.gray70),
                    padding: EdgeInsets.all(15.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: onGalleryTap,
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(color: PColor.gray70),
                    padding: EdgeInsets.all(15.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
