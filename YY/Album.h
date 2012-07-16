//
//  Album.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist;
@interface Album : NSManagedObject

@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) id coverThumbnail;
@property (nonatomic, retain) id coverBig;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * detail; //more about this album
@property (nonatomic, retain) NSString * downloadUrl;
@property (nonatomic, retain) NSString * listenUrl;
@property (nonatomic, retain) Artist *artist;
@end
