//
//  Created by sebastien on 29/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class SubSource;

@protocol ServiceProtocol

- (NSMutableArray *)searchSubtitlesForSubFile:(id)file;

+ (void)downloadSubtitleForSource:(SubSource *)source;

+ (BOOL)handlesMovies;

+ (BOOL)handlesShows;

+ (NSArray *)handleLanguages;

+ (NSString *)serviceName;

+ (NSString *)serviceHost;


@end