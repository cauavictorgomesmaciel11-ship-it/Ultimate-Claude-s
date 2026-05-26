#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

__attribute__((constructor))
static void Init(void) {
    NSLog(@"[MamoBall] Tweak carregado!");
    
    // Bloquear AppLovin
    Class ALSdk = NSClassFromString(@"ALSdk");
    if (ALSdk) {
        NSLog(@"[MamoBall] AppLovin encontrado - bloqueando");
    }
    
    // Bloquear Tracking
    Class ATManager = NSClassFromString(@"ATTrackingManager");
    if (ATManager) {
        NSLog(@"[MamoBall] Tracking encontrado - bloqueando");
    }
    
    NSLog(@"[MamoBall] Pronto!");
}
