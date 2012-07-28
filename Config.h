//
//  Config.h
//  YY
//
//  Created by Pierr Chen on 12-7-28.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Config : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdateTime;
@property (nonatomic, retain) NSNumber * isFreshInstall;

@end
