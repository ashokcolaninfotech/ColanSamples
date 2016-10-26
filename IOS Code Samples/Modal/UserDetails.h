//
//  UserDetails.h
//  EventParking
//
//  Created by Muthu Rajan on 28/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetails : NSObject

@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *userNo;
@property (nonatomic, retain) NSString *propertyID;
@property (nonatomic, retain) NSString *tennentID;
@property (nonatomic, retain) NSString *userNameStr;
@property (nonatomic, retain) NSString *userLoggedInId;
@property  BOOL isValidUser;

@end
