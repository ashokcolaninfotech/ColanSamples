//
//  WebserviceHelper.h
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONReader.h"

@interface WebserviceHelper : NSObject
{
    JSONReader *jsonReaderObject;
    
}

+(id)sharedWebserviceHelper;

//Connection Methods
- (id)requestURL:(NSString *)url json:(NSData *)requestJsonData httpMethod:(NSString *)method;
- (NSString *)ConnectURL:(NSURL *)url postData:(NSData *)postData httpMethod:(NSString *)method;

//ISL Methods
- (UserDetails *)requestLoginProcess:(NSDictionary *)loginDict;
- (UserDetails *)requestLogoutUser:(NSDictionary *)logoutDict;
- (NSDictionary *)requestForgotPasswordUser:(NSString *)email;
- (NSMutableArray *)requestPropertyDetails;
- (NSDictionary *)requestRateDetails:(NSString *)eventID;

- (NSDictionary *)requestProcessPaymentDetails:(NSDictionary *)processPaymentDict url:(NSString *)baseURL;
- (NSDictionary *)requestLoggedProperty:(NSDictionary *)loggedPropertyDict;

- (NSArray *)retrieveAllEventsByProperty:(NSString *)propertyID;
- (NSArray *)requestPaymentTypeByProperty:(NSString *)propertyID;

@end
