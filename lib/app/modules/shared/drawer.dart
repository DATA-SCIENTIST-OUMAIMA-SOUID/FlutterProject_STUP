import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:super_talab_user/app/modules/cart_module/cart_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import '../../data/model/Language.dart';
import '../../data/services/helper.dart';
import '../../translations/languageController.dart';
import '../../translations/local_storge.dart';
import '../../utils/constants.dart';
import '../changeaddress_module/changeaddress_page.dart';
import '../chat/inbox_driver_screen.dart';
import '../order_module/my_orders.dart';
import '../profile.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

final box = GetStorage();
Mycontroll mycontroll = Get.put(Mycontroll());

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isSwitched = false;
  //late final Language? _selectedLanguage;
  /*@override
  void initState() {
    // TODO: implement initState
    //execute_lang();
    // _selectedLanguage =Language.languageList()[0]; // Ou toute autre valeur initiale valide
    // ou toute autre logique pour définir une valeur initiale

    _selectedLanguage = languageController.appLocale;
    print(_selectedLanguage!.languageCode);
    super.initState();
  }*/

  /*execute_lang() async {
    await languageController.onInit();
  }*/

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(COLOR_PRIMARY),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        MyApp.currentUser!.firstName,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Row(
                              //   children: [
                              //    isDarkMode()? const Icon(Icons.light_mode_sharp) : const Icon(Icons.nightlight),
                              //    Obx(() => Switch(
                              //      // thumb color (round icon)
                              //      splashRadius: 50.0,
                              //      activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                              //      inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),
                              //      value: _themeController.isDarkMode.value,
                              //      onChanged: (value) {
                              //        _themeController.toggleTheme();
                              //      },
                              //    ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                MyApp.currentUser!.email,
                                maxLines: 2,
                                style: const TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                          title: Text(
                            'search'.tr,
                            style: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.black,
                                fontFamily: "Poppinsr"),
                          ),
                          leading: Icon(
                            Icons.search,
                            color: isDarkMode() ? Colors.white : Colors.black,
                          ),
                          onTap: () async {
                            Get.toNamed('/search');
                            // push(context, const SearchScreen());
                          }),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                          title: Text(
                            'My Address'.tr,
                            style: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.black,
                                fontFamily: "Poppinsr"),
                          ),
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: isDarkMode() ? Colors.white : Colors.black,
                          ),
                          onTap: () async {
                            if (MyApp.currentUser!.userID == '') {
                              Get.offAllNamed('/auth');
                            } else {
                              push(context, changeaddressPage());
                            }
                          }),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                          title: Text(
                            'My Orders'.tr,
                            style: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.black,
                                fontFamily: "Poppinsr"),
                          ),
                          leading: Icon(
                            Icons.shopping_basket,
                            color: isDarkMode() ? Colors.white : Colors.black,
                          ),
                          onTap: () async {
                            if (MyApp.currentUser!.userID == '') {
                              Get.offAllNamed('/auth');
                            } else {
                              push(context, OrdersScreen());
                            }
                          }),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                          title: Text(
                            'Cart'.tr,
                            style: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.black,
                                fontFamily: "Poppinsr"),
                          ),
                          leading: Icon(
                            CupertinoIcons.cart,
                            color: isDarkMode() ? Colors.white : Colors.black,
                          ),
                          onTap: () async {
                            if (MyApp.currentUser!.userID == '') {
                              Get.offAllNamed('/auth');
                            } else {
                              push(context, const cartPage());
                            }
                          }),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListTile(
                          title: Text(
                            'My Profile'.tr,
                            style: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.black,
                                fontFamily: "Poppinsr"),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: isDarkMode() ? Colors.white : Colors.black,
                          ),
                          onTap: () async {
                            if (MyApp.currentUser!.userID == '') {
                              Get.offAllNamed('/auth');
                            } else {
                              push(
                                  context,
                                  ProfileScreen(
                                    user: MyApp.currentUser!,
                                  ));
                            }
                          }),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
                      title: Text('Driver Inbox'.tr,
                          style: Theme.of(context).textTheme.titleMedium),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const InboxDriverScreen());
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.language,
                        color: Colors.black,
                      ),
                      title: Text('Language'.tr,
                          style: Theme.of(context).textTheme.titleMedium),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                'Language'.tr,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              content: Container(
                                width: double.maxFinite,
                                height: 150,
                                child: ListView.builder(
                                  itemCount: Language.languageList().length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: Text(
                                        Language.languageList()[index].flag,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      title: Text(
                                          Language.languageList()[index].name),
                                      //trailing: Icon(Icons.more_vert),
                                      isThreeLine: false,
                                      onTap: () async {
                                        setState(() {
                                          mycontroll.changeLanguage(
                                              Language.languageList()[index]
                                                  .locale);
                                          print(
                                              'the lang ${Get.locale!.languageCode}');

                                          Navigator.pop(
                                              context); // Fermer le dialogue après la sélection de la langue
                                        });
                                        //await mycontroll.getSavedLanguageCode();
                                        //mycontroll.
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    /*  DropdownButton<Language>(
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.black,
                      ),
                      onChanged: (Language? language) {
                        setState(() {
                          _selectedLanguage = language;
                          languageController
                              .changeLanguage(language!.languageCode);

                          print(
                              "lang selectionne : ${_selectedLanguage!.languageCode}");
                        });
                      },
                      //value: _selectedLanguage ?? null,
                      // Set the currently selected language here
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                            (e) => DropdownMenuItem<Language>(
                              value: e,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    e.flag,
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(e.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      hint: Text(
                        "Please choose a langauage",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                   */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => _launchFacebookURL(),
                          child: const Icon(
                            Icons.facebook,
                            size: 35,
                          ),
                        ),
                        InkWell(
                            onTap: () => _launchURL(),
                            child: Image.asset(
                              "assets/images/instagrem.png",
                              width: 35,
                              height: 35,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<void> _launchFacebookURL() async {
    const facebookURL =
        'https://www.facebook.com/profile.php?id=100093891807501&mibextid=2JQ9oc';
    if (await canLaunch(facebookURL)) {
      await launch(facebookURL);
    } else {
      throw 'Could not launch $facebookURL';
    }
  }

  Future<void> _launchURL() async {
    const instagramURL = 'https://www.instagram.com/supertalab/';
    if (await canLaunch(instagramURL)) {
      await launch(instagramURL);
    } else {}
  }
}
