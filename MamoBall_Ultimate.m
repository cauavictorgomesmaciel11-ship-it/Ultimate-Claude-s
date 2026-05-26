#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

#define KICK_MULT         5.0f
#define POWER_KICK_MULT   8.0f
#define PLAYER_SPEED_MULT 2.0f
#define SPRINT_MULT       3.0f

@interface ALSdk : NSObject
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c;
@end
@implementation ALSdk (MamoBlock)
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c {
    if (c) c(nil);
}
@end

@interface IronSource : NSObject
+ (void)initWithAppKey:(NSString*)k;
+ (BOOL)hasRewardedVideo;
@end
@implementation IronSource (MamoBlock)
+ (void)initWithAppKey:(NSString*)k {}
+ (BOOL)hasRewardedVideo { return YES; }
@end

@interface UnityAds : NSObject
+ (void)initialize:(NSString*)g initializationDelegate:(id)d;
+ (BOOL)isReady:(NSString*)p;
@end
@implementation UnityAds (MamoBlock)
+ (void)initialize:(NSString*)g initializationDelegate:(id)d {}
+ (BOOL)isReady:(NSString*)p { return YES; }
@end

@interface ATTrackingManager : NSObject
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c;
@end
@implementation ATTrackingManager (MamoBlock)
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c {
    if (c) c(0);
}
@end

static void ApplyHooks(void) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* n = _dyld_get_image_name(i);
        if (n && strstr(n, "UnityFramework")) {
            NSLog(@"[MamoBall] Base: %p", (void*)_dyld_get_image_header(i));
            break;
        }
    }
}

__attribute__((constructor))
static void Init(void) {
    NSLog(@"[MamoBall] Tweak carregado! Kick:%gx PowerKick:%gx Speed:%gx",
        (double)KICK_MULT, (double)POWER_KICK_MULT, (double)PLAYER_SPEED_MULT);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ ApplyHooks(); });
}
