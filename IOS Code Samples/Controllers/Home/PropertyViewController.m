//
//  PropertyViewController.m
//  EventParking
//
//  Created by Tamil Arasan on 05/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "PropertyViewController.h"
#import "AppDelegate.h"
#import "EventsDetails.h"

@interface PropertyViewController ()

@end

@implementation PropertyViewController

@synthesize propertyArray;
@synthesize filterArray;
@synthesize userModel;

#pragma mark - Loading Methods

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedInProperty:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    propertyArray    =   [[NSMutableArray alloc]init];
    filterArray      =   [[NSMutableArray alloc]init];
    searchString     =   [[NSMutableString alloc]init];
    eventFilteredArray = [[NSMutableArray alloc]init];
    
    webServiceObj    =   [WebserviceHelper sharedWebserviceHelper];
    activityLoader   =   [CustomIndicator sharedCustomIndicator];
    
    isCheckedSelectedRow        = FALSE;
    lblUserName.text            = userModel.userNameStr;
    
    [propertyTableView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    [propertyTableView setSeparatorColor:[UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0]];
    propertyTableView.layer.borderWidth = 1.0;
    propertyTableView.layer.cornerRadius = 8.0;
    propertyTableView.layer.borderColor = [UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0].CGColor;
    
    [lblNoPropertyFound setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    [lblNoPropertyFound.layer setCornerRadius:8.0];
    [lblNoPropertyFound.layer setBorderWidth:1.0];
    [lblNoPropertyFound.layer setBorderColor:[UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0].CGColor];
    
    [self getPropertyValues];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    //[self setTableViewHeight];
    [self orientationChangedInProperty:nil];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - TouchesBegan Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [searchTextField resignFirstResponder];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [filterArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    ListCell *cell = (ListCell *)[propertyTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ListCell" owner:self options:nil]objectAtIndex:0];
    }
    cell.tag = indexPath.row;
    
    if([filterArray count] > 0)
    {
        PropertyDetails     *propertyObjModel;
        propertyObjModel    = [filterArray objectAtIndex:indexPath.row];
        cell.lblTitle.text = propertyObjModel.propertyDesc;
        
        if(isCheckedSelectedRow == FALSE)
        {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
        }else{
            
            if(selectedIndexPath == indexPath.row)
            {
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.0 / 255.0 green:100.0 / 255.0 blue:166.0 / 255.0 alpha:1.0]];
                cell.tickImage.hidden = NO;
                [cell.lblTitle setTextColor:[UIColor whiteColor]];
            }
            else
            {
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
                cell.tickImage.hidden = YES;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath.row;
    if([filterArray count] > 0)
    {
        propObjModelData            = [filterArray objectAtIndex:indexPath.row];
        isCheckedSelectedRow        = TRUE;
    }
    
    [searchTextField resignFirstResponder];
    [propertyTableView reloadData];
}

-(void)viewDidLayoutSubviews
{
    if ([propertyTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [propertyTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([propertyTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [propertyTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma  mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    [filterArray removeAllObjects];
    [filterArray addObjectsFromArray:propertyArray];
    lblNoPropertyFound.hidden = (filterArray.count == 0) ? NO : YES;
    textField.text = @"";
    [textField resignFirstResponder];
    [self setTableViewHeight];
    [propertyTableView reloadData];
    
    return  YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 120, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == searchTextField)
    {
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        
        [self searchByProperty:substring];
    }
    return YES;
}

- (void)searchByProperty:(NSString *)searchStr
{
    if([searchStr length] > 0)
    {
        [filterArray removeAllObjects];
        for (PropertyDetails *propDetails in propertyArray)
        {
            NSRange range=[propDetails.propertyDesc rangeOfString:searchStr options:(NSCaseInsensitiveSearch)];
            
            if(range.location != NSNotFound)
                [filterArray addObject:propDetails];
        }
    }else{
        
        [filterArray removeAllObjects];
        [filterArray addObjectsFromArray:propertyArray];
    }
    
    lblNoPropertyFound.hidden = (filterArray.count == 0) ? NO : YES;
    
    
    
    [self setTableViewHeight];
    [propertyTableView reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
    [filterArray removeAllObjects];
    [filterArray addObjectsFromArray:propertyArray];
    lblNoPropertyFound.hidden = (filterArray.count == 0) ? NO : YES;
    
    [self setTableViewHeight];
    [propertyTableView reloadData];
    
    return NO;
}

#pragma mark - ISL Methods

- (NSDictionary *)createUpdateLoggedProperty
{
    NSMutableDictionary *loggedPropertyDict = nil;
    
    NSString *userID        = [[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSString *userLoggedID  = [[NSUserDefaults standardUserDefaults]valueForKey:@"userLoggedInId"];
    
    if([userID length] > 0 && [userLoggedID length] > 0)
    {
        loggedPropertyDict = [[NSMutableDictionary alloc] init];
        
        [loggedPropertyDict setObject:userID forKey:kWSUserIdKey];
        [loggedPropertyDict setObject:propObjModelData.propertyID forKey:kWSPropertyIdKey];
        [loggedPropertyDict setObject:userLoggedID forKey:kWSUserLoggedInIdKey];
    }
    return loggedPropertyDict;
}

-(void)updateUserLoggedProperty:(NSDictionary *)loggedPropertyDict
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *loggedResponseDict  = [webServiceObj requestLoggedProperty:loggedPropertyDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(loggedPropertyDict != nil)
            {
                NSString *errorMessage = [loggedResponseDict objectForKey:kWSResultMessageKey];
                if([errorMessage isEqualToString:kWSPropertyUpdateSuccessMsgKey])
                {
                    NSString *currentPropertyID = propObjModelData.propertyID;
                    
                    if (currentPropertyID.length >0) {
                        [self getAllEventsByProperty:currentPropertyID];
                    }
                    
                }else
                {
                    AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:errorMessage Type:e_defaultErrorAlert Controller:self];
                    [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
                }
            }
        });
    });
}

-(void)getAllEventsByProperty:(NSString *)propertyID
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        eventsList  = [webServiceObj retrieveAllEventsByProperty:propertyID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(eventsList != nil)
            {
                if([eventsList count] > 0)
                {
                    [self getPaymentTypeByProperty:propObjModelData.propertyID];
                }
                else
                {
                    AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No Events found in this property" Type:e_defaultErrorAlert Controller:self];
                    [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
                }
            }
            else
            {
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No Events found in this property" Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
            }
        });
    });
}

- (void)eventFilterMethod
{
    [eventFilteredArray removeAllObjects];
    currentDate = [[AppDelegate sharedAppdelegate]getCurrentDateTime];
    currentDateFormatted = [self dateFormatConversion:currentDate];
    
    for(EventsDetails *evnentsObj in eventsList)
    {
        NSString *eventDate = [evnentsObj startDate];
        
        NSArray *dateList = [eventDate componentsSeparatedByString:@"T"];
        if([dateList count] > 0)
            eventDate = [dateList objectAtIndex:0];
        
        if ([currentDateFormatted isEqualToString:eventDate]) {
            [eventFilteredArray addObject:evnentsObj];
        }
    }
    
    if([eventFilteredArray count] > 0)
    {
        [self getPaymentTypeByProperty:propObjModelData.propertyID];
    }
    else
    {
        AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No Events found in this property" Type:e_defaultErrorAlert Controller:self];
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    }
}

- (void)getPaymentTypeByProperty:(NSString *)propertyID
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *paymentTypeArray = [webServiceObj requestPaymentTypeByProperty:propertyID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityLoader stopLoadAnimation:self];
            
            if(paymentTypeArray != nil)
            {
                [[[AppDelegate sharedAppdelegate] finalPaymentTypeArray] removeAllObjects];
                [[AppDelegate sharedAppdelegate].finalPaymentTypeArray addObjectsFromArray:paymentTypeArray];
                
                NSInteger eventsCount = [eventsList count];
                
                if (eventsCount == 1)
                {
                    [self pushRatesViewPage:eventsList];
                }
                else
                {
                    [self pushEvnetsViewPage:eventsList];
                }
            }
            else
            {
                //show the error alert
            }
        });
    });
}

- (NSString *)dateFormatConversion:(NSString *)parseDefaultDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSDate *parseDate = [formatter dateFromString:parseDefaultDate];
    
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString *finalDate = [formatter stringFromDate:parseDate];
    
    return finalDate;
}

-(void)pushEvnetsViewPage :(NSMutableArray *)eventsListArray
{
    NSArray *finalEventsArray = [NSArray arrayWithArray:eventsListArray];
    
    EventsViewController *eventsViewControllerObj = [[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
    eventsViewControllerObj.propertyData    = propObjModelData;
    eventsViewControllerObj.eventsArray     = finalEventsArray;
    
    [self.navigationController pushViewController:eventsViewControllerObj animated:YES];
}

-(void)pushRatesViewPage:(NSMutableArray *)eventListArray
{
    NSArray *finalEventsArray = [NSArray arrayWithArray:eventListArray];
    
    if([eventListArray count] > 0)
    {
        EventsDetails *model = [eventListArray objectAtIndex:0];
        
        if (model.eventsID.length > 0)
        {
            RateViewController *rateViewControllerObj = [[RateViewController alloc]initWithNibName:@"RateViewController" bundle:nil];
            rateViewControllerObj.propertyModelObj  = propObjModelData;
            rateViewControllerObj.eventsModelObj    = [finalEventsArray objectAtIndex:0];
            [[AppDelegate sharedAppdelegate] setRateViewControllerObj:rateViewControllerObj];
            
            [self.navigationController pushViewController:rateViewControllerObj animated:YES];
        }
        else
        {
            AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No event found" Type:e_defaultErrorAlert Controller:self];
            [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
        }
    }
}

- (void)getPropertyValues
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverArray  = [webServiceObj requestPropertyDetails];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(serverArray != nil)
            {
                [propertyArray removeAllObjects];
                [filterArray removeAllObjects];
                
                [propertyArray addObjectsFromArray:serverArray];
                [filterArray addObjectsFromArray:propertyArray];
                
                if([propertyArray count] > 0)
                {
                    // [self loadMapLocation];
                    
                    [self setTableViewHeight];
                    [propertyTableView reloadData];
                }
                else
                {
                    AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No properties found" Type:e_defaultErrorAlert Controller:self];
                    [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
                }
            }
            else
            {
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"No properties found" Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
            }
        });
    });
}

- (void)requestLogoutProcess:(NSDictionary *)logoutDict
{
    [activityLoader startLoadAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UserDetails *logoutData  = [webServiceObj requestLogoutUser:logoutDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [activityLoader stopLoadAnimation:self];
            
            if(logoutData != nil)
            {
                if([[logoutData errorMessage] length] > 0)
                    [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"Logout Failed" Type:e_defaultErrorAlert Controller:self];
                [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
            }
        });
    });
}

- (void)setTableViewHeight
{
    float heightSize = filterArray.count * 44;
    CGPoint tablePoint  = propertyTableView.frame.origin;
    CGSize  tableSize   = propertyTableView.frame.size;
    
    if(IS_IPHONE_4)
    {
        if(heightSize <= 176)
        {
            propertyTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, heightSize);
        }else{
            propertyTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, 176);
        }
    }
    else
    {
        if(heightSize<=264)
        {
            propertyTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, heightSize);
        }
        else
        {
            propertyTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, 264);
        }
    }
    
 /*   UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {

        if([lblNoPropertyFound isHidden] == FALSE)
        {
            propertyTableView.hidden = TRUE;
        }
        else
            propertyTableView.hidden = FALSE;
        
        [scrollBackground setContentSize:CGSizeMake(0, 320)];
    } else if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        if([lblNoPropertyFound isHidden] == FALSE)
        {
            propertyTableView.hidden = TRUE;
        }
        else
            propertyTableView.hidden = FALSE;

        [scrollBackground setContentSize:CGSizeMake(0, 0)];
    } */
}

#pragma mark - IBAction Methods

- (IBAction)clickDoneButton:(id)sender
{
    if(isCheckedSelectedRow == TRUE)
    {
        NSDictionary *loggedPropertyDict = [self createUpdateLoggedProperty];
        if(loggedPropertyDict != nil)
        {
            [self updateUserLoggedProperty:loggedPropertyDict];
        }
    }else
    {
        AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"Please select the property" Type:e_defaultErrorAlert Controller:self];
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
        
        //Testing
//        BOOL isBLEDynaMaxConnected  =   [[AppDelegate sharedAppdelegate] isBLEDynaMaxDeviceConnected];
//        if(isBLEDynaMaxConnected)
//        {
//            NSLog(@"BLE Device connected");
//          
//        }
    }
}

- (IBAction)logoutButtonPressed:(id)sender
{
    AlertDetails *alertData = [[AlertDetails alloc] init];
    [alertData setTitle:@"Warning!"];
    [alertData setMessage:@"Are you sure want to logout?"];
    [alertData setPrimaryButtonTitle:@"Yes"];
    [alertData setSecondaryButtonTitle:@"No"];
    [alertData setAlertTag:e_logoutAlert];
    [alertData setWhichController:self];
    
    [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    
//    warningAlert  = [[UIAlertView alloc] initWithTitle:@"Warning!"
//                                               message:@"Are you sure want to logout?"
//                                              delegate:self
//                                     cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    [warningAlert show];
}

- (IBAction)settingsButtonPressed:(id)sender
{
    StarMicronicsViewController *starmicronics = [[StarMicronicsViewController alloc]initWithNibName:@"StarMicronicsViewController" bundle:nil];
    [self.navigationController pushViewController:starmicronics animated:YES];
}

#pragma mark - Handle Alert Methods
- (void)handleLogoutProcess
{
    NSUserDefaults  *userPref   =   [NSUserDefaults standardUserDefaults];
    NSString *userId            =   [userPref valueForKey:@"userid"];
    NSString *userLoggedinId    =   [userPref valueForKey:@"userLoggedInId"];
    
    if([userId length] > 0 && [userLoggedinId length] > 0)
    {
        NSMutableDictionary *logoutDict = [[NSMutableDictionary alloc] init];
        [logoutDict setObject:userId forKey:@"UserId"];
        [logoutDict setObject:userLoggedinId forKey:@"UserLoggedInId"];
        
        [self requestLogoutProcess:logoutDict];
    }
}

#pragma mark - CoreLocation Delegate

- (void)loadMapLocation
{
    currentLocationManager=[[CLLocationManager alloc]init];
    currentLocationManager.delegate=self;
    
    currentLocationManager.distanceFilter = kCLDistanceFilterNone;
    currentLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if([currentLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [currentLocationManager requestWhenInUseAuthorization];
        [currentLocationManager requestAlwaysAuthorization];
    }
    
    [currentLocationManager startUpdatingLocation];
}

-(void)getCurrentLocation
{
    float latitude = currentLocationManager.location.coordinate.latitude;
    float longitude = currentLocationManager.location.coordinate.longitude;
    
    currentLatitute = [NSString stringWithFormat:@"%.8f", latitude];
    currentLongtitue = [NSString stringWithFormat:@"%.8f", longitude];
    [self calculateDistance];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Error ==>%@",[error description]);
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if(currentLocationManager)
        [currentLocationManager stopUpdatingLocation];
    
    currentLatitute = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude];
    currentLongtitue = [NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude];
    
    if([currentLongtitue length] > 0 && [currentLatitute length] > 0)
    {
        [self calculateDistance];
    }
}

- (void)calculateDistance
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:[currentLatitute floatValue] longitude:[currentLongtitue floatValue]];
    
    int propertyIndex = 0;
    for(PropertyDetails *details in filterArray)
    {
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[details.latitude floatValue] longitude:[details.longitude floatValue]];
        
        CLLocationDistance distance= [location1 distanceFromLocation:location2];
        NSLog(@"Double value ==>%f",distance);
        
        if(distance < 3975327)  // < 500 meeters
        {
            CLLocationDistance kilometers = distance / 1000.0;
            double value = kilometers;
            NSString *kilometerStr = [NSString stringWithFormat:@"%f",value];
            
            NSString *propertyKey = [NSString stringWithFormat:@"%d",propertyIndex];
            [distanceArray addObject:[NSDictionary dictionaryWithObject:kilometerStr forKey:propertyKey]];
        }
        
        propertyIndex++;
        
        NSLog(@"Calculated Miles %@", [NSString stringWithFormat:@"%.1fmi",(distance/1609.344)]);
    }
    
    NSLog(@"arrau===%@",distanceArray);
    
    NSArray      *keyList = nil;
    double  minimumKilometer = 0;
    
    //Get First kilometer
    if([distanceArray count] > 0)
    {
        NSDictionary *distanceDict =    [distanceArray objectAtIndex:0];
        keyList = [distanceDict allKeys];
        NSString *firstKilometer    = [distanceDict objectForKey:[keyList objectAtIndex:0]];
        
        minimumKilometer    = [firstKilometer doubleValue];
        autoPropertSelectedIndex = [[keyList objectAtIndex:0] intValue];
    }
    
    if([distanceArray count] > 1)
    {
        //Check other distance property
        for(NSDictionary *distanceDict in distanceArray)
        {
            NSArray *keyList     =   [distanceDict allKeys];
            NSString *kilometerStr = [distanceDict objectForKey:[keyList objectAtIndex:0]];
            
            double currentKilometer     =[kilometerStr doubleValue];
            if (minimumKilometer > currentKilometer)
            {
                minimumKilometer = currentKilometer;
                autoPropertSelectedIndex = [[keyList objectAtIndex:0] intValue];
            }
        }
    }
}

#pragma mark - Orientation Method

- (void)orientationChangedInProperty:(NSNotification *)notification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        [[NSUserDefaults standardUserDefaults]setValue:@"LandScape" forKey:@"Orientation"];
        NSLog(@"LandScape");
        
        [self orientationWithLandScape];
    }
    else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationUnknown)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"Portrait" forKey:@"Orientation"];
        NSLog(@"Portrait");
        
        [self orientationWithPortrait];
    }
    else
    {
        orientationStatus = [[NSUserDefaults standardUserDefaults]valueForKey:@"Orientation"];
        
        if ([orientationStatus isEqualToString:@"LandScape"])
        {
            NSLog(@"FaceUp - LandScape");
            [self orientationWithLandScape];
        }
        else if ([orientationStatus isEqualToString:@"Portrait"])
        {
            NSLog(@"FaceUp - Portrait");
            [self orientationWithPortrait];
        }
    }
}

- (void)orientationWithPortrait
{
    [propertyTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 175)];
    [btnDone setFrame:CGRectMake(btnDone.frame.origin.x,scrollBackground.frame.size.height-75, btnDone.frame.size.width, btnDone.frame.size.height)];
    [scrollBackground setContentSize:CGSizeMake(0, 0)];
    

    [self setTableViewHeight];
    [propertyTableView reloadData];
     
}

- (void)orientationWithLandScape
{
    [propertyTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 132)];
    [scrollBackground setContentSize:CGSizeMake(0, 320)];
    [btnDone setFrame:CGRectMake(btnDone.frame.origin.x, propertyTableView.frame.origin.y + propertyTableView.frame.size.height + 20, btnDone.frame.size.width, btnDone.frame.size.height)];
    

    [self setTableViewHeight];
    [propertyTableView reloadData];
    
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
