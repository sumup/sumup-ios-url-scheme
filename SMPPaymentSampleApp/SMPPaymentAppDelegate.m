//
//  SMPPaymentSampleAppDelegate.m
//  SMPPaymentSampleApp
//
//  Created by Lukas Mollidor on 10/31/12.
//  Copyright (c) 2012-2015 SumUp. All rights reserved.
//

#import "SMPPaymentAppDelegate.h"
#import "SMPPaymentViewController.h"
#import <SMPPayment/SMPPaymentRequest.h>

@implementation SMPPaymentAppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController =
        [[SMPPaymentViewController alloc] initWithNibName:@"SMPPaymentViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)handleSumUpCallbackURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication
{
    if (sourceApplication.length && ![sourceApplication hasPrefix:@"com.sumup.merchant"])
    {
        NSLog(@"Not SumUp merchant app.");
        return YES;
    }

    NSString* status;
    NSString* txCode;

    for (NSURLQueryItem* queryItem in [[NSURLComponents alloc] initWithURL:url
                                                   resolvingAgainstBaseURL:NO]
             .queryItems)
    {
        if ([queryItem.name isEqualToString:(NSString*)SMPPaymentRequestKeyStatus])
        {
            status = queryItem.value;
        }
        else if ([queryItem.name isEqualToString:(NSString*)SMPPaymentRequestKeyTransactionCode])
        {
            txCode = queryItem.value;
        }
    }

    NSString* alertMessage;

    if ([status isEqualToString:(NSString*)SMPPaymentRequestStatusSuccess])
    {
        alertMessage = [NSString stringWithFormat:@"Thanks. Payment successful. Code: %@.", txCode];
    }
    else
    {
        alertMessage = [NSString
            stringWithFormat:@"Payment failed with status and code: %@ - %@", status, txCode];
    }

    NSLog(@"status - code: %@ - %@", status, txCode);

    [[[UIAlertView alloc] initWithTitle:status
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

    return YES;
}

- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options
{
    return [self handleSumUpCallbackURL:url
                      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}

@end
