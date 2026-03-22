// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:payflexx/screens/client_screens/chatbot_page.dart';
import 'package:payflexx/screens/client_screens/pending_orders_screen.dart';
import 'package:payflexx/screens/client_screens/home_view_Client.dart';
import 'package:payflexx/screens/client_screens/profile_screen.dart';
import 'package:provider/provider.dart';

import 'Controllers/providers/fullorder_provider.dart';

class RootScreen extends StatefulWidget {
  static const routName = '/RootScreen';
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with SingleTickerProviderStateMixin {
  late PageController controller;
  int currentScreen = 0;
  List<Widget> screens = [
    const HomeScreen(),
    const PendingOrdersPage(),
    const ProfileScreen()
  ];
  @override
  void initState() {
    super.initState();
    controller = PageController(
      initialPage: currentScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
          ),
          Positioned(
            bottom: 16.0, // Adjust the bottom position as needed
            right: 16.0, // Adjust the right position as needed
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              child: const Icon(
                Icons.chat,
                color: Color.fromARGB(255, 19, 68, 94),
              ),
              backgroundColor: const Color.fromARGB(255, 198, 211, 0),
              elevation: 10,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 2,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index) {
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(currentScreen);
        },
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.list_alt),
            icon: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                return FutureBuilder(
                  future: orderProvider.fetchPendingOrders(),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    int count = 0;
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        count =
                            snapshot.data!.length; // Number of pending orders
                      }
                    }
                    return Badge(
                      backgroundColor: Colors.red,
                      label: Text(count.toString()),
                      child: const Icon(Icons.list_alt),
                    );
                  },
                );
              },
            ),
            label: "Orders",
          ),
         const  NavigationDestination(
            selectedIcon: Icon(IconlyBold.profile),
            icon: Icon(IconlyLight.profile),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
