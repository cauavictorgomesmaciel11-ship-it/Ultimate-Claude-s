#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@interface ALSdk : NSObject
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c;
@end
@implementation ALSdk (A)
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c {
    if (c) c(nil);
}
@end

@interface ATTrackingManager : NSObject
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c;
@end
@implementation ATTrackingManager (B)
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c {
    if (c) c(0);
}
@end

__attribute__((constructor))
static void Init(void) {
    NSLog(@"[MamoBall] Ads e tracking bloqueados!");
}
