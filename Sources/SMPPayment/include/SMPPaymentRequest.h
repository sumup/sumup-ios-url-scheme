//
//  SMPPaymentRequest.h
//  SMPPayment
//
//  Created by Lukas Mollidor on 10/31/12.
//  Copyright (c) 2012-2015 sumup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMPSkipScreenOptions.h"

extern NSString const *SMPPaymentRequestStatusParameterKey __deprecated_msg("Please use SMPPaymentRequestKeyStatus.");

extern NSString const *SMPPaymentRequestKeyStatus;
extern NSString const *SMPPaymentRequestStatusSuccess;
extern NSString const *SMPPaymentRequestStatusFailed;
extern NSString const *SMPPaymentRequestStatusInvalidState;

extern NSString const *SMPPaymentRequestKeyMessage;
extern NSString const *SMPPaymentRequestKeyTransactionCode;
extern NSString const *SMPPaymentRequestKeyForeignTransactionID;

@interface SMPPaymentRequest : NSObject

+ (SMPPaymentRequest *)paymentRequestWithAmount:(NSDecimalNumber *)anAmount currency:(NSString *)iso4217code title:(NSString *)optionalTitle affiliateKey:(NSString *)key;
+ (BOOL)canOpenSumUpMerchantApp;
+ (BOOL)showSumUpMerchantInAppStore;

@property (strong, readonly) NSDecimalNumber *amount;
@property (strong, readonly) NSString *currencyCode;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *affiliateKey;

@property (strong) NSURL *callbackURLSuccess;
@property (strong) NSURL *callbackURLFailure;

@property (strong) NSString *receiptEmailAddress;
@property (strong) NSString *receiptPhoneNumber;
@property (strong) NSString *foreignTransactionID;
@property (nonatomic) SMPSkipScreenOptions skipScreenOptions;

- (void)addTag:(NSString *)aTag forKey:(NSString *)tagKey;
- (BOOL)openSumUpMerchantApp;
- (NSURL *)urlToLaunchSumupMerchantApp;

@end
