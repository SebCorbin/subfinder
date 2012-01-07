//
//  SubSource.h
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubFile.h"

@interface SubSource : NSObject {
    Class sourceClass;
    NSURL *link;
    SubFile *originalFile;

    // @TODO transform following properties into a NSDictionary to make them optional
    NSString *team;
    NSNumber *hearing;
}

@property(nonatomic, retain) Class sourceClass;
@property(nonatomic, retain) NSURL *link;
@property(nonatomic, retain) NSString *team;
@property(nonatomic, retain) NSNumber *hearing;
@property(nonatomic, retain) SubFile *originalFile;


- (id)initWithSource:(Class)source link:(NSURL *)aLink file:(SubFile *)aFile team:(NSString *)aTeam
             hearing:(NSNumber *)isHearingImpaired;

- (id)initWithSource:(Class)source link:(id)aLink file:(id)aFile hearing:(NSNumber)isHearingImpaired;

@end
