import 'dart:async';
import 'dart:isolate';

class WorkerThread {
  late Isolate _thread;
  late BiDiPort _port;
  Map<Capability, Completer> _taskList = <Capability, Completer>{};

  WorkerThread() {
    _port = BiDiPort();
    _initThread();
  }

  Future _initThread() async {
    _thread = await Isolate.spawn(_threadFunc, _port.rPort.sendPort);
    _port.rPort.listen((message) {
      if (message is SendPort) _port.sPort = message;
      if (message is WorkTask) _taskList[message.tag]!.complete(message.result);
    });
  }

  Future<E> runJob<T, E>(WorkTask<T, E> task) {
    Completer<E> completer = Completer<E>();
    _taskList[task.tag] = completer;
    if (_port.sPort != null) _port.sPort.send(task);
    return completer.future;
  }
}

void _threadFunc(message) {
  BiDiPort threadPort = BiDiPort();
  if (message is SendPort) threadPort.sPort = message;
  threadPort.sPort.send(threadPort.rPort.sendPort);

  threadPort.rPort.listen((message) {
    if (message is WorkTask) {
      message.job();
      threadPort.sPort.send(message);
    }
  });
}

class BiDiPort {
  BiDiPort() {
    rPort = ReceivePort();
  }

  late ReceivePort rPort;
  late SendPort sPort;
}

abstract class WorkTask<T, E> {
  late T data;
  E? result;
  Capability tag = Capability();

  WorkTask(this.data);

  void job();

  // void run()
  // {
  //   result = job(data);
  // }
}

typedef WorkFunc<T, E> = E Function<T, E>(T data);
