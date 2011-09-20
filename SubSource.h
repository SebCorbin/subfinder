//
//  SubSource.h
//  SubFinder
//
//  Created by sebcorbin on 28/04/11.
//  Copyright 2011 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubFile.h"


@interface SubSource : NSObject {
	
}
-(BOOL)getSubtitleFrom:(SubFile*)movie;

@end
