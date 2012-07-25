//
//  Album.m
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "Album.h"
#import "Artist.h"
#import "UIImageToDataTransformer.h"


@implementation Album

@dynamic releaseDate;
@dynamic coverThumbnail;
@dynamic coverBig;
@dynamic title;
@dynamic artist;
@dynamic listenUrl;
@dynamic downloadUrl;
@dynamic detail;
@dynamic coverThumbnailUrl;
@dynamic coverBigUrl;
@dynamic rating;
@dynamic detailUrl;


+ (void)initialize {
	if (self == [Album class]) {
		UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
	}
}

@end
