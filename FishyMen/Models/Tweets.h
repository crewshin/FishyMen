//
//  Tweets.h
//  
//
//  Created by Gene Crucean on 7/22/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweets : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * tweetId;

@end
