#import "SnapKitPlugin.h"
#import <snapkit/snapkit-Swift.h>

@implementation SnapKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSnapKitPlugin registerWithRegistrar:registrar];
}
@end
