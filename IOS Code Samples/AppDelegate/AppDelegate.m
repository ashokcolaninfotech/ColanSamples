//
//  AppDelegate.m
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "AppDelegate.h"
#import "iDynamoViewController.h"
#import "DynaMaxViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize rateViewControllerObj;
@synthesize paymentConfirmationObj;
@synthesize iDynamoViewContorllerObj = m_dynamoViewController;
@synthesize finalPaymentTypeArray;
@synthesize lastReceiptPaymentDict;
@synthesize dynamaxViewControllerObj = m_dynamaxViewController;

static NSString *portName = nil;
static NSString *portSettings = nil;

#pragma mark - Appdelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#if defined (DEBUG) && (DEBUG==1)
    
    [self writeLogsIntoFile];
    
    NSString	*ourVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];

    NSLog(@"********************************************");
    NSLog(@"  This is the Event Parking app version %@", ourVersion);
    NSLog(@"********************************************");
    
#endif
    
    [self configDynamoDevice];
    
    //Create loginView controller instance and add it into navigation
    self.navigationController = [[UINavigationController alloc]init];
    self.loginVc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:self.loginVc animated:YES];
    self.navigationController.navigationBarHidden=YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.lineaProViewControllerObj = [[LineaViewController alloc]initWithNibName:@"LineaViewController" bundle:nil];
	
	[StarMicronicsViewController setupPrinter];
	
    finalPaymentTypeArray = [[NSMutableArray alloc]init];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    if([self isBLEDynaMaxDeviceConnected])
    {
        [m_dynamaxViewController.lib setDeviceType:MAGTEKDYNAMAX];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Reconnnect BLE device if device is in saved mode.
    DynaMaxViewController *dynaMaxObj = [self dynamaxViewControllerObj];
    [dynaMaxObj resumeDynaMaxConnection];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)writeLogsIntoFile
{
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [docDirectory stringByAppendingPathComponent:@"console.txt"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

#pragma mark - Login Methods




#pragma mark - Share Object Methods

+ (AppDelegate *)sharedAppdelegate
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

#pragma mark - Commom Methods

- (NSString *)getCurrentDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar: [NSCalendar currentCalendar]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return dateString;
}

- (NSString *)getRequestDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return dateString;
}

-(NSString *)getPaymentTypeMethod:(NSString *)requestCardType
{
//  Cash = 1, Visa = 2, MC = 3, AMEX = 4,  Discover = 5
    NSString *paymentType = nil;
    if([requestCardType length] > 0)
    {
        NSString *cardType = [requestCardType lowercaseString];
        
        if([cardType isEqualToString:@"cash"])
            paymentType = @"1";
        else if([cardType isEqualToString:@"visa"])
            paymentType = @"2";
        else if([cardType isEqualToString:@"master card"])
            paymentType = @"3";
        else if([cardType isEqualToString:@"american express"])  //Amex
            paymentType = @"4";
        else if([cardType isEqualToString:@"discover"])
            paymentType = @"5";
        else if([cardType isEqualToString:@"dinners club"])
            paymentType = @"6";
        else
            paymentType = @"0";
    }
    
    paymentType = (paymentType && [paymentType length] > 0) ? paymentType : @"1";
    
    return paymentType;
}


#pragma mark - iDynamo Methods

- (void)configDynamoDevice
{
    self.mtSCRALib = [[MTSCRA alloc] init];
    [self.mtSCRALib listenForEvents:(TRANS_EVENT_START|TRANS_EVENT_OK|TRANS_EVENT_ERROR)];
    
    [self isDynamoDeviceConnected];
}

- (BOOL)isDynamoDeviceConnected
{
    BOOL isDynamoConnect = FALSE;
    
    if(self.iDynamoViewContorllerObj)
    {
        [self.iDynamoViewContorllerObj connectDevice];
        isDynamoConnect = [self.iDynamoViewContorllerObj.mtSCRALib isDeviceConnected];
    }
    
    return isDynamoConnect;
}

- (iDynamoViewController *)iDynamoViewContorllerObj
{
    if (m_dynamoViewController == nil)
    {
        iDynamoViewController *idynamoController = [[iDynamoViewController alloc] initWithNibName: @"iDynamoViewController"
                                                                                           bundle: nil];
        self.iDynamoViewContorllerObj = idynamoController;
    }
    
    // Force a view load, if necessary.
    [m_dynamoViewController view];
    
    return m_dynamoViewController;
}

- (void)getIDynamoCardDetails:(NSDictionary *) userInfo
{
    NSLog(@"Appdelegate : getIDynamoCardDetails ==>%@",userInfo);
    
    if(self.paymentConfirmationObj && userInfo)
    {
        [self.paymentConfirmationObj dynamoCardTrackNotification:userInfo];
    }
}

#pragma mark - DyanaMax Methods

- (BOOL)isBLEDynaMaxDeviceConnected
{
    BOOL isBleDynaMaxConnected = FALSE;
    
    DynaMaxViewController *dynamaObj = self.dynamaxViewControllerObj;
    
    if(dynamaObj)
    {
        isBleDynaMaxConnected = [dynamaObj.lib isDeviceConnected];
        if(isBleDynaMaxConnected)
        {
            [dynamaObj.lib setDeviceType:MAGTEKDYNAMAX];
            [dynamaObj.lib setDelegate:self.dynamaxViewControllerObj];
        }
    }
    
    return isBleDynaMaxConnected;
}

- (DynaMaxViewController *)dynamaxViewControllerObj
{
    if (m_dynamaxViewController == nil)
    {
        DynaMaxViewController *dynaMaxControllerObj = [[DynaMaxViewController alloc] initWithNibName: @"DynaMaxViewController"
                                                                                           bundle: nil];
        self.dynamaxViewControllerObj = dynaMaxControllerObj;
    }
    
    // Force a view load, if necessary.
    [m_dynamaxViewController view];
    
    return m_dynamaxViewController;
}

#pragma mark getter/setter
+ (NSString*)getPortName
{
	return portName;
}

+ (void)setPortName:(NSString *)m_portName
{
	if (portName != m_portName) {
		portName = nil;
		portName = [m_portName copy];
	}
}

+ (NSString *)getPortSettings
{
	return portSettings;
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
	if (portSettings != m_portSettings) {
		portSettings = nil;
		portSettings = [m_portSettings copy];
	}
}
#pragma mark - End of getter/setter

#pragma mark - Star Micronics Printer Methods

- (void)printReceipt:(NSDictionary *)paymentDict
{
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableDictionary *lineDict;
    
	NSString *transactionId			= [paymentDict objectForKey:@"transactionUniqueID"];
    NSString *propertyName          = [paymentDict objectForKey:@"PropertyName"];
    NSString *rateName              = [paymentDict objectForKey:@"RateName"];
    NSString *eventName             = [paymentDict objectForKey:@"EventName"];
    NSString *currentDateTime       = [paymentDict objectForKey:@"CurrentDateTime"];
    NSString *paymentType           = [paymentDict objectForKey:@"PaymentType"];
    NSString *totalDue              = [paymentDict objectForKey:@"TotalDueAmount"];
    NSString *totalPaid             = [paymentDict objectForKey:@"PaidDueAmount"];
    NSString *changeDue             = [paymentDict objectForKey:@"ChangeDueAmount"];
	
	// Cleanup Amount strings.  Using Dollars so might need to internationalize
	if (![totalDue containsString:@"$"])
	{
		totalDue = [NSString stringWithFormat:@"$%@", [totalDue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	if (![totalPaid containsString:@"$"])
	{
		totalPaid = [NSString stringWithFormat:@"$%@", [totalPaid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	if (![changeDue containsString:@"$"])
	{
		changeDue = [NSString stringWithFormat:@"$%@", [changeDue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	lineDict = [NSMutableDictionary dictionary];
    [lineDict setValue: @"STS Parking" forKey: kPrintTextStringKey];
    [lineDict setValue: [NSNumber numberWithBool: YES] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Center] forKey: kPrintTextJustificationKey];
	[textArray addObject: lineDict];
    
	lineDict = [NSMutableDictionary dictionary];
    
    NSString *prefixDigit;
    
    if([transactionId length] == 1)
    {
        prefixDigit = [NSString stringWithFormat:@"0000%@", transactionId];
    }
    else if([transactionId length] == 2)
    {
        prefixDigit = [NSString stringWithFormat:@"000%@", transactionId];
    }
    else if([transactionId length] == 3)
    {
        prefixDigit = [NSString stringWithFormat:@"00%@", transactionId];
    }
    else if([transactionId length] == 4)
    {
        prefixDigit = [NSString stringWithFormat:@"0%@", transactionId];
    }
    else
    {
        prefixDigit = transactionId;
    }
    
    
	[lineDict setValue: [NSString stringWithFormat:@"%@  :  %@", @"Transaction Id", prefixDigit] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
	[textArray addObject: lineDict];
	
    
    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@  :  %@", @"Receipt Date", currentDateTime] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject:lineDict];
    
    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@ :  %@", @"Property Name", propertyName] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];
    
    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@    :  %@", @"Event Name", eventName] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject:lineDict];
    
    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@     :  %@", @"Rate Name", rateName] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];
    
    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@  :  %@", @"Payment Type", paymentType] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];

    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@     :  %@", @"Total Due", totalDue] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];

    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@    :  %@", @"Total Paid", totalPaid] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];

    lineDict = [NSMutableDictionary dictionary];
	[lineDict setValue: [NSString stringWithFormat:@"%@    :  %@", @"Change Due", changeDue] forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
    [textArray addObject: lineDict];

//	// Add a line feed before the QRCode
//	lineDict = [NSMutableDictionary dictionary];
//	[lineDict setValue: @"\n" forKey: kPrintTextStringKey];
//	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
//	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
//	[textArray addObject: lineDict];

    
	[self printReceiptText:textArray];
    
	NSString *paymentData = [self generateQRCode2D:paymentDict];
	
	[self printQRCode:paymentData];

	// Add a line feed after the QRCode
	lineDict = [NSMutableDictionary dictionary];
	textArray = [NSMutableArray array];
	[lineDict setValue: @"\n" forKey: kPrintTextStringKey];
	[lineDict setValue: [NSNumber numberWithBool: NO] forKey: kPrintTextBoldKey];
	[lineDict setValue: [NSNumber numberWithInt: Left] forKey: kPrintTextJustificationKey];
	[textArray addObject: lineDict];
	
	[self printReceiptText:textArray];
}

- (void)printReceiptText:(NSArray *)receiptArray
{
	NSString *portStringVal = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    NSString *portName;
    
    if ([portStringVal containsString:@"BT:"])
        portName = portStringVal;
    else
        portName = [@"tcp:" stringByAppendingString: portStringVal];
    
	NSMutableData *combinedReceiptText = [[NSMutableData alloc] init];
	NSString *currentLine = @"          ";
	
	NSData *titleMargin = [currentLine dataUsingEncoding:NSWindowsCP1252StringEncoding];
	
	[combinedReceiptText appendData:titleMargin];
	
	[receiptArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop)
	{
		NSString *currentLineFormat = @"";
		
		// do something with object
		if (idx == 0)
		{
			currentLineFormat = @"     %@\n\n";
		}
		else
		{
			currentLineFormat = @"     %@\n";
		}
		
		NSString *currentLine = [NSString stringWithFormat:currentLineFormat, [object valueForKey:kPrintTextStringKey]];
		
		// BOOL currentFontWeight = (BOOL)[object valueForKey:kPrintTextBoldKey];
		
		// Alignment currentJustification = (Alignment)[[object valueForKey:kPrintTextJustificationKey] integerValue];
		
		NSData *lineData = [currentLine dataUsingEncoding:NSWindowsCP1252StringEncoding];
		
		[combinedReceiptText appendData:lineData];
	}];
	
	unsigned char *receiptBytes = (unsigned char*)malloc([combinedReceiptText length]);
	[combinedReceiptText getBytes:receiptBytes];
	
	[MiniPrinterFunctions PrintText:portName
					   PortSettings:portSettings
						  Underline:NO
						 Emphasized:NO
						Upsideddown:NO
						InvertColor:NO
					HeightExpansion:0
					 WidthExpansion:0
						 LeftMargin:5
						  Alignment:ALIGN_JUSTIFY
						TextToPrint:receiptBytes
					TextToPrintSize:(unsigned int)[combinedReceiptText length]];
	
	free(receiptBytes);
}

- (void)printQRCode:(NSString *)paymentData
{
	NSInteger selectedCorrection = 0;
	NSInteger selectedModule = 4;
	NSInteger selectedCode = 0;
	
//	NSString *portName = [AppDelegate getPortName];
//	NSString *portSettings = [AppDelegate getPortSettings];
    
    NSString *portStringVal = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    NSString *portName;
    
    if ([portStringVal containsString:@"BT:"])
        portName = portStringVal;
    else
        portName = [@"tcp:" stringByAppendingString: portStringVal];
    
	
	NSData *barcodeData = [paymentData dataUsingEncoding:NSWindowsCP1252StringEncoding];
	
	unsigned char *barcodeBytes = (unsigned char*)malloc([barcodeData length]);
	[barcodeData getBytes:barcodeBytes];
	
	NSLog(@"barcodeBytes: %s", barcodeBytes);
	
	CorrectionLevelOption correction = (CorrectionLevelOption)selectedCorrection;
	unsigned char         code       = selectedCode;
	//  unsigned char         module     = selectedModule;
	unsigned char         module     = selectedModule + 1;
	
	[MiniPrinterFunctions PrintQrcodePortname:portName
								 portSettings:portSettings
						correctionLevelOption:correction
									  ECLevel:code
								   moduleSize:module
								  barcodeData:barcodeBytes
							  barcodeDataSize:(unsigned int)[barcodeData length]];
	
	free(barcodeBytes);
}

- (NSString *)generateQRCode2D:(NSDictionary *)paymentDict
{
  //  NSString *transactionId     = [paymentDict objectForKey:@"transactionUniqueID"];
    
    NSString *locationNo        = [paymentDict objectForKey:@"PropertyNo"];
    NSString *eventNo           = [paymentDict objectForKey:@"EventNo"];
    NSString *eventStartDate    = [self getEventDateFormat:[paymentDict objectForKey:@"EventStartDate"]];
    NSString *eventEndDate      = [self getEventDateFormat:[paymentDict objectForKey:@"EventEndDate"]];
    
    NSString *transactionId     = [paymentDict objectForKey:@"transactionUniqueID"];
    
    NSString *prefixDigit;
    
    if([transactionId length] == 1)
    {
        prefixDigit = [NSString stringWithFormat:@"0000%@", transactionId];
    }
    else if([transactionId length] == 2)
    {
        prefixDigit = [NSString stringWithFormat:@"000%@", transactionId];
    }
    else if([transactionId length] == 3)
    {
        prefixDigit = [NSString stringWithFormat:@"00%@", transactionId];
    }
    else if([transactionId length] == 4)
    {
        prefixDigit = [NSString stringWithFormat:@"0%@", transactionId];
    }
    else
    {
        prefixDigit = transactionId;
    }
    
    
  //  NSString *paymentType       = [paymentDict objectForKey:@"paymentType"];
    
    NSString *eventRateString =  [paymentDict objectForKey:@"TotalDueAmount"];
    eventRateString = [eventRateString stringByReplacingOccurrencesOfString:@"$" withString:@""];

    NSString *rateString = [self addZeroByRate:eventRateString];
    
   // NSString *qrCodeString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",locationNo, eventNo,eventStartDate, eventEndDate,rateString,prefixDigit,paymentType];
    
    NSString *qrCodeString = [NSString stringWithFormat:@"%@%@%@%@%@%@",locationNo, eventNo,eventStartDate, eventEndDate,rateString,prefixDigit];
    
    NSLog(@"AppDelegate :  generateQRCode2D ==%@",qrCodeString);
    
    return qrCodeString;
}

- (NSMutableString *)addZeroByRate:(NSString *)eventRateString
{
    NSMutableString *rateString = [[NSMutableString alloc] init];
    
    if([eventRateString containsString:@"."])
    {
        NSArray *digitArray = [eventRateString componentsSeparatedByString:@"."];
        if([digitArray count] >= 1)
        {
            NSString *prefixDigit = [digitArray objectAtIndex:0];
            if([prefixDigit length] == 1)
            {
                [rateString appendFormat:@"0%@",prefixDigit];
                [rateString appendString:[digitArray objectAtIndex:1]];
            }
            else
            {
                eventRateString = [eventRateString stringByReplacingOccurrencesOfString:@"." withString:@""];
                [rateString appendString:eventRateString];
            }
        }
    }
    else
    {
        if([eventRateString length] == 1)
            [rateString appendFormat:@"000%@",eventRateString];
        else if([eventRateString length] == 2)
            [rateString appendFormat:@"00%@",eventRateString];
        else if([eventRateString length] == 3)
            [rateString appendFormat:@"0%@",eventRateString];
        else
            [rateString appendFormat:@"%@",eventRateString];
        
        //[rateString appendString:@"00"];
    }
    
    return rateString;
}


-(NSString *)getEventDateFormat:(NSString *)eventDate
{
    NSString *parseDateString = nil;
    
    NSArray *dateList = [eventDate componentsSeparatedByString:@" "];
    if([dateList count] >= 2)
    {
        NSString *dateString = [dateList objectAtIndex:0];
        NSString *timeString = [dateList objectAtIndex:1];
        NSString *hoursFormat= [dateList objectAtIndex:2];
        NSString *eventTime = nil;
        
        NSArray *timeList =  [timeString componentsSeparatedByString:@":"];
        
        if([[hoursFormat lowercaseString] isEqualToString:@"pm"])
        {
            if([timeList count] >= 2)
            {
                int hourDigit = [[timeList objectAtIndex:0] intValue];
                if(hourDigit != 12)  //If 12 PM do nothing. else change the 24 hours format
                {
                    int hours = [[timeList objectAtIndex:0] intValue]+12;
                    eventTime = [NSString stringWithFormat:@"%d:%@",hours,[timeList objectAtIndex:1]];
                }
                else
                    eventTime = timeString;
            }
            else
                eventTime = timeString;
        }
        else
        {
            if([timeList count] >= 2)
            {
                int hourDigit = [[timeList objectAtIndex:0] intValue];
                if(hourDigit == 12)
                    eventTime = [NSString stringWithFormat:@"00:%@",[timeList objectAtIndex:1]];
                else
                    eventTime = timeString;
            }
        }
        
        parseDateString = [NSString stringWithFormat:@"%@%@",dateString,eventTime];
    }
    
    parseDateString = [parseDateString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    parseDateString = [parseDateString stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    return parseDateString;
}


@end


@implementation UINavigationController (RotationAll)
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


@end
