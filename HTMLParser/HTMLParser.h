//
//  HTMLParser.h
//  StackOverflow
//
//  Created by Ben Reeves on 09/03/2010.
//  Copyright 2010 Ben Reeves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"

@class HTMLNode;

@interface HTMLParser : NSObject 
{
	@public
	htmlDocPtr _doc;
}

-(id)initWithContentsOfURL:(NSURL*)url error:(NSError**)error;
+ (id)parseWithContentsOfURL:(NSURL *)url;

-(id)initWithData:(NSData*)data error:(NSError**)error;
-(id)initWithString:(NSString*)string error:(NSError**)error;

+ (id)parseWithString:(NSString *)contentString;

//Returns the doc tag
-(HTMLNode*)doc;

//Returns the body tag
-(HTMLNode*)body;

//Returns the html tag
-(HTMLNode*)html;

@end
