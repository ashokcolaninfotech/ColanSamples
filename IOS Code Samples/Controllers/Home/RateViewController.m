//
//  RateViewController.m
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "RateViewController.h"
#import "AppDelegate.h"

@interface RateViewController ()

@end

@implementation RateViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    float height;
    float width;
}

@synthesize imageArray;
@synthesize rateArray;
@synthesize responseArray;
@synthesize rateModelObj,propertyModelObj;
@synthesize eventsModelObj;


#pragma mark - Loading Methods

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedInRates:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    
    [self handlingViewLoads];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self orientationChangedInRates:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        screenWidth = self.view.frame.size.width;
        screenHeight = self.view.frame.size.height;
        
    } else {
        
        screenWidth=[UIScreen mainScreen].bounds.size.height;
        screenHeight=[UIScreen mainScreen].bounds.size.width;
    }
    
    [self.view setBounds:CGRectMake(0, 0, screenWidth, screenHeight)];

    [self orientationChangedInRates:nil];

    [self reloadRatesData];
    
    [super viewWillAppear:animated];
}

- (void)handlingViewLoads
{
    imageArray      = [[NSMutableArray alloc]init];
    rateArray       = [[NSMutableArray alloc]init];
    responseArray   = [[NSMutableArray alloc]init];
    
    webServiceObj   = [WebserviceHelper sharedWebserviceHelper];
    activityLoader  = [CustomIndicator sharedCustomIndicator];
    
    cellCount       = 0;
    
    lblEventDesc.text       = eventsModelObj.eventsDesc;
    lblPropertyDesc.text    = propertyModelObj.propertyDesc;
    isCheckedRateButton     = FALSE;
    isCheckedCellButton     = FALSE;
    
    btnCash.userInteractionEnabled      = NO;
    btnCredit.userInteractionEnabled    = NO;
    
    [btnCash setBackgroundImage:[UIImage imageNamed:@"ep_cashInActiveButton.png"] forState:UIControlStateNormal];
    [btnCredit setBackgroundImage:[UIImage imageNamed:@"ep_creditInActiveButton.png"] forState:UIControlStateNormal];

    
    [collectionView_Obj registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
}

- (void)reloadRatesData
{
    isCheckedCellButton     = FALSE;
    
    btnCash.userInteractionEnabled      = NO;
    btnCredit.userInteractionEnabled    = NO;
    [lblRateHeader setText:@"Select rate:"];
    
    [btnCash setBackgroundImage:[UIImage imageNamed:@"ep_cashInActiveButton.png"] forState:UIControlStateNormal];
    [btnCredit setBackgroundImage:[UIImage imageNamed:@"ep_creditInActiveButton.png"] forState:UIControlStateNormal];
    
    cellCount       = 0;
    
    [self getRateValues];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Alert Methods
-(void)showRatesSuccessFailedAlert:(AlertDetails *)alertData
{
    if(alertData)
    {
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    }
}

- (AlertDetails *)getAlertData:(BOOL)status Message:(NSString *)message Type:(ALERT_TYPE)alertType
{
    AlertDetails *alertData = [[AlertDetails alloc] init];
    [alertData setMessage:message];
    [alertData setWhichController:self];
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

- (void)popToPreviousPage
{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleZeroProcessPayment:(BOOL)paymentStatus
{
    if (paymentStatus)  // Yes button
    {
        NSDictionary *cashDict = [self getCashPaymentData];
        if(cashDict != nil)
            [self processCashPaymentMethod:cashDict];
    }
    else
    {
        [lblRateHeader setText:@"Select rate:"];
        lbl_Payment.textColor = [UIColor colorWithRed:78.0 / 255.0 green:88.0 / 255.0 blue:99.0 / 255.0 alpha:1.0];
        
        //Reload rates
        [self reloadRatesData];
    }
}

-(void)handlePaymentSucces
{
    [lblRateHeader setText:@"Select rate:"];
    lbl_Payment.textColor = [UIColor colorWithRed:78.0 / 255.0 green:88.0 / 255.0 blue:99.0 / 255.0 alpha:1.0];
    
    [self reloadRatesData];
}


#pragma mark - ISL Methods

- (void)getRateValues
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *rateDict = [webServiceObj requestRateDetails:eventsModelObj.eventsID];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(rateDict != nil)
            {
                BOOL isSuccess = [[rateDict objectForKey:@"Status"] boolValue];
                
                if(isSuccess)
                {
                    NSArray *rateResponseArray =   [rateDict objectForKey:@"RatesModelList"];
                    [rateArray removeAllObjects];

                    NSArray *filterRatesList =  [self filterRates:rateResponseArray];
                    if([filterRatesList count] > 0)
                        [rateArray addObjectsFromArray:filterRatesList];
                }
                
                if([rateArray count] > 0)
                {
                    [collectionView_Obj reloadData];
                }
                else
                {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Rates found for selected event" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                    alert.tag = 1000;
//                    [alert show];
                    
                    AlertDetails *alertData = [self getAlertData:YES Message:kNoRatesFoundMsgkey Type:e_noRatesErrorAlert];
                    [self showRatesSuccessFailedAlert:alertData];
                }
            }
            else
            {
                AlertDetails *alertData = [self getAlertData:YES Message:kNoRatesFoundMsgkey Type:e_noRatesErrorAlert];
                [self showRatesSuccessFailedAlert:alertData];
                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Rates found for selected event" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                alert.tag = 1000;
//                [alert show];
            }
        });
    });
}

- (NSArray *)filterRates :(NSArray *)ratesList
{
    NSArray *sortedArray = [ratesList sortedArrayUsingComparator:^NSComparisonResult(id rate1, id rate2)
                            {
                                NSString *rateAmount1 = [(RateDetails *)rate1 rateAmount];
                                NSString *rateAmount2 = [(RateDetails *)rate2 rateAmount];
                                
                                return ([rateAmount2 compare:rateAmount1 options:NSNumericSearch]);
                            }];
    
    return sortedArray;
}

- (NSDictionary *)getCashPaymentData
{
    NSMutableDictionary *processPaymentDict = nil;
    NSString *userId    = [[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSString *tennentID = [[NSUserDefaults standardUserDefaults]valueForKey:@"tennent"];
    NSString *currentDateTime   = [[AppDelegate sharedAppdelegate] getRequestDateTime];
    
    if([userId length] > 0 && [tennentID length] > 0)
    {
        processPaymentDict = [[NSMutableDictionary alloc] init];
        
        [processPaymentDict setObject:propertyModelObj.propertyID forKey:@"PropertyId"];
        [processPaymentDict setObject:tennentID forKey:@"TenantId"];
        [processPaymentDict setObject:eventsModelObj.eventsID forKey:@"EventId"];
        [processPaymentDict setObject:rateModelObj.rateID forKey:@"RateID"];
        
        [processPaymentDict setObject:@"cash" forKey:@"ModeofPayment"];
        [processPaymentDict setObject:rateModelObj.rateAmount forKey:@"Amount"];
        [processPaymentDict setObject:userId forKey:@"CreatedBy"];
        [processPaymentDict setObject:currentDateTime forKey:@"createdon"];
    }
    
    return processPaymentDict;
}


- (void)processCashPaymentMethod:(NSDictionary *)cashDict
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *response = [webServiceObj requestProcessPaymentDetails:cashDict url:@"cash"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(response != nil)
            {
                NSString *message       = [response valueForKey:kWSResultMessageKey];
                NSString *transactionID = [response valueForKey:kWSTransactionIDKey];
                
                if([[message lowercaseString] isEqualToString:kWSResultSuccessKey])
                {
                    NSUserDefaults *userPref    = [NSUserDefaults standardUserDefaults];
                    NSString *printerIPAddr     = [userPref valueForKey:kPrefsPrinterIPAddressesKey];
                    
                    NSString *cardType          = [response valueForKey:kWSCardTypeKey];
                    NSString *paymentID         = [[AppDelegate sharedAppdelegate] getPaymentTypeMethod:cardType];
                    
                    NSString *transactionUniqueID   = [response valueForKey:kWSTransactionUniqueKey];
                    NSString *totalAmount       = rateModelObj.rateAmount;
                    NSString *paidAmount        = rateModelObj.rateAmount;
                    NSString *DueAmount         = rateModelObj.rateAmount;
                    
                    if([printerIPAddr length] > 0)  //Print the Receipt
                    {
                        NSString *tenantID          = [userPref  valueForKey:@"tennent"];
                        NSString *currentDateTime   = [[AppDelegate sharedAppdelegate]getCurrentDateTime];
                        
                        paymentDict = [[NSMutableDictionary alloc] init];
                        [paymentDict setObject:currentDateTime forKey:@"CurrentDateTime"];
                        [paymentDict setObject:propertyModelObj.propertyDesc forKey:@"PropertyName"];
                        [paymentDict setObject:eventsModelObj.eventsDesc forKey:@"EventName"];
                        [paymentDict setObject:rateModelObj.rateDesc forKey:@"RateName"];
                        
                        [paymentDict setObject:tenantID forKey:@"TenantId"];
                        [paymentDict setObject:propertyModelObj.propertyID forKey:@"PropertyId"];
                        [paymentDict setObject:eventsModelObj.eventsID forKey:@"EventID"];
                        [paymentDict setObject:rateModelObj.rateID forKey:@"RateID"];
                        [paymentDict setObject:transactionID forKey:@"TransactionID"];
                        [paymentDict setObject:transactionUniqueID forKey:@"transactionUniqueID"];
                        [paymentDict setObject:paymentID forKey:@"paymentType"];
                        
                        [paymentDict setObject:eventsModelObj.startDate forKey:@"EventStartDate"];
                        [paymentDict setObject:eventsModelObj.endDate forKey:@"EventEndDate"];
                        [paymentDict setObject:eventsModelObj.eventNo forKey:@"EventNo"];
                        [paymentDict setObject:propertyModelObj.propertyNo forKey:@"PropertyNo"];

                        
                        [paymentDict setObject:totalAmount forKey:@"TotalDueAmount"];
                        [paymentDict setObject:paidAmount forKey:@"PaidDueAmount"];
                        [paymentDict setObject:DueAmount forKey:@"ChangeDueAmount"];
                        [paymentDict setObject:@"Cash Type" forKey:@"PaymentType"];
                        
                        [[AppDelegate sharedAppdelegate] setLastReceiptPaymentDict:paymentDict];
                        [[AppDelegate sharedAppdelegate]printReceipt:paymentDict];
                    }
                    
                    [activityLoader stopLoadAnimation:self];
                    
                    AlertDetails *alertData = [self getAlertData:YES Message:kCashPaymentSuccessMsgKey Type:e_rateZeroProcessSuccess];
                    [self showRatesSuccessFailedAlert:alertData];
                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:kCashPaymentSuccessMsgKey delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                    alert.tag = 1001;
//                    [alert show];
                }
                else
                {
                    [activityLoader stopLoadAnimation:self];
                    
                    AlertDetails *alertData = [self getAlertData:NO Message:kCashPaymentFailedMsgKey Type:e_rateZeroProcessFailed];
                    [self showRatesSuccessFailedAlert:alertData];
                }
            }
            else
            {
                [activityLoader stopLoadAnimation:self];
                
                AlertDetails *alertData = [self getAlertData:NO Message:kCashPaymentFailedMsgKey Type:e_rateZeroProcessFailed];
                [self showRatesSuccessFailedAlert:alertData];
            }
        });
    });
}



#pragma mark - CollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return rateArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView_Obj dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    
    cell.cellButton.tag      = indexPath.row;
    cell.tag                 = indexPath.row;
    NSLog(@"indexpath.row%ld",(long)indexPath.row);
    
    [cell.cellButton addTarget:self action:@selector(clickedCellButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //Show the shadow into Rates
    [cell.cellButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [cell.cellButton.layer setShadowOffset:CGSizeMake(0.0, 1.5)];
    [cell.cellButton.layer setShadowOpacity:0.3];
    [cell.cellButton.layer setShadowRadius:3.0];
    
    [cell.cellLblRateDescription.layer setShadowColor:[UIColor blackColor].CGColor];
    [cell.cellLblRateDescription.layer setShadowOffset:CGSizeMake(0.0, 1.5)];
    [cell.cellLblRateDescription.layer setShadowOpacity:0.3];
    [cell.cellLblRateDescription.layer setShadowRadius:3.0];
    
    RateDetails *rateModel;
    NSString    *rateString;
    
    if(rateArray.count>0)
    {
        rateModel   = [rateArray objectAtIndex:indexPath.row];
        rateString  = [NSString stringWithFormat:@"$%@",rateModel.rateAmount];
        cell.cellBG_Image.image     = [UIImage imageNamed:@"Rate-Btn-1-bg.png"];
        [cell.cellLblRateDescription setText:rateModel.rateDesc];
    }
    if(isCheckedCellButton == FALSE)
    {
        [cell.cellButton setTitle:rateString forState:UIControlStateNormal];
        cell.cellTick_Image.hidden = YES;
    }else{
        if(selectedButtonTag == indexPath.row)
        {
            [cell.cellButton setTitle:rateString forState:UIControlStateNormal];
            cell.cellTick_Image.hidden = NO;
            
            cell.cellBG_Image.image     = [UIImage imageNamed:@"Rate-Btn-1-bg.png"];
            cell.cellTick_Image.image   = [UIImage imageNamed:@"Rate-Btn-1-Tick.png"];
            
        }else{
            [cell.cellButton setTitle:rateString forState:UIControlStateNormal];
            cell.cellTick_Image.hidden = YES;
            [cell.cellButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            cell.cellBG_Image.image = [UIImage imageNamed:@"Blank-Rate-btn-bg.png"];
        }
    }
    return cell;
}

- (void)clickedCellButton:(id)sender
{
    cellCount=0;
    
    UIButton *button=(UIButton *)sender;
    NSLog( @"Delete button clicked");
    
    selectedButtonTag = button.tag;
    rateModelObj= [rateArray objectAtIndex:selectedButtonTag];
    NSLog(@"tag===%ld",(long)selectedButtonTag);
    
    isCheckedCellButton = TRUE;
    
    if ([rateModelObj.rateAmount isEqualToString:@"0"])
    {
        [btnCash setBackgroundImage:[UIImage imageNamed:@"ep_cashInActiveButton.png"] forState:UIControlStateNormal];
        [btnCash setUserInteractionEnabled:NO];
        
        [btnCredit setBackgroundImage:[UIImage imageNamed:@"ep_creditInActiveButton.png"] forState:UIControlStateNormal];
        [btnCredit setUserInteractionEnabled:NO];
        
        AlertDetails *alertData = [self getAlertData:NO Message:@"Do you want to proceed with $0 ?" Type:e_zeroProcessPayment];
        [alertData setPrimaryButtonTitle:@"Yes"];
        [alertData setSecondaryButtonTitle:@"No"];
        [self showRatesSuccessFailedAlert:alertData];
        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to proceed with $0 ?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
//        alert.tag = 555;
//        [alert show];
        
    }
    else
    {
        NSMutableArray *finalPaymentList = [AppDelegate sharedAppdelegate].finalPaymentTypeArray;
        if(finalPaymentList != nil)
        {
            if ([finalPaymentList containsObject:@"Cash"])
            {
                [btnCash setBackgroundImage:[UIImage imageNamed:@"ep_cashActiveButton.png"] forState:UIControlStateNormal];
                btnCash.userInteractionEnabled = YES;
            }
            
            if ([finalPaymentList containsObject:@"Credit"])
            {
                [btnCredit setBackgroundImage:[UIImage imageNamed:@"ep_creditActiveButton.png"] forState:UIControlStateNormal];
                btnCredit.userInteractionEnabled = YES;
            }
        }
    }
    
    lbl_Payment.textColor = [UIColor colorWithRed:78.0 / 255.0 green:88.0 / 255.0 blue:99.0 / 255.0 alpha:1.0];
    lblRateHeader.text = @"Rate Selected!";
    lblRateHeader.textColor =[UIColor lightGrayColor];
    
    [collectionView_Obj reloadData];
}


#pragma mark - IBAction Method

- (IBAction)cashCreditPayment:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *requestType   = (button.tag == 0) ? @"cash" : @"credit";
    [[NSUserDefaults standardUserDefaults] setValue:requestType forKey:@"credit/cash"];
    
    paymentConfirmVCObj = [[PaymentConfirmatioViewController alloc]initWithNibName:@"PaymentConfirmatioViewController" bundle:nil];
    paymentConfirmVCObj.propertyModelObj_payment    =propertyModelObj;
    paymentConfirmVCObj.rateModelObj_payment        =rateModelObj;
    paymentConfirmVCObj.eventModelObj_payment       = eventsModelObj;
    
    AppDelegate *appDeleagate = [AppDelegate sharedAppdelegate];
    [appDeleagate setPaymentConfirmationObj:paymentConfirmVCObj];
    
    [self.navigationController pushViewController:paymentConfirmVCObj animated:YES];
}

- (IBAction)pressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Last Receipt Methods

-(IBAction)lastReceiptButtonPressed:(id)sender
{
    NSUserDefaults *userPref    = [NSUserDefaults standardUserDefaults];
    NSString *printerIPAddr     = [userPref valueForKey:kPrefsPrinterIPAddressesKey];
    
    if([printerIPAddr length] > 0)  //Print the Receipt
    {
        AppDelegate *appDelegateRef = [AppDelegate sharedAppdelegate];
        if(appDelegateRef.lastReceiptPaymentDict != nil)
        {
            [activityLoader startLoadAnimation:self];
            [appDelegateRef printReceipt:appDelegateRef.lastReceiptPaymentDict];
            [activityLoader stopLoadAnimation:self];
        }
        else
        {
            
            AlertDetails *alertData = [self getAlertData:NO Message:kNoTransactionMsgKey Type:e_ratesErrorAlert];
            [self showRatesSuccessFailedAlert:alertData];
        }
    }
    else
    {
        AlertDetails *alertData = [self getAlertData:NO Message:@"Please enable the printer settings" Type:e_ratesErrorAlert];
        [self showRatesSuccessFailedAlert:alertData];
    }
}

#pragma mark - TextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Orientation Method

- (void)orientationChangedInRates:(NSNotification *)notification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    height = self.view.frame.size.height;
    width = self.view.frame.size.width;

    
    if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        [[NSUserDefaults standardUserDefaults]setValue:@"LandScape" forKey:@"Orientation"];
        NSLog(@"LandScape");
        
        [self orientationWithLandScape];
    }
    
    else if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationUnknown)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"Portrait" forKey:@"Orientation"];
        NSLog(@"Portrait");
        
        [self orientationWithPortrait];
    }
    else
    {
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
    
    [lbl_Payment setFrame:CGRectMake(lbl_Payment.frame.origin.x, collectionView_Obj.frame.origin.y + collectionView_Obj.frame.size.height + 10, lbl_Payment.frame.size.width, lbl_Payment.frame.size.height)];
    [btnCash setFrame:CGRectMake(40, height - 130, width - 80, 55)];
    [btnCredit setFrame:CGRectMake(40, height - 65, width - 80, 55)];
}

- (void)orientationWithLandScape {
    
    [lbl_Payment setFrame:CGRectMake(lbl_Payment.frame.origin.x, collectionView_Obj.frame.origin.y + collectionView_Obj.frame.size.height + 10, lbl_Payment.frame.size.width, lbl_Payment.frame.size.height)];
    [btnCash setFrame:CGRectMake(20, lbl_Payment.frame.origin.y + lbl_Payment.frame.size.height, 200, 50)];
    [btnCredit setFrame:CGRectMake(width - 220, btnCash.frame.origin.y, 200, 50)];
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
