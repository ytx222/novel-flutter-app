import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fast_gbk/fast_gbk.dart';
// import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:charset_converter/charset_converter.dart';

enum FileItemType {
  /// 目录
  dir,

  /// 文件
  file,

  /// txt文件
  textFile,

  /// 其他类型
  other,
}

class FileItem {
  /// 文件类型 默认一般文件
  FileItemType type = FileItemType.file;

  /// 文件的entity对象
  FileSystemEntity entity;

  /// 文件名
  String name = '';

  /// 文件的最后一次修改时间
  DateTime? updateTime;

  ///文件大小
  int size = 0;

  FileItem(this.entity) {
    name = entity.path.split("/").removeLast();

  }

  /// 初始化这个文件项目的信息
  FileItem initInfo() {
    if (updateTime == null) {
      print("初始化这个文件项目的信息 $entity");
      FileStat stat = entity.statSync();
      size = stat.size;
      updateTime = stat.modified;
      // 如果是目录执行的特殊操作
      if (stat.type == FileSystemEntityType.directory) {
        type = FileItemType.dir;
      } else if (stat.type == FileSystemEntityType.file) {
        // 如果是文件,判断是txt文件还是普通文件
        //FIXME: 用正则
        if (name.endsWith(".txt")) {
          type = FileItemType.textFile;
        } else {
          type = FileItemType.file;
        }
      } else {
        // 其他不识别的类型
        type = FileItemType.other;
      }
    }
    return this;
  }

  bool get isFile {
    return type == FileItemType.textFile || type == FileItemType.file;
  }

  @override
  String toString() {
    return """ FileItem{ name: $name, size: $size, type: $type, updateTime: $updateTime ?? ''}""";
  }
}

// import 'package:path_provider/path_provider.dart';

/// 获取
Future<List<FileItem>> getDirChild(String path) async {
  // ignore: await_only_futures
  var directory = await new Directory(path);
  print(directory);
  int t = DateTime.now().millisecondsSinceEpoch;
  try {
    var entityList = await directory.list().toList();
    List<FileItem> list = entityList.map<FileItem>((item) {
      return FileItem(item).initInfo();
    }).toList();
    // print(Timeline.now);
    print("获取到的文件列表长度: ${list.length}");
    print("时间:${DateTime.now().millisecondsSinceEpoch - t}");
    return list;
  } catch (e) {
    print(e);
    print("获取文件失败 path=$path");
    return [];
  }
  // print("uri");
  // print(list[0]);
  // print(FileItem(list[0]));
}

/// 获取文件编码
Future<String?> getFileEncode({String? path, File? file}) async {
  // 先读取文件的128kb内容
  if (file == null) {
    if (path == null) return null;
    file ??= new File(path);
  }
  var stream = file.openRead(0, 1024 * 128);
  List<int> list = [];
  await stream.forEach((el) {
    list.addAll(el);
  });
  /**
   * 先解析utf-8,再解析gbk,如果两个都失败,返回null,无需识别多余的编码格式,没有意义
   *
   */
  // 尝试解析utf8
  try {
    utf8.decode(list, allowMalformed: false);
    return "UTF8";
  } catch (e) {
    FormatException err = e as FormatException;
    // 如果在接近结束的位置报未完成的utf8序列错误,则认为是成功
    if (err.message == "Unfinished UTF-8 octet sequence" &&
        err.offset! > list.length - 10) {
      // print(utf8.decode(list, allowMalformed: true));
      print("解析UTF8--认为解析成功");
      return "UTF8";
    }
    // print(err);
    // print("解析出错--utf8");
    print("尝试解析UFT8失败");
  }
  // 尝试解析gbk
  try {
    gbk.decode(list);
    return "GBK";
  } catch (e) {
    print(e.runtimeType);
    /*
        输出是这样的,不过我也认为是成功了吧
        RangeError (index): Invalid value: Not in inclusive range 0..131071: 131072
        I/flutter ( 5291): 131072
        */
    if (e.runtimeType.toString() == 'RangeError') {
      RangeError err = e as RangeError;
      if (err.end! > list.length - 20) {
        print("解析GBK--认为解析成功");
        return "GBK";
      }
    } else if (e.runtimeType.toString() == 'FormatException') {
      FormatException err = e as FormatException;
      if (err.offset! > list.length - 20) {
        print("解析GBK--认为解析成功====FormatException");
        return "GBK";
      }
    } else {
      print("尝试解析GBK失败");
      print(e);
    }
  }
}

/// 将GBK文件覆盖保存文件为UTF8格式
Future<File?> saveAsUTF8(String path, [String? content]) async {
  if (content == null) {
    content = await readTxtFile(path: path, encoding: "GBK");
  }
  try {
    File file = new File(path);
    var newFile =
        await file.writeAsString(content!, mode: FileMode.write, flush: true);
    return newFile;
  } catch (e) {
    return null;
  }
}

/// 读文件
Future<String?> readTxtFile({
  required String path,
  String? encoding,
}) async {
  File file = new File(path);
  // 如果编码为null,则初始化编码类型
  if (encoding == null) encoding = await getFileEncode(path: path);
  try {
    var s;
    if (encoding == 'UTF8') {
      s = await file.readAsString(encoding: utf8);
    } else if (encoding == 'GBK') {
      var data = file.readAsBytesSync();
      s = await CharsetConverter.decode(encoding ?? '', data);
    } else {
      throw new ErrorDescription("无法读取该类型编码!");
    }
    // print(s.substring(0, 100));
    // var s = "字符串";
    print("readTxtFile读取$encoding,长度=${s.length} ");
    return s;
  } catch (e) {
    print(e);
    print("读取失败");
    return null;
  }
}

/// 在一个新线程中读文件,非阻塞
Future<String?> readTxtFileASync({
  String? path,
  String? encoding,
}) async {
  var t = (DateTime.now()).millisecondsSinceEpoch;

  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(dataLoader, receivePort.sendPort);
  // 获取新isolate的监听port
  SendPort sendPort = (await receivePort.first) as SendPort;
  // 调用sendReceive自定义方法
  String? s = (await sendReceive(sendPort, [path, encoding])) as String?;
  print("readTxtFileASync-时间${DateTime.now().millisecondsSinceEpoch - t}");
  return s;
}

// isolate的绑定方法
dataLoader(SendPort sendPort) async {
  // 创建监听port，并将sendPort传给外界用来调用
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  var msg = await receivePort.first;
  SendPort callbackPort = msg[0];
  String path = msg[1];
  String? encoding = msg[2];
  var s = await readTxtFile(path: path, encoding: encoding);
  // print("开始等待");
  // await _sleep(5000);
  // print("结束等待");
  // 回调返回值给调用者
  callbackPort.send(s);
  // 没用了,关闭
  receivePort.close();
  // 监听外界调用
  // await for (var msg in receivePort) { }
}

// Future<void> _sleep(int ms) {
//   var completer = new Completer<void>();
//   Timer.periodic(Duration(milliseconds: ms), (timer) {
//     timer.cancel();
//     completer.complete();
//   });
//   return completer.future;
// }

// 创建自己的监听port，并且向新isolate发送消息
Future sendReceive(SendPort sendPort, List<dynamic> parms) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(
    <dynamic>[
      receivePort.sendPort,
    ]..addAll(parms.toList()),
  );
  // 接收到返回值，返回给调用者
  return receivePort.first;
}

/// 申请权限
/// 1  = 成功
/// 0  = 拒绝
/// -1 = 永久拒绝
Future<int> getPermission() async {
  print("获取文件权限");
  var status = await Permission.manageExternalStorage.status;
  _pr(status);
  // 永久拒绝直接返回-1
  if (status.isPermanentlyDenied) {
    return -1;
  } else if (status.isGranted) {
    //给过权限了直接返回1
    return 1;
  }

  // 申请权限
  if (status.isDenied) {
    print("权限拒绝或未确认");
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    print("status2=$status2");
    if (status2.isGranted) {
      return 1;
    } else {
      return status2.isPermanentlyDenied ? -1 : 0;
    }
  }
  // 剩下的我也不知道啥情况的也返回1吧
  return 1;
}

_pr(PermissionStatus status) {
  // print("权限.undetermined${status.isUndetermined}");
  print("权限.isDenied: ${status.isDenied}");
  print("权限.isGranted: ${status.isGranted}");
}
