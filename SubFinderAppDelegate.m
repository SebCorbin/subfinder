//
//  SubFinderAppDelegate.m
//  SubFinder
//
//  Created by SebCorbin on 10/03/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import "SubFinderAppDelegate.h"

@implementation SubFinderAppDelegate

/**
 * On Nib display
 */
@synthesize serviceWindow;

- (void)awakeFromNib {
    [Logger log:@"Nib initialized"];
    [preferencesWindow center];
    [self initializePreferences];
}

/**
 * When loaded
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Logger log:@"Application initialized"];
    // Registering service
    [NSApp setServicesProvider:self];
}

/**
 * Helper method : process a file
 */
- (BOOL)processFilePath:(NSString *)path {
    id file = [[[[SubFile alloc] initWithLocalUrl:path] findType] autorelease];
    if (![file guessFileData]) {
        [Logger log:@"Could not guess file data"];
        return NO;
    }

    if ([[ServicesController chosenServices] count] == 0) {
        [Logger log:@"No service chosen"];
        // @TODO Alert when no service chosen
    }

    NSMutableArray *subtitles = [NSMutableArray array];
    for (NSString *serviceName in [ServicesController chosenServices]) {
        id service = [[NSClassFromString([serviceName stringByAppendingString:@"Service"]) alloc] init];
        id serviceClass = [service class];
        if ([file class] == NSClassFromString(@"SubFileShow") && [serviceClass handlesShows] ||
                [file class] == NSClassFromString(@"SubFileMovie") && [serviceClass handlesMovies]) {
            // Query each service chosen
            [Logger log:@"Querying %@", serviceName];
            [subtitles addObjectsFromArray:[service searchSubtitlesForSubFile:file]];
        }
    }

    if ([subtitles count]) {
        [subSheet showSubtitles:subtitles inWindow:serviceWindow];
        return YES;
    }
    return NO;
}

/**
 * Service : find a subtitle
 */
- (void)findSubtitle:(NSPasteboard *)pBoard userData:(NSString *)userData error:(NSString **)error {
    // Window behaviour
    [preferencesWindow close];
    [serviceWindow center];
    [serviceWindow makeKeyAndOrderFront:nil];

    NSString *msgServiceStarted = NSLocalizedString(@"Service started", @"ServiceStarted");
    [Logger log:msgServiceStarted];
    [progressLabel setStringValue:msgServiceStarted];
    [progressIndicator startAnimation:nil];

    NSArray *types = [pBoard types];
    if ([types containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pBoard propertyListForType:NSFilenamesPboardType];
        int filesFound = 0;
        for (NSString *path in files) {
            // Here the file is a local URL
            [Logger log:@"Searching subtitles for %@", path];
            if ([self processFilePath:path]) {
                filesFound++;
            }
        }
        if ([files count] == filesFound &&
                [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"CloseOnSuccess"]) {
            [NSApp terminate:nil];
        }
        else {
            // Some subtitles were not found, notify user
            NSString *msgSubsNotFound = [NSString stringWithFormat:NSLocalizedString(@"%d subtitle(s) not found", @"MsgSubsNotFound"),
                                                                   [files count] - filesFound];
            [Logger log:msgSubsNotFound];
            [progressLabel setStringValue:msgSubsNotFound];
            [progressIndicator setHidden:YES];
        }
    }
}

/**
 * Preferences initialization
 */
- (void)initializePreferences {
    [languagesComboBox setDataSource:self];
    id langValue = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:@"Language"];
    [languagesComboBox selectItemAtIndex:[[[ServicesController languagesForServices] allValues] indexOfObject:langValue]];
    [languagesComboBox sendAction:@selector(filterServicesForLanguage:) to:self];
}

- (IBAction)filterServicesForLanguage:(id)sender {
    // Get current language
    NSString *langSelected = [[[ServicesController languagesForServices] allKeys]
            objectAtIndex:[sender indexOfSelectedItem]];

    // Get services that handle language
    NSArray *servicesForLanguage = [ServicesController getServicesForLanguage:langSelected];
    int elementHeight = 20, expandHeight = [servicesForLanguage count] * elementHeight;
    int y = 10;

    // Remove all elements first
    NSView *subview;
    while ((subview = [[[servicesBox contentView] subviews] lastObject]) != nil) {
        [subview removeFromSuperview];
    }

    // Resizing Window
    NSRect frame = [preferencesWindow frame];
    frame.origin.y = 464 - expandHeight;
    frame.size.height = 160 + expandHeight;
    [preferencesWindow setFrame:frame display:YES animate:YES];

    for (id service in servicesForLanguage) {
        // Create elements
        // First, the checkbox
        NSButton *checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(14, y, 22, 18)];
        [checkBox setButtonType:NSSwitchButton];
        [checkBox setTitle:nil];
        [servicesBox addSubview:checkBox];
        [checkBox bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController]
           withKeyPath:[@"values.Services." stringByAppendingString:[service serviceName]]
               options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                   forKey:@"NSContinuouslyUpdatesValue"]];

        // Then the service name
        NSTextField *nameText = [[NSTextField alloc] initWithFrame:NSMakeRect(32, y - 1, 150, 18)];
        [nameText setStringValue:[service serviceName]];
        [nameText setBezeled:NO];
        [nameText setDrawsBackground:NO];
        [nameText setEditable:NO];
        [servicesBox addSubview:nameText];

        // Then the link to the service
        NSTextField *linkText = [[NSTextField alloc] initWithFrame:NSMakeRect(182, y - 1, 230, 18)];
        [self setHyperLink:linkText
                     label:[[service serviceHost] stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                 stringURL:[service serviceHost]];
        [linkText setBezeled:NO];
        [linkText setDrawsBackground:NO];
        [linkText setEditable:NO];
        [linkText setFont:[NSFont userFontOfSize:12]];
        [servicesBox addSubview:linkText];

        y += elementHeight;
    }
}


/**
 * Create hyperlink
 */
- (void)setHyperLink:(NSTextField *)inTextField label:(NSString *)label stringURL:(NSString *)stringURL {
    // both are needed, otherwise hyperlink won't accept mouseDown
    [inTextField setAllowsEditingTextAttributes:YES];
    [inTextField setSelectable:YES];

    NSURL *url = [NSURL URLWithString:stringURL];
    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:label] autorelease];
    NSRange range = NSMakeRange(0, [attrString length]);
    [attrString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            [url absoluteString], NSLinkAttributeName,
            [NSColor blueColor], NSForegroundColorAttributeName,
            [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
            nil]        range:range];
    [attrString setAlignment:NSRightTextAlignment range:range];
    [inTextField setAttributedStringValue:attrString];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

/**
 * Events
 */
- (IBAction)terminateApp:(id)sender {
    [NSApp terminate:nil];
}


- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [[[ServicesController languagesForServices] allKeys] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    return [[ServicesController languagesForServices] objectForKey:
            [[[ServicesController languagesForServices] allKeys] objectAtIndex:index]];
}

- (void)dealloc {
    [serviceWindow release];
    [super dealloc];
}

@end

@implementation HTMLNode (HTMLNodeAdditions)

- (HTMLNode *)nextNode {
    return [[[HTMLNode alloc] initWithXMLNode:_node->next] autorelease];
}

@end
