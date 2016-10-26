//
//  EventsDetails.h
//  EventParking
//
//  Created by Muthu Rajan on 30/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventsDetails : NSObject
{
    
}

@property  BOOL isDeleteStatus;
@property (nonatomic, retain) NSString *eventsID;
@property (nonatomic, retain) NSString *eventNo;

@property (nonatomic, retain) NSString *eventsDesc;
@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;


@end
