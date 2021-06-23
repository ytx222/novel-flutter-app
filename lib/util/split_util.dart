import 'dart:isolate';

import 'package:flutter/material.dart' hide Page;
import 'package:novel_app/class/chapter.dart';
import 'package:novel_app/class/section.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/class/page.dart' show Page;
import 'package:novel_app/util/ytx_ScreenUtil.dart';

/// 用于计算页面数量及每一页的内容
class SplitUtil {
  /* 计算过程中用到的一些变量 */
  static double width = 0;
  static double height = 0;
  static double titleFontSize = 0;
  static double titleLineHeight = 0;
  static double fontSize = 0;
  static double lineHeight = 0;
  static double sectionSpace = 0;
  static TextStyle titleStyle = TextStyle();
  static TextStyle sectionStyle = TextStyle();
  static String indentString = "";

  static bool isListener = false;

  static bool isLog = false;

  static _pring(String t) {
    // 通过调用内部方法实现禁用日志
    if (isLog) {
      print(t);
    }
  }

  /// 初始化,这个方法会在ReaderSettingModel更新时被调用
  static void init(ReaderSettingModel data) {
    _pring("初始化 SplitUtil==============================");
    if (!isListener) {
      isListener = true;
      data.addListener(() {
        SplitUtil.init(data);
      });
    }
    // 读取阅读设置
    titleFontSize = data.titleFontSize;
    fontSize = data.fontSize;
    titleLineHeight = data.titleLineHeight;
    lineHeight = data.lineHeight;
    indentString = data.indentString;
    //间距
    sectionSpace = data.sectionSpace;

    width = (100.vw - data.contentHorizontalPadding * 2).floorToDouble();
    //完整的高度
    height = 1334.h;
    // 减去header bar的
    height = height - 80.w - data.headerTopOffset;
    // 减去footerBar
    height = height - 80.w - data.footerBottomOffset;
    // 减去内容的上下间距
    height = height - data.contentToplPadding - data.contentBottomlPadding;
    // 取整
    height = height.floorToDouble();

    _pring("height: $height");
    // 将这两个变量也初始化一下,避免每次使用的时候再去定义
    titleStyle = TextStyle(
      fontSize: titleFontSize,
      height: titleLineHeight,
    );
    sectionStyle = TextStyle(
        fontSize: fontSize,
        height: lineHeight,
        textBaseline: TextBaseline.ideographic);
  }

  /**
   * 在计算页时需要用到的一些变量
   */
  /// 本页的剩余高度
  static double _remainH = 0;

  /// 当前章节的所有页面
  static List<Page> _pageList = [];

  /// 当前页面的所有段落
  static List<Section> _curPageSections = [];

  /// 当前页面的所有段落
  static Chapter? _curChapter;

  /// 计算一章的内容的页
  /// 需要返回`[Page]`
  /// [title] 章节标题
  /// [content] 章节段落列表
  static List<Page> splitPage({
    required Chapter chapter,
  }) {
    _curChapter = chapter;
    var title = chapter.name;
    var content = chapter.content;
    // 初始化行数据
    var _lineInfo = _getLineInfo();
    int lineLen = _lineInfo["length"] as int;
    double lineHei = _lineInfo["height"] as double;
    double lineHei2 = _getTxtHeight(" “啊 ");
    _pring("""
             开始计算页面
======================================
width: $width
height: $height
titleFontSize: $titleFontSize
titleLineHeight: $titleLineHeight
fontSize: $fontSize
lineHeight: $lineHeight
sectionSpace: $sectionSpace
渲染使用的字体大小${sectionStyle.fontSize}
一行字符长度： $lineLen
一行高度: $lineHei
行高度-2: $lineHei2
======================================
""");
// 本页的剩余高度
    _remainH = height;
    _pageList = [];
    _curPageSections = [];
    // 先获取章节标题高度,并把章节标题添加进list
    var titleHeigth = _getTxtHeight(title, isIndent: false, style: titleStyle);
    _curPageSections.add(Section(title, isTitle: true, index: -1));
    _remainH -= titleHeigth + sectionSpace;
    // _pring("章节标题高度 $titleHeigth  减去标题后剩余高度$_remainH");
    //本章的所有段落,循环计算高度
    var sections = splitSection(content);
    for (var i = 0; i < sections.length; i++) {
      var txt = sections[i];
      if (_remainH < lineHei) {
        // 如果放不下一行(一行高度+段落间距),直接进入下一页,就能放下了
        _pring("如果放不下一行(一行高度+段落间距),直接进入下一页,就能放下了=====");
        _pring(txt);
        nextPage();
      }
      var h = _getTxtHeight(txt);
      _pring("内容高度 $h\t剩余高度$_remainH");
      if (_remainH > h) {
        // 如果能完全放下
        addSection(txt, i, h: h);
      } else {
        /// 如果 高度 > 一行的高度   &&   高度 < 段落高度,则需要根据剩余高度计算
        /**
         * 关于段落跨页，
         * 1.根据已有高度信息，第一段设置maxline，第二段通过布局隐藏文本?
         * 2.计算，同样根据信息
         * 目前采用硬算,因为我翻了源码,没有直接计算这方面的api(也有可能是我没找到)
         * 同时,在复用TextPainter的情况下,计算的性能也足够高
         *
         */
        //FIXME: 有特殊符号时,一行会从33像素变成34像素,这个问题如何解决
        //如果在只有一行的情况下,可以通过一些设置,然后只计算高度,不计算宽度
        _pring("开始计算 剩余高度=$_remainH 间距$sectionSpace,lineHei:$lineHei");
        // 剩余位置可以容纳几行
        var lineNum = (_remainH / lineHei).floor();
        _pring("lineNum:$lineNum");
        // _pring("height:$height  lineHeight:$lineHeight  lineLength:$lineLength");
        var index = lineNum * lineLen - 6;
        if (index > txt.length) {
          index = txt.length;
        }
        _pring("首次计算,index=$index");
        String curTxt = txt.substring(0, index);
        // _pring("所以内容是,curTxt=$curTxt");
        var h = _getTxtHeight(curTxt);
        // 循环增加获取减少到正确位置
        _pring("h:$h 剩余高度$_remainH");
        if (h < _remainH) {
          _pring("相等++++++");
          // 如果相等,则加到值不相等结束
          // 所以while的条件是两个值相等
          do {
            curTxt = txt.substring(0, ++index);
            h = _getTxtHeight(curTxt);
          } while (h < _remainH);
          // 用这种方法计算,结束时index会大1,所以减去
          index--;
        } else {
          _pring("大于 -----");
          // 如果大于,就减到不大于(可以放下)返回即可
          // 所以while的条件是两个值不相等
          do {
            curTxt = curTxt.substring(0, --index);
            h = _getTxtHeight(curTxt);
          } while (h > _remainH);
        }
        _pring("计算完成===============================================");
        _pring(txt.substring(0, index));
        _pring(txt.substring(index));

        // 先添加一部分,然后将剩下的添加到下一页
        _curPageSections.add(Section(txt.substring(0, index)));
        nextPage();
        addSection(txt.substring(index), i, isStart: false);
      }
    }
    _pring("计算完成,返回_pageList$_pageList");
    // 将最后一页手动添加
    _pageList.add(Page(_curPageSections, _pageList.length, chapter));
    return _pageList;
  }

  // 计算时复用TextPainter
  static TextPainter _painter = TextPainter(
    locale: Locale('zh', 'CH'),
    textDirection: TextDirection.ltr,
  );

  /// 渲染并获取某个段落的高度
  static double _getTxtHeight(
    String txt, {
    TextStyle? style,
    bool isIndent = true,
    int? maxLines,
  }) {
    style ??= sectionStyle;
    if (isIndent) {
      txt = indentString + txt;
    }
    var testSpan = TextSpan(text: txt, style: style);
    // 重新设置参数 text
    _painter.text = testSpan;
    _painter.maxLines = maxLines;
    _painter.layout(maxWidth: width);

    return _painter.height;
  }

  /// 获取一行的大概长度
  static Map<String, num> _getLineInfo() {
    var txt = "正";
    var h = _getTxtHeight(txt, isIndent: false);
    // 这里可以优化算法,但是没有必要
    while (_getTxtHeight(txt, isIndent: false) == h) {
      txt += "正";
    }
    return {'length': txt.length, 'height': h};
  }

  /// 计算时下一页
  static void nextPage() {
    _pring(
        '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ${_pageList.length + 1}');
    _remainH = height;
    _pageList.add(Page(_curPageSections, _pageList.length, _curChapter!));
    _pring("添加页面======$_pageList");
    _curPageSections = [];
  }

  // 计算时,向当前页添加一个段落
  static void addSection(
    String txt,
    int sectionIndex, {
    double? h,
    bool isStart = true,
  }) {
    bool isSpace = isStart;
    if (_curPageSections.isEmpty) {
      isSpace = false;
    }
    var section = Section(
      txt,
      isStart: isStart,
      index: sectionIndex,
      isSpace: isSpace,
    );
    _curPageSections.add(section);
    if (h == null) {
      h = _getTxtHeight(txt, isIndent: isStart);
    }
    _remainH -= h + sectionSpace;
  }

  /// 分段(章节-段落)
  static List<String> splitSection(String txt) {
    // 根据换行符分割
    return txt.split("\n").map((e) {
      // 先循环去除空白字符
      return e.trim();
    }).where((element) {
      // 如果有的行是空的,则丢弃
      return !(element == '');
    })
        /*.map((e) {
      // 其余操作
      return e;
    })*/
        .toList();
  }

  /// 根据正则分章,分章对数据其实没什么依赖
  static List<Chapter> splitChapter(String txt) {
    _pring("开始分章=========================");
    //FIXME: 通过mmkv读取正则
    //FIXME: 分章时综合考虑,合并章节(章节名称相同或类型,同时上一章的内容过短时)
    var regStr = "(?:\\s*)第[一二三四五六七八九十百千万零〇两\\d]*章[^\\n]*";
    var reg = new RegExp(regStr, dotAll: true);

    var res = reg.allMatches(txt);
    /**
     * 每一项都是一个章节名称的起始位置和结束为止
     * 也就是说,这个章节名称的终止为止 ~ 下个章节名称的起始位置
     * 就是这个章节名称的完整内容位置
     *  注意,这里匹配的是章名,而不是实际内容,逻辑搞清楚
     */
    var _first = res.first;
    var chapterList = [Chapter('开始', 0, _first.start)];

    // 上一章内容开始的位置(章节名称结束的位置)
    var startIndex = _first.end;
    var name = txt.substring(_first.start, _first.end).trim();
    res.skip(1).forEach((e) {
      // 添加上一章
      chapterList.add(Chapter(name, startIndex, e.start));
      // 保存相关信息
      name = txt.substring(e.start, e.end).trim();
      startIndex = e.end;
    });
    // 最后一章的处理
    chapterList.add(Chapter(name, startIndex, txt.length));
    // print(chapterList);
    print("分章完成=========================");
    return chapterList;
  }

  /// 根据正则分章,分章对数据其实没什么依赖
  static Future<List<Chapter>> splitChapterASync(String txt) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_dataLoader, receivePort.sendPort);
    // 获取新isolate的监听port
    SendPort sendPort = (await receivePort.first) as SendPort;
    // 调用sendReceive自定义方法
    List<Chapter> res = (await _sendReceive(sendPort, [txt])) as List<Chapter>;
    return res;
  }

  // isolate的绑定方法
  static _dataLoader(SendPort sendPort) async {
    // 创建监听port，并将sendPort传给外界用来调用
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    var msg = await receivePort.first;
    SendPort callbackPort = msg[0];
    String txt = msg[1];

    var res = splitChapter(txt);

    // 回调返回值给调用者
    callbackPort.send(res);
    // 没用了,关闭
    receivePort.close();
    // 监听外界调用
    // await for (var msg in receivePort) { }
  }

  // 创建自己的监听port，并且向新isolate发送消息
  static Future _sendReceive(SendPort sendPort, List<dynamic> parms) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(
      <dynamic>[
        receivePort.sendPort,
      ]..addAll(parms.toList()),
    );
    // 接收到返回值，返回给调用者
    return receivePort.first;
  }
}

/**
// 计算效率的代码
print("==================================");
var t = DateTime.now();
for (var i = 0; i < 10000*100; i++) {
  var h = _getTxtHeight("""正""");
}
print("==================================");
print("时间${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}");

300字 	10000次 	23ms
300字 	10000次 	5500ms		不复用的情况
300字 	100w次 	 	1500ms
100字 	100w次 	 	1000ms
1字 	  100w次 	 	600ms

*/
/*
/// 模板方法,我基于这个方法写自己的代码
  /// value: 文本内容；fontSize : 文字的大小；fontWeight：文字权重；maxWidth：文本框的最大宽度；maxLines：文本支持最大多少行
  static double calculateTextHeight(
    String value,
    fontSize,
    FontWeight fontWeight,
    double maxWidth,
    int maxLines,
  ) {
    // value = filterText(value);
    TextPainter painter = TextPainter(
      ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: Locale('zh', 'CH'),
      // Localizations.localeOf(GlobalStatic.context),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
        ),
      ),
    );

    painter.layout(maxWidth: maxWidth);

    ///文字的宽度:painter.width
    return painter.height;
  }
*/
/*
///根据已知每行高度,每行文本长度(大概),可用高度
  ///,计算出这么多行可以放多少个文字,并返回下标位置
  static int _lineToIndex(
    String txt,
    int lineLength,
    double lineHeight,
    double height, // 可使用的高度
  ) {
    // 需要几行
    var lineNum = (height / lineHeight).floor();
    // print("height:$height  lineHeight:$lineHeight  lineLength:$lineLength");
    var index = lineNum * lineLength - 6;
    String curTxt = txt.substring(0, index);
    var h = _getTxtHeight(curTxt);
    // 如果相等,需要加一个index继续计算
    // 如果大于,则需要减index继续计算
    // print("${h == lineNum * lineHeight} $h == ${lineNum * lineHeight}");
    // print(curTxt);
    if ((h - lineNum * lineHeight).abs() < 0.000001) {
      // 如果相等,则加到值不相等结束
      // 所以while的条件是两个值相等
      do {
        curTxt = txt.substring(0, ++index);
        h = _getTxtHeight(curTxt);
      } while ((h - lineNum * lineHeight).abs() < 0.000001);
      // 用这种方法计算,结束时index会大1,所以减去
      index--;
    } else {
      // 如果大于,就减到不大于(可以放下)返回即可
      // 所以while的条件是两个值不相等
      do {
        curTxt = curTxt.substring(0, --index);
        h = _getTxtHeight(curTxt);
      } while ((h - lineNum * lineHeight).abs() > 0.000001);
    }

    return index;
  } */
