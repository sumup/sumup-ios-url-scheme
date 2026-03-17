#import "SMPPaymentRequest.h"

#import <UIKit/UIKit.h>

NSString const *SMPPaymentRequestStatusParameterKey = @"smp-status";
NSString const *SMPPaymentRequestKeyStatus = @"smp-status";
NSString const *SMPPaymentRequestStatusSuccess = @"success";
NSString const *SMPPaymentRequestStatusFailed = @"failed";
NSString const *SMPPaymentRequestStatusInvalidState = @"invalidstate";
NSString const *SMPPaymentRequestKeyMessage = @"smp-message";
NSString const *SMPPaymentRequestKeyTransactionCode = @"smp-tx-code";
NSString const *SMPPaymentRequestKeyForeignTransactionID = @"foreign-tx-id";

static NSString *const SMPPaymentRequestScheme = @"sumupmerchant";
static NSString *const SMPPaymentRequestHost = @"pay";
static NSString *const SMPPaymentRequestVersionPath = @"/1.0";
static NSString *const SMPPaymentRequestAppStoreURL = @"https://itunes.apple.com/app/id514879214&mt=8";

static NSString *SMPStringValueTwoDecimalDigitsFromDecimalNumber(NSDecimalNumber *decimalNumber) {
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimumFractionDigits = 2;
        formatter.maximumFractionDigits = 2;
        formatter.usesGroupingSeparator = NO;
    });

    return [formatter stringFromNumber:decimalNumber];
}

@interface SMPPaymentRequest ()

@property (strong, readwrite) NSDecimalNumber *amount;
@property (strong, readwrite) NSString *currencyCode;
@property (strong, readwrite) NSString *title;
@property (strong, readwrite) NSString *affiliateKey;
@property (strong) NSMutableDictionary<NSString *, NSString *> *tagDict;

@end

@implementation SMPPaymentRequest

+ (SMPPaymentRequest *)paymentRequestWithAmount:(NSDecimalNumber *)anAmount currency:(NSString *)iso4217code title:(NSString *)optionalTitle affiliateKey:(NSString *)key {
    if (!anAmount || [anAmount isEqual:[NSDecimalNumber notANumber]] || iso4217code.length == 0 || key.length == 0) {
        return nil;
    }

    SMPPaymentRequest *request = [[self alloc] init];
    request.amount = anAmount;
    request.currencyCode = iso4217code;
    request.title = optionalTitle;
    request.affiliateKey = key;
    request.skipScreenOptions = SMPSkipScreenOptionNone;
    request.tagDict = [NSMutableDictionary dictionary];
    return request;
}

+ (BOOL)canOpenSumUpMerchantApp {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", SMPPaymentRequestScheme]];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (BOOL)showSumUpMerchantInAppStore {
    NSURL *url = [NSURL URLWithString:SMPPaymentRequestAppStoreURL];
    if (!url) {
        return NO;
    }

    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    return YES;
}

- (void)addTag:(NSString *)aTag forKey:(NSString *)tagKey {
    if (aTag.length == 0 || tagKey.length == 0) {
        return;
    }

    self.tagDict[tagKey] = aTag;
}

- (BOOL)openSumUpMerchantApp {
    NSURL *url = [self urlToLaunchSumupMerchantApp];
    if (!url) {
        return NO;
    }

    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        return NO;
    }

    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    return YES;
}

- (NSURL *)urlToLaunchSumupMerchantApp {
    if (!self.amount || self.currencyCode.length == 0 || self.affiliateKey.length == 0) {
        return nil;
    }

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = SMPPaymentRequestScheme;
    components.host = SMPPaymentRequestHost;
    components.path = SMPPaymentRequestVersionPath;

    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"amount" value:SMPStringValueTwoDecimalDigitsFromDecimalNumber(self.amount)]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"currency" value:self.currencyCode]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"affiliate-key" value:self.affiliateKey]];

    if (self.title.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"title" value:self.title]];
    }
    if (self.callbackURLFailure.absoluteString.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"callbackfail" value:self.callbackURLFailure.absoluteString]];
    }
    if (self.callbackURLSuccess.absoluteString.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"callbacksuccess" value:self.callbackURLSuccess.absoluteString]];
    }
    if (self.receiptEmailAddress.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"receipt-email" value:self.receiptEmailAddress]];
    }
    if (self.receiptPhoneNumber.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"receipt-mobilephone" value:self.receiptPhoneNumber]];
    }
    if (self.foreignTransactionID.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"foreign-tx-id" value:self.foreignTransactionID]];
    }
    if (self.skipScreenOptions & SMPSkipScreenOptionSuccess) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"skip-screen-success" value:@"true"]];
    }

    for (NSString *tagKey in [[self.tagDict allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:tagKey value:self.tagDict[tagKey]]];
    }

    components.queryItems = queryItems;
    return components.URL;
}

@end
