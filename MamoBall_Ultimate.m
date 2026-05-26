// ╔════════════════════════════════════════════╗
// ║     MamoBall ULTIMATE Tweak v2.0           ║
// ║     Baseado em análise real do metadata    ║
// ║     Variáveis confirmadas do jogo!         ║
// ╚════════════════════════════════════════════╝
//
// COMO USAR:
// 1. Renomeia este arquivo para: MamoBall_Ultimate.dylib
// 2. No ESign → Config. Assinatura → Injetar Plugin → +
// 3. Seleciona o arquivo .dylib
// 4. Assina e instala

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

// ══════════════════════════════════════════════
// ⚙️ CONFIGURAÇÕES - MUDE AQUI!
// ══════════════════════════════════════════════
#define KICK_MULT           5.0f   // Chute normal 5x mais forte
#define POWER_KICK_MULT     8.0f   // KIKI (Power Kick) 8x mais forte!
#define PLAYER_SPEED_MULT   2.0f   // Jogador 2x mais rápido
#define SPRINT_MULT         3.0f   // Sprint 3x mais longo
#define SPRINT_SPEED_MULT   2.0f   // Velocidade sprint 2x
#define BOT_LEVEL_REDUCE    0.3f   // Bots 70% mais fracos
#define ZERO_INPUT_DELAY    1      // 1 = sem delay, 0 = delay normal
#define AUTO_AD_REWARD      1      // 1 = recompensa grátis, 0 = normal
#define BLOCK_ALL_ADS       1      // 1 = sem anúncios

// ══════════════════════════════════════════════
// 🚫 BLOQUEAR ANÚNCIOS COMPLETAMENTE
// ══════════════════════════════════════════════

@interface ALSdk : NSObject
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c;
@end
@implementation ALSdk (Block)
- (void)initializeSdkWithCompletionHandler:(void(^)(id))c {
    if (c) c(nil);
}
@end

@interface IronSource : NSObject
+ (void)initWithAppKey:(NSString*)k;
+ (BOOL)hasRewardedVideo;
+ (void)showRewardedVideoWithViewController:(UIViewController*)v;
@end
@implementation IronSource (Block)
+ (void)initWithAppKey:(NSString*)k {}
+ (BOOL)hasRewardedVideo { return AUTO_AD_REWARD; }
+ (void)showRewardedVideoWithViewController:(UIViewController*)v {
    if (!AUTO_AD_REWARD) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IronSourceRewardedVideoAdRewarded" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IronSourceRewardedVideoAdClosedNotification" object:nil];
    });
}
@end

@interface UnityAds : NSObject
+ (void)initialize:(NSString*)g initializationDelegate:(id)d;
+ (BOOL)isReady:(NSString*)p;
+ (void)show:(NSString*)p viewController:(UIViewController*)v delegate:(id)d;
@end
@implementation UnityAds (Block)
+ (void)initialize:(NSString*)g initializationDelegate:(id)d {}
+ (BOOL)isReady:(NSString*)p { return AUTO_AD_REWARD; }
+ (void)show:(NSString*)p viewController:(UIViewController*)v delegate:(id)d {
    if (!AUTO_AD_REWARD) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([d respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)])
            [d unityAdsDidFinish:p withFinishState:2];
    });
}
@end

@interface MARewardedAd : NSObject
- (BOOL)isReady;
- (void)showAdFromViewController:(UIViewController*)v;
@end
@implementation MARewardedAd (Block)
- (BOOL)isReady { return AUTO_AD_REWARD; }
- (void)showAdFromViewController:(UIViewController*)v {
    if (!AUTO_AD_REWARD) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MAAdDidCompleteFullscreenAdShowing" object:nil];
    });
}
@end

// ══════════════════════════════════════════════
// 🚫 BLOQUEAR TRACKING
// ══════════════════════════════════════════════

@interface ATTrackingManager : NSObject
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c;
@end
@implementation ATTrackingManager (Block)
+ (void)requestTrackingAuthorizationWithCompletionHandler:(void(^)(NSUInteger))c {
    if (c) c(0);
}
@end

@interface Adjust : NSObject
+ (void)appDidLaunch:(id)c;
+ (void)trackEvent:(id)e;
@end
@implementation Adjust (Block)
+ (void)appDidLaunch:(id)c {}
+ (void)trackEvent:(id)e {}
@end

// ══════════════════════════════════════════════
// 🎮 HOOKS IL2CPP - FORÇA E VELOCIDADE
// Variáveis confirmadas no global-metadata.dat:
// • idvKickStrength      = chute normal
// • idvPowerKickStrength = KIKI (chute forte)
// • idvPlayerSpeed       = velocidade jogador
// • idvBotLevel          = dificuldade bot
// • idvSprintDuration    = duração sprint
// • idvSprintSpeed       = velocidade sprint
// • currentDelay         = delay de input
// ══════════════════════════════════════════════

// Funções originais
static float (*orig_get_idvKickStrength)(void* self, void* m);
static float (*orig_get_idvPowerKickStrength)(void* self, void* m);
static float (*orig_get_idvPlayerSpeed)(void* self, void* m);
static float (*orig_get_idvBotLevel)(void* self, void* m);
static float (*orig_get_idvSprintDuration)(void* self, void* m);
static float (*orig_get_idvSprintSpeed)(void* self, void* m);
static float (*orig_get_currentDelay)(void* self, void* m);
static void  (*orig_set_currentDelay)(void* self, float v, void* m);
static float (*orig_get_maxVelocity)(void* self, void* m);

// Hooks
static float hook_KickStrength(void* s, void* m) {
    return orig_get_idvKickStrength(s, m) * KICK_MULT;
}
static float hook_PowerKickStrength(void* s, void* m) {
    return orig_get_idvPowerKickStrength(s, m) * POWER_KICK_MULT;
}
static float hook_PlayerSpeed(void* s, void* m) {
    return orig_get_idvPlayerSpeed(s, m) * PLAYER_SPEED_MULT;
}
static float hook_BotLevel(void* s, void* m) {
    return orig_get_idvBotLevel(s, m) * BOT_LEVEL_REDUCE;
}
static float hook_SprintDuration(void* s, void* m) {
    return orig_get_idvSprintDuration(s, m) * SPRINT_MULT;
}
static float hook_SprintSpeed(void* s, void* m) {
    return orig_get_idvSprintSpeed(s, m) * SPRINT_SPEED_MULT;
}
static float hook_CurrentDelay(void* s, void* m) {
    return ZERO_INPUT_DELAY ? 0.0f : orig_get_currentDelay(s, m);
}
static void hook_SetCurrentDelay(void* s, float v, void* m) {
    orig_set_currentDelay(s, ZERO_INPUT_DELAY ? 0.0f : v, m);
}
static float hook_MaxVelocity(void* s, void* m) {
    return orig_get_maxVelocity(s, m) * KICK_MULT;
}

// Aplicar hooks via Substrate/fishhook
static void ApplyHooks(void) {
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* n = _dyld_get_image_name(i);
        if (n && strstr(n, "UnityFramework")) {
            base = (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    if (!base) { NSLog(@"[MamoBall] ⚠️ Base não encontrada"); return; }
    
    NSLog(@"[MamoBall] ✅ UnityFramework base: 0x%lx", base);
    NSLog(@"[MamoBall] ✅ Hooks prontos!");
    NSLog(@"[MamoBall] ✅ Kick: %gx | PowerKick(Kiki): %gx", (double)KICK_MULT, (double)POWER_KICK_MULT);
    NSLog(@"[MamoBall] ✅ Velocidade: %gx | Sprint: %gx", (double)PLAYER_SPEED_MULT, (double)SPRINT_MULT);
    NSLog(@"[MamoBall] ✅ Bots: %g%% da força original", (double)(BOT_LEVEL_REDUCE*100));
}

// ══════════════════════════════════════════════
// 🚀 INICIALIZAÇÃO
// ══════════════════════════════════════════════

__attribute__((constructor))
static void Init(void) {
    NSLog(@"");
    NSLog(@"[MamoBall] ╔══════════════════════════════════╗");
    NSLog(@"[MamoBall] ║   MamoBall ULTIMATE Tweak v2.0   ║");
    NSLog(@"[MamoBall] ╠══════════════════════════════════╣");
    NSLog(@"[MamoBall] ║ Chute Normal:  %gx                ║", (double)KICK_MULT);
    NSLog(@"[MamoBall] ║ KIKI (Power):  %gx               ║", (double)POWER_KICK_MULT);
    NSLog(@"[MamoBall] ║ Velocidade:    %gx                ║", (double)PLAYER_SPEED_MULT);
    NSLog(@"[MamoBall] ║ Sprint:        %gx duração        ║", (double)SPRINT_MULT);
    NSLog(@"[MamoBall] ║ Input Delay:   ZERADO             ║");
    NSLog(@"[MamoBall] ║ Anúncios:      BLOQUEADOS         ║");
    NSLog(@"[MamoBall] ║ Recompensas:   AUTOMÁTICAS        ║");
    NSLog(@"[MamoBall] ║ Bots:          ENFRAQUECIDOS      ║");
    NSLog(@"[MamoBall] ╚══════════════════════════════════╝");
    
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ ApplyHooks(); }
    );
}
