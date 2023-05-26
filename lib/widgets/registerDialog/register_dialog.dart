// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:developer';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/models/post/woo_post_model.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/common/themes/app_colors.dart';
import 'package:biton_ai/widgets/threeColumnDialog/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../common/constants.dart';
import '../../common/extensions/widget_ext.dart';
import '../../common/models/category/woo_category_model.dart';
import '../../common/models/prompt/result_model.dart';
import '../../common/models/user/woo_user_model.dart';
import '../../common/services/color_printer.dart';
import '../../main.dart';
import '../../screens/homeScreen.dart';
import '../customButton.dart';
import 'package:flutter/material.dart';

import '../threeColumnDialog/design.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({Key? key}) : super(key: key);

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _pageController = PageController(initialPage: 0); // Initialize the PageController
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  String? errMessage;
  String? phone;
  bool _isPasswordVisible = false; // Track the password visibility state
  bool loginMode = true;

  @override
  Widget build(BuildContext context) {
    String? token = context.uniProvider.currUser.token;
    double width = MediaQuery.of(context).size.width;
    bool desktopMode = width > 900;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (token != null)
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: AppColors.secondaryBlue),
          )
              .onTap(
                  () => _pageController.page == 0
                      ? Navigator.pop(context)
                      : _pageController.hasClients
                          ? _pageController
                              .jumpToPage((_pageController.page! - 1).toInt())
                          : null,
                  tapColor: Colors.blue)
              .center
              .pOnly(right: 400, bottom: 10),
        //
        Dialog(
          backgroundColor: AppColors.white,
          shape: 15.roundedShape,
          insetPadding: EdgeInsets.symmetric(horizontal: desktopMode ? 40 : 25),
          child: SizedBox(
            width: 450,
            height: loginMode ? 390 : 470,
            child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  buildPromptForm(),
                ]),
          ),
        ),
      ],
    );
  }

  Widget buildPromptForm() {
    bool isLoading = false;
    StateSetter? errState;
    StateSetter? formState;

    return StatefulBuilder(builder: (context, stfState) {
      formState = stfState;
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20.0),
            'TextStore'
                .toText(
                  color: Colors.black,
                  fontSize: 44,
                  bold: true,
                )
                .center,
            // (loginMode ? 'Login' : 'Sign up')
            //     .toText(
            //       color: Colors.black,
            //       fontSize: 22,
            //       medium: true,
            //     )
            //     .px(3)
            //     .centerLeft,
            const SizedBox(height: 10.0),
            fieldTitle('Email'),
            SizedBox(
              height: 50,
              child: TextField(
                autofocus: true,
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
                height: 50,
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
            if (!loginMode) ...[
              fieldTitle('Phone (SMS code)'),
              SizedBox(
                height: 65,
                child: IntlPhoneField(
                  pickerDialogStyle: PickerDialogStyle(padding: 20.all, width: 400),
                  controller: _phoneController,
                  decoration: fieldPromptStyle(false),
                  initialCountryCode: 'IL',
                  style: const TextStyle(color: Colors.black),
                  onChanged: (_phone) {
                    phone = _phone.completeNumber;
                  },
                ),
              ),
              const SizedBox(height: 5.0),
            ],
            StatefulBuilder(builder: (context, stfState) {
              errState = stfState;
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
                    ).pOnly(top: 5);
            }),

            //? Todo (Login instead) will instant login ?
            (loginMode ? 'New? Create profile' : 'Login instead')
                .toText(color: AppColors.secondaryBlue, underline: true)
                .py(5)
                .onTap(() {
              errMessage = null;
              loginMode = !loginMode;
              setState(() {});
              // formState!(() {});
            }, radius: 5).centerLeft,
            const SizedBox(height: 15),
            buildTextstoreButton(
              title: loginMode ? 'Login' : 'Sign up',
              invert: !loginMode,
              isUnavailable: false,
              isLoading: isLoading,
              createMode: !loginMode,
              onPressed: () async {
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

                final isPhoneValid = _formKey.currentState!.validate();
                if (!isPhoneValid) {
                  errMessage = 'Please use a valid phone';
                  errState!(() {});
                  return;
                }

                errMessage = null;
                isLoading = true;
                formState!(() {});

                //~ SignUp if needed:
                if (!loginMode) {
                  await WooApi.userSignup(
                    email: _emailController.text,
                    password: _passController.text,
                    phone: phone!,
                  ).catchError((err) {
                    isLoading = false;
                    printRed('My ERROR: $err');
                    errMessage = err.toString().replaceAll('Exception: ', '');
                    //? TODO: User exist? Try Auto login ?
                    formState!(() {});
                  });
                }
                if (errMessage != null) return;

                //~ Login:
                var token = await WooApi.userLogin(
                  email: _emailController.text,
                  password: _passController.text,
                ).catchError((err) {
                  isLoading = false;
                  printRed('My ERROR: $err');
                  errMessage = err.toString().replaceAll('Exception: ', '');
                  //? TODO: User exist? Try Auto login ?
                  formState!(() {});
                });

                setUserToken(
                  token: token,
                  userEmail: _emailController.text,
                  userPass: _passController.text,
                );
                context.uniProvider.updateWooUserModel(WooUserModel(token: token));
                Navigator.pop(context);
              },
            ).center,
          ],
        ).px(60),
      );
    });
  }
}
