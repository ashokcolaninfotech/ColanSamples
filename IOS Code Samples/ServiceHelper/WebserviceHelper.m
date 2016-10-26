//
//  WebserviceHelper.m
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "WebserviceHelper.h"
#import "UserDetails.h"
#import "PropertyDetails.h"
#import "RateDetails.h"
#import "Common.h"

@implementation WebserviceHelper

#pragma mark - Shared Methods

+ (id)sharedWebserviceHelper
{
    static WebserviceHelper *sharedWebservice = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedWebservice = [[WebserviceHelper alloc] init];
    });
    
    return sharedWebservice;
}

- (id)init
{
    if(self = [super init])
    {
        jsonReaderObject = [JSONReader sharedJSONReaderInstance];
    }
    
    return self;
}

#pragma mark - Service Methods

- (UserDetails *)requestLoginProcess:(NSDictionary *)loginDict
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kServerBaseURLKey, kRequestLoginISLKey];
    NSData *requestJson = [jsonReaderObject  toLoginJSONString:loginDict];
    NSLog(@"URL = %@ \n JSON String = %@",urlString, requestJson);
    
    id serverResponse = [self requestURL:urlString json:requestJson httpMethod:@"POST"];
    NSLog(@"theJSONResult:%@",serverResponse);
    
    UserDetails *userData = [jsonReaderObject getLoginUserData:serverResponse];
    
    return userData;
}

- (NSMutableArray *)requestPropertyDetails
{
    NSString *userID = [[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?UserID=%@",kServerBaseURLKey, kGetPropertiesISLKey,userID];
    
    id serverResponse = [self requestURL:urlString json:nil httpMethod:@"POST"];
    NSLog(@"requestPropertyDetails:%@",serverResponse);
    
    NSMutableArray *propertyData = [jsonReaderObject getPropertyDetailsData:serverResponse];
    
    return propertyData;
}

- (NSDictionary *)requestRateDetails:(NSString *)eventID
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?EventId=%@",kServerBaseURLKey, kGetRatesISLKey,eventID];
    id serverResponse = [self requestURL:urlString json:nil httpMethod:@"POST"];
    NSLog(@"requestRateDetails:%@",serverResponse);
    
    NSDictionary *rateDic = [jsonReaderObject getRateDetailsData:serverResponse];
    
    return rateDic;
}

- (NSDictionary *)requestProcessPaymentDetails:(NSDictionary *)processPaymentDict url:(NSString *)baseURL{
    
     NSLog(@"Service Helper : requestProcessPaymentDetails ==>%@",processPaymentDict);
    
    NSString *urlString;
    NSData *requestJson = nil;
    if([baseURL isEqualToString:@"cash"])
    {
        urlString = [NSString stringWithFormat:@"%@%@",kServerBaseURLKey, KProcessCashPayment];
        NSString *jsonString  = [jsonReaderObject  getCashPaymentJSONString:processPaymentDict];
        requestJson = [jsonString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
        
        NSLog(@"requestProcessPaymentDetails Cash URL, JSON ==>%@, %@",urlString, jsonString);
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@%@",kServerBaseURLKey, KProcessCreditCardPayment];
        NSString *jsonString = [jsonReaderObject getPaymentJSONString:processPaymentDict];
        requestJson = [jsonString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
        
        NSLog(@"requestProcessPaymentDetails Credit URL, JSON ==>%@, %@",urlString, jsonString);
    }
    
    id serverResponse = [self requestURL:urlString json:requestJson httpMethod:@"POST"];
    NSLog(@"requestProcessPaymentDetails Response :%@",serverResponse);
    
    NSDictionary *paymentDict =  [jsonReaderObject getPaymentResponse:serverResponse];
    
    return paymentDict;
}

- (UserDetails *)requestLogoutUser:(NSDictionary *)logoutDict
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kServerBaseURLKey, kRequestLogoutISLKey];
    NSData *requestJson = [jsonReaderObject  toLoginJSONString:logoutDict];
    NSLog(@"requestLogoutUser = %@ \n JSON String = %@",urlString, requestJson);
    
    id serverResponse = [self requestURL:urlString json:requestJson httpMethod:@"POST"];
    NSLog(@"theJSONResult:%@",serverResponse);
    
    UserDetails *logoutData = [jsonReaderObject getLogoutUserData:serverResponse];
    
    return logoutData;
}

- (NSDictionary *)requestForgotPasswordUser:(NSString *)email
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?Email=%@",kServerBaseURLKey, kRequestForgotPasswordISLKey, email];
    NSLog(@"requestForgotPasswordUser URL = %@",urlString);
    
    id serverResponse = [self requestURL:urlString json:nil httpMethod:@"POST"];
    NSLog(@"theJSONResult:%@",serverResponse);
    
    return serverResponse;
}

- (NSDictionary *)requestLoggedProperty:(NSDictionary *)loggedPropertyDict
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kServerBaseURLKey, kRequestLoggedPropertyISLKey];
    NSLog(@"loggedProperty URL = %@",urlString);
    NSData *requestJson = [jsonReaderObject  toLoginJSONString:loggedPropertyDict];
    id serverResponse = [self requestURL:urlString json:requestJson httpMethod:@"POST"];
    NSLog(@"theJSONResult:%@",serverResponse);
    
    return serverResponse;
}

//Get All Events based on properyt ID
- (NSArray *)retrieveAllEventsByProperty:(NSString *)propertyID
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?PropertyID=%@",kServerBaseURLKey, kGetAllEventsISLKey, propertyID];
    NSLog(@"retrieveAllEventsByProperty URL = %@",urlString);
   
    id serverResponse           = [self requestURL:urlString json:nil httpMethod:@"GET"];
    NSMutableArray *eventsList    = [jsonReaderObject getAllEvents:serverResponse];
    
    return eventsList;
}

- (NSArray *)requestPaymentTypeByProperty:(NSString *)propertyID
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?PropertyID=%@",kServerBaseURLKey, kGetPaymentTypeISLKey, propertyID];
    NSLog(@"requestPaymentType URL = %@",urlString);
    
    id serverResponse = [self requestURL:urlString json:nil httpMethod:@"POST"];
    NSMutableArray *paymentTypeList = [jsonReaderObject getPaymentType:serverResponse];
    
    return paymentTypeList;
}

#pragma mark - Connection Methods

- (id )requestURL:(NSString *)url json:(NSData *)requestJsonData httpMethod:(NSString *)method;
{
    id serverResponse = nil;
    NSURL *URL = [NSURL URLWithString:url];
    
    serverResponse = [self ConnectURL:URL postData:requestJsonData httpMethod:method];
    return serverResponse;
}

- (id)ConnectURL:(NSURL *)url postData:(NSData *)postData httpMethod:(NSString *)method
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:300];
    
    //Set the body, method and content type into request
    
    if(postData)
        [urlRequest setHTTPBody:postData];
    
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    NSLog(@"urlData:%@",urlData);
    id serverResponse = nil;
    if(urlData != nil)
    {
        serverResponse = [jsonReaderObject parseJSONData:urlData];
        
    }
    
    return serverResponse;
}

@end
