#import "SnapchatPlugin.h"
#import <snapchat/snapchat-Swift.h>

@implementation SnapchatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSnapchatPlugin registerWithRegistrar:registrar];
}
@end
