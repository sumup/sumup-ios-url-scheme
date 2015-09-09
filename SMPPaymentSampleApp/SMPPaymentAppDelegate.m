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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[SMPPaymentViewController alloc] initWithNibName:@"SMPPaymentViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![sourceApplication hasPrefix:@"com.sumup.merchant"]) {
        NSLog(@"Not SumUp merchant app.");
        return YES;
    }
    
    // Get status and transaction code from URL query when being opened from SumUp app.
    NSArray *pairs = [[url query] componentsSeparatedByString:@"&"];
    NSString *status;
    NSString *txCode;
    
    for (NSString *kvp in pairs) {
        NSArray *kv = [kvp componentsSeparatedByString:@"="];
        
        if ([kv count] != 2) {
            continue;
        }
        
        NSString *key = [kv[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([key isEqualToString:(NSString *)SMPPaymentRequestKeyStatus]) {
            status = val;
        } else if ([key isEqualToString:(NSString *)SMPPaymentRequestKeyTransactionCode]) {
            txCode = key;
        }
    }
    
    NSString *alertMessage;
    
    // check if payment did succeed
    if ([status isEqualToString:(NSString *)SMPPaymentRequestStatusSuccess]) {
        alertMessage = [NSString stringWithFormat:@"Thanks. Payment successful. Code: %@.", txCode];
    } else {
        alertMessage = [NSString stringWithFormat:@"Payment failed with status and code: %@ - %@", status, txCode];
    }
    
    NSLog(@"status - code: %@ - %@", status, txCode);
    
    [[[UIAlertView alloc] initWithTitle:status message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    return YES;
}

@end
