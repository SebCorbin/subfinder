//
//  BetaseriesService.m
//  SubFinder
//
//  Created by sebcorbin on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BetaseriesService.h";
#import "HTMLParser.h"
#import "SubSource.h"

@implementation BetaseriesService

+ (NSString *)serviceName {
    return @"Betaseries";
}

+ (NSString *)serviceHost {
    return @"http://www.betaseries.com";
}


- (NSMutableArray *)searchSubtitlesForSubFile:(id)file {
    // Initialization
    file = (SubFileShow *) file;
    NSMutableArray *subtitles = [[NSMutableArray array] autorelease];

    // @TODO : handle languages
    NSString *language = @"VO";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/subtitles/show.xml?file=%@&key=%@&language=%@",
                                                                 @"http://api.betaseries.com",
                                                                 [file filename],
                                                                 @"01d9224c4fd8", // API Key for BetaSeries
                                                                 language]];
    /*
    NSError **error = nil;
    HTMLNode *doc = [[HTMLParser alloc] initWithContentsOfURL:url error:error];
    for (HTMLNode *subtitle in [doc findChildTags:@"subtitle"]) {
        //if(subtitle fin)
    }
    */
    return subtitles;
}

+ (NSString *)getContentsFromURL:(NSURL *)url {
    NSURLRequest *query = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
    if (!response) {
        // @TODO Connection failed
    }
    else {
        // HTTP Status code must be 200
        int statusCode = [(NSHTTPURLResponse *) response statusCode];
        if (statusCode == 404) {
            // @TODO Handle 404
        }
        else if (statusCode == 200) {
            return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return nil;
}


+ (void)downloadSubtitleForSource:(SubSource *)source {
    /*
    NSURLRequest *query = [NSURLRequest requestWithURL:[NSURL URLWithString:[source link]]
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];

        // Unzip
        if ([[response MIMEType] isEqualToString:@"application/zip"]) {
            NSURL *zipUrl = [NSURL fileURLWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[response suggestedFilename]]];
            NSError *writeError;
            if (![data writeToURL:zipUrl atomically:YES]) {
                // Error creating zip
            }

            NSTask *unzip = [[NSTask alloc] init];
            NSPipe *zipPipe = [NSPipe pipe];
            [unzip setLaunchPath:@"/usr/bin/unzip"];
            [unzip setStandardOutput:zipPipe];
            [unzip setArguments:[NSArray arrayWithObjects:@"-p", [NSString stringWithFormat:@"%@", [zipUrl relativePath]], nil]];
            [unzip launch];

            NSData *zipData = [[zipPipe fileHandleForReading] readDataToEndOfFile];

            NSURL *srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
            [zipData writeToURL:srtUrl options:YES error:&writeError];
            [unzip waitUntilExit];
            [unzip release];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm removeItemAtURL:zipUrl error:NULL]) {
                // error deleting
            }
            else {
                // successfully deleted
            }
            [fm release];
        }
        else {
            NSError *writeError;
            NSURL *srtUrl;
            if ([[[[NSUserDefaultsController sharedUserDefaultsController] values]
                    valueForKey:@"RenameFile"] booleanValue]) {
                srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
            }
            else {
                srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[response suggestedFilename]]];
            }
            //[Logger log:@"%@", srtUrl];
            if (![data writeToURL:srtUrl options:YES error:&writeError]) {
                //[Logger log:@"Erreur lors de l'enregistrement du fichier: %@", writeError];
            }
        }
        */
}

+ (BOOL)handlesMovies {
    return NO;
}

+ (NSArray *)handleLanguages {
    return [NSArray arrayWithObjects:@"en", @"fr", nil];
}

+ (BOOL)handlesShows {
    return YES;
}
@end
