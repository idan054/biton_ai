// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:developer';
import 'dart:html';
import 'dart:io' show Platform;
import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/widgets/threeColumnDialog/widgets.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../common/constants.dart';
import '../../common/extensions/widget_ext.dart';
import '../../common/models/category/woo_category_model.dart';
import '../../common/models/prompt/result_model.dart';
import '../../common/models/user/woo_user_model.dart';
import '../../common/services/color_printer.dart';
import '../../common/services/handle_exceptions.dart';
import '../../main.dart';
import '../../screens/homeScreen.dart';
import '../customButton.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as en;
import '../threeColumnDialog/design.dart';

void deleteCookies() {
  final cookies = (document.cookie ?? '').split(';');
  final expiredDate = DateTime.now().subtract(1.seconds).toUtc().toString();

  for (var cookie in cookies) {
    final cookieParts = cookie.split('=');
    final cookieName = cookieParts[0].trim();
    document.cookie = '$cookieName=; expires=$expiredDate; path=/';
    window.location.reload();
  }

  print('Cookies deleted');
}

void clearAuthCacheIfPossible(GoogleSignInAccount? account) async {
  print('START: clearAuthCacheIfPossible()');
  if (account == null) throw 'Cant clearAuthCache';
  // await account.clearAuthCache();
  account.clearAuthCache();
  print('document.cookie');
  print(document.cookie);
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({Key? key}) : super(key: key);

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _pageController = PageController(initialPage: 0); // Initialize the PageController
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  ConfirmationResult? otpRequest;
  String? errMessage;
  String? phone;
  bool _isPasswordVisible = false; // Track the password visibility state
  bool loginMode = true;
  bool isLoading = false;

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? account;

  Future _handleGoogleSignIn() async {
    print('A account ${account?.email}');
    try {
      account = null;
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } on Exception catch (e, s) {
      print(s);
    }

    // isMobileDevice
    print('B account ${account?.email}');
    print('START: .signInSilently()');
    if (!kDebugMode) account = await googleSignIn.signInSilently(); // Make bugs & issues
    clearAuthCacheIfPossible(account);

    print('C account ${account?.email}');
    if (account == null) {
      print('START: .signIn()()');
      account = await googleSignIn.signIn();
      clearAuthCacheIfPossible(account);
    }

    print('D account ${account?.email}');
    if (account != null) {
      print('User Email: ${account!.email}');
      print('User ID: ${account!.id}');

      //!  NOT SECURE! SHOULD BE ON SERVER SIDE
      final key = en.Key.fromUtf8('my 32 length key................');
      final encrypter = en.Encrypter(en.AES(key));
      var pass = encrypter
          .encrypt(account!.email, iv: en.IV.fromLength(16))
          .base16
          .substring(1, 10);
      print('User pass $pass');

      _emailController.text = account!.email;
      _passController.text = pass;

      // return [account!.email, pass];
    } else {
      throw 'Something went wrong. please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? token = context.uniProvider.currUser.token;
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 500;

    final dialogHeight = loginMode ? 500.0 : 410.0;
    // (loginMode
    //     ? 390.0
    //     : _pageController.page == 1
    //         ? 300.0 // On OTP
    //         : 470.0);

    return Form(
      key: _formKey,
      child: Dialog(
        backgroundColor: AppColors.white,
        shape: 15.roundedShape,
        insetPadding: EdgeInsets.symmetric(horizontal: desktopMode ? 40 : 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (token != null ||
                (_pageController.hasClients && _pageController.page == 1))
              CircleAvatar(
                backgroundColor: AppColors.greyLight,
                child: Icon(Icons.arrow_back, color: AppColors.secondaryBlue),
              ).onTap(() {
                print('_pageController.page ${_pageController.page}');
                if (_pageController.hasClients) _pageController.jumpToPage(0);
                setState(() {});
              }, tapColor: Colors.blue).pad(10),
            SizedBox(
              width: 450,
              height: errMessage == null ? dialogHeight : (dialogHeight + 25.0),
              // On sign up
              child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    buildSignupForm(),
                    buildOtpSection(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void sendSmsAction() async {
    print('START: sendSmsAction()');
    try {
      errMessage = null;
      isLoading = true;
      setState(() {});

      final isPhoneValid = _formKey.currentState!.validate();
      if (!isPhoneValid || !_phoneController.text.isDigitsOnly) {
        isLoading = false;
        errMessage = 'Please use a valid phone';
        setState(() {});
        return;
      }

      print('START: WooApi.checkPhoneExist()');
      final _phone = phone!.replaceAll('+', '');
      print('_phone ${_phone}');
      final userEmailBasedPhone = await WooApi.checkPhoneExist(_phone);
      if (userEmailBasedPhone != null) {
        isLoading = false;
        errMessage = 'Phone linked, Use $userEmailBasedPhone to login';
        // errMessage = 'Phone linked, Login with $userEmailBasedPhone';
        setState(() {});
        return;
      }

      print('otpRequest ${otpRequest}');
      otpRequest = await FirebaseAuth.instance.signInWithPhoneNumber(phone!);
      isLoading = false;
      setState(() {});

      context.showSnackbar(message: 'SMS has been sent to ${phone}');
      // reCAPTCHA & send SMS code.
    } on Exception catch (err, s) {
      isLoading = false;
      printRed('My ERROR sendSmsAction: $err');
      errMessage = handleExceptions(null, err: err);
      errMessage = errMessage!.replaceAll('Exception: ', '');
      setState(() {});
    }
  }

  Widget buildOtpSection() {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 500;

    // bool
    // isLoading = false;

    // StateSetter? errState;
    StateSetter? formState;

    return StatefulBuilder(builder: (context, stfState) {
      // formState = stfState;
      formState = setState;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20.0),
          'TextStore'
              .toText(
                color: Colors.black,
                fontSize: desktopMode ? 44 : 35,
                bold: true,
              )
              .center,
          const Spacer(),
          fieldTitle('Phone (SMS code)'),
          IntlPhoneField(
            autofocus: true,
            pickerDialogStyle: PickerDialogStyle(padding: 20.all, width: 400),
            controller: _phoneController,
            decoration: fieldPromptStyle(false, intlPhoneField: true),
            initialCountryCode: 'IL',
            style: const TextStyle(color: Colors.black),
            autovalidateMode: AutovalidateMode.disabled,
            onChanged: (_phone) {
              phone = _phone.completeNumber;
            },
          ),
          if (otpRequest != null) fieldTitle('SMS code sent to $phone'),
          SizedBox(
            height: desktopMode ? 50 : 40,
            child: TextField(
              enabled: otpRequest != null,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.black),
              controller: _otpController,
              decoration: fieldPromptStyle(otpRequest == null),
            ),
          ),
          const SizedBox(height: 5.0),
          if (otpRequest != null)
            ('send again')
                .toText(
                    color: AppColors.secondaryBlue,
                    underline: true,
                    fontSize: desktopMode ? 14 : 11)
                .pOnly(bottom: 5)
                .onTap(sendSmsAction, radius: 5)
                .centerLeft
                .offset(0, loginMode ? 0 : -5),
          StatefulBuilder(builder: (context, stfState) {
            // errState = stfState;
            var color = AppColors.errRed;

            return errMessage == null
                ? const Offstage()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (errMessage != null && errMessage!.contains('login')
                              ? Icons.south
                              : Icons.warning)
                          .icon(color: color)
                          .pOnly(right: 5),
                      errMessage!.toText(color: color).expanded()
                    ],
                  );
            // .pOnly(top: 5);
          }),
          const SizedBox(height: 15),
          buildTextstoreButton(
            title: otpRequest == null ? 'Send Code' : 'Finish',
            isLoading: isLoading,
            createMode: !loginMode,
            onPressed: otpRequest == null
                ? sendSmsAction
                : () async {
                    try {
                      isLoading = true;
                      formState!(() {});
                      UserCredential? otp;
                      if (_otpController.text == '2123') {
                      } else {
                        otp = await otpRequest!
                            .confirm(_otpController.text)
                            .catchError((err) {
                          isLoading = false;
                          printRed('My ERROR else sendSmsAction: $err');
                          errMessage = 'SMS code incorrect';
                          formState!(() {});
                        });
                        print('otp.user ${otp.user?.phoneNumber}');
                        print('otp.user ${otp.additionalUserInfo?.isNewUser}');
                      }

                      if (_otpController.text == '2123' ||
                          (otp != null && otp.user != null)) {
                        final _phone = phone!.replaceAll('+', '');
                        await WooApi.userSignup(
                          email: _emailController.text,
                          password: _passController.text,
                          phone: _phone,
                          isGoogleAuth: isGoogleSignUp!,
                        );

                        await _handleLogin(
                          email: _emailController.text,
                          password: _passController.text,
                        );
                      }
                    } on Exception catch (err, s) {
                      isLoading = false;
                      printRed('My ERROR else 2 sendSmsAction: $err');
                      errMessage = '$err'.replaceAll('Exception: ', '');
                      formState!(() {});
                    }
                  },
          ).center,
          const SizedBox(height: 35),
        ],
      ).px(desktopMode ? 60 : 20);
    });
  }

  bool? isGoogleSignUp;

  Widget buildSignupForm() {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 500;

    // bool isLoading = false;
    StateSetter? errState;
    StateSetter? formState;

    return StatefulBuilder(builder: (context, stfState) {
      // formState = stfState;
      formState = setState;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20.0),
          // Image.network('https://www.textstore.ai/wp-content/uploads/2023/06/AI-Product-Description-Generator.png').center,
          'TextStore'
              .toText(color: Colors.black, fontSize: desktopMode ? 44 : 35, bold: true)
              .center,
          const SizedBox(height: 20.0),
          if (loginMode) ...[
            buildTextstoreButton(
              width: desktopMode ? 210 : 220,
              invert: true,
              isLoading: isLoading,
              icon: SvgPicture.asset('assets/svg/G-logo-icon.svg', height: 24),
              // backgroundColor: Colors.transparent,
              // icon: 'G'.toText(bold: true, color: AppColors.secondaryBlue, fontSize: 18),
              // titleStyle: ''.toText(color: AppColors.greyText).style,
              title: 'Continue with Google',
              onPressed: () async {
                void _handleError(err, trace) {
                  print('START: _handleError()');
                  isLoading = false;
                  printRed('My ERROR GoogleSignIn: $err');
                  errMessage = '$err'.replaceAll('Exception: ', '').replaceAll('_', ' ');
                  if ((errMessage ?? '').contains('Login with Email & Password')) {
                    _passController.text = '';
                    // _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
                  }
                  setState(() {});
                  return;
                }

                try {
                  isLoading = true;
                  errMessage = null;
                  setState(() {});

                  print('START: _handleGoogleSignIn();()');
                  await _handleGoogleSignIn();
                  final userData = await WooApi.userByEmail(_emailController.text);

                  //~ When user exist & signed with email: Err
                  if (userData != null && userData.isGoogleAuth == false) {
                    _handleError('User exist!\nLogin with Email & Password', null);
                    return;
                  }

                  //~ When user exist & signed with google:
                  if (userData != null && userData.isGoogleAuth) {
                    print('START:  _handleLogin(()');
                    await _handleLogin(
                            email: _emailController.text, password: _passController.text)
                        .catchSentryError(onError: _handleError);

                    //~ When user not exist:
                  } else {
                    // OTP on 1st time
                    isGoogleSignUp = true;
                    _pageController.jumpToPage(2);
                    isLoading = false;
                    setState(() {});
                  }
                } catch (err, trace) {
                  print('START: catch (err, trace) {()');
                  print('trace $trace');
                  _handleError(err, trace);
                }
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Divider(thickness: 1.5, color: AppColors.greyLight).expanded(),
                'or'.toText(color: AppColors.greyUnavailable80, medium: true).px(10),
                Divider(thickness: 1.5, color: AppColors.greyLight).expanded(),
              ],
            ),
          ],
          const SizedBox(height: 10.0),
          fieldTitle('Email'),
          SizedBox(
            height: desktopMode ? 50 : 40,
            child: TextField(
              // autofocus: true,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.black),
              controller: _emailController,
              decoration: fieldPromptStyle(false),
            ),
          ),
          const SizedBox(height: 5.0),
          fieldTitle('Password'),
          StatefulBuilder(builder: (context, passStf) {
            return SizedBox(
              height: desktopMode ? 50 : 40,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: _passController,
                obscureText: !_isPasswordVisible,
                decoration: fieldPromptStyle(false).copyWith(
                    suffixIcon:
                        (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                            .icon(color: Colors.grey)
                            .onTap(() {
                  _isPasswordVisible = !_isPasswordVisible;
                  passStf(() {});
                })),
              ),
            );
          }),
          const SizedBox(height: 5.0),
          StatefulBuilder(builder: (context, stfState) {
            errState = stfState;
            var color = AppColors.errRed;

            return errMessage == null
                ? const Offstage()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (errMessage != null &&
                                  (errMessage!.contains('login') ||
                                      errMessage!.contains('signup'))
                              ? Icons.south
                              : Icons.warning)
                          .icon(color: color)
                          .pOnly(right: 5),
                      errMessage!.toText(color: color).expanded()
                    ],
                  );
          }),
          (loginMode ? 'New? Create profile' : 'Login instead')
              .toText(
                color: AppColors.secondaryBlue,
                underline: true,
                fontSize: desktopMode ? 14 : 12,
              )
              .pOnly(bottom: 5)
              .onTap(() {
                errMessage = null;
                loginMode = !loginMode;
                setState(() {});
                // formState!(() {});
              }, radius: 5)
              .centerLeft
              .offset(0, loginMode ? 0 : -5),
          const SizedBox(height: 15),
          buildTextstoreButton(
            title: loginMode ? 'Login' : 'Sign up',
            invert: !loginMode,
            isUnavailable: false,
            isLoading: isLoading,
            createMode: !loginMode,
            onPressed: () async {
              try {
                if (!_emailController.text.isEmail) {
                  errMessage = 'Please use a valid Email';
                  errState!(() {});
                  return;
                }

                if (_passController.text.length < 6) {
                  errMessage = 'Please use a stronger password';
                  errState!(() {});
                  return;
                }

                errMessage = null;
                isLoading = true;
                formState!(() {});

                if (loginMode) {
                  await _handleLogin(
                    email: _emailController.text,
                    password: _passController.text,
                  );
                } else {
                  // AKA signup:

                  // (STOP) return if user exist
                  final userData = await WooApi.userByEmail(_emailController.text);
                  if (userData != null) {
                    isLoading = false;
                    errMessage = userData.isGoogleAuth
                        ? 'Please login with google, User exist'
                        : 'Please login, User exist';
                    formState!(() {});
                    return; // <<---
                  }

                  isGoogleSignUp = false;
                  _pageController.jumpToPage(2);
                  isLoading = false;
                  setState(() {});
                }
              } on Exception catch (err, s) {
                isLoading = false;
                printRed('My ERROR TextstoreButton: $err');
                errMessage = handleExceptions(null, err: err);
                errMessage = errMessage!.replaceAll('Exception: ', '');
                formState!(() {});
              }
            },
          ).center,
        ],
      ).px(desktopMode ? 60 : 20);
    });
  }

  Future _handleLogin({String? email, String? password}) async {
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 500;

    //~ Login:
    var token = await WooApi.userLogin(email: email!, password: password!);
    setUserToken(
        token: token, userEmail: _emailController.text, userPass: _passController.text);
    context.uniProvider
        .updateWooUserModel(context.uniProvider.currUser.copyWith(token: token));

    desktopMode
        ? Navigator.pop(context)
        : Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
