//
//  SavedTweetsTableViewController.m
//  FishyMen
//
//  Created by Gene Crucean on 7/21/15.
//  Copyright (c) 2015 Dagger Dev. All rights reserved.
//

#import "SavedTweetsTableViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface SavedTweetsTableViewController ()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSArray *tweetManagedObjects;
@property (nonatomic, weak) NSIndexPath *tmpIndexPath;


@end

@implementation SavedTweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tweets = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Fetch and load current data.
    [self fetch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_tweets.count == 0) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"zeroTweetsMessageViewed"]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"There are zero saved tweets" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"zeroTweetsMessageViewed"];
        }
        
    }
    
    return _tweets.count;
}


#pragma mark - METHODS

// Fetch stored data from CoreData.
- (void)fetch
{
    // Lets start fresh eh?
    [_tweets removeAllObjects];
    
    // Fetch some saved tweeties.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweets" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    _tweetManagedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"Fetch failed. Dum dum dummmmmmm");
        NSLog(@"%@", error.localizedDescription);
        
    }
    else
    {
        for (NSManagedObject *tweet in _tweetManagedObjects)
        {
            // Save a dictionary and store in an array for use on this view controller.
            NSDictionary *tmp = @{@"username":[tweet valueForKey:@"username"], @"text": [tweet valueForKey:@"text"], @"tweetId": [tweet valueForKey:@"tweetId"]};
            
            [_tweets addObject:tmp];
        }
        
        [self.tableView reloadData];
    }
}

// Handle which alert view the user tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Delete tweet.
    if (buttonIndex == 1)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        NSManagedObject *tweet = [_tweetManagedObjects objectAtIndex:_tmpIndexPath.row];
        
        [managedObjectContext deleteObject:tweet];
        [_tweets removeObjectAtIndex:_tmpIndexPath.row];
        
        NSError *error = nil;
        
        if (![tweet.managedObjectContext save:&error])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            NSLog(@"%@", error.localizedDescription);
        }
        
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedTweetCell" forIndexPath:indexPath];
    
    NSString *username = [[_tweets objectAtIndex:indexPath.row] objectForKey:@"username"];
    NSString *text = [[_tweets objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    cell.textLabel.text = username;
    cell.detailTextLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    _tmpIndexPath = indexPath;
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this tweet?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}



@end
