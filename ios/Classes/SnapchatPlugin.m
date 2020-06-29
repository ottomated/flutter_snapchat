#import "SnapchatPlugin.h"
#import <snapchat_androidx/snapchat_androidx-Swift.h>

@implementation SnapchatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSnapchatPlugin registerWithRegistrar:registrar];
}
@end
