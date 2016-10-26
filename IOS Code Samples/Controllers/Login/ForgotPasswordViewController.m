//
//  ForgotPasswordViewController.m
//  EventParking
//
//  Created by Abdul Jabbar on 08/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize txtForgotPassword;
@synthesize scrollForgotBackground;

#pragma mark - Loading Methods

- (void)viewDidLoad {
    
    webServiceObj    =   [WebserviceHelper sharedWebserviceHelper];
    activityLoader   =   [CustomIndicator sharedCustomIndicator];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 75, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - Button Action Methods

- (IBAction)sendPwdButtonPressed:(id)sender
{
    NSString *forgotPwd     =   txtForgotPassword.text;
    NSString *errorMesasge  =   nil;
    BOOL isSuccess          =   FALSE;
    
    if ([forgotPwd isEqualToString:@""])
        errorMesasge = @"Please enter your E-Mail Id";
    else if ([Validation validateEmail:forgotPwd] == FALSE)
        errorMesasge = @"Please enter valid E-Mail Id";
    else
    {
        isSuccess = TRUE;
        [self requestForgotPasswordProcess];
    }
    
    if(isSuccess == FALSE)
    {
        AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:errorMesasge Type:e_defaultErrorAlert Controller:self];
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ISL Methods

- (void)requestForgotPasswordProcess
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *serverDict  = [webServiceObj requestForgotPasswordUser:txtForgotPassword.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(serverDict != nil)
            {
                NSString *errorMessage  = [serverDict objectForKey:kWSResultMessageKey];
                BOOL isSuccess = FALSE;
                isSuccess = ([errorMessage isEqualToString:kWSForgotSuccessMsgKey]) ? TRUE : FALSE;
                
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:isSuccess Message:errorMessage Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
            }
            else
            {
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"ForgotPassword Failed" Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
                
                txtForgotPassword.text = @"";
            }
        });
    });
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate
{
    return YES;
}


@end
