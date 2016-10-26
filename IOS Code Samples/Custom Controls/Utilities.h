//
//  Utilities.h
//  EventParking
//
//  Created by Muthu Rajan on 05/08/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlertDetails.h"

@interface Utilities : NSObject <UIAlertViewDelegate>
{
    AlertDetails *currentAlertObj;
    
    
}

@property (nonatomic, strong) UIAlertView *appAlertView;
@property (nonatomic, strong) UIAlertController *appAlertController;

+ (id)sharedUtilitiesInstance;

- (AlertDetails *)getAlertData:(BOOL)status Message:(NSString *)message Type:(ALERT_TYPE)alertType Controller:(UIViewController *)controller;
- (void)showAlertWithDetails:(AlertDetails *)alertData;

-(BOOL)isAlertControllerPresented;
- (BOOL)isAlertVisible;


@end
