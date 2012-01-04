//
//  Logger.m
//  SubFinder
//
//  Created by SebCorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import "Logger.h"

@implementation Logger

@synthesize logPanel;
@synthesize logText;

static Logger *loggerInstance = nil;

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (loggerInstance == nil) {
            loggerInstance = [super allocWithZone:zone];
            return loggerInstance;
        }
    }

    return nil;
}

+ (Logger *)sharedLogger {
    @synchronized (self) {
        if (loggerInstance == nil) {
            [[self alloc] init];
        }
    }

    return loggerInstance;
}

+ (void)log:(NSString *)format, ... {
    // Static formatter for optimisation
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    NSString *date = [dateFormatter stringFromDate:[[[NSDate alloc] init] autorelease]];
    va_list ap;
    va_start(ap, format);
    NSString *str = [[[NSString alloc] initWithFormat:format arguments:ap] autorelease];
    NSLog(str, nil); // logs into system.log
    va_end(ap);
    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] init] initWithString:[NSString stringWithFormat:@"[%@] %@ \n", date, str]];
    NSRange range = NSMakeRange(0, [attrStr length]);
    [attrStr addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:range];
    [[[loggerInstance logText] textStorage] appendAttributedString:attrStr];
}

- (IBAction)toggleLog:(id)sender {
    if ([logPanel isKeyWindow]) {
        [logPanel close];
    }
    else {
        [logPanel makeKeyAndOrderFront:nil];
    }
}

@end
