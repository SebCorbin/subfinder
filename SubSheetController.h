//
//  SubSheetController.h
//  SubFinder
//
//  Created by SebCorbin on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubSource.h"
#import "ServiceProtocol.h"

@interface SubSheetController : NSObject <NSTableViewDataSource> {
    NSMutableArray *subtitles;
    IBOutlet NSPanel *subPanel;
    IBOutlet NSButton *button;
    IBOutlet NSTableView *table;
}

- (IBAction)downloadSubtitle:(id)sender;

- (void)showSubtitles:(NSMutableArray *)array inWindow:(NSWindow *)window;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
