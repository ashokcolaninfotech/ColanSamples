//
//  ForgotPasswordViewController.h
//  EventParking
//
//  Created by Abdul Jabbar on 08/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Validation.h"

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>
{
    CustomIndicator         *activityLoader;
    WebserviceHelper        *webServiceObj;
    
    NSString                *orientationStatus;
}

@property (strong, nonatomic) IBOutlet UITextField *txtForgotPassword;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollForgotBackground;

- (IBAction)sendPwdButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

- (void)requestForgotPasswordProcess;

@end
