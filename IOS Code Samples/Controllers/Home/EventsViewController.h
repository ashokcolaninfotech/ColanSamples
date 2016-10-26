//
//  EventsViewController.h
//  EventParking
//
//  Created by Muthu Rajan on 30/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsDetails.h"
#import "PropertyDetails.h"

@interface EventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView    *eventsTableView;
    IBOutlet UILabel        *selectedEventLabel;
    IBOutlet UITextField    *eventSearchTextField;
    IBOutlet UILabel        *noEventFoundLabel;
    
    IBOutlet UIScrollView   *scrollBackground;
    IBOutlet UIButton       *btnDone;
    IBOutlet UILabel        *lblSelectEvent;
    IBOutlet UIImageView    *imageSearchField;

    NSMutableArray          *eventFilterArray;
    BOOL                    b_IsSelectedEvent;
    NSInteger               selectedIndexPath;
    EventsDetails           *selectedEventObj;
    
    NSString                *orientationStatus;
}

@property (nonatomic, strong) NSArray           *eventsArray;
@property (nonatomic, strong) PropertyDetails   *propertyData;


- (IBAction)onEventDone:(id)sender;
- (IBAction)goToBackAction:(id)sender;



@end
