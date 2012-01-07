//
//  Created by sebastien on 29/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class SubSource;

@protocol ServiceProtocol

/**
 * file : SubFileShow or SubFileMovie
 * return an array of SubSource
 */
- (NSMutableArray *)searchSubtitlesForSubFile:(id)file;

/**
 * Actually creates the srt file
 */
+ (void)downloadSubtitleForSource:(SubSource *)source;

/**
 * If the service handles movie subtitles
 */
+ (BOOL)handlesMovies;

/**
 * If the service handles show subtitles
 */
+ (BOOL)handlesShows;

/**
 * Returns an array of language codes handled by the service
 */
+ (NSArray *)handleLanguages;

/**
 * Returns the name of the service
 */
+ (NSString *)serviceName;

/**
 * Returns the URL of the service
 */
+ (NSString *)serviceHost;


@end