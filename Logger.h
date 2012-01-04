//
//  Logger.h
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Logger : NSObject {
	NSPanel *logPanel;
    NSTextView *logText;
}

// IBActions
-(IBAction)toggleLog:(id)sender;

// Methods
+(Logger *) sharedLogger;
+(void) log:(NSString*) format, ...;

@property (retain) IBOutlet NSPanel *logPanel;
@property (retain) IBOutlet NSTextView *logText;

@end
