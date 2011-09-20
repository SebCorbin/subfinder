//
//  Unzipper.h
//  SubFinder
//
//  Created by sebcorbin on 16/05/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Unzipper : NSObject {
	
}

+(BOOL)unzip:(NSURL*)file andReturn:(NSURL*)srtFile;

@end
