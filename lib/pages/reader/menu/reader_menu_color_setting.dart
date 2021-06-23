import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/util.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 颜色设置模块
/// 包含 字体颜色,背景颜色
class ReaderMenuColorSetting extends StatefulWidget {
  ReaderMenuColorSetting({Key? key}) : super(key: key);

  @override
  _ReaderMenuColorSettingState createState() => _ReaderMenuColorSettingState();
}

class _ReaderMenuColorSettingState extends State<ReaderMenuColorSetting> {
  /// 当前设置的是字体颜色还是背景颜色
  String radioType = "font"; // font,background
  /// 阅读设置
  ReaderSettingModel? setting;

  /// 阅读数据
  ReaderDataModel? data;
  Color get color {
    if (setting == null) {
      return Color(0xFFFFFFFF);
    } else {
      if (radioType == 'font') {
        return setting!.color;
      } else {
        return setting!.backgroundColor;
      }
    }
  }

  set color(Color c) {
    if (setting == null) {
      throw FlutterError('setting未初始化,无法设置颜色');
    } else {
      if (radioType == 'font') {
        return setting!.setColor(c);
      } else {
        return setting!.setBackgroundColor(c);
      }
    }
  }

  // create some values
  Color pickerColor = Color(0xff443a49);

  @override
  Widget build(BuildContext context) {
    setting = Provider.of<ReaderSettingModel>(context);
    data = Provider.of<ReaderDataModel>(context);
    return ReaderMenuContainer(
      height: 750.w,
      child: Column(
        children: [
          SizedBox(
            height: 20.w,
          ),
          // 当前设置的是字体颜色还是背景颜色

          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                radioItem('font', '字体'),
                radioItem('background', '背景'),
              ],
            ),
          ),
          SizedBox(
            height: 30.w,
          ),
          Container(
            child: ColorPicker(
              pickerColor: color,
              paletteType: PaletteType.hsv,
              displayThumbColor: true,
              // showLabel: false,
              onColorChanged: (Color _color) {
                print('onColorChanged $_color');
                color = _color;
              },
              // showLabel: true,
              pickerAreaHeightPercent: 0.4,
            ),
          )
        ],
      ),
    );
  }

  Widget radioItem(
    String value,
    String title,
  ) {
    var active = value == radioType;
    //0xFF7BD361
    var color = active ? Color(0xFF007AFF) : Color(0xFFBBBBBB);
    return Container(
      // width: 130.w,
      height: 80.w,
      child: OutlinedButton(
          style: ButtonStyle(
            // shape: MaterialStateProperty.all(StadiumBorder()),
            side: MaterialStateProperty.all(
              BorderSide(
                color: color,
                width: 2.w,
              ),
            ),

            padding: MaterialStateProperty.all(EdgeInsets.all(10)),
          ),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: radioType,
                fillColor: MaterialStateProperty.resolveWith((state) {
                  if (state.contains(MaterialState.selected))
                    return Color(0xFF007AFF);
                  return Color(0xFFBBBBBB);
                }),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) {
                  setState(() {
                    radioType = value;
                  });
                },
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 30.w,
                    // color: color,
                    color: Color(0xFFBBBBBB)),
              ),
              SizedBox(
                width: 20.w,
              )
            ],
          ),
          onPressed: () {
            print("onPressed");
            setState(() {
              radioType = value;
            });
          }),
    );
  }
}
