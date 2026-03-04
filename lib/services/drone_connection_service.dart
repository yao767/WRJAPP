class DroneConnectionService {
  bool _connected = false;
  String? _deviceName;

  bool get isConnected => _connected;
  String? get deviceName => _deviceName;

  Future<List<String>> scanDevices() async {
    return ['遥控器-A01', '遥控器-B02', '植保机模拟设备'];
  }

  Future<void> connect(String device) async {
    _connected = true;
    _deviceName = device;
  }

  Future<void> disconnect() async {
    _connected = false;
    _deviceName = null;
  }

  Future<void> pushFlightParams(Map<String, dynamic> params) async {
    if (!_connected) {
      throw StateError('设备未连接，无法下发参数');
    }
  }
}
