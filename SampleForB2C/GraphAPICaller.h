//
//  GraphAPICaller.h
//  SampleForB2C
//
//  Created by Brandon Werner on 7/25/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import "Task.h"
#import <Foundation/Foundation.h>

@interface GraphAPICaller : NSObject <NSURLConnectionDataDelegate>

+ (void)addTask:(Task *)task
completionBlock:(void (^)(bool, NSError *error))completionBlock;

+ (void)getTaskList:(void (^)(NSMutableArray *, NSError *error))completionBlock;

@end
