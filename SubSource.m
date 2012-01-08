//
//  SubSource.m
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import "SubSource.h"


@implementation SubSource

@synthesize link;
@synthesize hearing;
@synthesize team;
@synthesize sourceClass;
@synthesize originalFile;

- (id)initWithSource:(Class)source link:(NSURL *)aLink file:(SubFile *)aFile team:(NSString *)aTeam
             hearing:(NSNumber *)isHearingImpaired {
    self = [super init];
    if (self) {
        self.sourceClass = [[source copy] autorelease];
        self.link = [[aLink copy] autorelease];
        self.originalFile = [[aFile copy] autorelease];
        self.team = [[aTeam copy] autorelease];
        self.hearing = [isHearingImpaired copy];
    }
    return self;
}

- (void)dealloc {
    [team release];
    [link release];
    [sourceClass release];
    [originalFile release];
    [super dealloc];
}

@end
