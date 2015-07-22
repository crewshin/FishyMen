//
//  TweetsTableViewController.m
//  FishyMen
//
//  Created by Gene Crucean on 7/21/15.
//  Copyright (c) 2015 Dagger Dev. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "TwitterSearchManager.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <CoreData/CoreData.h>

@interface TweetsTableViewController ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, weak) NSMutableArray *filteredTweetsList;
@property (nonatomic, strong) NSIndexPath *tmpIndexPath;

@end

@implementation TweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup notification observers.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTwitterResponse:) name:NOTI_TWITTER_QUERY_SUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTwitterResponse:) name:NOTI_TWITTER_QUERY_FAILED object:nil];
    
    // Setup long press to save tweets.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPressGesture];
    
    
    // Present a simple how-to save aleartview.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"initialLaunch"])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Long press a tweet to save." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"initialLaunch"];
    }
    
    // Add a progress hud and remove separator lines until loaded.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:true];
    
    // Build query dictionary for search.
    NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject:@"fishermenlabs" forKey:@"q"]; // Query.
    [query setObject:@"mixed" forKey:@"result_type"]; // Response type.
    [query setObject:@50 forKey:@"count"]; // Number of tweets returned. Not sure why this isn't working. Ideas?
    [TwitterSearchManager queryTwitterWith:query];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _tweets.count;
}


#pragma mark - METHODS

// Handles the response from Twitter in TwitterSearchManager.
- (void)handleTwitterResponse:(NSNotification *)noti
{
    // If it's successful, grab userInfo and dumb data into tweets array for UI display.
    if ([noti.name isEqualToString:NOTI_TWITTER_QUERY_SUCCESSFUL]) {
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:true];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        _tweets = [noti.userInfo objectForKey:@"statuses"];
        [self.tableView reloadData];
    }
    
    // If it fails... notify user something ham-jammed.
    if ([noti.name isEqualToString:NOTI_TWITTER_QUERY_FAILED]) {
        NSLog(@"failed");
        
        NSString *message = [noti.userInfo objectForKey:@"status"];
        
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}

#pragma mark - Twitter

// Tap and hold to save tweet.
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // Get location you tapped for indexPath.
        CGPoint location = [sender locationInView:self.tableView];
        _tmpIndexPath = [self.tableView indexPathForRowAtPoint:location];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_tmpIndexPath];
        
        NSString *title = [NSString stringWithFormat:@"Save tweet from %@?", cell.textLabel.text];
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    }
}


// Handle which alert view the user tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If it's YES... then save tweet to CoreData.
    if (buttonIndex == 1)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tweets" inManagedObjectContext:managedObjectContext];
        NSManagedObject *newTweet = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
        
        NSString *username = [[[_tweets objectAtIndex:_tmpIndexPath.row] objectForKey:@"user"] objectForKey:@"screen_name"];
        NSString *text = [[_tweets objectAtIndex:_tmpIndexPath.row] objectForKey:@"text"];
        NSInteger tweetId = [[[_tweets objectAtIndex:_tmpIndexPath.row] objectForKey:@"id"] integerValue];
        
        NSLog(@"%ld", _tmpIndexPath.row);
        NSLog(@"%@ - %@ - %ld", username, text, tweetId);
        
        [newTweet setValue:username forKey:@"username"];
        [newTweet setValue:text forKey:@"text"];
        [newTweet setValue:[NSNumber numberWithInteger:tweetId] forKey:@"tweetId"];
        
        [newTweet.managedObjectContext save:nil];
    }
}



#pragma mark - UITableViewDelegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    NSString *username = [[[_tweets objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *text = [[_tweets objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    cell.textLabel.text = username;
    cell.detailTextLabel.text = text;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}







@end
