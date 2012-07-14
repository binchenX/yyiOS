//
//  Artist.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Artist : NSManagedObject

@property (nonatomic, retain) Album *albums;

@end
