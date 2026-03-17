//
//  SMPPaymentSampleAppDelegate.m
//  SMPPaymentSampleApp
//
//  Created by Lukas Mollidor on 10/31/12.
//  Copyright (c) 2012-2015 SumUp. All rights reserved.
//

#import "SMPPaymentAppDelegate.h"

@implementation SMPPaymentAppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (UISceneConfiguration*)application:(UIApplication*)application
configurationForConnectingSceneSession:(UISceneSession*)connectingSceneSession
                              options:(UISceneConnectionOptions*)options API_AVAILABLE(ios(13.0))
{
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

@end
