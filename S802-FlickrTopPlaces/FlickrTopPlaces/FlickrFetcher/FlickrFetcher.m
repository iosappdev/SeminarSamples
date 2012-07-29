//
//  FlickrFetcher.m
//
//  Created for Stanford CS193p Fall 2011.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "FlickrFetcher.h"
#import "FlickrAPIKey.h"

#define FLICKR_PLACE_ID @"place_id"

@implementation FlickrFetcher


+ (NSDictionary *)executeFlickrFetch:(NSString *)query
{
    // 1. URL 구성 (parameter 조합)
    // 2. URL에서 다운로드
    // 3. JSON에서 Foundation object로 변환 -> NSDictionary
    query = [NSString stringWithFormat:@"%@&format=json&nojsoncallback=1&api_key=%@", query, FlickrAPIKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] 
                                                 encoding:NSUTF8StringEncoding 
                                                    error:nil] 
                        dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    return results;
}

+ (NSArray *)recentGeoreferencedPhotos
{
    NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&per_page=500&license=1,2,4,7&has_geo=1&extras=original_format,tags,description,geo,date_upload,owner_name,place_url"];
    return [[self executeFlickrFetch:request] valueForKeyPath:@"photos.photo"];
}

+ (NSArray *)topPlaces
{
    // http://www.flickr.com/services/api/flickr.places.getTopPlacesList.html
    // API : flickr.places.getTopPlacesList
    NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.places.getTopPlacesList&place_type_id=7"];
    NSDictionary *result = [self executeFlickrFetch:request];
    // {stat=? places=?}
    for( id key in result.allKeys ) {
        NSLog(@"key:%@", [key description]);
    }
    return [result valueForKeyPath:@"places.place"];
}

+ (NSArray *)photosInPlace:(NSDictionary *)place maxResults:(int)maxResults
{
    // http://www.flickr.com/services/api/flickr.photos.search.html
    // API Method: flickr.photos.search
    //      place_id=<places.place.place_id>
    //      per_page=<maxResult>
    NSString *placeId = [place objectForKey:FLICKR_PLACE_ID];
    if (placeId) {
        NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&has_geo=1&place_id=%@&per_page=%d&extras=original_format,tags,description,geo,date_upload,owner_name,place_url", placeId, maxResults];
        /*
         Example Response:
         <photos page="2" pages="89" perpage="10" total="881">
             <photo id="2636" owner="47058503995@N01" secret="a123456" server="2" title="test_04" ispublic="1" isfriend="0" isfamily="0" />
             <photo id="2635" owner="47058503995@N01"
             secret="b123456" server="2" title="test_03"
             ispublic="0" isfriend="1" isfamily="1" />
             <photo id="2633" owner="47058503995@N01"
             secret="c123456" server="2" title="test_01"
             ispublic="1" isfriend="0" isfamily="0" />
             <photo id="2610" owner="12037949754@N01"
             secret="d123456" server="2" title="00_tall"
             ispublic="1" isfriend="0" isfamily="0" />
         </photos>         
         */
        return [[self executeFlickrFetch:request] valueForKeyPath:@"photos.photo"];
    }
    return nil;
}

+ (NSString *)urlStringForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
	id farm = [photo objectForKey:@"farm"];
	id server = [photo objectForKey:@"server"];
	id photo_id = [photo objectForKey:@"id"];
	id secret = [photo objectForKey:@"secret"];
	if (format == FlickrPhotoFormatOriginal) secret = [photo objectForKey:@"originalsecret"];
    
	NSString *fileType = @"jpg";
	if (format == FlickrPhotoFormatOriginal) fileType = [photo objectForKey:@"originalformat"];
	
	if (!farm || !server || !photo_id || !secret) return nil;
	
	NSString *formatString = @"s";
	switch (format) {
		case FlickrPhotoFormatSquare:    formatString = @"s"; break;
		case FlickrPhotoFormatLarge:     formatString = @"b"; break;
		// case FlickrPhotoFormatThumbnail: formatString = @"t"; break;
		// case FlickrPhotoFormatSmall:     formatString = @"m"; break;
		// case FlickrPhotoFormatMedium500: formatString = @"-"; break;
		// case FlickrPhotoFormatMedium640: formatString = @"z"; break;
		case FlickrPhotoFormatOriginal:  formatString = @"o"; break;
	}
    // http://www.flickr.com/services/api/misc.urls.html
    // Old URL format: http://farm{farm-id}.static.flickr.com/...
    // New URL format: http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
    //                  http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
	return [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_%@.%@", farm, server, photo_id, secret, formatString, fileType];
}

+ (NSURL *)urlForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
    return [NSURL URLWithString:[self urlStringForPhoto:photo format:format]];
}

@end
