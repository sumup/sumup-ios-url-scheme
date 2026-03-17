//
//  SMPPaymentViewController.m
//  SMPPaymentSampleApp
//
//  Created by Lukas Mollidor on 10/31/12.
//  Copyright (c) 2012-2015 SumUp. All rights reserved.
//

#import "SMPPaymentViewController.h"
#import <SMPPayment/SMPPaymentRequest.h>

#define AFFILIATE_KEY @"169f0ee2-bc0a-470f-8fac-f30c26d698da"

@implementation SMPPaymentViewController

- (void)handleSumUpCallbackURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication
{
    if (sourceApplication.length && ![sourceApplication hasPrefix:@"com.sumup.merchant"])
    {
        NSLog(@"Not SumUp merchant app.");
        return;
    }

    NSString* status;
    NSString* txCode;

    for (NSURLQueryItem* queryItem in [[NSURLComponents alloc] initWithURL:url
                                                 resolvingAgainstBaseURL:NO].queryItems)
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

    NSString* alertTitle = status ?: @"Callback received";
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

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:
                                                                          UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSString* currency = [[NSUserDefaults standardUserDefaults] stringForKey:@"currency"];

    if (!currency.length)
    {
        currency = @"EUR";
    }

    [self.textFieldCurrency setText:currency];

    // verify that SumUp app is installed. If it's not ask user to install and open AppStore using
    // +[SMPPaymentRequest showSumUpMerchantInAppStore]
    NSLog(@"SumUp app is installed: %@",
          [SMPPaymentRequest canOpenSumUpMerchantApp] ? @"YES" : @"NO");
}

- (IBAction)payFromSender:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.textFieldCurrency.text
                                              forKey:@"currency"];

    SMPPaymentRequest* request =
        [SMPPaymentRequest paymentRequestWithAmount:[self amountNumber]
                                           currency:self.textFieldCurrency.text
                                              title:self.textFieldTitle.text
                                       affiliateKey:AFFILIATE_KEY];

    // This should match your app's URL scheme.
    // See "URL Types" in target's "Info" tab in project editor.
    [request setCallbackURLFailure:[NSURL URLWithString:@"samplepaymentapp://"]];
    [request setCallbackURLSuccess:[NSURL URLWithString:@"samplepaymentapp://"]];

    // optional parameters to be pre-filled when sending a receipt
    [request setReceiptPhoneNumber:self.textFieldPhone.text];
    [request setReceiptEmailAddress:self.textFieldEmail.text];

    // The foreignTransactionID is an optional parameter and can be used
    // to retrieve a transaction from SumUp's API.
    // See -[SMPPaymentRequest foreignTransactionID]
    [request setForeignTransactionID:[NSString stringWithFormat:@"your-unique-id-%@",
                                                                [[NSProcessInfo processInfo]
                                                                    globallyUniqueString]]];

    NSURL* launchURL = [request urlToLaunchSumupMerchantApp];
    NSLog(@"request: %@ :%@", request, launchURL);

    if (!launchURL)
    {
        [self.textView setText:@"Failed to create URL. Missing mandatory parameters?"];
        return;
    }

    [self.textView setText:[launchURL absoluteString]];

    if (![request openSumUpMerchantApp])
    {
        [self.textView setText:[self.textView.text
                                   stringByAppendingFormat:@"\nNo app installed to handle URL!"]];
    }
}

- (NSDecimalNumber*)amountNumber
{
    if (![self.textFieldAmount.text length])
    {
        return [NSDecimalNumber zero];
    }

    NSString* decSep = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];

    return [NSDecimalNumber decimalNumberWithString:[self.textFieldAmount.text
                                                        stringByReplacingOccurrencesOfString:decSep
                                                                                  withString:@"."]];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
