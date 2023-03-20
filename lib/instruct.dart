import 'dart:typed_data';

import 'package:flutter_blue_elves/flutter_blue_elves.dart';

void changeLbs(double lbs) {
  var a = lbs * 10;
  if (a > 255) {
    var str = a.toInt().toRadixString(16);
    var b = str.substring(1);
    List<int> list = [0x02, 0x63, 0x03, 0x02, 0x01, int.parse(b), 0x00, 0x02];
    _sendAsync(list);
  } else {
    List<int> list = [0x02, 0x63, 0x03, 0x02, 0x00, a.toInt(), 0x00, 0x02];
    _sendAsync(list);
  }
}

void play() {
  List<int> list = [0x02, 0x63, 0x00, 0x00, 0x06, 0x03];
  _sendAsync(list);
}

void pause() {
  List<int> list = [0x02, 0x63, 0x01, 0x00, 0x06, 0x03];
  _sendAsync(list);
}

void stop() {
  List<int> list = [0x02, 0x63, 0x02, 0x00, 0x06, 0x03];
  _sendAsync(list);
}

void queryInfo() {
  List<int> list = [0x02, 0x61, 0x00, 0x00, 0x00, 0x03];
  _sendAsync(list);
}

_sendAsync(List<int> list) {
  Uint8List data = Uint8List.fromList(list);
  _device.writeData(_bleService.serviceUuid, ffe1.uuid, false, data);
}

late BleCharacteristic ffe1;
late Device _device;
late BleService _bleService;

void initBle(Device device) {
  _device = device;
  device.serviceDiscoveryStream.listen((event) {
    for (var element in event.characteristics) {
      if (element.uuid.contains("FFE1") || element.uuid.contains("ffe1")) {
        ffe1 = element;
      } else if (element.uuid.contains("FFE4") ||
          element.uuid.contains("ffe4")) {
        device.setNotify(event.serviceUuid, element.uuid, true);
      }
    }
    _bleService = event;
  });
}

/**
 * aaa
 */
void initListener(
    Function(bool isPlay) isPlay,
    Function(double lbs) lbs,
    Function(int right, int left) wt,
    Function(int seconds) seconds,
    Function(int calories) calories,
    Function(int left, int right) count) {
  _device.deviceSignalResultStream.listen((event) {
    if (event.data != null &&
        event.data!.isNotEmpty &&
        event.data!.length > 5) {
      print("========>>>>${event.data}");
      if (event.data![0] == 162 && event.data![1] == 97) {
        if (event.data![2] == 1) {
          isPlay(true);
        } else {
          isPlay(false);
        }
        //轮询读取数据
        lbs(((event.data![4] * 256 + event.data![5]) / 10));
        wt(event.data![8], event.data![9]);
        seconds(event.data![10] * 256 + event.data![11]);
        calories(event.data![12] * 256 + event.data![13]);
        count(event.data![14] * 256 + event.data![15],
            event.data![16] * 256 + event.data![17]);
      }
    }
  });
}
