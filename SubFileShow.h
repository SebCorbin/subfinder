//
//  Created by sebastien on 26/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <RegexKit/RegexKit.h>
#import "SubFile.h"

@interface SubFileShow : SubFile {
    NSString *show;
    NSString *season;
    NSString *episode;
}

@property(nonatomic, retain) NSString *show;
@property(nonatomic, retain) NSString *season;
@property(nonatomic, retain) NSString *episode;

- (id)initWithSubFile:(SubFile *)subFile;

@end