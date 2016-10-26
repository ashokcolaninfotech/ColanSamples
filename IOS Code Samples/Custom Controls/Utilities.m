//
//  Utilities.m
//  EventParking
//
//  Created by Muthu Rajan on 05/08/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities
@synthesize appAlertView;
@synthesize appAlertController;

+ (id)sharedUtilitiesInstance
{
    static Utilities *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Utilities alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        
    }
    
    return self;
}

- (AlertDetails *)getAlertData:(BOOL)status Message:(NSString *)message Type:(ALERT_TYPE)alertType Controller:(UIViewController *)controller
{
    AlertDetails *alertData = [[AlertDetails alloc] init];
    [alertData setMessage:message];
    [alertData setWhichController:controller];
    [alertData setAlertTag:alertType];
    
    if(status)
    {
        [alertData setTitle:@"Success"];
        [alertData setPrimaryButtonTitle:@"Ok"];
        [alertData setSecondaryButtonTitle:@""];
    }
    else
    {
        [alertData setTitle:@"Alert"];
        [alertData setPrimaryButtonTitle:@""];
        [alertData setSecondaryButtonTitle:@"Ok"];
    }
    
    return alertData;
}


- (void)showAlertWithDetails:(AlertDetails *)alertData
{
    NSString *title             = [alertData title];
    NSString *message           = [alertData message];
    NSString *primaryButton     = [alertData primaryButtonTitle];
    NSString *secondaryButton   = [alertData secondaryButtonTitle];
    int whichTag                = [alertData alertTag];
    UIViewController *whichController = [alertData whichController];
    
    currentAlertObj = alertData;
    
    if([UIAlertController  class])
    {
        appAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if(secondaryButton && [secondaryButton length] > 0)
        {
            UIAlertAction *noButton = [UIAlertAction actionWithTitle:secondaryButton style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                   {
                       [appAlertController dismissViewControllerAnimated:YES completion:nil];
                       [self handleUserActionProcess:NO];
                       
                   }];
            
            [appAlertController addAction:noButton];
        }
        
        if(primaryButton && [primaryButton length] > 0)
        {
            UIAlertAction *yesButton = [UIAlertAction actionWithTitle:primaryButton style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                {
                    [appAlertController dismissViewControllerAnimated:YES completion:nil];
                    
                    [self handleUserActionProcess:YES];
                    
                    
                }];
            [appAlertController addAction:yesButton];
        }
        
        [whichController presentViewController:appAlertController animated:YES completion:nil];
        
    }
    else
    {
        if([primaryButton length] > 0 && [secondaryButton length] > 0)
        {
            appAlertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message delegate:self cancelButtonTitle:secondaryButton otherButtonTitles:primaryButton, nil];
        }
        else if([primaryButton length] > 0)
        {
            appAlertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message delegate:self cancelButtonTitle:nil otherButtonTitles:primaryButton, nil];
        }
        else
        {
            appAlertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:secondaryButton
                                            otherButtonTitles:nil];
        }
        
        [appAlertView setTag:whichTag];
        [appAlertView show];
    }
}

-(BOOL)isAlertControllerPresented
{
    NSLog(@"utilities : isAlertControllerPresented Callled");
    
    
    BOOL isPresented = FALSE;
    if(self.appAlertController) // && [self.appAlertController isBeingPresented])
    {
        [self.appAlertController dismissViewControllerAnimated:YES completion:nil];
        self.appAlertController = nil;
        
        isPresented =TRUE;
    }
    
    NSLog(@"utilities : isAlertControllerPresented isPresented ===%@",isPresented ? @"YES" : @"NO");
    
    
    return isPresented;
}

- (BOOL)isAlertVisible
{
    BOOL isAppalertVisible = FALSE;
    
    if(self.appAlertView && [self.appAlertView isVisible])
    {
        [self.appAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.appAlertView = nil;
        
        isAppalertVisible = TRUE;
    }
    
    return isAppalertVisible;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL isSuccessButton = NO;

    if(alertView.tag == e_logoutAlert || alertView.tag == e_zeroProcessPayment)
    {
        isSuccessButton = (buttonIndex == 1) ? YES : NO;
    }
    
    else if(alertView.tag == e_rateZeroProcessSuccess || alertView.tag == e_cashPaymentSuccessAlert || alertView.tag == e_creditPaymentSucccessAlert || alertView.tag == e_swipeCreditPaymentSuccess || alertView.tag == e_noRatesErrorAlert)
    {
        isSuccessButton = YES;
    }
    else
    {
        isSuccessButton = NO;
    }

    [self handleUserActionProcess:isSuccessButton];

}

- (void)handleUserActionProcess:(BOOL)buttonStatus
{
    NSLog(@"Utitlities :: handleUserActionProcess  Called Status =%@",buttonStatus ? @"YES" : @"NO");
    
    if(currentAlertObj != nil)
    {
        UIViewController *whichController = [currentAlertObj whichController];
        ALERT_TYPE whichAlertType   = [currentAlertObj alertTag];
        NSLog(@"Utitlities :: handleUserActionProcess whichAlertType ==%d",whichAlertType);
        
        switch (whichAlertType) {
            case e_logoutAlert:
            {
                if(buttonStatus)
                {
                    PropertyViewController *propertyObj = (PropertyViewController *)whichController;
                    if(propertyObj)
                        [propertyObj handleLogoutProcess];
                }
                
                break;
            }
            case e_noRatesErrorAlert:
            {
                if(buttonStatus)
                {
                    RateViewController *rateViewObj = (RateViewController *)whichController;
                    if(rateViewObj)
                        [rateViewObj popToPreviousPage];
                }
                
                break;
            }
            case e_zeroProcessPayment:
            {
                RateViewController *rateViewObj = (RateViewController *)whichController;
                if(buttonStatus)
                    [rateViewObj handleZeroProcessPayment:YES];
                else
                    [rateViewObj handleZeroProcessPayment:NO];
                
                break;
            }
            case e_rateZeroProcessSuccess:
            {
                if(buttonStatus)
                {
                    RateViewController *rateViewObj = (RateViewController *)whichController;
                    if(rateViewObj)
                        [rateViewObj handlePaymentSucces];
                }
                break;
            }
            case e_cashPaymentSuccessAlert:
            {
                if(buttonStatus)
                {
                    CashViewController *cashViewObj = (CashViewController *)whichController;
                    if(cashViewObj)
                        [cashViewObj handlePaymentProcessAlert];
                }
                
                break;
            }
            case e_creditPaymentSucccessAlert:
            {
                if(buttonStatus)
                {
                    CreditPaymentViewController *creditViewObj = (CreditPaymentViewController *)whichController;
                    if(creditViewObj)
                        [creditViewObj goToRateView];
                }
                
                break;
            }
            case e_swipeCreditPaymentSuccess:
            {
                NSLog(@"Utitlities :: handleUserActionProcess - e_swipeCreditPaymentSuccess");
                
                if(buttonStatus)
                {
                    PaymentConfirmatioViewController *paymentConfirmView = (PaymentConfirmatioViewController *)whichController;
                    if(paymentConfirmView)
                        [paymentConfirmView goToRatesController];
                }
                
                break;
            }
            default:
                break;
        }
    }
}


@end
