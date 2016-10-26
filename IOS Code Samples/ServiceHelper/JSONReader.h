//
//  JSONReader.h
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDetails.h"
#import "PropertyDetails.h"
#import "RateDetails.h"
#import "EventsDetails.h"


@interface JSONReader : NSObject
{
    
}

+(id)sharedJSONReaderInstance;

- (NSData *)toLoginJSONString:(NSDictionary *)userDict;
- (id)parseJSONData:(NSData *)jsonData;
- (UserDetails *)getLoginUserData:(NSDictionary *)loginServerDict;
- (UserDetails *)getLogoutUserData:(NSDictionary *)logoutServerDict;
- (NSMutableArray *)getPropertyDetailsData:(NSArray *)propertyList;
- (NSDictionary *)getRateDetailsData:(NSDictionary *)rateDict;
- (NSMutableArray *)getAllEvents:(NSArray *)eventsList;
-(NSDictionary *)getPaymentResponse:(NSDictionary *)paymentDict;
- (NSString *)getPaymentJSONString:(NSDictionary *)processPaymentDict;
- (NSMutableArray *)getPaymentType:(NSDictionary *)paymentTypeDict;

-(NSString *)getCashPaymentJSONString:(NSDictionary *)paymentDict;

@end

