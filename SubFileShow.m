//
//  Created by sebastien on 26/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SubFileShow.h"

@implementation SubFileShow

@synthesize show;
@synthesize season;
@synthesize episode;


- (id)initWithSubFile:(SubFile *)subFile {
    self = [super init];
    if (self) {
        localUrl = [[subFile localUrl] copy];
        filename = [[subFile filename] copy];
    }

    return self;
}

- (BOOL)guessFileData {
    NSString *strTeams = nil;
    if (![filename getCapturesWithRegexAndReferences:@"(?P<show>.*).S(?P<season>[0-9]{2})E(?P<episode>[0-9]{2}).(?P<strTeams>.*)",
                                                     @"${show}", &show, @"${season}", &season, @"${episode}", &episode,
                                                     @"${strTeams}", &strTeams, nil]) {
        if (![filename getCapturesWithRegexAndReferences:@"(?P<show>.*).?(?P<season>[0-9]{1,2})x(?P<episode>[0-9]{1,2}).(?P<strTeams>.*)",
                                                         @"${show}", &show, @"${season}", &season, @"${episode}", &episode,
                                                         @"${strTeams}", &strTeams, nil]) {
            return NO;
        }
    }
    show =[[[show stringByReplacingOccurrencesOfString:@"." withString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] autorelease];
    teams = [[strTeams componentsSeparatedByString:@"."] autorelease];
    return YES;
}

- (void)dealloc {
    [show release];
    [super dealloc];
}

@end