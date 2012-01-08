//
//  Created by sebastien on 26/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SubFileMovie.h"

@implementation SubFileMovie

@synthesize movie;
@synthesize year;
@synthesize part;


- (id)initWithSubFile:(SubFile *)subFile {
    self = [super init];
    if (self) {
        localUrl = [[subFile localUrl] copy];
        filename = [[subFile filename] copy];
        part = 0;
    }

    return self;
}

- (void)guessFileData {
    NSString *strTeams;
    [filename getCapturesWithRegexAndReferences:@"(?P<movie>.*)[\\.|\\[|\\(| ]{1}(?P<year>(?:(?:19|20)[0-9]{2}))[\\.|\\[|\\(| ]{1}(?P<strTeams>.*)",
                                                @"${movie}", &movie, @"${year}", &year, @"${strTeams}", &strTeams, nil];
    movie = [[movie stringByReplacingOccurrencesOfString:@"." withString:@" "]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *dirtyTeams = [NSMutableArray arrayWithArray:[strTeams componentsSeparatedByCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@". -"]]];
    if ([dirtyTeams containsObjectMatchingRegex:@"cd1"]) {
        part = 1;
        [dirtyTeams removeObjectsMatchingRegex:@"cd1"];
    }
    if ([teams containsObjectMatchingRegex:@"cd2"]) {
        part = 2;
        [dirtyTeams removeObjectsMatchingRegex:@"cd2"];
    }
    teams = [NSArray arrayWithArray:dirtyTeams];
}

- (void)dealloc {
    [movie release];
    [super dealloc];
}


@end