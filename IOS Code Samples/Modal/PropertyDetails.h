//
//  PropertyDetails.h
//  EventParking
//
//  Created by Tamil Arasan on 05/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyDetails : NSObject

@property  BOOL isDeleteStatus;
@property (nonatomic, retain) NSString *propertyID;
@property (nonatomic, retain) NSString *tennentID;
@property (nonatomic, retain) NSString *propertyDesc;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *propertyNo;

@end
