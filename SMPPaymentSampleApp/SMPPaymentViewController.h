//
//  SMPPaymentViewController.h
//  SMPPaymentSampleApp
//
//  Created by Lukas Mollidor on 10/31/12.
//  Copyright (c) 2012-2015 SumUp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMPPaymentViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldAmount;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)payFromSender:(id)sender;

@end
