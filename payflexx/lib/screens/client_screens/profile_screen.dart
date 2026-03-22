// ignore_for_file: use_build_context_synchronously, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:payflexx/screens/client_screens/adresse.dart';
import 'package:payflexx/screens/client_screens/update_userInfo.dart';
import 'package:payflexx/screens/inner_screens/orders/orders_screen.dart';
import 'package:payflexx/services/Managers/loading_manager.dart';
import 'package:payflexx/screens/welcome.dart';
import 'package:payflexx/services/auth/securepin_dialog.dart';
import 'package:payflexx/widgets/text_style/subtitle_text.dart';
import 'package:payflexx/widgets/text_style/title_text.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../Controllers/providers/theme_provider.dart';
import '../../Controllers/providers/userinfo_provider.dart';
import '../../services/Managers/assets_manager.dart';
import '../../widgets/image_picker/camera_dialog.dart';
import '../../widgets/Qr code/qr_generator.dart';
import '../../widgets/text_style/app_name_text.dart';
import '../../widgets/Qr code/displayQrCode.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  UserModel? userModel;

  Future<void> fetchUserInfo() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      userModel = await userProvider.fetchUserInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "An error has been occured $error",
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String smartecoImagePath =
        Provider.of<ThemeProvider>(context).getIsDarkTheme
            ? AssetsManager.smarteco_light
            : AssetsManager.smarteco;
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const AppNameTextWidget(fontSize: 20),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.balance_outlined),
        ),
      ),
      body: LoadingManager(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: user == null ? true : false,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TitlesTextWidget(
                      label: "Please login to have Full access"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              userModel == null
                  ? const SizedBox.shrink()
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
                              TitlesTextWidget(label: userModel!.userName),
                              SubtitleTextWidget(
                                label: userModel!.userEmail,
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
                                const OrdersPage().routename,
                              );
                            },
                          ),
                    user == null
                        ? const SizedBox.shrink()
                        : CustomListTile(
                            imagePath: AssetsManager.qrCode,
                            text: "Code Qr",
                            function: () async {
                              SecurePinDialog.show(context, () async {
                                String userInfo = await QRCodeService()
                                    .fetchAndCombineUserInfo(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DisplayQRCodePage(userInfo: userInfo),
                                  ),
                                );
                              });
                            },
                          ),
                    CustomListTile(
                      imagePath: AssetsManager.address,
                      text: "Adresses",
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
                    CustomListTile(
                      imagePath: AssetsManager.updateUser,
                      text: "Mettre à jour les informations de l'utilisateur",
                      function: () async {
                        SecurePinDialog.show(context, () async {
                          Navigator.pushNamed(context, updateUserInfo.routName);
                        });
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
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.function});
  final String imagePath, text;
  final Function function;
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
