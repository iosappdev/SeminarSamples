//
//  FlickrFetcher.h
//
//  Created for Stanford CS193p Fall 2011.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"

#define FLICKR_PLACE_PHOTOCOUNT @"photo_count"

typedef enum {
	FlickrPhotoFormatSquare = 1,
	FlickrPhotoFormatLarge = 2,
	FlickrPhotoFormatOriginal = 64
} FlickrPhotoFormat;

@interface FlickrFetcher : NSObject

/*
    Element: NSDictionary {
        FLICKR_PLACE_NAME = ?
        FLICKR_PLACE_PHOTOCOUNT = ?
        FLICKR_LATITUDE = ?
        FLICKR_LONGITUDE = ?
        FLICKR_PLACE_ID = ?
        woeid
        place_url
        place_type
        place_type_id 
    }
 */
+ (NSArray *)topPlaces; // of NSDictionary (@"places.place")
/*
    farm
    server
    id
    secret
    originalsecret
    originalformat
 */
+ (NSArray *)photosInPlace:(NSDictionary *)place maxResults:(int)maxResults;
+ (NSURL *)urlForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;

@end
