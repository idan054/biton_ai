// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:html';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../common/constants.dart';
import '../common/models/category/woo_category_model.dart';
import '../common/models/post/woo_post_model.dart';
import '../common/models/prompt/result_model.dart';
import '../common/models/user/woo_user_model.dart';
import '../common/services/createProduct_service.dart';
import '../common/services/gpt_service.dart';
import '../widgets/registerDialog/register_dialog.dart';
import '../widgets/threeColumnDialog/actions.dart';
import '../widgets/threeColumnDialog/threeColumnDialog.dart';

bool get isMobileDevice {
  final userAgent = window.navigator.userAgent.toLowerCase();
  return userAgent.contains('android') || userAgent.contains('iphone');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchController =
      // TextEditingController();
      // TextEditingController(text: kDebugMode ? 'Nike Air Max 90' : null);
      TextEditingController(text: kDebugMode ? 'מדפסת 3D Ender3' : null);

  //
  List<WooCategoryModel> _categories = [];
  List<WooPostModel> _promptsList = [];
  List<WooPostModel> _inUsePrompts = [];
  WooUserModel? currUser;
  String? errorMessage;
  bool buyTokensMessage = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => setup());
    super.initState();
  }

  void setup({bool forceDialog = false}) async {
    print('START: setup()');
    final initToken = context.uniProvider.currUser.token;
    print('initToken $initToken');
    getCategories();

    print('initToken == null ${initToken == null}');
    print('isMobileDevice $isMobileDevice');
    if (initToken == null || forceDialog) {
      if (isMobileDevice) {
        print('START: await Navigator.pushReplacement(()');
        await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Scaffold(
                      backgroundColor: AppColors.lightPrimaryBg,
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const RegisterDialog(),
                          const Spacer(),
                          appVersion.toText(fontSize: 12).pad(10).center,
                        ],
                      ),
                    )));
      } else {
        print('START:  await showDialog(()');
        await showDialog(
          context: context,
          barrierDismissible: initToken != null,
          builder: (BuildContext context) {
            return const RegisterDialog();
          },
        );
      }
    }

    final updatedToken = context.uniProvider.currUser.token;
    await getUser(updatedToken!); // SET currUser
    getPrompts(); // USE  currUser
  }

  Future getUser(String token) async {
    print('START: getUser()');
    _profileLoading = true;
    currUser = null;
    setState(() {});

    currUser = await WooApi.getUserByToken(token).catchError((err) {
      printRed('My ERROR getUserByToken: $err');
      errorMessage = err.toString().replaceAll('Exception: ', '');
      setState(() {});
    });
    context.uniProvider.updateWooUserModel(currUser!.copyWith(token: token));

    print('uniProvider.currUser.toJson() ${context.uniProvider.currUser.toJson()}');

    _profileLoading = false;
    setState(() {});
  }

  void getPrompts() async {
    _promptsList = [];
    _inUsePrompts = [];
    setState(() {});

    _promptsList = await getAllUserPrompts(currUser!);
    _inUsePrompts = await setSelectedList(context, _promptsList).catchSentryError();

    context.uniProvider.updateFullPromptList(_promptsList);
    context.uniProvider.updateInUsePromptList(_inUsePrompts);
    setState(() {});
  }

  void getCategories() async {
    if (_categories.isEmpty) {
      _categories = await WooApi.getCategories();
      _categories = sortCategories(_categories);
      context.uniProvider.updateCategories(_categories);
      setState(() {});
    }
  }

  bool _profileLoading = false;
  bool _isLoading = false;
  Timer? _timer; // 1 time run.
  String? loadingText;
  int loadingIndex = 0;

  void startLoader(String input) {
    List loaderActivities = [
      // '',
      'Get info about $input...',
      'Summery info about $input...',
      'Create 3 Google Titles...',
      'Create 3 Google Descriptions...',
      'Improve Google Titles & Descriptions SEO...',
      'Generate 3 Amazing Titles for your Product page...',
      'Generate 3 Short Descriptions (3-5 lines) for your Product page...',
      'Create a sales article for your Product page...',
    ];
    loadingText ??= loaderActivities.first;
    if (_isLoading && _timer == null) {
      _timer = Timer.periodic(4000.milliseconds, (timer) {
        // > Cycle loaderActivities list:
        // loadingIndex = (loadingIndex + 1) % loaderActivities.length;

        //> Stop at end loaderActivities list:
        if (loadingIndex < loaderActivities.length - 1) loadingIndex++;

        loadingText = loaderActivities[loadingIndex];
        setState(() {});
      });
    }
  }

  void _logoutUser() async {
    print('START: _logoutUser()');
    currUser = null;
    context.uniProvider.updateWooUserModel(const WooUserModel());
    appConfig_userJwt = '';
    setState(() {});
    final box = await Hive.openBox('currUserBox');
    box.clear();
  }

  // void _redirectWebsite() async {
  //   print('START: _redirectWebsite()');
  //
  //   _profileLoading = true;
  //   setState(() {});
  //   final userWebToken = await WooApi.userWebToken();
  //   String url = 'https://textstore.ai/my-account/?mo_jwt_token=$userWebToken';
  //   print('url ${url}');
  //   await Future.delayed(350.milliseconds);
  //   _profileLoading = false;
  //   setState(() {});
  //
  //   // window.open(url, '_blank');
  //   window.open(url, 'New Tab');
  // }

  @override
  Widget build(BuildContext context) {
    // var loader = context.listenUniProvider.textstoreBarLoader;
    _isLoading = _isLoading && errorMessage == null;
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 850;

    return Scaffold(
        backgroundColor: AppColors.lightPrimaryBg,
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildHomeMenu(context,
                    isAlignLeft: true,
                    onTapLogin: () async => setup(forceDialog: true),
                    onTapAdvanced: (_categories.isEmpty || _promptsList.isEmpty)
                        ? () {}
                        : () => _handleOnAdvanced()
                    // : () async => _redirectWebsite()),
                    )
                .centerLeft,
            // const SizedBox(height: 230),
            const Spacer(),
            Hero(
                tag: 'textStoreAi',
                child:
                    // textStoreAi.toText(fontSize: 50, bold: true),
                    Image.asset('assets/DARK-LOGO.png', height: desktopMode ? 82 : 68)
                        .offset(desktopMode ? -35 : -25, desktopMode ? 10 : 5)),

            // const SizedBox(height: 10),
            // 'Sell more by Ai Text for your store'.toText(fontSize: 20).px(25),
            // 'Fast | Create product | SEO'.toText(fontSize: 20).px(25),
            // 'Ai that make sales'.toText(fontSize: 20).px(25),
            // 'Sell more with Ai text for your store'
            // 'Boost sales with Ai products'
            'Make products with Ai & Boost sales'
                .toText(
                  fontSize: desktopMode ? 16 : 14,
                  textAlign: TextAlign.center,
                )
                .px(25),
            const SizedBox(height: 35),
            // region Search TextField
            textStoreBar(
              context,
              isLoading: _isLoading,
              searchController: searchController,
              onChanged: (val) => setState(() {}),
              onStart: _inUsePrompts.isEmpty || currUser == null
                  ? null
                  : () async => _handleOnSubmit(),
              onSubmitted: _inUsePrompts.isEmpty || currUser == null
                  ? null
                  : (val) async => _handleOnSubmit(),
              suffixIcon: searchController.text.isNotEmpty && !_isLoading
                  ? Icons.close
                      .icon(color: AppColors.greyText.withOpacity(0.30), size: 25)
                      .px(10)
                      .py(12)
                      .onTap(() {
                      searchController.clear();
                      setState(() {});
                    }, radius: 5)
                  : null,

              // Icons.settings_suggest
              //     .icon(
              //         color: _categories.isEmpty || _promptsList.isEmpty
              //             ? AppColors.greyText.withOpacity(0.30)
              //             : AppColors.greyText,
              //         size: 25)
              //     .px(20)
              //     .py(12)
              //     .onTap((_categories.isEmpty || _promptsList.isEmpty)
              //         ? null
              //         : () => _handleOnAdvanced()),

              //   prefixIcon: Builder(builder: (context) {
              //     var currUser = context.uniProvider.currUser;
              //     var color = AppColors.greyText.withOpacity(_isLoading ? 0.3 : 0.5);
              //     var style = ''.toText(fontSize: 15, medium: true, color: color).style;
              //     return Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icons.offline_bolt.icon(color: color, size: 24).pOnly(left: 15),
              //         ('${currUser.points}').toText(style: style).px(7),
              //         // verticalDivider(height: 20, color: color).pOnly(right: 7),
              //       ],
              //     );
              //   }),
            ),

            if (buyTokensMessage)
              SizedBox(
                  width: 750,
                  child: 'Buy Tokens & keep save time for only 1\$ per product >>> '
                      // child: 'Buy Tokens & keep boost sales for only 1\$ per product >>> '
                      .toTextButton(
                    color: AppColors.secondaryBlue,
                    underline: true,
                    fontSize: 16,
                    tapColor: Colors.transparent,
                    onTap: () {
                      print('START: Buy Tokens');
                      String url = 'https://www.textstore.ai/priceing-plan/';
                      window.open(url, 'New Tab');
                    },
                  )).py(10),

            if (errorMessage != null)
              // 'This can take up to 15 seconds...'
              SizedBox(
                width: 800,
                child: errorMessage
                    .toString()
                    .toText(
                        color: (errorMessage != null &&
                                errorMessage!.contains('we need details'))
                            ? AppColors.greyText
                            : AppColors.errRed,
                        fontSize: 16,
                        maxLines: 5)
                    .py(10)
                    .px(30)
                    .appearAll,
              ),

            if (_isLoading)
              // 'This can take up to 15 seconds...'
              SizedBox(
                width: 800,
                child: '$loadingText'
                    .toText(color: AppColors.greyText, fontSize: 18)
                    .py(5)
                    .px(30)
                    .appearAll,
              ),
            // endregion Search TextField
            const Spacer(),
            appVersion.toText(fontSize: 12).pad(10).centerLeft,
          ],
        )
        // .center,
        );
  }

  void _handleOnAdvanced() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ThreeColumnDialog(
          promptsList: _promptsList,
          selectedPrompts: _inUsePrompts,
          categories: _categories,
        );
      },
    );
    setState(() {}); // Update uniModel values
  }

  void _handleOnSubmit() async {
    print('START: _handleOnSubmit()');

    errorMessage = null;
    _isLoading = true;
    setState(() {});
    startLoader(searchController.text);

    if (context.uniProvider.currUser.points == 0) {
      buyTokensMessage = true;
      errorMessage = null;
      _isLoading = false;
      setState(() {});
      return;
    }

    await createProductAction(context, searchController).catchError((err, s) {
      printRed('My ERROR createProductAction: $err S: $s');
      errorMessage = err.toString().replaceAll('Exception: ', '');
    });
    _isLoading = false;
    setState(() {});
  }
}

void showUserMenu(
  BuildContext context, {
  required bool isHomeScreen,
  List<PopupMenuItem>? items,
  double alignOffset = 0,
  void Function()? onTapYourProfile,
  void Function()? onTapContactUs,
  void Function()? onTapLogoutProfile,
}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final positionData = button.localToGlobal(
      isHomeScreen
          ? button.size.topLeft(Offset(-10 + alignOffset, 40))
          : button.size.topRight(Offset(-10 + alignOffset, 40)),
      ancestor: overlay);

  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      positionData,
      positionData,
    ),
    Offset.zero & overlay.size,
  );

  showMenu(
    context: context,
    position: position,
    items: items ??
        [
          PopupMenuItem(
            onTap: onTapContactUs,
            child: 'Contact us'.toTextButton(icon: Icons.email),
          ),
          PopupMenuItem(
            onTap: onTapYourProfile,
            child: 'Your profile'.toTextButton(icon: Icons.person),
          ),
          PopupMenuItem(
            onTap: onTapLogoutProfile,
            child: 'Logout'.toTextButton(color: AppColors.errRed, icon: Icons.logout),
          ),
        ],
    elevation: 8,
  ).then((value) => print('Selected: $value'));
}

Widget buildHomeMenu(
  BuildContext context, {
  GestureTapCallback? onCloseIcon,
  GestureTapCallback? onTapLogin,
  GestureTapCallback? onTapAdvanced,
  List<PopupMenuItem>? items,
  required bool isAlignLeft,
}) {
  late bool loginMode;
  bool? _isLoading;
  _isLoading ??= context.uniProvider.currUser.id == null;

  return StatefulBuilder(builder: (context, userStf) {
    var currUser = context.uniProvider.currUser;
    var color = AppColors.greyText.withOpacity(_isLoading! ? 0.5 : 1);
    var style = ''.toText(fontSize: 15, medium: true, color: color).style;
    loginMode = currUser.id == null;
    final name = currUser.name?.split('-').first ?? '';

    void onTapUser() {
      showUserMenu(
        context,
        isHomeScreen: isAlignLeft,
        alignOffset: -230,
        items: items,
        onTapContactUs: () {
          print('START: onTapContactUs()');
          String url = 'https://www.textstore.ai/contact-us/';
          window.open(url, 'New Tab');
        },
        onTapYourProfile: () async {
          print('START: _redirectWebsite()');
          _isLoading = true;
          userStf(() {});

          // final userWebToken = await WooApi.userWebToken();
          // String url = 'https://textstore.ai/my-account/?mo_jwt_token=$userWebToken';

          String url =
              'https://www.textstore.ai/wp-json/simple-jwt-login/v1/autologin?JWT=$appConfig_userJwt';
          print('url $url');
          window.open(url, 'New Tab');
          // window.open(url, '_blank');

          await Future.delayed(450.milliseconds);
          _isLoading = false;
          userStf(() {});
        },
        onTapLogoutProfile: () async {
          print('START: _logoutUser()');
          // _isLoading = false;
          // userStf(() {});

          context.uniProvider.updateWooUserModel(const WooUserModel());
          currUser = context.uniProvider.currUser;
          appConfig_userJwt = '';
          userStf(() {});
          final box = await Hive.openBox('currUserBox');
          box.clear();

          // if (onTapLogin == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          // }
        },
      );
    }

    return SizedBox(
            height: 50,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_isLoading! || loginMode) ...[
                    Icons.account_circle.icon(color: color, size: 24),
                    (_isLoading! ? 'Loading...' : 'Login profile')
                        .toText(style: style)
                        .pOnly(right: 10, left: 10),
                  ] else ...[
                    Row(
                      children: [
                        Icons.account_circle.icon(color: color, size: 24),
                        name.toString().toText(style: style).pOnly(left: 10),
                      ],
                    ).px(10).py(10).onTap(
                        _isLoading! ? null : (loginMode ? onTapLogin : onTapUser),
                        radius: 5),
                    ('| ').toText(style: style),
                    if (onTapAdvanced != null) ...[
                      Row(
                        children: [
                          Icons.settings_suggest
                              .icon(color: color, size: 24)
                              .pOnly(right: 10, left: 10),
                          ('Advanced').toText(style: style).pOnly(right: 10),
                        ],
                      ).py(10).onTap(onTapAdvanced, radius: 5),
                      ('| ').toText(style: style),
                    ],
                    // Icons.offline_bolt.icon(color: color, size: 24).pOnly(right: 10),
                    ('${currUser.points} Tokens')
                        .toTextButton(
                            style: style,
                            icon: Icons.offline_bolt,
                            px: 10,
                            py: 10,
                            onTap: () {
                              showUserMenu(
                                context,
                                isHomeScreen: isAlignLeft,
                                alignOffset: 290,
                                items: [
                                  PopupMenuItem(
                                    child: 'Buy subscription'
                                        .toTextButton(icon: Icons.shopping_bag),
                                    onTap: () {
                                      print('START: Buy subscription');
                                      String url =
                                          'https://www.textstore.ai/priceing-plan/';
                                      window.open(url, 'New Tab');
                                    },
                                  )
                                ],
                                onTapContactUs: null,
                                onTapYourProfile: null,
                                onTapLogoutProfile: null,
                              );
                            })
                        .pOnly(right: 10),
                  ],
                  if (onCloseIcon != null) ...[
                    const Spacer(),
                    Icons.close
                        .icon(color: AppColors.greyText, size: 30)
                        .pad(10)
                        .onTap(onCloseIcon)
                        .pOnly(right: 15)
                        .centerRight,
                  ]
                ]).px(10))
        .appearOpacity;
  });
}

void handleUserAction() {}

Future<List<WooPostModel>> setSelectedList(
    BuildContext context, List<WooPostModel> _fullPromptList) async {
  List<WooPostModel> _selectedPromptList = [];
  int isDefaultCounter = 0;

  //1) Add user selected prompts
  for (var prompt in _fullPromptList) {
    if (prompt.isDefault) isDefaultCounter++;
    if (prompt.isSelected && prompt.author == context.uniProvider.currUser.id) {
      _selectedPromptList.add(prompt);
    }
  }

  if (isDefaultCounter != 4) {
    throw '[$isDefaultCounter/4 isDefault prompts found!]'
        '\n Server should return only 4 isDefault (1 for each type).'
        '\n Get full info with GET v2/posts?_fields=acf, id';
  }

  //2) Add default ONLY where needed
  for (var prompt in _fullPromptList) {
    if (_selectedPromptList.any((p) => p.category == prompt.category)) {
      // Do nothing, this category already have prompt.isSelected
    } else {
      //~ Must be only 1 prompt.isDefault per type
      if (prompt.isAdmin && prompt.isDefault) _selectedPromptList.add(prompt);
    }
  }
  print('\nDONE: _selectedPromptList (${_selectedPromptList.length} prompts)');
  for (var p in _selectedPromptList) printLightBlue("${p.id} | ${p.title}");
  return _selectedPromptList;
}

List<WooPostModel> setDefaultPromptFirst(List<WooPostModel> postList) {
  var _postList = postList;
  // Set the Default prompt on Top
  for (var post in [..._postList]) {
    if (post.isAdmin) {
      _postList.remove(post);
      _postList.insert(0, post);
    }
  }
  return _postList;
}

Widget textStoreBar(
  BuildContext context, {
  required bool isLoading,
  required TextEditingController searchController,
  Widget? prefixIcon,
  Widget? suffixIcon,
  required ValueChanged<String>? onSubmitted,
  required GestureTapCallback? onStart,
  ValueChanged<String>? onChanged,
}) {
  String? token = context.uniProvider.currUser.token;
  var _inUsePrompts = context.uniProvider.inUsePromptList;
  var hLoaderRatio = 1.2;
  var loaderWidth = 800.0;

  // double width = MediaQuery.of(context).size.width;
  // bool desktopMode = width > 850;

  // borderRadius: BorderRadius.circular(99),
  var radius = BorderRadius.only(
    bottomLeft: 99.circular,
    topLeft: 99.circular,
    topRight: 20.circular,
    bottomRight: 20.circular,
  );

  return Hero(
    tag: 'buildMainBar',
    child: Stack(
      children: [
        if (isLoading)
          SizedBox(
            width: loaderWidth - 14,
            height: 50 + (10 * hLoaderRatio),
            child: const LinearProgressIndicator(
              color: AppColors.lightShinyPrimary,
              backgroundColor: AppColors.transparent,
            ),
          ).roundedFull.offset(7, -5 * hLoaderRatio).pOnly(right: 15),
        SizedBox(
          width: loaderWidth,
          child: Material(
            color: AppColors.transparent,
            // elevation: 3,
            borderRadius: BorderRadius.circular(99),
            child: Row(
              children: [
                Directionality(
                  textDirection: searchController.text.isHebrew
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: TextField(
                    onChanged: onChanged,
                    autofocus: true,
                    controller: searchController,
                    onSubmitted: onSubmitted,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: prefixIcon == null ? 20 : 0),
                      filled: true,
                      fillColor: AppColors.white,
                      hoverColor: AppColors.greyLight.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, borderRadius: radius),
                      focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: AppColors.greyLight),
                          borderSide: BorderSide.none,
                          borderRadius: radius),
                      hintText: 'Full product name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: suffixIcon,
                      prefixIcon: prefixIcon,
                      // suffixIcon: _buildCreateButton(isLoading, _inUsePrompts, token, context, onStart),
                    ),
                  ).expanded(),
                ),
                const SizedBox(width: 10),
                _buildCreateButton(isLoading, _inUsePrompts, token, context, onStart),
              ],
            ),
          ).px(15),
        ),
      ],
    ),
  );
}

Widget _buildCreateButton(bool isLoading, List<WooPostModel> _inUsePrompts, String? token,
    BuildContext context, GestureTapCallback? onStart) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.secondaryBlue,
      borderRadius: BorderRadius.only(
        bottomLeft: 20.circular,
        topLeft: 20.circular,
        topRight: 99.circular,
        bottomRight: 99.circular,
      ),
    ),
    width: 60,
    height: 50,
    child: Stack(
      // Use Stack to overlay prefixIcon and CircularProgressIndicator
      alignment: Alignment.center,
      children: [
        if ((isLoading || _inUsePrompts.isEmpty) && token != null) ...[
          CurvedCircularProgressIndicator(
            value: _inUsePrompts.isEmpty
                ? null
                : context.listenUniProvider.textstoreBarLoader,
            // color: AppColors.lightShinyPrimary,
            color: AppColors.white,
            strokeWidth: 6,
            backgroundColor: AppColors.secondaryBlue,
            animationDuration: 1500.milliseconds,
          ).sizedBox(30, 30).px(10).py(5),
        ] else ...[
          // if (!isLoading && _inUsePrompts.isNotEmpty)

          // Icons.search_rounded.icon(color: Colors.blueAccent, size: 30)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icons.send.icon(
                  size: 30,
                  color: _inUsePrompts.isEmpty
                      ? AppColors.white.withOpacity(0.40)
                      : AppColors.white),

              // 'Create'.toText(
              //     color: _inUsePrompts.isEmpty
              //         ? AppColors.primaryShiny.withOpacity(0.40)
              //         : AppColors.primaryShiny,
              //     medium: true,
              //     fontSize: 14)
            ],
          )
              .px(15)
              .py(10)
              // .py(15)
              .onTap(
                onStart,
                // tapColor: AppColors.primaryShiny.withOpacity(0.1)
              ),
        ]
      ],
    ),
  );
}
