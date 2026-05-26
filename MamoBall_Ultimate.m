#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

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
    NSLog(@"[MamoBall] Ads bloqueados! Tracking bloqueado!");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ ApplyHooks(); });
}
