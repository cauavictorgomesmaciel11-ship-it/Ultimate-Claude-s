#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

__attribute__((constructor))
static void Init(void) {
    NSLog(@"[MamoBall] Tweak carregado!");
}
