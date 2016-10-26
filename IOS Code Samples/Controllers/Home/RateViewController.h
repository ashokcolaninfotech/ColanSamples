//
//  RateViewController.h
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCell.h"
#import "WebserviceHelper.h"
#import "RateDetails.h"
#import "PropertyDetails.h"
#import "PropertyViewController.h"
#import "CreditPaymentViewController.h"
#import "CashViewController.h"
#import "PaymentConfirmatioViewController.h"
#import "EventsDetails.h"

@class AlertDetails;

@interface RateViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
{
    IBOutlet UICollectionView   *collectionView_Obj;
    IBOutlet UILabel            *lbl_Payment;
    IBOutlet UIButton           *btnCash;
    IBOutlet UIButton           *btnCredit;
    IBOutlet UILabel            *lblRateHeader;
    IBOutlet UILabel            *lblPropertyDesc;
    IBOutlet UILabel            *lblEventDesc;
    
    NSInteger                   cellCount;
    NSInteger                   selectedButtonTag;
    CustomIndicator             *activityLoader;
    WebserviceHelper            *webServiceObj;
    
    PaymentConfirmatioViewController    *paymentConfirmVCObj;
    CashViewController                  *cashVCObj;
    NSMutableDictionary                 *paymentDict;
    
    BOOL                isCheckedCellButton;
    BOOL                isCheckedRateButton;
    
    NSString            *orientationStatus;
}

@property (strong, nonatomic) NSMutableArray    *imageArray;
@property (strong, nonatomic) NSMutableArray    *rateArray;
@property (nonatomic, retain) NSMutableArray    *responseArray;
@property (nonatomic, retain) RateDetails       *rateModelObj;
@property (nonatomic, retain) PropertyDetails   *propertyModelObj;
@property (nonatomic, retain) EventsDetails     *eventsModelObj;



- (IBAction)cashCreditPayment:(id)sender;
- (IBAction)pressBack:(id)sender;
-(IBAction)lastReceiptButtonPressed:(id)sender;

- (void)showRatesSuccessFailedAlert:(AlertDetails *)alertData;
- (AlertDetails *)getAlertData:(BOOL)status Message:(NSString *)message Type:(ALERT_TYPE)alertType;


- (void)popToPreviousPage;
-(void)handleZeroProcessPayment:(BOOL)paymentStatus;
-(void)handlePaymentSucces;




@end
