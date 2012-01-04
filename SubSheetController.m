//
//  SubSheetController.m
//  SubFinder
//
//  Created by sebcorbin on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubSheetController.h";

@implementation SubSheetController


- (IBAction)downloadSubtitle:(id)sender {
    // Get current selected subtitle
    SubSource *subSource = [subtitles objectAtIndex:[table selectedRow]];
    [[subSource sourceClass] downloadSubtitleForSource:subSource];
    [NSApp endSheet:subPanel];
    [subPanel orderOut:nil];
    [NSApp stopModal];
}

- (void)showSubtitles:(NSMutableArray *)array inWindow:(NSWindow *)window {
    subtitles = [array copy];
    [table setDataSource:self];
    [table reloadData];
    [table setTarget:self];
    [table setDoubleAction:@selector(downloadSubtitle:)];
    [NSApp beginSheet:subPanel modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];
    [NSApp runModalForWindow:subPanel];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [subtitles count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    SubSource *subSource = [subtitles objectAtIndex:rowIndex];
    if ([[tableColumn identifier] isEqualTo:@"team"]) {
        return [subSource team];
    }
    else if ([[tableColumn identifier] isEqualTo:@"hearing"]) {
        if ([subSource hearing] == nil) {
            return @"?";
        }
        else {
            return [[subSource hearing] boolValue] ? @"Yes" : @"No";
        }
    }
    else {
        return [[subSource sourceClass] serviceName];
    }
}

- (void)dealloc {
    [table release];
    [button release];
    [subPanel release];
    [subtitles release];
    [super dealloc];
}

@end
