//
//  SubFile.m
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import "SubFile.h"
#import "SubFileShow.h"
#import "SubFileMovie.h"

@implementation SubFile

@synthesize filename;
@synthesize localUrl;
@synthesize teams;


- (id)initWithLocalUrl:(NSString *)path {
    self = [super init];
    if (self) {
        localUrl = [[[NSURL alloc] initFileURLWithPath:path] retain];
        // Get the filename
        NSError *error;
        NSFileWrapper *file = [[NSFileWrapper alloc] initWithURL:localUrl
                                                         options:NSFileWrapperReadingWithoutMapping error:NULL];
        if (!file) {
            [[NSAlert alertWithError:error] runModal];
        }
        if (![file isRegularFile]) {
            // @TODO Input is a directory
        }
        filename = [[NSString alloc] initWithString:[file filename]];
        [file release];
    }
    return self;
}

- (id)findType {
    // Find out which file type we are processing
    if ([filename isMatchedByRegex:@"(?P<show>.*).S(?P<season>[0-9]{2})E(?P<episode>[0-9]{2}).(?P<teams>.*)"]
            || [filename isMatchedByRegex:@"(?P<show>.*).?(?P<season>[0-9]{1,2})x(?P<episode>[0-9]{1,2}).(?P<teams>.*)"]) {
        // Regexes for shows
        return [[SubFileShow alloc] initWithSubFile:self];
    }
    else if ([filename isMatchedByRegex:@"(?P<movie>.*)[\\.|\\[|\\(| ]{1}(?P<year>(?:(?:19|20)[0-9]{2}))(?P<teams>.*)"]) {
        // Regex for movies
        return [[SubFileMovie alloc] initWithSubFile:self];
    }
    else {
        // @TODO No regex matched
    }
    return nil;
}

- (BOOL)guessFileData {
    // Nothing to do here
    return NO;
}


- (id)copyWithZone:(NSZone *)zone {
    SubFile *subFileCopy = [[SubFile allocWithZone:zone] init];
    subFileCopy.filename = [filename copy];
    subFileCopy.localUrl = [localUrl copy];
    subFileCopy.teams = [teams copy];
    return subFileCopy;
}

- (void)dealloc {
    [filename release];
    [localUrl release];
    [teams release];
    [super dealloc];
}

@end
