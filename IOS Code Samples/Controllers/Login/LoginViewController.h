//
//  LoginVC.h
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceHelper.h"
#import "JSONReader.h"
#import "CustomIndicator.h"
#import "AppDelegate.h"
#import "RateViewController.h"
#import "CreditPaymentViewController.h"
#import "Validation.h"
#import "PropertyViewController.h"
#import "ForgotPasswordViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>
{
    WebserviceHelper         *webServiceObj;
    CustomIndicator          *activityLoader;
    
    IBOutlet UITextField    *txtUsername;
    IBOutlet UITextField    *txtPassword;
    IBOutlet UIButton       *btnSignIn;
    IBOutlet UIButton       *btnForgetPassword;
    IBOutlet UIButton       *btnRememberMe;
    IBOutlet UIImageView    *imageviewLogo;
    IBOutlet UIImageView    *imageviewUserNameIcon;
    IBOutlet UIImageView    *imageviewPasswordIcon;
    IBOutlet UILabel        *lblDividerUserName;
    IBOutlet UILabel        *lblDividerPassWord;
    IBOutlet UILabel        *lblRememberMe;
    
    
    BOOL                    isCheckedCheckBox;
    
    NSString *orientationStatus;
}


- (IBAction)signInButtonPressed:(id)sender;
- (IBAction)forgetPasswordButtonPressed:(id)sender;
- (IBAction)btnClickRemeberMe:(id)sender;

@end
