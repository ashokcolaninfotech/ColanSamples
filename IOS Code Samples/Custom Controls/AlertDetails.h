//
//  AlertDetails.h
//  EventParking
//
//  Created by Muthu Rajan on 05/08/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertDetails : NSObject
{
    
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *primaryButtonTitle;
@property (nonatomic, strong) NSString *secondaryButtonTitle;
@property (nonatomic, strong) UIViewController *whichController;
@property int alertTag;

@end
