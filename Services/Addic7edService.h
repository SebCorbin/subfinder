//
//  Created by sebastien on 29/12/11.
//


#import <Foundation/Foundation.h>
#import <RegexKit/RegexKit.h>
#import "../ServiceProtocol.h"
#import "SubFileShow.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface Addic7edService : NSObject <ServiceProtocol> {

}

+ (NSString *)releasePattern;

- (NSMutableArray *)searchSubtitlesForSubFile:(id)file;

+ (NSString *)getLanguageFromKey:(NSString *)key;


@end