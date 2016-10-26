//
//  AppDelegate.h
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MTSCRA.h"
#import "RateViewController.h"
#import "LineaViewController.h"

@class LoginViewController;
@class iDynamoViewController;
@class LineaViewController;
@class RateViewController;
@class PaymentConfirmatioViewController;
@class DynaMaxViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    iDynamoViewController *m_dynamoViewController;
    DynaMaxViewController *m_dynamaxViewController;
    
}

@property (strong, nonatomic) UIWindow                  *window;
@property (strong, nonatomic) UINavigationController    *navigationController;
@property (strong, nonatomic) LoginViewController       *loginVc;
@property (strong, nonatomic) RateViewController        *rateViewControllerObj;

@property (strong, nonatomic) MTSCRA                    *mtSCRALib;
@property (strong, nonatomic) iDynamoViewController     *iDynamoViewContorllerObj;
@property (strong, nonatomic) DynaMaxViewController     *dynamaxViewControllerObj;
@property (strong, nonatomic) LineaViewController       *lineaProViewControllerObj;
@property (strong, nonatomic) PaymentConfirmatioViewController *paymentConfirmationObj;
@property (strong, nonatomic) NSMutableArray            *finalPaymentTypeArray;
@property (strong, nonatomic) NSMutableDictionary       *lastReceiptPaymentDict;


+ (AppDelegate *)sharedAppdelegate;
+ (NSString *)getPortName;
+ (void)setPortName:(NSString *)m_portName;
+ (NSString*)getPortSettings;
+ (void)setPortSettings:(NSString *)m_portSettings;

- (NSString *)getCurrentDateTime;
- (NSString *)getRequestDateTime;
-(NSString *)getPaymentTypeMethod:(NSString *)requestCardType;


//DynaMax Methods
- (BOOL)isBLEDynaMaxDeviceConnected;
- (DynaMaxViewController *)dynamaxViewControllerObj;


//iDynamo Methods
- (void)configDynamoDevice;
- (BOOL)isDynamoDeviceConnected;
- (iDynamoViewController *)iDynamoViewContorllerObj;
- (void)getIDynamoCardDetails:(NSDictionary *) userInfo;

//Star Micronics Methods
- (void)printReceipt:(NSDictionary *)paymentDict;
- (void)printReceiptText:(NSArray *)receiptArray;
- (void)printQRCode:(NSString *)paymentData;
- (NSString *)generateQRCode2D:(NSDictionary *)paymentDict;


@end


@interface UINavigationController (RotationAll)
-(NSUInteger)supportedInterfaceOrientations;
@end
