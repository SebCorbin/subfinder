//
//  Created by sebastien on 07/01/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ServiceProtocol.h"
#import "HTMLParser.h"
#import "SubFileMovie.h"

@interface SubsceneService : NSObject <ServiceProtocol> {

}

+ (NSString *)getFullLanguageName:(NSString *)lang;


@end