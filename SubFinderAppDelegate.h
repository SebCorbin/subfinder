//
//  SubFinderAppDelegate.h
//  SubFinder
//
//  Created by sebcorbin on 10/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (MyOwnAdditions)

-(NSString *) urlencode ;

@end


@interface SubFinderAppDelegate : NSObject <NSApplicationDelegate> {
	NSUserDefaults *preferences;

    NSWindow *serviceWindow;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	IBOutlet NSButton *okButton;
	
    NSWindow *preferencesWindow;	
	IBOutlet NSButton *renameFileCheckbox;
	IBOutlet NSComboBox *languageComboBox;
	IBOutlet NSTextField *addic7edLabel;
	IBOutlet NSTextField *betaseriesLabel;
	IBOutlet NSButton *addic7edCheckbox;
	IBOutlet NSButton *betaseriesCheckbox;
	IBOutlet NSButton *closeOnFoundCheckbox;
}

-(IBAction)renameFileChecked:(id)sender;
-(IBAction)languageChanged:(id)sender;
-(IBAction)addic7edChecked:(id)sender;
-(IBAction)betaseriesChecked:(id)sender;
-(IBAction)closeOnFoundChecked:(id)sender;

-(IBAction)okPressed:(id)sender;

-(void)initializePreferences;
-(void)setHyperLink:(NSTextField*)inTextField withLabel:(NSString*)label withStringURL:(NSString*)stringUrl;
-(void)findSubtitle:(NSPasteboard *)pb userData:(NSString *)userData error:(NSString **)error;
-(BOOL)findSubtitleForFile:(NSString*)filepath;
-(BOOL)getAddic7edSubtitles:(NSString*)name inPath:(NSString *)path;
-(BOOL)getBetaseriesSubtitles:(NSString*)name inPath:(NSString*)path;
-(NSString *)findSubtitleUrlInHTML:(NSString *)htmlCode withTeams:(NSString *)teams;
-(NSString *)cleanShowName:(NSString *)show;

-(NSString *)betaseriesRequest:(NSString *)url searchForTag:(NSString *)tag;

@property (assign) IBOutlet NSWindow *preferencesWindow;
@property (assign) IBOutlet NSWindow *serviceWindow;

@end
