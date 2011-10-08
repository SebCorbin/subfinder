//
//  SubFinderAppDelegate.m
//  SubFinder
//
//  Created by sebcorbin on 10/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define DEBUG 0

#import "SubFinderAppDelegate.h"
#import <RegexKit/RegexKit.h>
#import "HTMLParser.h"
#import "Logger.h"

@implementation SubFinderAppDelegate

@synthesize preferencesWindow;
@synthesize serviceWindow;

/**
 * A l'affichage de la GUI
 */
-(void)awakeFromNib {
	[preferencesWindow center];
	[self initializePreferences];
}

/**
 * A la fin du chargement
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[Logger log:@"Application initialisée"];
	// Registering service
	[NSApp setServicesProvider:self];
	if (DEBUG) {
		[self findSubtitle:nil userData:nil error:nil];
	}
}

/**
 * Service : trouver un sous-titre
 */
- (void)findSubtitle:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	// Comportement de la fenêtre
	[preferencesWindow close];
	[Logger log:@"Service démarré"];
	[progressLabel setStringValue:@"Service démarré"];
	[progressIndicator startAnimation:nil];
	[serviceWindow center];
	[serviceWindow makeKeyAndOrderFront:nil];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		int found = 0;
		
        for(NSString *file in files) {
			[Logger log:@"%@", file];
			found += [self findSubtitleForFile:file] ? 1 : 0;
		}
		if (found) {
			[progressLabel setStringValue:[NSString stringWithFormat:@"Terminé : %d sous-titre(s) trouvé(s)", found]];
			if(![closeOnFoundCheckbox intValue]) {
				[NSApp waitUntilExit];
			}
			else {
				[NSApp terminate:nil];
			}
		}
		else {
			[progressLabel setStringValue:@"Terminé mais aucun résultat"];
			[NSApp waitUntilExit];
		}
    }
	else if(!DEBUG) {
		[progressLabel setStringValue:@"Pas de fichiers passés en paramètres"];
		[NSApp waitUntilExit];
	}

	
	//Debug
	if (DEBUG && pboard == nil) {
		[self findSubtitleForFile:@"/Users/sebastien/Downloads/The.Big.Bang.Theory.S05E04.The.Wiggly.Finger.Catalyst.HDTV.XviD-FQM.avi"];
		[progressLabel setStringValue:@"Terminé"];
	}
}

/**
 * Methode : Trouver un sous-titre pour un chemin
 */
-(BOOL)findSubtitleForFile:(NSString*)filepath {
	[Logger log:@"Recherche de sous-titres pour “%@“", filepath];
	
	NSURL *fileUrl = [NSURL fileURLWithPath:filepath];
	NSString *pBoardString = [fileUrl absoluteString];
	
	// Get the filename
	NSFileWrapper *file = [[NSFileWrapper alloc] initWithURL:[NSURL URLWithString:pBoardString] options:NSFileWrapperReadingImmediate error:NULL];
	if(!file ) {
		[Logger log:@"Le fichier source n'a pas été trouvé"];
		[progressLabel setStringValue:@"Le fichier source n'a pas été trouvé"];
		[progressIndicator setHidden:YES];
		[okButton setHidden:FALSE];
		return NO;
	}
	if(![file isRegularFile]) {
		[Logger log:@"Le fichier est un dossier"];
		[progressLabel setStringValue:@"Ce n'est pas un fichier régulier"];
		[progressIndicator setHidden:YES];
		[okButton setHidden:FALSE];
		return NO;
	}
	NSString *name = [file filename];
	[file release];
	
	[Logger log:@"Le fichier est %@", name];
	[progressLabel setStringValue:[NSString stringWithFormat:@"Le fichier est %@", name]];
	
	BOOL found = FALSE;
	
	// Récupération addic7ed
	if( [(NSNumber*)[preferences objectForKey:@"addic7ed"] boolValue]) {
		[Logger log:@"Recherche sur Addic7ed"];
		found = found || [self getAddic7edSubtitles:name inPath:[fileUrl relativePath]];
	}

	// Récupération betaseries
	if( [(NSNumber*)[preferences objectForKey:@"betaseries"] boolValue]) {
		found = found || [self getBetaseriesSubtitles:name inPath:[fileUrl relativePath]];
	}
	if(!found) {
		[Logger log:@"Aucun sous-titre trouvé pour %@", name];
		[progressLabel setStringValue:@"Aucun sous titre trouvé"];
		[progressIndicator setHidden:YES];
		[okButton setHidden:FALSE];
		return FALSE;
	}
	return TRUE;
}

/**
 * Methode : Récupérer un sous-titre via Betaseries
 */
-(BOOL)getBetaseriesSubtitles:(NSString*)name inPath:(NSString*)path {
	
	[Logger log:@"Recherche sur Betaseries"];
	[progressLabel setStringValue:[NSString stringWithFormat:@"Recherche sur Betaseries"]];
	
	NSString *show = [[[name stringByReplacingOccurrencesOfString:@"." withString:@" "] stringByReplacingOccurrencesOfString:@"_" withString:@" "] urlencode];
	NSString *language = [[languageComboBox stringValue] isEqualToString:@"Anglais"]?@"VO":@"VF";
	NSString *stringUrl = [NSString stringWithFormat:@"http://api.betaseries.com/subtitles/show.xml?file=%@&key=01d9224c4fd8&language=%@", show, language];
	//[Logger log:@"Requete betaseries : %@", [stringUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *url = [self betaseriesRequest:stringUrl searchForTag:@"url"];
	if(url == nil) {
		[Logger log:@"Aucun résultat sur Betaseries"];
		[progressLabel setStringValue:[NSString stringWithFormat:@"Aucun résultat sur Betaseries"]];
		return FALSE;
	}
	[Logger log:@"Sous-titres trouvés sur betaseries"];
	[progressLabel setStringValue:[NSString stringWithFormat:@"Sous-titres trouvés sur Betaseries"]];
	NSURLRequest *query = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
	
	// Unzip
	if ([[response MIMEType] isEqualToString:@"application/zip"]) {
		[Logger log:@"Décompression"];
		[progressLabel setStringValue:[NSString stringWithFormat:@"Décompression"]];
		NSURL *zipUrl = [NSURL fileURLWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[response suggestedFilename]]];
		NSError *writeError;
		if (![data writeToURL:zipUrl atomically:YES]) {
			[Logger log:@"Erreur lors de l'enregistrement du zip"];
		}
		
		NSTask *unzip = [[NSTask alloc] init];
		NSPipe *zipPipe = [NSPipe pipe];
		[unzip setLaunchPath:@"/usr/bin/unzip"];
		[unzip setStandardOutput:zipPipe];
		[unzip setArguments:[NSArray arrayWithObjects: @"-p", [NSString stringWithFormat:@"%@", [zipUrl relativePath]], nil]];
		[unzip launch];
		
		NSData *data = [[zipPipe fileHandleForReading] readDataToEndOfFile];
		
		NSURL *srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
		[data writeToURL:srtUrl options:YES error:&writeError];
		[unzip waitUntilExit];
		[unzip release];
		NSFileManager* fm = [NSFileManager defaultManager];
		if (![fm removeItemAtURL:zipUrl error:NULL]) {
			[Logger log:@"Erreur lors de la suppression du zip: %@", writeError];
		}
		else {
			[Logger log:@"Archive supprimée avec succès"];
		}
		[fm release];
	}
	else {
		NSError *writeError;
		NSURL *srtUrl;
		if([renameFileCheckbox intValue]) {
			srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
		}
		else {
			srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[response suggestedFilename]]];
		}
		[Logger log:@"%@", srtUrl];
		if (![data writeToURL:srtUrl options:YES error:&writeError]) {
			[Logger log:@"Erreur lors de l'enregistrement du fichier: %@", writeError];
		}
	}
	return TRUE;
}

/**
 * Methode : Récupérer un sous-titre via Addic7ed
 */
-(BOOL)getAddic7edSubtitles:(NSString*)name inPath:(NSString *)path {
	NSArray *regexes = [[NSArray alloc] init];
	NSString *show = nil, *season = nil, *episode = nil, *teams = nil;
	
	regexes = [regexes arrayByAddingObject:@"(?P<show>.*).S(?P<season>[0-9]{2})E(?P<episode>[0-9]{2}).(?P<teams>.*)"];
	regexes = [regexes arrayByAddingObject:@"(?P<show>.*).?(?P<season>[0-9]{1,2})x(?P<episode>[0-9]{1,2}).(?P<teams>.*)"];
	
	// Execute each regex on filename
	for(NSString *regex in regexes) {
		if([name getCapturesWithRegexAndReferences:regex, @"${show}", &show, @"${season}", &season, @"${episode}", &episode, @"${teams}", &teams, nil]) {
			
			[Logger log:@"Analyse : %@ S%@E%@ by %@ detecté", show, season, episode, teams];
			[progressLabel setStringValue:[NSString stringWithFormat:@"Le fichier est %@", name]];
			show = [self cleanShowName:show];
			
			NSString *url = [NSString stringWithFormat:@"http://www.addic7ed.com/serie/%@/%@/%@/%@", show, season, episode, show];
			
			[Logger log:@"Connection à Addic7ed"];
			NSURLRequest *query = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
												   cachePolicy:NSURLRequestUseProtocolCachePolicy
											   timeoutInterval:60.0];
			NSURLResponse *response = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
			// Connection failed
			if (!response) {
				[Logger log:@"La connection à Addic7ed a échouée", url];
			}
			// Connection ok
			else {
				// HTTP Status code must be 200
				int statusCode = [(NSHTTPURLResponse*)response statusCode];
				if(statusCode == 404) {
					[Logger log:@"404 Not Found: %@", url];
				}
				else if(statusCode == 200) {
					NSString *htmlCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					
					NSString *subtitleUrl = [self findSubtitleUrlInHTML:htmlCode withTeams:teams];
					if(subtitleUrl) {
						[Logger log:@"Téléchargement du sous-titre depuis : %@", subtitleUrl];
						[progressLabel setStringValue:[NSString stringWithFormat:@"Téléchargement du sous-titre depuis : %@", subtitleUrl]];
						// Modifying headers to get the .srt file
						NSURLRequest *q = [NSURLRequest requestWithURL:[NSURL URLWithString:subtitleUrl]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:60.0];
						NSMutableURLRequest *query = [q mutableCopy];
						[query setValue:subtitleUrl forHTTPHeaderField:@"Referer"];
						NSURLResponse *response = nil;
						NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
						if (response && [[response suggestedFilename] isEqualToString:@"downloadexceeded.php"]) {
							// Storing .srt
							NSURL *srtUrl;
							if([renameFileCheckbox intValue]) {
								srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
							}
							else {
								srtUrl = [NSURL fileURLWithPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[response suggestedFilename]]];
							}
							[Logger log:@"Enregistrement du fichier : %@", srtUrl];
							[progressLabel setStringValue:[NSString stringWithFormat:@"Enregistrement du fichier"]];
							NSError *writeError = nil;
							if(![data writeToURL:srtUrl options:NSDataWritingAtomic error:&writeError]) {
								[Logger log:@"Erreur à l'écriture : %@", writeError];
								[progressLabel setStringValue:[NSString stringWithFormat:@"Erreur à l'ecriture"]];
								[progressIndicator setHidden:YES];
								[okButton setHidden:FALSE];
								return FALSE;
							}
							else {
								return TRUE;
							}
						}
						else if(response) {
							[Logger log:@"Trop de téléchargements sur Addic7ed pour aujourd'hui"];
						}
					}
					else {
						[Logger log:@"Pas de sous-titre trouvé sur Addic7ed"];
					}

				}
				else {
					[Logger log:@"HTTP error : %@", statusCode];
					[progressLabel setStringValue:[NSString stringWithFormat:@"HTTP error: %d", statusCode]];
					[progressIndicator setHidden:YES];
					[okButton setHidden:FALSE];
					return FALSE;
				}	
			}
		}
	}
	return FALSE;
}

/**
 * Initialisation des préférences
 */
-(void)initializePreferences {
	// Initialize preferences
	preferences = [[NSUserDefaults standardUserDefaults] retain];
	
	// Apply defaults
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSNumber numberWithBool:YES], @"renameFile",
						 @"Anglais", @"language",
						 [NSNumber numberWithBool:YES], @"addic7ed",
						 [NSNumber numberWithBool:NO], @"betaseries",
						 [NSNumber numberWithBool:YES], @"closeOnFound",
						 nil ];
	[preferences registerDefaults:dict];
	
	// Set UI to preferences
	[renameFileCheckbox setIntValue:[(NSNumber*)[preferences objectForKey:@"renameFile"] integerValue]];
	[languageComboBox setStringValue:(NSString*)[preferences objectForKey:@"language"]];
	[addic7edCheckbox setIntValue:[(NSNumber*)[preferences objectForKey:@"addic7ed"] integerValue]];
	[betaseriesCheckbox setIntValue:[(NSNumber*)[preferences objectForKey:@"betaseries"] integerValue]];
	[closeOnFoundCheckbox setIntValue:[(NSNumber*)[preferences objectForKey:@"closeOnFound"] integerValue]];
	
	// Format hyperlinks
	[self setHyperLink:addic7edLabel withLabel:@"www.addic7ed.com" withStringURL:@"http://www.addic7ed.com"];
	[self setHyperLink:betaseriesLabel withLabel:@"www.betaseries.com" withStringURL:@"http://www.betaseries.com"];
}

/**
 * Création d'un lien HTTP
 */
-(void)setHyperLink:(NSTextField*)inTextField withLabel:(NSString*)label withStringURL:(NSString*)stringUrl
{
    // both are needed, otherwise hyperlink won't accept mousedown
    [inTextField setAllowsEditingTextAttributes: YES];
    [inTextField setSelectable: YES];
	
    NSURL* url = [NSURL URLWithString:stringUrl];
	
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
	
    // set the attributed string to the NSTextField
    [inTextField setAttributedStringValue: string];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: label];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[url absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [attrString endEditing];
	[inTextField setAttributedStringValue:attrString];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification {
	[preferences synchronize];
}

/**
 * Events
 */
-(IBAction)renameFileChecked:(id)sender {
	[preferences setInteger:[renameFileCheckbox intValue] forKey:@"renameFile"];
}
-(IBAction)languageChanged:(id)sender {
	[preferences setObject:[languageComboBox stringValue] forKey:@"language"];
}
-(IBAction)addic7edChecked:(id)sender {
	[preferences setInteger:[addic7edCheckbox intValue] forKey:@"addic7ed"];
}
-(IBAction)betaseriesChecked:(id)sender {
	[preferences setInteger:[betaseriesCheckbox intValue] forKey:@"betaseries"];
}
-(IBAction)closeOnFoundChecked:(id)sender {
	[preferences setInteger:[closeOnFoundCheckbox intValue] forKey:@"closeOnFound"];
}
-(IBAction)okPressed:(id)sender {
	[NSApp terminate:nil];
}

/**
 * Functions
 */
-(NSString *)findSubtitleUrlInHTML:(NSString *)htmlCode withTeams:(NSString *)teams {
	// Parsage
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlCode error:&error];
	if (error) {
		[Logger log:@"Error while parsing: %@", error];
		return nil;
	}
	HTMLNode * node = [parser body];
	
	// Get the potential subteams
	NSArray *subteams = [teams componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- ._"]];
	
	for(HTMLNode *td in [node findChildrenWithAttribute:@"class" matchingName:@"NewsTitle" allowPartial:0]) {
		
		if ([[td getAttributeNamed:@"colspan"] isEqualToString:@"3"]){
			NSString *content = [td allContents];
			for(NSString *subteam in subteams) {
				if([content rangeOfString:subteam].length > 0) {
					[Logger log:@"Team %@ corresponding found, try finding language\"%@\"", subteam, [languageComboBox stringValue]];
					
					// Team found, get language
					HTMLNode *table = [[td parent] parent];
					NSString *language = [[languageComboBox stringValue] isEqualToString:@"Anglais"]?@"English":@"French";
					for(HTMLNode *tag in [table findChildrenWithAttribute:@"class" matchingName:@"language" allowPartial:0]) {
						if([[tag allContents] rangeOfString:language].length > 0) {
							[Logger log:@"Langage %@ trouvé", [languageComboBox stringValue]];
							// Completed ?
							if([[[[tag parent] findChildTag:@"strong"] allContents] rangeOfString:@"Completed"].length > 0) {
								HTMLNode *tdSubtitle = [[tag parent] findChildWithAttribute:@"colspan" matchingName:@"3" allowPartial:0];
								return [NSString stringWithFormat:@"http://www.addic7ed.com%@", [[[tdSubtitle findChildTags:@"a"] lastObject] getAttributeNamed:@"href"]];
							}
						}
					}
				}
			}
		}
	}
	return nil;
}


-(NSString *)cleanShowName:(NSString *)show {
	return [show stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

-(NSString *)betaseriesRequest:(NSString *)url searchForTag:(NSString *)tag {
	NSURLRequest *query = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
									   timeoutInterval:60.0];
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
	// Connection failed
	if (!response) {
		[Logger log:@"Betaseries: Connexion impossible"];
	}
	// Connection ok
	else {
		// HTTP Status code must be 200
		int statusCode = [(NSHTTPURLResponse*)response statusCode];
		if(statusCode == 404) {
			[Logger log:@"Betaseries: 404 not found %@", url];
		}
		else if(statusCode == 200) {
			NSString *htmlCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

			NSError *error = nil;
			HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlCode error:&error];
			if (error) {
				[Logger log:@"Betaseries: Error while parsing, %@", error];
				return nil;
			}
			HTMLNode *node = [parser doc];
			
			return [[node findChildTag:tag] allContents];
		}
		else {
			[Logger log:@"Betaseries: Error %@ on %@", statusCode, url];
		}
	}
	return nil;
}

@end

@implementation NSString (MyOwnAdditions)
-(NSString *) urlencode {
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @" ", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", @"%20", nil];
	
    int len = [escapeChars count];
    NSMutableString *temp = [self mutableCopy];
    for(int i = 0; i < len; i++) {
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    return [NSString stringWithString:temp];
}

@end
