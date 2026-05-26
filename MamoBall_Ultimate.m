#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

static void BlockAds(void) {
    Class ALSdk = NSClassFromString(@"ALSdk");
    if (ALSdk) NSLog(@"[MamoBall] AppLovin bloqueado");
    Class IronSource = NSClassFromString(@"IronSource");
    if (IronSource) NSLog(@"[MamoBall] IronSource bloqueado");
    Class UnityAds = NSClassFromString(@"UnityAds");
    if (UnityAds) NSLog(@"[MamoBall] UnityAds bloqueado");
    Class ATManager = NSClassFromString(@"ATTrackingManager");
    if (ATManager) NSLog(@"[MamoBall] Tracking bloqueado");
}

static void AutoReward(void) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IronSourceRewardedVideoAdRewarded" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MAAdDidCompleteFullscreenAdShowing" object:nil];
    NSLog(@"[MamoBall] Recompensa automatica!");
}

static void ApplyGameHooks(void) {
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* n = _dyld_get_image_name(i);
        if (n && strstr(n, "UnityFramework")) {
            base = (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    if (!base) { NSLog(@"[MamoBall] Base nao encontrada"); return; }

    // idvKickStrength - chute normal 5x
    float *kickStrength = (float *)(base + 0x15ba74);
    if (kickStrength) *kickStrength *= 5.0f;

    // idvPowerKickStrength - Kiki 8x
    float *powerKick = (float *)(base + 0x13ef4c);
    if (powerKick) *powerKick *= 8.0f;

    // idvPlayerSpeed - velocidade 2x
    float *playerSpeed = (float *)(base + 0x15e820);
    if (playerSpeed) *playerSpeed *= 2.0f;

    // currentDelay - zerar delay
    float *delay = (float *)(base + 0x2f4ccf);
    if (delay) *delay = 0.0f;

    NSLog(@"[MamoBall] Kick 5x, PowerKick 8x, Speed 2x, Delay 0!");
}

__attribute__((constructor))
static void Init(void) {
    NSLog(@"[MamoBall] Ultimate Tweak v3 carregado!");
    BlockAds();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ AutoReward(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ ApplyGameHooks(); });
}
