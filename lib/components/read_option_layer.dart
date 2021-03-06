import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/components/read_pager.dart';
import 'package:seek_book/pages/demopage.dart';
import 'package:seek_book/utils/browser.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seek_book/globals.dart' as Globals;

/// 阅读页选项弹出层
class ReadOptionLayer extends StatefulWidget {
  final Map bookInfo;
  final GlobalKey<ReadPagerState> readPagerKey;

  ReadOptionLayer({Key key, this.bookInfo, this.readPagerKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ReadOptionLayerState();
  }
}

class ReadOptionLayerState extends State<ReadOptionLayer> {
  var layerShow = false;

  Map bookInfo;

  bool tocOrder = false;

  @override
  void initState() {
    this.bookInfo = widget.bookInfo;

    super.initState();

    initScreenOrientation();
  }

//  void

  onBookInfoChange(Map bookInfo) {
    this.bookInfo = bookInfo;
  }

  void initScreenOrientation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    if (MediaQuery.of(context).orientation == Orientation.portrait) {
    var orientation = prefs.getString('orientation');
    if (orientation == 'landscape') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else if (orientation == 'portrait') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void show() {
    if (layerShow) return;
    setState(() {
      layerShow = true;
    });
    StatusBar.show();
  }

  void hide() {
    if (!layerShow) return;
    setState(() {
      layerShow = false;
    });
    StatusBar.hide();
  }

  void toggleShow() {
    if (layerShow) {
      hide();
    } else {
      show();
    }
  }

  toggleOrientation() async {
    var orientation = Globals.orientation;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (orientation == 'landscape') {
      prefs.setString('orientation', 'portrait');
      Globals.orientation = 'portrait';
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (orientation == 'portrait') {
      prefs.setString('orientation', 'landscape');
      Globals.orientation = 'landscape';
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List chapterList = bookInfo['chapterList'];
    var currentChapterIndex = bookInfo['currentChapterIndex'];
    var chapterUrl;
    if (currentChapterIndex < chapterList.length) {
      chapterUrl = chapterList[currentChapterIndex]['url'];
    }
    var topLayer = Container(
//      height: 100.0,
      color: Colors.black,
      child: SafeArea(
        child: Container(
          width: vw(100),
          color: Color(0xff191919),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Color(0x00ffffff),
                      child: Image.asset(
                        "assets/images/ab_back.png",
                        width: dp(23),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: dp(16),
                        vertical: dp(21),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        bookInfo['name'],
                        style: TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: dp(20),
                        ),
                      ),
                      margin: EdgeInsets.only(left: dp(20)),
                    ),
                  ),
                ],
              ),
              chapterUrl == null
                  ? Container()
                  : Container(
                      padding: EdgeInsets.symmetric(
//                        vertical: dp(11.5),
                        vertical: dp(0),
                        horizontal: dp(20),
                      ),
                      color: Color(0xff2A2929),
                      child: Clickable(
                        onClick: () {
                          Browser.openURL(chapterUrl);
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                chapterUrl,
                                style: TextStyle(
                                  color: Color(0xffFFFFFF).withOpacity(0.2),
                                  fontSize: dp(12),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '显示原网页',
                              style: TextStyle(
                                color: Color(0xffFFFFFF).withOpacity(0.2),
                                fontSize: dp(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
    var bottomLayer = Container(
      padding: EdgeInsets.symmetric(vertical: dp(10)),
//      height: 100.0,
      color: Color(0xff191919),
      child: Row(
        children: <Widget>[
          _BottomButton(
            label: Globals.readTheme == 'normal' ? '夜间' : '正常',
            imageAssets: Globals.readTheme == 'normal'
                ? 'assets/images/ic_menu_mode_night_normal.png'
                : 'assets/images/ic_menu_mode_normal_normal.png',
            onClick: toggleTheme,
          ),
          _BottomButton(
            label: Globals.orientation == 'portrait' ? '横屏' : '竖屏',
            imageAssets: 'assets/images/ic_menu_orientation_normal.png',
            onClick: toggleOrientation,
          ),
          _BottomButton(
            label: '设置',
            imageAssets: 'assets/images/ic_menu_settings_normal.png',
          ),
          _BottomButton(
            label: '目录',
            imageAssets: 'assets/images/ic_menu_toc_normal.png',
            onClick: showTocListDialog,
          ),
        ],
      ),
    );
    var children = <Widget>[
      topLayer,
      Expanded(child: Container()),
      bottomLayer
    ];
    if (!layerShow) {
      children = [];
    }
    return Container(
      child: Column(
        children: children,
      ),
    );
  }

  toggleTheme() async {
    if (Globals.readTheme == 'normal') {
      Globals.readTheme = 'dark';
    } else {
      Globals.readTheme = 'normal';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('readTheme', Globals.readTheme);
    widget.readPagerKey.currentState.setState(() {});
    setState(() {});
  }

  showTocListDialog() async {
//    await Navigator.push(
//      context,
//      CupertinoPageRoute(
//        builder: (context) => DemoPage(),
//      ),
//    );
//    return;
//    var color = Color(0xFFffffff).withOpacity(0.4);
//    print('Color(0xFFffffff).withOpacity(0.4) 输出 $color');
    final ThemeData theme = Theme.of(context);
    List chapterList = bookInfo['chapterList'];
    var scrollController = ScrollController(
//      initialScrollOffset: dp(55) *
//          max(0, widget.readPagerKey.currentState.currentChapterIndex - 5),
        );
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return _SimpleDialog(
          titlePadding: EdgeInsets.symmetric(
            horizontal: dp(24),
            vertical: dp(20),
          ),
          title: Container(
//              padding: EdgeInsets.only(bottom: dp(20)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    bookInfo['name'],
                    style:
                        TextStyle(fontSize: dp(17), color: theme.primaryColor),
                  ),
                ),
                GestureDetector(
                  onTap: toggleTocOrder,
                  child: Text(tocOrder ? "倒序" : "正序"),
                )
              ],
            ),
          ),
          children: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
//                color: Colors.red,
            ),
            height: vh(100) - dp(160),
            width: vw(80),
            child: ListView.builder(
              controller: scrollController,
              itemBuilder: buildCRow,
              itemCount: chapterList.length,
//              reverse: true,
            ),
          ),
        );
      },
    ).then<void>((String value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {}
    });
//    Future.delayed(Duration(milliseconds: 1000)).then((a) {
//      print("1111111111");
//      scrollController.jumpTo(
//          dp(35) * widget.readPagerKey.currentState.currentChapterIndex);
//    });
  }

  Widget buildCRow(context, index) {
    var textStyle = TextStyle(
      fontSize: dp(15),
    );
    if (tocOrder) {
      index = bookInfo['chapterList'].length - index - 1;
    }
    if (index == widget.readPagerKey.currentState.currentChapterIndex) {
      textStyle = TextStyle(
        fontSize: dp(15),
        color: Color(0xFFff0000),
      );
    }
    if (bookInfo['chapterList'].length ==
            widget.readPagerKey.currentState.currentChapterIndex &&
        index == widget.readPagerKey.currentState.currentChapterIndex - 1) {
      textStyle = TextStyle(
        fontSize: dp(15),
        color: Color(0xFFff0000),
      );
    }
    return GestureDetector(
      onTap: () {
        widget.readPagerKey.currentState.changeChapter(index);
        Navigator.pop(context, '');
      },
      child: Container(
        height: dp(55),
        padding: EdgeInsets.symmetric(
          horizontal: dp(20),
//                        vertical: dp(10),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${bookInfo['chapterList'][index]['title']}',
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  toggleTocOrder() async {
    setState(() {
      tocOrder = !tocOrder;
    });
    Navigator.pop(context, '');
    showTocListDialog();
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final String imageAssets;
  final onClick;

  _BottomButton({Key key, this.label, this.imageAssets, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bottomLabelStyle = TextStyle(
      color: Color(0xffFFFFFF).withOpacity(0.6),
      fontSize: dp(13),
    );
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onClick != null) {
            onClick();
          }
        },
        child: Container(
          color: Color(0xffFFFFFF).withOpacity(0.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                imageAssets,
                width: dp(30),
              ),
              Text(
                label,
                style: bottomLabelStyle,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleDialog extends StatelessWidget {
  /// Creates a simple dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  ///
  /// The [titlePadding] and [contentPadding] arguments must not be null.
  const _SimpleDialog({
    Key key,
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    this.children,
    this.contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.semanticLabel,
  })  : assert(titlePadding != null),
        assert(contentPadding != null),
        super(key: key);

  /// The (optional) title of the dialog is displayed in a large font at the top
  /// of the dialog.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Padding around the title.
  ///
  /// If there is no title, no padding will be provided.
  ///
  /// By default, this provides the recommend Material Design padding of 24
  /// pixels around the left, top, and right edges of the title.
  ///
  /// See [contentPadding] for the conventions regarding padding between the
  /// [title] and the [children].
  final EdgeInsetsGeometry titlePadding;

  /// The (optional) content of the dialog is displayed in a
  /// [SingleChildScrollView] underneath the title.
  ///
  /// Typically a list of [SimpleDialogOption]s.
//  final List<Widget> children;
  final Widget children;

  /// Padding around the content.
  ///
  /// By default, this is 12 pixels on the top and 16 pixels on the bottom. This
  /// is intended to be combined with children that have 24 pixels of padding on
  /// the left and right, and 8 pixels of padding on the top and bottom, so that
  /// the content ends up being indented 20 pixels from the title, 24 pixels
  /// from the bottom, and 24 pixels from the sides.
  ///
  /// The [SimpleDialogOption] widget uses such padding.
  ///
  /// If there is no [title], the [contentPadding] should be adjusted so that
  /// the top padding ends up being 24 pixels.
  final EdgeInsetsGeometry contentPadding;

  /// The semantic label of the dialog used by accessibility frameworks to
  /// announce screen transitions when the dialog is opened and closed.
  ///
  /// If this label is not provided, a semantic label will be infered from the
  /// [title] if it is not null.  If there is no title, the label will be taken
  /// from [MaterialLocalizations.dialogLabel].
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.isRouteName], for a description of how this
  ///    value is used.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final List<Widget> body = <Widget>[];
    String label = semanticLabel;

    if (title != null) {
      body.add(Padding(
          padding: titlePadding,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.title,
            child: Semantics(namesRoute: true, child: title),
          )));
    } else {
      switch (Platform.operatingSystem) {
        case 'ios':
          label = semanticLabel;
          break;
        case 'android':
        case 'fuchsia':
          label =
              semanticLabel ?? MaterialLocalizations.of(context)?.dialogLabel;
      }
    }

    if (children != null) {
//      body.add(Flexible(
//          child: SingleChildScrollView(
//        padding: contentPadding,
////        child: ListBody(children: children),
//        child: ListBody(children: children),
//      )));
      body.add(children);
    }

    Widget dialogChild = IntrinsicWidth(
      stepWidth: 56.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: body,
        ),
      ),
    );

    if (label != null)
      dialogChild = Semantics(
        namesRoute: true,
        label: label,
        child: dialogChild,
      );
    return Dialog(child: dialogChild);
  }
}
