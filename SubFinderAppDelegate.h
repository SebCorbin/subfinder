//
//  SubFinderAppDelegate.h
//  SubFinder
//
//  Created by SebCorbin on 10/03/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

// Frameworks and utilities
#import <Cocoa/Cocoa.h>
#import <RegexKit/RegexKit.h>
#import "HTMLParser.h"

#import "Logger.h"
#import "SubFile.h"
#import "SubSheetController.h"

// Services
#import "Addic7edService.h"
#import "BetaseriesService.h"
#import "SubsceneService.h"
#import "ServicesController.h"

@class SubSheetController;

@interface HTMLNode (HTMLNodeAdditions)

- (HTMLNode *)nextNode;

@end


@interface SubFinderAppDelegate : NSObject <NSApplicationDelegate, NSComboBoxDataSource> {
    IBOutlet NSWindow *serviceWindow;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *progressLabel;
    IBOutlet NSButton *okButton;

    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSComboBox *languagesComboBox;
    IBOutlet NSBox *servicesBox;

    IBOutlet SubSheetController *subSheet;
}

@property(nonatomic, retain) NSWindow *serviceWindow;

- (IBAction)terminateApp:(id)sender;

- (void)initializePreferences;

- (IBAction)filterServicesForLanguage:(id)sender;

- (void)setHyperLink:(NSTextField *)inTextField label:(NSString *)label stringURL:(NSString *)stringURL;

- (int)processPath:(NSString *)path filesNumber:(int *)filesToFind;

- (BOOL)processFile:(NSString *)path;

- (void)findSubtitle:(NSPasteboard *)pb userData:(NSString *)userData error:(NSString **)error;

@end
