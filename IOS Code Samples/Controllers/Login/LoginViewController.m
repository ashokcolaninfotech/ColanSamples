//
//  LoginVC.m
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - Loading Methods

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedInLogin:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    activityLoader = [CustomIndicator sharedCustomIndicator];
    webServiceObj  = [WebserviceHelper sharedWebserviceHelper];

    isCheckedCheckBox = FALSE;
    
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self orientationChangedInLogin:nil];
    
   //Load the remember me and username, password based on remember enabled
    NSUserDefaults *userPref    = [NSUserDefaults standardUserDefaults];
    isCheckedCheckBox           = [userPref boolForKey:@"rememberme"];
    NSString *imageName         = (isCheckedCheckBox) ? @"remember_selected.png" : @"remember_unselected.png";
    
    [btnRememberMe setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    NSString *usernameStr       =   [userPref valueForKey:@"remember_username"];
   // NSString *passwordStr       =   [userPref valueForKey:@"remember_password"];
    [txtUsername setText:usernameStr];
    [txtPassword setText:@""];
    
    
    //Testing
//    [txtUsername setText:@"superadmin@eventparking.com"];
//    [txtPassword setText:@"admin"];

    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ISL Methods

- (void)requestLoginProcess:(NSDictionary *)loginDict
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UserDetails *userData = [webServiceObj requestLoginProcess:loginDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(userData != nil)
            {
                if(userData.isValidUser == TRUE)
                {
                    PropertyViewController *propertyVCObj = [[PropertyViewController alloc]initWithNibName:@"PropertyViewController" bundle:nil];
                    propertyVCObj.userModel = userData;
                    [self.navigationController pushViewController:propertyVCObj animated:YES];
                    
                }
                else
                {
                    AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"Invalid credentials" Type:e_defaultErrorAlert Controller:self];
                    [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
                }
            }
            else
            {
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"Please check the internet connection!" Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
            }
        });
    });
}

#pragma mark - Button Action Methods

- (IBAction)signInButtonPressed:(id)sender {
    
  //Reset the Loginsubview frame
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    
    BOOL isSuccess = FALSE;
    
    NSString *username      = txtUsername.text;
    NSString *password      = txtPassword.text;
    NSString *errorMessage  = nil;

    
    if ([username length] == 0 && [password length] == 0) {
        errorMessage = @"Please enter valid credentials";
    }
    else if ([txtUsername.text length] == 0) {
        errorMessage = @"Please enter User Name";
    }
    else if ([txtPassword.text length] == 0) {
        errorMessage = @"Please enter Password";
    }
    else if([Validation validateEmail:txtUsername.text] == FALSE)
    {
         errorMessage = @"Please enter valid E-Mail Id";
    }
    else
    {
        isSuccess = TRUE;
        
     //Save Username and password based on rememeber me.
        NSUserDefaults *userPref    = [NSUserDefaults standardUserDefaults];

        if(isCheckedCheckBox)
        {
            [userPref setValue:txtUsername.text forKey:@"remember_username"];
            [userPref setValue:txtPassword.text forKey:@"remember_password"];
        }
        else
        {
            [userPref setValue:@"" forKey:@"remember_password"];
        }
        
        [userPref synchronize];
        
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:password forKey:@"PassWord"];
        [userDict setObject:username forKey:@"Email"];
        
        [self requestLoginProcess:userDict];
    }
    
    if(!isSuccess)
    {
        AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:errorMessage Type:e_defaultErrorAlert Controller:self];
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    }
    
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

- (IBAction)forgetPasswordButtonPressed:(id)sender {
    
    ForgotPasswordViewController *forgotPwdVCObj = [[ForgotPasswordViewController alloc]initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPwdVCObj animated:YES];
}

-(IBAction)btnClickRemeberMe:(id)sender
{
    NSUserDefaults *userPref    = [NSUserDefaults standardUserDefaults];
    isCheckedCheckBox           = [userPref boolForKey:@"rememberme"];
    
    if (isCheckedCheckBox == FALSE)
    {
        [btnRememberMe setBackgroundImage:[UIImage imageNamed:@"remember_selected.png"] forState:UIControlStateNormal];
        isCheckedCheckBox = TRUE;
    }
    else
    {
        [btnRememberMe setBackgroundImage:[UIImage imageNamed:@"remember_unselected.png"] forState:UIControlStateNormal];
        isCheckedCheckBox = FALSE;
    }
    
    [userPref setBool:isCheckedCheckBox forKey:@"rememberme"];
    [userPref synchronize];
}

#pragma mark - TextField Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    
    if (textField == txtUsername) {
        [self.view setFrame:CGRectMake(0, - 100, self.view.frame.size.width, self.view.frame.size.height)];

    } else if (textField == txtPassword) {
        [self.view setFrame:CGRectMake(0, - 120, self.view.frame.size.width, self.view.frame.size.height)];

    }
    [UIView commitAnimations];
}

#pragma mark - Orientation Method

- (void)orientationChangedInLogin:(NSNotification *)notification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        [[NSUserDefaults standardUserDefaults]setValue:@"LandScape" forKey:@"Orientation"];
        NSLog(@"LandScape");
        
        [self orientationWithLandScape];
    }
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationUnknown)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"Portrait" forKey:@"Orientation"];
        NSLog(@"Portrait");
        
        [self orientationWithPortrait];
    }
    else {
        
        orientationStatus = [[NSUserDefaults standardUserDefaults]valueForKey:@"Orientation"];
        
        if ([orientationStatus isEqualToString:@"LandScape"]) {
            NSLog(@"FaceUp - LandScape");
            
            [self orientationWithLandScape];
            
        } else if ([orientationStatus isEqualToString:@"Portrait"]) {
            NSLog(@"FaceUp - Portrait");
            
            [self orientationWithPortrait];
        }
    }
}

- (void)orientationWithPortrait {
    
    
    [imageviewLogo setFrame:CGRectMake(19, 25, 280, 158)];
    
    [imageviewUserNameIcon setFrame:CGRectMake(22, imageviewLogo.frame.origin.y + imageviewLogo.frame.size.height + 40, 35, 35)];
    [txtUsername setFrame:CGRectMake(68, imageviewUserNameIcon.frame.origin.y + 5, 216, 30)];
    [lblDividerUserName setFrame:CGRectMake(22, imageviewUserNameIcon.frame.origin.y + imageviewUserNameIcon.frame.size.height + 15, 262, 1)];
    
    [imageviewPasswordIcon setFrame:CGRectMake(22, imageviewUserNameIcon.frame.origin.y + imageviewUserNameIcon.frame.size.height + 30, 35, 35)];
    [txtPassword setFrame:CGRectMake(68, imageviewPasswordIcon.frame.origin.y + 5, 216, 30)];
    [lblDividerPassWord setFrame:CGRectMake(22, imageviewPasswordIcon.frame.origin.y + imageviewPasswordIcon.frame.size.height + 15, 262, 1)];
    
    [btnSignIn setFrame:CGRectMake(28, self.view.frame.size.height - 130, 262, 60)];
    
    [btnRememberMe setFrame:CGRectMake(10, self.view.frame.size.height - 45, 19, 19)];
    
    [lblRememberMe setFrame:CGRectMake(37, self.view.frame.size.height - 50, 118, 30)];
    
    [btnForgetPassword setFrame:CGRectMake(156, self.view.frame.size.height - 50, 155, 30)];
     
}

- (void)orientationWithLandScape {
    
    [imageviewLogo setFrame:CGRectMake(self.view.frame.size.width / 2 - 70, 20, 140, 80)];
    
    [imageviewUserNameIcon setFrame:CGRectMake(self.view.frame.size.width / 4, imageviewLogo.frame.origin.y + imageviewLogo.frame.size.height + 20, 35, 35)];
    [txtUsername setFrame:CGRectMake(imageviewUserNameIcon.frame.origin.x + imageviewUserNameIcon.frame.size.width + 10, imageviewUserNameIcon.frame.origin.y, self.view.frame.size.width - 2 * self.view.frame.size.width / 4 - 45, 30)];
    [lblDividerUserName setFrame:CGRectMake(self.view.frame.size.width / 4, txtUsername.frame.origin.y + txtUsername.frame.size.height + 10, self.view.frame.size.width - 2 * self.view.frame.size.width / 4, 1)];
    
    [imageviewPasswordIcon setFrame:CGRectMake(self.view.frame.size.width / 4, txtUsername.frame.origin.y + txtUsername.frame.size.height + 20, 35, 35)];
    [txtPassword setFrame:CGRectMake(imageviewPasswordIcon.frame.origin.x + imageviewPasswordIcon.frame.size.width + 10, imageviewPasswordIcon.frame.origin.y, self.view.frame.size.width - 2 * self.view.frame.size.width / 4 - 45, 30)];
    [lblDividerPassWord setFrame:CGRectMake(self.view.frame.size.width / 4, txtPassword.frame.origin.y + txtPassword.frame.size.height + 10, self.view.frame.size.width - 2 * self.view.frame.size.width / 4, 1)];
    
    [btnSignIn setFrame:CGRectMake(lblDividerPassWord.frame.origin.x, txtPassword.frame.origin.y + txtPassword.frame.size.height + 20, self.view.frame.size.width - 2 * self.view.frame.size.width / 4, 60)];
    
    [btnRememberMe setFrame:CGRectMake(20, btnSignIn.frame.origin.y + btnSignIn.frame.size.height + 10, 19, 19)];
    
    [lblRememberMe setFrame:CGRectMake(btnRememberMe.frame.origin.x + btnRememberMe.frame.size.width + 5, btnRememberMe.frame.origin.y - 5, 118, 30)];
    
    [btnForgetPassword setFrame:CGRectMake(self.view.frame.size.width - 155, lblRememberMe.frame.origin.y, 155, 30)];
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
