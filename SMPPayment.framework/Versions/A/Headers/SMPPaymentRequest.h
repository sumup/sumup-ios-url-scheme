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

/**
 *  This key will be used to append the status
 *  as a query parameter to the callback URLs.
 *  See below for possible values.
 */
extern NSString const *SMPPaymentRequestKeyStatus;
extern NSString const *SMPPaymentRequestStatusSuccess;          // checkout has succeeded
extern NSString const *SMPPaymentRequestStatusFailed;           // checkout failed
extern NSString const *SMPPaymentRequestStatusInvalidState;     // The SumUp app can not perform a checkout. Please ask the user to open the SumUp app and make sure she's ready to accept a payment.


/**
 *  This key will be used to append a localized message
 *  as a query parameter to the callback URLs.
 */
extern NSString const *SMPPaymentRequestKeyMessage;

/**
 *  This key will be used to append the transaction code
 *  as a query parameter to the callback URLs.
 */
extern NSString const *SMPPaymentRequestKeyTransactionCode;

/**
 *  This key will be used to append the foreignTransactionID (if provided)
 *  as a query parameter to the callback URLs.
 */
extern NSString const *SMPPaymentRequestKeyForeignTransactionID;

@interface SMPPaymentRequest : NSObject

/**
 *  A preconfigured payment request including all mandatory paramenters to open the SumUp merchant app.
 *  Will return nil if a mandatory parameter is missing.
 *
 *  @param anAmount      The amount to charge. E.g. 12.34 as a NSDecimalNumber (mandatory)
 *  @param iso4217code   The currency ISO code. E.g. EUR (mandatory)
 *  @param optionalTitle a title to set on this payment (optional)
 *  @param key           your app's affiliate key (mandatory)
 *
 *  @return A preconfigured payment request to open the SumUp app.
 */
+ (SMPPaymentRequest *)paymentRequestWithAmount:(NSDecimalNumber *)anAmount currency:(NSString *)iso4217code title:(NSString *)optionalTitle affiliateKey:(NSString *)key;

/**
 *  Will check whether the SumUp app is installed by calling
 *  -[UIApplication canOpenURL:] using SumUp's URL scheme 'sumupmerchant://'.
 *
 *  Please make sure to add 'sumupmerchant' to your list of LSApplicationQueriesSchemes
 *  See https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html#//apple_ref/doc/uid/TP40009250-SW14
 *
 *
 *  @return A boolean indicating if the SumUp app is installed.
 */
+ (BOOL)canOpenSumUpMerchantApp;

/**
 *  Will open AppStore and reveal SumUp by calling
 *  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id514879214&mt=8"]]
 *  See https://developer.apple.com/library/ios/qa/qa1629/_index.html
 *
 *  @return A boolean indicating if AppStore will be opened.
 */
+ (BOOL)showSumUpMerchantInAppStore;

@property (strong, readonly) NSDecimalNumber *amount;
@property (strong, readonly) NSString *currencyCode;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *affiliateKey;

/**
 * Optional URLs to call back source application after transaction
 * has been executed in then SumUp app.
 * These URLs are optional, however we would encourage you to set
 * them to bring the user back to your app or website once the
 * transaction has been finished.
 *
 * See https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102207
 */
@property (strong) NSURL *callbackURLSuccess;
@property (strong) NSURL *callbackURLFailure;

@property (strong) NSString *receiptEmailAddress;
@property (strong) NSString *receiptPhoneNumber;

/**
 *  An (optional) ID to be associated with this transaction.
 *  See https://sumup.com/integration#transactionReportingAPIs
 *  on how to retrieve a transaction using this ID.
 *  This ID has to be unique in the scope of a SumUp merchant account and its sub-accounts.
 *  It must not be longer than 128 characters and can only contain printable ASCII characters.
 *  If provided it will be appended to the callback URLs as a query parameter.
 */
@property (strong) NSString *foreignTransactionID;

/**
 *  An optional flag to skip the confirmation screen in checkout.
 *  If set, the checkout will be dismissed w/o user interaction.
 *  Default is SMPSkipScreenOptionNone.
 */
@property (nonatomic) SMPSkipScreenOptions skipScreenOptions;


- (void)addTag:(NSString *)aTag forKey:(NSString *)tagKey;

/**
 *  Will open the SumUp app by calling
 *  -[UIApplication openURL:] with the urlToLaunchSumupMerchantApp (see below).
 *  Returns NO if the URL can not be opened (e.g. if the SumUp app is not installed).
 *
 *  @return Boolean indicating if SumUp app will be opened.
 */
- (BOOL)openSumUpMerchantApp;

/**
 *  The preconfigured URL to open the SumUp app with a payment request.
 *  Will return nil if mandatory parameters are missing.
 *
 *  @return a URL to launch the SumUp app with.
 */
- (NSURL *)urlToLaunchSumupMerchantApp;

@end
