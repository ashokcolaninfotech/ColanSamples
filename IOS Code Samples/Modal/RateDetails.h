//
//  RateDetails.h
//  EventParking
//
//  Created by Tamil Arasan on 06/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateDetails : NSObject

@property  BOOL isRateDeleteStatus;
@property (nonatomic, retain) NSString *rateID;
@property (nonatomic, retain) NSString *rateTennentID;
@property (nonatomic, retain) NSString *rateDesc;
@property (nonatomic, retain) NSString *rateAmount;
@property  NSInteger *rateAmount1;

@end
