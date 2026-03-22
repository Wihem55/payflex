// ignore_for_file: use_build_context_synchronously, sort_child_properties_last, unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:payflexx/screens/provider_screens/new_order.dart';
import 'package:payflexx/services/auth/securepin_dialog.dart';
import 'package:payflexx/widgets/text_style/app_name_text.dart';
import '../../widgets/animatedButton/animated_button.dart';
import '../../widgets/heads/headProvider.dart';

Size getScreenSize(BuildContext context) {
  final mediaQueryData = MediaQuery.of(context).size;
  return mediaQueryData;
}

class HomeViewProvider extends StatefulWidget {
  static const routeName = '/HomeViewProvider';

  const HomeViewProvider({super.key});

  @override
  State<HomeViewProvider> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeViewProvider>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Light Grey background
      appBar: AppBar(
        title: const AppNameTextWidget(fontSize: 30),
        backgroundColor: const Color(0xFF1E1E2C), // Dark Grey-Blue
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.balance_outlined,
              color: Color(0xFF9E9E9E)), // Grey icon
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const headWidgetProvider(),
              const SizedBox(height: 25),
              const SizedBox(height: 20),
              AnimatedAddButton(
                onPressed: () async {
                  SecurePinDialog.show(context, () async {
                    Navigator.pushNamed(context, proceedCommand.routeName);
                  });
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
