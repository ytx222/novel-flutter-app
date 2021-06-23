import 'dart:async';

/// 仿js的Promise
class Promise {
  late Future future;
  Promise(dynamic excutor(dynamic resolve(val), dynamic reject(val))) {
    if (!(excutor is Function)) {
      throw new AssertionError('Promise resolver $excutor is not a function');
    }
    final completer = Completer();
    try {
      excutor(completer.complete,
          completer.completeError as dynamic Function(dynamic));
    } catch (e) {
      completer.completeError(e);
    }
    this.future = completer.future;
    // return future;
  }

  /// Promise链式回调，对应Dart [.then]
  Future then(Future Function(dynamic) onValue, {Function? onError}) {
    return this.future.then(onValue, onError: onError);
  }

  /// Promise链式回调，对应Dart [.catchError]
  Future onCatch(Function onError, {bool Function(Object)? test}) {
    return this.future.catchError(onError, test: test);
  }

  /// Promise链式回调，对应Dart [.whenComplete]
  Future onFinally(Future<dynamic> Function() action) {
    return this.future.whenComplete(action);
  }

  Stream asStream() {
    throw UnimplementedError();
  }

  Future catchError(Function onError, {bool Function(Object error)? test}) {
    throw UnimplementedError();
  }

  Future<void> timeout(Duration timeLimit,
      {Future Function()? onTimeout}) async {
    throw UnimplementedError();
  }

  Future<void> whenComplete(Future<void> Function() action) async {
    throw UnimplementedError();
  }
}
