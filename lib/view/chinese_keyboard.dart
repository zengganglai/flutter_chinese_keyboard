import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chinese_keyboard/view/chinese_keyboard_controller.dart';

class TextKeyStyle {
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final BoxShadow? boxShadow;

  TextKeyStyle(
      {this.textStyle,
      this.backgroundColor,
      this.margin,
      this.splashColor,
      this.boxShadow,
      this.borderRadius});
}

class TextKey extends StatefulWidget {
  const TextKey(
      {Key? key,
      this.text,
      this.child,
      this.flex = 1,
      this.value,
      this.onTextInput,
      this.isCanLongPressing = true,
      this.textKeyStyle})
      : super(key: key);
  final String? text;
  final Widget? child;
  final String? value;
  final int flex;
  final ValueSetter<String?>? onTextInput;
  final TextKeyStyle? textKeyStyle;
  final bool isCanLongPressing;

  @override
  State<TextKey> createState() => _TextKeyState();
}

class LongPressController {
  Timer? _longPressTimer;
  Timer? _longIntervalPressTimer;
  bool _isLongPressing = false;
  // 长按触发的最小持续时间（毫秒）
  static const Duration _kLongPressTimeout = Duration(milliseconds: 500);
  static const Duration _kLongIntervalTimeout = Duration(milliseconds: 100);

  void cancel() {
    try {
      _isLongPressing = false;
      if (_longPressTimer?.isActive == true) {
        _longPressTimer?.cancel();
      }
      _longPressTimer = null;

      if (_longIntervalPressTimer?.isActive == true) {
        _longIntervalPressTimer?.cancel();
      }
      _longIntervalPressTimer = null;
    } catch (e) {
      print(e);
    }
  }

  void start(Function? call) {
    _longPressTimer = Timer(_kLongPressTimeout, () {
      if (_isLongPressing) {
        try {
          if (_longIntervalPressTimer?.isActive == true) {
            _longIntervalPressTimer?.cancel();
          }
        } catch (e) {
          print(e);
        }
        // 开始计时
        _longIntervalPressTimer =
            Timer.periodic(_kLongIntervalTimeout, (timer) {
          if (_isLongPressing) {
            call?.call();
          } else if (timer.isActive) {
            timer.cancel();
          }
        });
      }
    });
    call?.call();
    _isLongPressing = true;
  }
}

class _TextKeyState extends State<TextKey> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> opacityAnimation;
  Timer? _longPressTimer;
  Timer? _longIntervalPressTimer;
  bool _isLongPressing = false;
  LongPressController? longPressController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 180), vsync: this);
    opacityAnimation = Tween(begin: 0.0, end: 0.3).animate(_controller);
    opacityAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!widget.isCanLongPressing) {
          _controller.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    longPressController?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _inkWellKey(context);
  }

  void _clearLongPressTimer() {
    try {
      _longPressTimer?.cancel();
      _longPressTimer = null;
      _longIntervalPressTimer?.cancel();
      _longIntervalPressTimer = null;
      _isLongPressing = false;
    } catch (e) {
      print(e);
    }
  }

  void _cancelLongPressTimer() {
    if (widget.isCanLongPressing) {
      longPressController?.cancel();
      longPressController = null;
      _controller.reverse();
    }
  }

  Widget _inkWellKey(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Container(
        margin: widget.textKeyStyle?.margin,
        decoration: BoxDecoration(
          borderRadius: widget.textKeyStyle?.borderRadius,
          boxShadow: widget.textKeyStyle?.boxShadow != null
              ? [
                  widget.textKeyStyle!.boxShadow!,
                ]
              : null,
        ),
        child: Material(
          borderRadius: widget.textKeyStyle?.borderRadius,
          color: widget.textKeyStyle?.backgroundColor ?? Colors.white,
          child: Listener(
              onPointerDown: (event) {
                _controller.forward();
                FocusScope.of(context).unfocus();
                if (widget.isCanLongPressing) {
                  longPressController?.cancel();
                  longPressController = LongPressController();
                  longPressController?.start(() {
                    widget.onTextInput?.call(widget.value);
                  });
                } else {
                  widget.onTextInput?.call(widget.value);
                }
              },
              onPointerUp: (PointerUpEvent event) {
                // 释放手指时取消计时器
                _cancelLongPressTimer();
              },
              onPointerCancel: (PointerCancelEvent event) {
                // 取消事件时取消计时器
                _cancelLongPressTimer();
              },
              child: AnimatedBuilder(
                animation: _controller,
                //_controller控制内持续的调用builder
                builder: (context, child) {
                  //每次调用builder，内部所有组件都会重新渲染，注意考虑优化性能
                  return Container(
                    decoration: BoxDecoration(
                      color: (widget.textKeyStyle?.splashColor ?? Colors.grey)
                          .withOpacity(_controller.value),
                      borderRadius: widget.textKeyStyle?.borderRadius,
                    ),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                          child: widget.child ??
                              Text(
                                widget.text ?? widget.value ?? '',
                                style: widget.textKeyStyle?.textStyle,
                              )),
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }
}

class ChineseKeyboard extends StatefulWidget {
  ChineseKeyboard(
      {Key? key,
      required this.controller,
      this.background,
      this.keyColor,
      this.candidateWordsBackground,
      this.keyHeight,
      this.keyMargin,
      this.pinyinPadding,
      this.borderRadius,
      this.candidateWordRowHeight,
      this.candidateWordTextStyle,
      this.pageTurnIconSize,
      this.onInput,
      this.onBackspace,
      this.textController,
      this.pinyinTextStyle,
      this.candidateWordsRows = 3,
      this.canClose = false,
      this.showBottomClose = false,
      this.onDone,
      this.onClose,
      this.keyTextStyle,
      this.keyStyle})
      : super(key: key);
  Color? background;
  Color? keyColor;
  Color? candidateWordsBackground;
  TextStyle? keyTextStyle;
  TextStyle? pinyinTextStyle;
  TextEditingController? textController;
  ChineseKeyboardController controller;
  int candidateWordsRows;
  bool canClose;
  bool showBottomClose;
  EdgeInsets? keyMargin;
  EdgeInsets? pinyinPadding;
  double? borderRadius;
  double? keyHeight;
  double? candidateWordRowHeight;
  TextStyle? candidateWordTextStyle;
  double? pageTurnIconSize;
  TextKeyStyle? keyStyle;
  Function(String)? onInput;
  Function()? onBackspace;
  Function()? onDone;
  Function()? onClose;
  @override
  State<ChineseKeyboard> createState() => _ChineseKeyboardState();
}

class _ChineseKeyboardState extends State<ChineseKeyboard>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> sizeAnimation;
  late final ScrollController _scrollController;
  ChineseKeyboardController get controller => widget.controller;

  TextKeyStyle get textKeyStyle =>
      widget.keyStyle ??
      TextKeyStyle(
          backgroundColor: widget.keyColor,
          textStyle: widget.keyTextStyle,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
          margin: widget.keyMargin);

  double get candidateWordsRowHeight => widget.candidateWordRowHeight ?? 60;

  int get candidateWordsRows => widget.candidateWordsRows;

  ValueNotifier<bool> candidateWordsCanPrevious = ValueNotifier(false);
  ValueNotifier<bool> candidateWordsCanNext = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 180), vsync: this);
    sizeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _scrollController = ScrollController(
      onAttach: (position) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          updateCandidateWordsScrollStatus();
        });
      },
    );
    controller.candidateWords.addListener(addCandidateWordsListener);
    _scrollController.addListener(() {
      updateCandidateWordsScrollStatus();
    });
  }

  addCandidateWordsListener() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateCandidateWordsScrollStatus();
    });
  }

  @override
  void dispose() {
    controller.candidateWords.removeListener(addCandidateWordsListener);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      child: AnimatedBuilder(
        animation: _controller,
        //_controller控制内持续的调用builder
        builder: (context, child) {
          //每次调用builder，内部所有组件都会重新渲染，注意考虑优化性能
          return Transform(
            transform: Matrix4.translationValues(
                0,
                (widget.keyHeight ?? 0) * 4 -
                    (widget.keyHeight ?? 0) * 4 * _controller.value,
                0),
            child: child,
          );
        },
        //动画执行过程中，不需要变化的部分可以传给AnimatedBuilder，
        // 每次builder回调时候会再传出来，这样就避免了child部分的重新渲染
        child: _keyboard(),
      ),
    );
  }

  Widget _keyboard() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: 0),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: controller.pinyin,
            builder: (context, pinyin, child) => ValueListenableBuilder<String>(
              valueListenable: controller.pinyinShow,
              builder: (context, pinyinShow, child) => pinyin.isEmpty
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        controller.clear();
                        _inputHandler(pinyin);
                      },
                      child: Container(
                        padding: widget.pinyinPadding,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(widget.borderRadius ?? 0),
                                topRight:
                                    Radius.circular(widget.borderRadius ?? 0)),
                            color: widget.background ?? Colors.white),
                        child: Text(
                          pinyinShow.isEmpty ? pinyin : pinyinShow,
                          style: widget.pinyinTextStyle,
                        ),
                      ),
                    ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.showCandidateWords,
            builder: (context, showCandidateWords, child) {
              var rowHeight = widget.keyHeight;
              return Container(
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            !showCandidateWords ? widget.borderRadius ?? 0 : 0),
                        topRight: Radius.circular(widget.borderRadius ?? 0),
                        bottomLeft: Radius.circular(widget.borderRadius ?? 0),
                        bottomRight: Radius.circular(widget.borderRadius ?? 0)),
                    color: widget.background ?? Colors.white),
                child: ValueListenableBuilder<InputLanguage>(
                  valueListenable: controller.selectedInputLanguage,
                  builder: (context, language, child) =>
                      ValueListenableBuilder<bool>(
                    valueListenable: controller.showSymbol,
                    builder: (context, showSymbol, child) =>
                        ValueListenableBuilder<bool>(
                      valueListenable: controller.capitalize,
                      builder: (context, capitalize, child) => Column(
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: controller.pinyin,
                            builder: (context, value, child) => value.isEmpty
                                ? SizedBox(
                                    height: rowHeight,
                                    child: Row(
                                      children: [
                                        ...buildNumRow(),
                                        if (widget.canClose)
                                          TextKey(
                                            value: "\n",
                                            flex: 1,
                                            textKeyStyle: textKeyStyle,
                                            onTextInput: (s) {
                                              widget.onDone?.call();
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              size: (textKeyStyle.textStyle
                                                          ?.fontSize ??
                                                      32) *
                                                  2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding:
                                        widget.keyMargin ?? EdgeInsets.all(0),
                                    child: buildCandidateWordsWidget(context),
                                  ),
                          ),
                          SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: [
                                ...showSymbol
                                    ? buildSymbolRow1(language)
                                    : buildLetterRow1(capitalize),
                                TextKey(
                                  textKeyStyle: textKeyStyle,
                                  onTextInput: (s) {
                                    if (controller.pinyin.value.isNotEmpty) {
                                      controller.removeKey();
                                      return;
                                    }
                                    if (widget.textController != null) {
                                      var textController =
                                          widget.textController!;
                                      if (textController.text.isNotEmpty) {
                                        String textBefore = textController
                                            .selection
                                            .textBefore(textController.text);
                                        String textInside = textController
                                            .selection
                                            .textInside(textController.text);
                                        String textAfter = textController
                                            .selection
                                            .textAfter(textController.text);
                                        if (textInside.isNotEmpty) {
                                          textController.text =
                                              textBefore + textAfter;
                                        } else if (textBefore.isNotEmpty) {
                                          final currentOffset = textController
                                                      .selection.baseOffset ==
                                                  -1
                                              ? textController.text.length
                                              : textController
                                                  .selection.baseOffset;
                                          if (textController.text.isEmpty ||
                                              currentOffset < 1) return;
                                          var newText = textController.text
                                                  .substring(
                                                      0, currentOffset - 1) +
                                              textController.text
                                                  .substring(currentOffset);
                                          var newSelection =
                                              TextSelection.collapsed(
                                                  offset: currentOffset - 1);
                                          textController.value =
                                              TextEditingValue(
                                                  text: newText,
                                                  selection: newSelection);
                                        }
                                      }
                                    }
                                    widget.onBackspace?.call();
                                  },
                                  child: Icon(
                                    Icons.keyboard_backspace_outlined,
                                    size: textKeyStyle.textStyle?.fontSize,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: [
                                ...showSymbol
                                    ? buildSymbolRow2(language)
                                    : buildLetterRow2(capitalize),
                                TextKey(
                                  text: '换行',
                                  value: "\n",
                                  flex: 1,
                                  textKeyStyle: textKeyStyle,
                                  onTextInput: _textInputHandler,
                                  isCanLongPressing: false,
                                ),
                                TextKey(
                                  text:
                                      controller.showSymbol.value ? '字母' : '符号',
                                  flex: 1,
                                  textKeyStyle: textKeyStyle,
                                  isCanLongPressing: false,
                                  onTextInput: (s) {
                                    controller.clear();
                                    controller.showSymbol.value =
                                        !controller.showSymbol.value;
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: [
                                TextKey(
                                  value: capitalize ? "大写" : "小写",
                                  isCanLongPressing: false,
                                  flex: 1,
                                  onTextInput: (s) {
                                    controller.capitalize.value =
                                        !controller.capitalize.value;
                                  },
                                  textKeyStyle: textKeyStyle,
                                ),
                                ...showSymbol
                                    ? buildSymbolRow3(language)
                                    : buildLetterRow3(capitalize),
                                TextKey(
                                  isCanLongPressing: false,
                                  onTextInput: (s) {
                                    controller.clear();
                                    controller.selectedInputLanguage.value =
                                        controller.selectedInputLanguage
                                                    .value ==
                                                InputLanguage.zh
                                            ? InputLanguage.en
                                            : InputLanguage.zh;
                                  },
                                  flex: 2,
                                  textKeyStyle: textKeyStyle,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        language == InputLanguage.zh
                                            ? '中'
                                            : '英',
                                        style: widget.keyTextStyle,
                                      ),
                                      Text(
                                        '/',
                                        style: TextStyle(
                                            fontSize: (widget.keyTextStyle
                                                        ?.fontSize ??
                                                    32) *
                                                0.6,
                                            height: 1,
                                            color: Colors.grey),
                                      ),
                                      Text(
                                        language == InputLanguage.zh
                                            ? '英'
                                            : '中',
                                        style: TextStyle(
                                            fontSize: (widget.keyTextStyle
                                                        ?.fontSize ??
                                                    32) *
                                                0.6,
                                            height: 1,
                                            color: Colors.grey),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: [
                                TextKey(
                                    value: language != InputLanguage.zh
                                        ? ','
                                        : '，',
                                    onTextInput: _textInputHandler,
                                    textKeyStyle: textKeyStyle),
                                TextKey(
                                    value: language != InputLanguage.zh
                                        ? '.'
                                        : '。',
                                    onTextInput: _textInputHandler,
                                    textKeyStyle: textKeyStyle),
                                TextKey(
                                    value: "@",
                                    onTextInput: _textInputHandler,
                                    textKeyStyle: textKeyStyle),
                                TextKey(
                                  flex: 4,
                                  value: " ",
                                  onTextInput: (value) {
                                    if (controller.showCandidateWords.value) {
                                      if (controller
                                          .candidateWords.value.isNotEmpty) {
                                        _inputHandler(controller
                                            .candidateWords.value.first);
                                      } else {
                                        _inputHandler(
                                            controller.pinyinShow.value);
                                      }
                                      controller.clear();
                                    } else {
                                      controller.clear();
                                      if (value != null) {
                                        _inputHandler(value);
                                      }
                                    }
                                  },
                                  textKeyStyle: textKeyStyle,
                                  child: Icon(
                                    Icons.space_bar,
                                    size: textKeyStyle.textStyle?.fontSize,
                                  ),
                                ),
                                TextKey(
                                    value: language != InputLanguage.zh
                                        ? '?'
                                        : '？',
                                    onTextInput: _textInputHandler,
                                    textKeyStyle: textKeyStyle),
                                TextKey(
                                    value: language != InputLanguage.zh
                                        ? '!'
                                        : '！',
                                    onTextInput: _textInputHandler,
                                    textKeyStyle: textKeyStyle),
                                TextKey(
                                  isCanLongPressing: false,
                                  onTextInput: (s) {
                                    if (controller.showCandidateWords.value &&
                                        controller
                                            .candidateWords.value.isNotEmpty) {
                                      _inputHandler(controller
                                          .candidateWords.value.first);
                                      controller.clear();
                                    }
                                    widget.onDone?.call();
                                  },
                                  flex: 2,
                                  textKeyStyle: textKeyStyle,
                                  child: Text(
                                    "确认",
                                    style: widget.keyTextStyle,
                                  ),
                                ),
                                if (widget.showBottomClose)
                                  TextKey(
                                    isCanLongPressing: false,
                                    value: "",
                                    flex: 1,
                                    textKeyStyle: textKeyStyle,
                                    onTextInput: (s) {
                                      controller.clear();
                                      widget.onClose?.call();
                                    },
                                    child: Icon(
                                      CupertinoIcons.multiply_circle,
                                      size: (widget.keyTextStyle?.fontSize ??
                                              32) *
                                          1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildCandidateWordsWidget(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: controller.candidateWords,
      builder: (context, candidateWords, child) {
        return Row(
          children: [
            Expanded(
                child: Container(
              width: double.infinity,
              height: candidateWordsRowHeight * candidateWordsRows + (24),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: widget.candidateWordsBackground ?? Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                child: Wrap(
                  clipBehavior: Clip.antiAlias,
                  direction: Axis.horizontal,
                  children: candidateWords
                      .map((e) => GestureDetector(
                            onTap: () {
                              controller.selected(e);
                              controller.clear();
                              _inputHandler(e);
                            },
                            child: Container(
                              height: candidateWordsRowHeight,
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    e,
                                    style: widget.candidateWordTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            )),
            SizedBox(
              width: 12,
            ),
            candidateWordsRows > 1
                ? Container(
                    width: 64,
                    child: Column(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: candidateWordsCanPrevious,
                          builder: (context, value, child) => IconButton(
                            iconSize: widget.pageTurnIconSize ?? 42,
                            icon: const Icon(
                              Icons.keyboard_arrow_up,
                            ),
                            color: !value ? Colors.grey : null,
                            onPressed: value
                                ? () {
                                    previousCandidateWords();
                                  }
                                : null,
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: candidateWordsCanNext,
                          builder: (context, value, child) => IconButton(
                            iconSize: widget.pageTurnIconSize ?? 42,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                            ),
                            color: !value ? Colors.grey : null,
                            onPressed: value
                                ? () {
                                    nextCandidateWords();
                                  }
                                : null,
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: Row(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: candidateWordsCanPrevious,
                          builder: (context, value, child) => IconButton(
                            iconSize: widget.pageTurnIconSize ?? 42,
                            icon: const Icon(Icons.keyboard_arrow_left),
                            color: !value ? Colors.grey : null,
                            onPressed: value
                                ? () {
                                    previousCandidateWords();
                                  }
                                : null,
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: candidateWordsCanNext,
                          builder: (context, value, child) => IconButton(
                            iconSize: widget.pageTurnIconSize ?? 42,
                            icon: const Icon(
                              Icons.keyboard_arrow_right,
                            ),
                            color: !value ? Colors.grey : null,
                            onPressed: value
                                ? () {
                                    nextCandidateWords();
                                  }
                                : null,
                          ),
                        )
                      ],
                    ),
                  )
          ],
        );
      },
    );
  }

  updateCandidateWordsScrollStatus() {
    debugPrint("updateCandidateWordsScrollStatus");
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      candidateWordsCanNext.value =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
      candidateWordsCanPrevious.value =
          _scrollController.offset > _scrollController.position.minScrollExtent;
    } else if (controller.candidateWords.value.isEmpty) {
      candidateWordsCanNext.value = false;
      candidateWordsCanPrevious.value = false;
    } else {
      candidateWordsCanNext.value = true;
      candidateWordsCanPrevious.value = false;
    }
  }

  nextCandidateWords() {
    if (_scrollController.offset < _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
          _scrollController.offset +
              candidateWordsRowHeight * candidateWordsRows,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease);
    }
  }

  previousCandidateWords() {
    if (_scrollController.offset > _scrollController.position.minScrollExtent) {
      _scrollController.animateTo(
          _scrollController.offset -
              candidateWordsRowHeight * candidateWordsRows,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease);
    }
  }

  List<Widget> buildNumRow() {
    String textKey = "1234567890";
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _textInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  List<Widget> buildLetterRow1(bool capitalize) {
    String textKey = "qwertyuiop";
    if (capitalize) {
      textKey = textKey.toUpperCase();
    }
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _letterInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  List<Widget> buildLetterRow2(bool capitalize) {
    String textKey = "asdfghjkl";
    if (capitalize) {
      textKey = textKey.toUpperCase();
    }
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _letterInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  List<Widget> buildLetterRow3(bool capitalize) {
    String textKey = "zxcvbnm";
    if (capitalize) {
      textKey = textKey.toUpperCase();
    }
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _letterInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  void _textInputHandler(String? value) {
    controller.clear();
    if (value != null) {
      _inputHandler(value);
    }
  }

  void _letterInputHandler(String? value) {
    if (value != null) {
      if (controller.capitalize.value) {
        _inputHandler(value.toUpperCase());
      } else if (controller.selectedInputLanguage.value == InputLanguage.en) {
        _inputHandler(value.toLowerCase());
      } else {
        controller.addKey(value.toLowerCase());
      }
    }
  }

  _inputHandler(String value) {
    if (widget.textController != null) {
      var textController = widget.textController!;
      final currentOffset = textController.selection.baseOffset == -1
          ? textController.text.length
          : textController.selection.baseOffset;
      var newText = textController.text.substring(0, currentOffset) +
          value +
          textController.text.substring(currentOffset);
      var newSelection =
          TextSelection.collapsed(offset: currentOffset + value.length);
      textController.value =
          TextEditingValue(text: newText, selection: newSelection);
    }
    widget.onInput?.call(value);
  }

  List<Widget> buildSymbolRow1(InputLanguage language) {
    String textKey =
        language == InputLanguage.en ? "~+-=\$%^&()" : "~+-=￥%…&（）";
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _textInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  List<Widget> buildSymbolRow2(InputLanguage language) {
    String textKey = language == InputLanguage.en ? "*:;'\"\\/_" : "*：；‘“、/_";
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _textInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }

  List<Widget> buildSymbolRow3(InputLanguage language) {
    String textKey = language == InputLanguage.en ? "<>{}[]" : "《》{}【】";
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _textInputHandler,
          textKeyStyle: textKeyStyle,
          child: item == ' '
              ? Icon(
                  Icons.space_bar,
                  size: textKeyStyle.textStyle?.fontSize,
                )
              : null,
        )
    ];
  }

  List<Widget> buildSymbolRow4(InputLanguage language) {
    String textKey = "., ?!";
    if (language == InputLanguage.zh) {
      textKey = "。， ？！";
    }
    return [
      for (var item in textKey.characters)
        TextKey(
          value: item,
          onTextInput: _letterInputHandler,
          textKeyStyle: textKeyStyle,
        )
    ];
  }
}
