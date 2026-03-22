// ignore_for_file: prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:payflexx/screens/provider_screens/home_view_provider.dart';
import 'package:payflexx/screens/provider_screens/profile_screenProvider.dart';

class MainTabView extends StatefulWidget {
  static const routName = '/maintabview';
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0; // Current index of the selected tab
  final List widgetIcons = const [
    Icons.home,
    IconlyLight.profile,
  ]; // Icons for the tabs
  final List widgetTitles = const [
    'Home',
    'Profile',
  ]; // Titles for the tabs

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex, // Display the selected tab's content
          children: const [
            HomeViewProvider(), // Home tab content
            ProfileScreenProvider(), // Profile tab content
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          notchMargin: 10,
          shadowColor: Colors.purple,
          shape: const CircularNotchedRectangle(), // Floating action button notch
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Spacer(),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              _onItemTapped(0); // Select Home tab
                            },
                            constraints: const BoxConstraints(
                              minWidth: 50,
                              minHeight: 50,
                            ),
                            icon: Icon(
                              widgetIcons[0],
                              color: _selectedIndex == 0
                                  ? const Color.fromARGB(255, 155, 196, 32) // Active color
                                  : Colors.grey, // Inactive color
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                const Spacer(),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _onItemTapped(1); // Select Profile tab
                      },
                      constraints: const BoxConstraints(
                        minWidth: 50,
                        minHeight: 50,
                      ),
                      icon: Icon(
                        widgetIcons[1],
                        color: _selectedIndex == 1
                            ? const Color.fromARGB(255, 155, 196, 32) // Active color
                            : Colors.grey, // Inactive color
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
