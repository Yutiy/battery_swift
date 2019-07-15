#import "BatteryPlugin.h"
#import <battery/battery-Swift.h>

@implementation BatteryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBatteryPlugin registerWithRegistrar:registrar];
}
@end
