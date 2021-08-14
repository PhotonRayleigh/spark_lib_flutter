import 'dart:async';
import 'dart:isolate';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

/// Wrapper to create a managed [Isolate] with bidirectional communication.
///
class ThreadHandler {
  late Isolate _threadHandle;
  Map<Capability, Completer> tasks = <Capability, Completer>{};
  TxPort port = TxPort();
  late Future _sendReady;
  late Future _handleReady;
  // void Function(TxPort p) listener;

  Future<Isolate> threadHandle() async {
    await _handleReady;
    return _threadHandle;
  }

  ThreadHandler(ThreadFunction threadFunc) {
    var f = Isolate.spawn<SendPort>(threadFunc, port.sendPort());
    f.then((value) => _threadHandle = value);
    listener(port);
  }

  Future<E> postJob<E>(JobType j) async {
    Completer<E> c = Completer<E>();
    tasks[j.tag] = c;
    await _sendReady;
    port.s.send(j);
    return c.future;
  }

  Future postJobVoid(JobType j) async {
    Completer c = Completer();
    tasks[j.tag] = c;
    j.retType = _RetType.none;
    await _sendReady;
    port.s.send(j);
    return c.future;
  }

  Future listener(TxPort p) async {
    var c = Completer();
    _sendReady = c.future;
    await for (var data in p.r) {
      if (data is SendPort) {
        p.s = data;
        c.complete();
      } else if (data is JobType) {
        switch (data.retType) {
          case _RetType.none:
            tasks[data.tag]!.complete();
            break;
          case _RetType.val:
            tasks[data.tag]!.complete(data.result);
            break;
        }
      }
    }
  }
}

typedef ThreadFunction = void Function(SendPort p);

class TxPort {
  late ReceivePort r;
  late SendPort s;

  TxPort() {
    r = ReceivePort();
  }

  sendPort() {
    return r.sendPort;
  }
}

/// Determines if a [JobType] returns a value or not.
enum _RetType { val, none }

/// The JobType class is the primary
class JobType<T, E> {
  // Int should be set by an enum determined by
  // the code that sets ThreadProc and ListenerProc
  int selector;
  T? input;
  E? result;
  Capability tag = Capability();
  _RetType retType = _RetType.val;

  JobType(this.selector, {this.input});
}

class ThreadProc {
  TxPort port = TxPort();
  List<Function> funcList = <Function>[];
  ThreadProc(SendPort p, this.funcList) {
    runThread(p);
  }

  Future runThread(SendPort p) async {
    port.s = p;
    port.s.send(port.sendPort());
    await for (var data in port.r) {
      if (data is JobType) {
        if (funcList.isNotEmpty &&
            data.selector < funcList.length &&
            data.selector >= 0) {
          funcList[data.selector](data);
        }
        port.s.send(
            data); // For this to work, the thread must ALWAYS send the jobtype back
      }
    }
  }
}

/// Example [Isolate] function that employs ThreadProc
/// to simplify the creation of ThreadHandlers.
void exampleThreadProc(SendPort p) async {
  ThreadProc proc = ThreadProc(p, <Function>[
    (JobType data) {
      print("print from func1!");
    },
    (JobType data) {
      if (JobType is JobType<int, int>) {
        data.result = data.input! * 2;
      }
    },
  ]);
}

/*
  This function acts as the base template to follow when making
  a thread procedure with bidirectional communication.
  This model is encapsulated by the ThreadProc class.

  If you need different behavior, I recommend subclassing ThreadProc
  and overriding the runThread function.
*/
// void exampleBaseThreadProc(SendPort p) async {
//   void t1() {
//     print("test");
//   }

//   void t2() {}
//   // etc...

//   TxPort port = TxPort();
//   port.s = p;
//   port.s.send(port.sendPort());
//   await for (var data in port.r) {
//     if (data is JobType) {
//       // If it's data, use it's selector to determine what to do
//       switch (data.selector) {
//         case 0:
//           print("hello from isolate!");
//           break;
//         case 1:
//           t1();
//           break;
//         case 2:
//           t2();
//           break;
//       }
//       port.s.send(
//           data); // For this to work, the thread must ALWAYS send the jobtype back
//     }
//   }
// }
