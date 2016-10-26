//
//  PropertyViewController.h
//  EventParking
//
//  Created by Tamil Arasan on 05/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "UserDetails.h"
#import "CustomIndicator.h"
#import "WebserviceHelper.h"
#import "RateViewController.h"
#import "StarMicronicsViewController.h"
#import "PropertyDetails.h"
#import "ListCell.h"
#import "EventsViewController.h"


@interface PropertyViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CLLocationManagerDelegate>
{
    IBOutlet UITableView    *propertyTableView;
    IBOutlet UITextField    *searchTextField;
    IBOutlet UILabel        *lblUserName;
    IBOutlet UILabel        *lblNoPropertyFound;
    
    IBOutlet UIScrollView   *scrollBackground;
    IBOutlet UIButton       *btnDone;
    IBOutlet UIImageView    *imageSearchField;
    
    NSMutableString         *searchString;
    CustomIndicator         *activityLoader;
    WebserviceHelper        *webServiceObj;
    BOOL                    isCheckedSelectedRow;
    PropertyDetails         *propObjModelData;
    NSInteger               selectedIndexPath;
    
    UIAlertView             *warningAlert;
    
    CLLocationManager       *currentLocationManager;
    NSString                *currentLatitute;
    NSString                *currentLongtitue;
    int                     autoPropertSelectedIndex;
    
    NSArray                 *eventsList;
    NSMutableArray          *eventFilteredArray;
    NSString                *currentDate;
    NSString                *currentDateFormatted;
    
    NSString                *orientationStatus;
}

@property (nonatomic, retain) NSMutableArray    *propertyArray;
@property (nonatomic, retain) NSMutableArray    *filterArray;
@property (nonatomic, retain) UserDetails       *userModel;

- (IBAction)clickDoneButton:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;

-(void)pushRatesViewPage:(NSArray *)eventList;
-(void)pushEvnetsViewPage :(NSArray *)eventsList;

- (void)handleLogoutProcess;

@end
