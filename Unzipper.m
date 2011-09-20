//
//  Unzipper.m
//  SubFinder
//
//  Created by sebcorbin on 16/05/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import "Unzipper.h"
#import "Logger.h"

@implementation Unzipper

+(BOOL)unzip:(NSURL*)file  andReturn:(NSURL*)srtFile{
	[Logger log:@"Décompression de %@", file];
	
	NSTask *unzip = [[NSTask alloc] init];
	NSPipe *aPipe = [NSPipe pipe];
	[unzip setLaunchPath:@"/usr/bin/unzip"];
	[unzip setStandardOutput:aPipe];
	[unzip setArguments:[NSArray arrayWithObjects: @"-p", [NSString stringWithFormat:@"%@", [file relativePath]], nil]];
	[unzip launch];
	
	NSData *data = [[aPipe fileHandleForReading] readDataToEndOfFile];
	
	NSURL *srtUrl = [NSURL fileURLWithPath:[[[file relativePath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
	NSError *writeError = NULL;
	[data writeToURL:srtUrl options:YES error:&writeError];
	[data release];
	[unzip terminate];
	[unzip release];
	NSFileManager* fm = [[NSFileManager alloc] init];
	if (![fm removeItemAtURL:file error:&writeError] && writeError) {
		[Logger log:@"Erreur lors de la suppression du zip: %@", writeError];
		NSException *e = [NSException exceptionWithName:@"UnzipException" 
												 reason:@"Could not remove zip" userInfo:nil];
		@throw e;
		return FALSE;
	}
	[fm release];
	return TRUE;
}

@end
