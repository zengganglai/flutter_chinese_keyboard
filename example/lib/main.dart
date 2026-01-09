import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_chinese_keyboard/flutter_chinese_keyboard.dart';
import 'package:flutter_chinese_keyboard/view/chinese_keyboard.dart';
import 'package:flutter_chinese_keyboard/view/chinese_keyboard_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterChineseKeyboardPlugin = FlutterChineseKeyboard();
  TextEditingController textEditingController = TextEditingController();
  ChineseKeyboardController chineseKeyboardController =
      ChineseKeyboardController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(1920, 1080),
        builder: (context, w) => MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('中文键盘'),
                ),
                body: Container(
                    margin: EdgeInsets.all(32.h),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .shadow
                                        .withOpacity(0.1),
                                    blurRadius: 24,
                                    offset: Offset(0, 10.r),
                                    spreadRadius: 0),
                              ]),
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: TextField(
                                      autofocus: true,
                                      controller: textEditingController,
                                      keyboardType: TextInputType.none,
                                      maxLines: 16,
                                      textAlign: TextAlign.start,
                                      textAlignVertical: TextAlignVertical.top,
                                      enabled: true,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          counterText: '',
                                          filled: true,
                                          contentPadding: EdgeInsets.all(6.h),
                                          fillColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          hintText: '请输入文本',
                                          hintStyle: TextStyle(
                                              color: const Color(0xffC0C0C0),
                                              fontSize: 32.sp)),
                                      onChanged: (value) {},
                                      onEditingComplete: () {
                                        // FocusScope.of(context).unfocus();
                                      })),
                            ],
                          ),
                        )),
                        SizedBox(
                          height: 24.h,
                        ),
                        ChineseKeyboard(
                          controller: chineseKeyboardController,
                          keyHeight: 100.h,
                          textController: textEditingController,
                          candidateWordsRows: 1,
                          keyTextStyle: TextStyle(fontSize: 32.sp),
                          pinyinTextStyle: TextStyle(fontSize: 32.sp),
                          pinyinPadding: EdgeInsets.all(8.r),
                          borderRadius: 12.r,
                          keyMargin: EdgeInsets.all(8.r),
                          background: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.5),
                          keyColor: Theme.of(context).colorScheme.surface,
                          candidateWordRowHeight: 64.h,
                          pageTurnIconSize: 56.r,
                          candidateWordTextStyle: TextStyle(fontSize: 32.sp),
                          candidateWordsBackground:
                              Theme.of(context).colorScheme.surface,
                        )
                      ],
                    )),
              ),
            ));
  }
}
