//
//  SubFile.h
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RegexKit/RegexKit.h>

@interface SubFile : NSObject {
    NSString *filename;
    NSURL *localUrl;
    NSArray *teams;
}

@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSURL *localUrl;
@property(nonatomic, retain) NSArray *teams;


- (id)initWithLocalUrl:(NSString *)path;

- (id)findType;

- (void)guessFileData;

@end
