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
#import "SubFinderAppDelegate.h"

@implementation SubFile

@synthesize filename;
@synthesize localUrl;
@synthesize teams;


- (id)initWithLocalUrl:(NSString *)path {
    self = [super init];
    if (self) {
        localUrl = [[[[NSURL alloc] initFileURLWithPath:path] autorelease] retain];
        // Get the filename
        NSError *error = NULL;
        NSFileWrapper *file = [[NSFileWrapper alloc] initWithURL:localUrl options:NSFileWrapperReadingWithoutMapping error:&error] ;
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
        return [[[SubFileShow alloc] initWithSubFile:self] autorelease];
    }
    else if ([filename isMatchedByRegex:@"(?P<movie>.*)[\\.|\\[|\\(| ]{1}(?P<year>(?:(?:19|20)[0-9]{2}))(?P<teams>.*)"]) {
        // Regex for movies
        return [[[SubFileMovie alloc] initWithSubFile:self] autorelease];
    }
    else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"UnknownFileType", @"") defaultButton:@"OK"
                                       alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"UnknownFileTypeComment", @"")];
        [alert beginSheetModalForWindow:[[NSApp delegate] serviceWindow] modalDelegate:[NSApp delegate] didEndSelector:@selector(terminateApp:) contextInfo:nil];
    }
    return nil;
}

- (BOOL)guessFileData {
    // Nothing to do here
    return NO;
}


- (id)copyWithZone:(NSZone *)zone {
    SubFile *subFileCopy = [[SubFile allocWithZone:zone] init];
    subFileCopy.filename = [[filename copy] autorelease];
    subFileCopy.localUrl = [[localUrl copy] autorelease];
    subFileCopy.teams = [[teams copy] autorelease];
    return subFileCopy;
}

- (void)dealloc {
    [filename release];
    [localUrl release];
    [super dealloc];
}

@end
