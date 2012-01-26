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

- (BOOL)guessFileData {
    NSString *strTeams, *strYear;
    if (![filename getCapturesWithRegexAndReferences:@"(?P<movie>.*)[\\.|\\[|\\(| ]{1}(?P<strYear>(?:(?:19|20)[0-9]{2}))[\\.|\\]|\\)| ]{1}(?P<strTeams>.*)",
                                                     @"${movie}", &movie, @"${strYear}", &strYear, @"${strTeams}", &strTeams, nil]) {
        return NO;
    }
    year = [strYear integerValue];
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
    return YES;
}

- (void)dealloc {
    [movie release];
    [super dealloc];
}


@end