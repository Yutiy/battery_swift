import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Indicates the current battery state.
enum BatteryState { full, charging, discharging }

class Battery {
  factory Battery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel('plugins.yutiy/battery');
      final EventChannel eventChannel = const EventChannel('plugins.yutiy/charging');
      _instance = Battery.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  @visibleForTesting
  Battery.private(this._methodChannel, this._eventChannel);

  static Battery _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<BatteryState> _onBatteryStateChanged;

  /// Returns the current battery level in percent.
  Future<int> get batteryLevel => _methodChannel
      .invokeMethod<int>('getBatteryLevel')
      .then<int>((dynamic result) => result);

  /// Fires whenever the battery state changes.
  Stream<BatteryState> get onBatteryStateChanged {
    if (_onBatteryStateChanged == null) {
      _onBatteryStateChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseBatteryState(event));
    }
    return _onBatteryStateChanged;
  }
}

BatteryState _parseBatteryState(String state) {
  switch (state) {
    case 'full':
      return BatteryState.full;
    case 'charging':
      return BatteryState.charging;
    case 'discharging':
      return BatteryState.discharging;
    default:
      throw ArgumentError('$state is not a valid BatteryState.');
  }
}
