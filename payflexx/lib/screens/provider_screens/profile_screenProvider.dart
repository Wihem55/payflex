// ignore_for_file: use_build_context_synchronously, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:payflexx/models/provider_model.dart';
import 'package:payflexx/screens/inner_screens/orders/orders_screen.dart';
import 'package:payflexx/services/Managers/loading_manager.dart';
import 'package:payflexx/screens/welcome.dart';
import 'package:payflexx/widgets/text_style/subtitle_text.dart';
import 'package:payflexx/widgets/text_style/title_text.dart';
import 'package:provider/provider.dart';

import '../../Controllers/providers/providerinfo_provider.dart';
import '../../Controllers/providers/theme_provider.dart';
import '../../services/Managers/assets_manager.dart';
import '../../widgets/image_picker/camera_dialog.dart';
import '../../widgets/text_style/app_name_text.dart';
import '../client_screens/adresse.dart';

class ProfileScreenProvider extends StatefulWidget {
  const ProfileScreenProvider({super.key});

  @override
  State<ProfileScreenProvider> createState() => _ProfileScreenProviderState();
}

class _ProfileScreenProviderState extends State<ProfileScreenProvider>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state of the widget alive
  User? user = FirebaseAuth.instance.currentUser; // Get the current user
  bool _isLoading = true; // Loading state
  ProviderUserModel? providerUserModel; // Provider user model

  // Function to fetch provider info
  Future<void> fetchProviderInfo() async {
    if (user == null) {
      setState(() {
        _isLoading = false; // Stop loading if no user is logged in
      });
      return;
    }

    final providerInfo = Provider.of<ProviderInfo>(context, listen: false);
    try {
      providerUserModel = await providerInfo.fetchProviderInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "An error has been occured $error",
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after fetching provider info
      });
    }
  }

  @override
  void initState() {
    fetchProviderInfo(); // Fetch provider info on init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get the screen size
    String smartecoImagePath =
        Provider.of<ThemeProvider>(context).getIsDarkTheme
            ? AssetsManager.smarteco_light
            : AssetsManager.smarteco; // Get image path based on theme
    super.build(context); // Call the build method of the superclass
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const AppNameTextWidget(fontSize: 20),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.balance_outlined),
          ),
        ),
        body: LoadingManager(
          isLoading: _isLoading, // Show loading spinner if loading
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: user == null, // Show if no user is logged in
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TitlesTextWidget(
                        label: "Please login to have Full access"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                providerUserModel == null
                    ? const SizedBox.shrink() // Show nothing if no provider info
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 7,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TitlesTextWidget(
                                    label: providerUserModel!.providerName ??
                                        'NULL'), // Display provider name
                                SubtitleTextWidget(
                                  label: providerUserModel!.email ?? 'NULL', // Display email
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitlesTextWidget(label: "Général"),
                      user == null
                          ? const SizedBox.shrink()
                          : CustomListTile(
                              imagePath: AssetsManager.orderSvg,
                              text: "Toutes les commandes",
                              function: () async {
                                await Navigator.pushNamed(
                                  context,
                                  OrdersPage().routename,
                                );
                              },
                            ),
                            // adresse part 
                      CustomListTile(
                        imagePath: AssetsManager.address,
                        text: "adresses",
                        function: () async {
                          await Navigator.pushNamed(
                            context,
                            AddressPage.routeName,
                          );
                        },
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      const TitlesTextWidget(label: "Paramètres"),
                      const SizedBox(
                        height: 7,
                      ),
                      SwitchListTile(
                        secondary: Image.asset(
                          AssetsManager.theme,
                          height: 30,
                        ),
                        title: Text(themeProvider.getIsDarkTheme
                            ? "Mode sombre"
                            : "Mode clair"),
                        value: themeProvider.getIsDarkTheme,
                        onChanged: (value) {
                          themeProvider.setDarkTheme(themeValue: value);
                        },
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),
                    icon: Icon(user == null ? Icons.login : Icons.logout),
                    label: Text(
                      user == null ? "Se connecter" : "Se déconnecter",
                    ),
                    onPressed: () async {
                      if (user == null) {
                        await Navigator.pushNamed(
                          context,
                          Welcome.routName,
                        );
                      } else {
                        await MyAppMethods.showErrorORWarningDialog(
                          context: context,
                          subtitle: "Êtes-vous sûr ?",
                          fct: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            await Navigator.pushNamed(
                              context,
                              Welcome.routName,
                            );
                          },
                          isError: false,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: Column(
                    children: [
                      const TitlesTextWidget(label: "Présenté par :"),
                      Image.asset(
                        smartecoImagePath,
                        height: size.height * 0.1,
                        width: size.width * 0.9,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// Custom ListTile widget
class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.function});
  final String imagePath, text; // Image path and text for the tile
  final Function function; // Function to execute on tap

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      leading: Image.asset(
        imagePath,
        height: 30,
      ),
      title: SubtitleTextWidget(label: text),
      trailing: const Icon(IconlyLight.arrowRight2),
    );
  }
}
