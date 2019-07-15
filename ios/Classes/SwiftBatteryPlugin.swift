import Flutter
import UIKit

public class SwiftBatteryPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var _eventSink: FlutterEventSink?
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self._eventSink = events;
    UIDevice.current.isBatteryMonitoringEnabled = true
    self.sendBatteryStateEvent()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.onBatteryStateDidChange),
      name: NSNotification.Name.UIDeviceBatteryStateDidChange,
      object: nil
    )
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self._eventSink = nil;
    NotificationCenter.default.removeObserver(self)
    return nil
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    // 本类型对象
    let instance = SwiftBatteryPlugin()

    let methodChannel = FlutterMethodChannel(name: "plugins.yutiy/battery", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    
    let eventChannel = FlutterEventChannel(name: "plugins.yutiy/charging", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getBatteryLevel") {
      let batteryLevel = getBatteryLevel()
      if (batteryLevel != -1) {
        result(batteryLevel)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable, don't use Simulator!", details: nil))
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
  
  @objc public func onBatteryStateDidChange(_ notification: NSNotification) {
    self.sendBatteryStateEvent()
  }
  
  // 获取电量
  private func getBatteryLevel() -> Int {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    if (device.batteryState == UIDeviceBatteryState.unknown) {
      return -1
    } else {
      return Int(device.batteryLevel * 100)
    }
  }
  
  // 获取电池状态
  private func sendBatteryStateEvent() {
    if (!(_eventSink != nil)) {
      return
    }
    
    // 发送通知给Flutter端
    let device = UIDevice.current
    switch (device.batteryState) {
      case .full:
        _eventSink?("full")
      case .charging:
        _eventSink?("charging")
      case .unplugged:
        _eventSink?("discharging")
      default:
        _eventSink?(FlutterError(code: "UNAVAILABLE", message: "Charging status unavailable", details: nil))
    }
  }
  
}
