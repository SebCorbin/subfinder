//
//  Logger.h
//  SubFinder
//
//  Created by sebcorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// This variable is global as we need to access it in log:
IBOutlet NSTextView *logText;

@interface Logger : NSObject {
	NSPanel *logPanel;
}

-(IBAction)toggleLog:(id)sender;

+(void) log:(NSString*) format, ...;

@property (assign) IBOutlet NSPanel *logPanel;

@end
