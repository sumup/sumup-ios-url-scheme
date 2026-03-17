//
//  SMPPaymentSceneDelegate.m
//  SMPPaymentSampleApp
//
//  Created by OpenAI Codex on 03/17/26.
//

#import "SMPPaymentSceneDelegate.h"
#import "SMPPaymentViewController.h"

@implementation SMPPaymentSceneDelegate

- (void)scene:(UIScene*)scene
    willConnectToSession:(UISceneSession*)session
                 options:(UISceneConnectionOptions*)connectionOptions API_AVAILABLE(ios(13.0))
{
    if (![scene isKindOfClass:[UIWindowScene class]])
    {
        return;
    }

    UIWindowScene* windowScene = (UIWindowScene*)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController =
        [[SMPPaymentViewController alloc] initWithNibName:@"SMPPaymentViewController" bundle:nil];
    [self.window makeKeyAndVisible];

    for (UIOpenURLContext* urlContext in connectionOptions.URLContexts)
    {
        [self handleURLContext:urlContext];
    }
}

- (void)scene:(UIScene*)scene
    openURLContexts:(NSSet<UIOpenURLContext*>*)URLContexts API_AVAILABLE(ios(13.0))
{
    for (UIOpenURLContext* urlContext in URLContexts)
    {
        [self handleURLContext:urlContext];
    }
}

- (void)handleURLContext:(UIOpenURLContext*)urlContext API_AVAILABLE(ios(13.0))
{
    if (![self.window.rootViewController isKindOfClass:[SMPPaymentViewController class]])
    {
        return;
    }

    SMPPaymentViewController* viewController =
        (SMPPaymentViewController*)self.window.rootViewController;
    [viewController handleSumUpCallbackURL:urlContext.URL
                         sourceApplication:urlContext.options.sourceApplication];
}

@end
