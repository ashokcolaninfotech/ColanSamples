//
//  EventsViewController.m
//  EventParking
//
//  Created by Muthu Rajan on 30/05/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "EventsViewController.h"

@interface EventsViewController ()

@end

@implementation EventsViewController
@synthesize eventsArray;
@synthesize propertyData;

#pragma mark - Loading Methods
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedInEvents:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    b_IsSelectedEvent   = FALSE;
    eventFilterArray    = [[NSMutableArray alloc] init];
    
    if(propertyData)
        [selectedEventLabel setText:propertyData.propertyDesc];
    
    noEventFoundLabel.hidden = TRUE;
    
    [eventsTableView setSeparatorColor:[UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0]];
    eventsTableView.layer.borderWidth = 1.0;
    eventsTableView.layer.cornerRadius = 8.0;
    eventsTableView.layer.borderColor = [UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0].CGColor;
    
    [eventsTableView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    
    [noEventFoundLabel setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    [noEventFoundLabel.layer setCornerRadius:8.0];
    [noEventFoundLabel.layer setBorderWidth:1.0];
    [noEventFoundLabel.layer setBorderColor:[UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0].CGColor];

    
    if([eventsArray count] > 0)
    {
        [eventFilterArray removeAllObjects];
        [eventFilterArray addObjectsFromArray:eventsArray];

        [self setTableViewHeight];
        [eventsTableView reloadData];
    }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self orientationChangedInEvents:nil];
    //[self setTableViewHeight];
    
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Methods

- (IBAction)onEventDone:(id)sender
{
    if(!b_IsSelectedEvent)
    {
        AlertDetails *alertData = [[Utilities sharedUtilitiesInstance] getAlertData:NO Message:@"Please select the events" Type:e_defaultErrorAlert Controller:self];
        [[Utilities sharedUtilitiesInstance] showAlertWithDetails:alertData];
    }
    else
    {
        [self pushRatesViewPage];
    }
}

- (IBAction)goToBackAction:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pushRatesViewPage
{
    EventsDetails *eventObj = [eventFilterArray objectAtIndex:selectedIndexPath];
    if(eventObj)
    {
        RateViewController *rateViewControllerObj = [[RateViewController alloc]initWithNibName:@"RateViewController" bundle:nil];
        rateViewControllerObj.propertyModelObj  = propertyData;
        rateViewControllerObj.eventsModelObj    = eventObj;
        
        [[AppDelegate sharedAppdelegate] setRateViewControllerObj:rateViewControllerObj];
        
        [self.navigationController pushViewController:rateViewControllerObj animated:YES];
    }
}

#pragma  mark - TouchesBegan Delegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [eventSearchTextField resignFirstResponder];
}

#pragma  mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
    [textField resignFirstResponder];
    textField.text = @"";
    [eventFilterArray removeAllObjects];
    [eventFilterArray addObjectsFromArray:eventsArray];
    noEventFoundLabel.hidden = (eventsArray.count == 0) ? NO : YES;
    
    [self setTableViewHeight];
    [eventsTableView reloadData];

    
    return  YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 60, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"" context:@""];
    [UIView animateWithDuration:0.5 animations:nil];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == eventSearchTextField)
    {
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        
        [self searchByEvents:substring];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
    [eventFilterArray removeAllObjects];
    [eventFilterArray addObjectsFromArray:eventsArray];
    noEventFoundLabel.hidden = (eventsArray.count == 0) ? NO : YES;
    
    [self setTableViewHeight];
    [eventsTableView reloadData];
    
    return NO;
}


- (void)searchByEvents:(NSString *)searchStr
{
    if([searchStr length] > 0)
    {
        [eventFilterArray removeAllObjects];
        for (EventsDetails *eventsData in eventsArray)
        {
            NSRange range=[eventsData.eventsDesc rangeOfString:searchStr options:(NSCaseInsensitiveSearch)];
            
            if(range.location != NSNotFound)
                [eventFilterArray addObject:eventsData];
        }
    }else{
        
        [eventFilterArray removeAllObjects];
        [eventFilterArray addObjectsFromArray:eventsArray];
    }
    
    noEventFoundLabel.hidden = (eventFilterArray.count == 0) ? NO : YES;
    
    [self setTableViewHeight];
    [eventsTableView reloadData];
}


#pragma mark - TableView Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [eventFilterArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    ListCell *cell = (ListCell *)[eventsTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ListCell" owner:self options:nil]objectAtIndex:0];
    }
    cell.tag = indexPath.row;
    
    if([eventFilterArray count] > 0)
    {
        EventsDetails   *eventsData     =   [eventFilterArray objectAtIndex:indexPath.row];
        cell.lblTitle.text  =   [eventsData eventsDesc];
        
        if(b_IsSelectedEvent == FALSE)
        {
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
        }else{
            
            if(selectedIndexPath == indexPath.row)
            {
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.0 / 255.0 green:100.0 / 255.0 blue:166.0 / 255.0 alpha:1.0]];
                cell.tickImage.hidden = NO;
                [cell.lblTitle setTextColor:[UIColor whiteColor]];
            }
            else
            {
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
                cell.tickImage.hidden = YES;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([eventFilterArray count] > 0)
    {
        selectedIndexPath = indexPath.row;
        b_IsSelectedEvent        = TRUE;
        
    }
    
    [eventsTableView reloadData];
    [eventSearchTextField resignFirstResponder];
}

-(void)viewDidLayoutSubviews
{
    if ([eventsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [eventsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([eventsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [eventsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setTableViewHeight
{
    float heightSize        = eventFilterArray.count * 44;
    CGPoint tablePoint  = eventsTableView.frame.origin;
    CGSize  tableSize   = eventsTableView.frame.size;
    
    if(IS_IPHONE_4)
    {
        if(heightSize <= 176)
        {
            eventsTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, heightSize);
        }else{
             eventsTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, 176);
        }
    }
    else
    {
        if(heightSize<=264)
        {
            eventsTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, heightSize);
        }
        else
        {
            eventsTableView.frame = CGRectMake(tablePoint.x, tablePoint.y, tableSize.width, 264);
        }
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        
        [eventsTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 132)];
        [scrollBackground setContentSize:CGSizeMake(0, 320)];
        [btnDone setFrame:CGRectMake(btnDone.frame.origin.x, eventsTableView.frame.origin.y + eventsTableView.frame.size.height + 20, btnDone.frame.size.width, btnDone.frame.size.height)];
        
    } else if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        [eventsTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 175)];
        [btnDone setFrame:CGRectMake(btnDone.frame.origin.x,scrollBackground.frame.size.height-75, btnDone.frame.size.width, btnDone.frame.size.height)];
        [scrollBackground setContentSize:CGSizeMake(0, 0)];
    }
}

#pragma mark - Orientation Method

- (void)orientationChangedInEvents:(NSNotification *)notification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"LandScape" forKey:@"Orientation"];
        NSLog(@"LandScape");
        
        [self orientationWithLandScape];
    }
    else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown || orientation == UIDeviceOrientationUnknown)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"Portrait" forKey:@"Orientation"];
        NSLog(@"Portrait");
        
        [self orientationWithPortrait];
    }
    else
    {
        orientationStatus = [[NSUserDefaults standardUserDefaults]valueForKey:@"Orientation"];
        
        if ([orientationStatus isEqualToString:@"LandScape"]) {
            NSLog(@"FaceUp - LandScape");
            
            [self orientationWithLandScape];
            
        } else if ([orientationStatus isEqualToString:@"Portrait"]) {
            NSLog(@"FaceUp - Portrait");
            
            [self orientationWithPortrait];
        }
    }
}

- (void)orientationWithPortrait
{
    [eventsTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 175)];
    [btnDone setFrame:CGRectMake(btnDone.frame.origin.x,scrollBackground.frame.size.height-75, btnDone.frame.size.width, btnDone.frame.size.height)];
    [scrollBackground setContentSize:CGSizeMake(0, 0)];
}

- (void)orientationWithLandScape
{
    [eventsTableView setFrame:CGRectMake(imageSearchField.frame.origin.x, imageSearchField.frame.origin.y + imageSearchField.frame.size.height + 10, imageSearchField.frame.size.width, 132)];
    [scrollBackground setContentSize:CGSizeMake(0, 320)];
    [btnDone setFrame:CGRectMake(btnDone.frame.origin.x, eventsTableView.frame.origin.y + eventsTableView.frame.size.height + 20, btnDone.frame.size.width, btnDone.frame.size.height)];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
