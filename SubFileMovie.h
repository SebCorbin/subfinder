//
//  Created by sebastien on 26/12/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SubFile.h"

@interface SubFileMovie : SubFile {
    NSString *movie;
    NSInteger year;
    NSInteger part;
}

@property(nonatomic, retain) NSString *movie;
@property(nonatomic) NSInteger year;
@property(nonatomic) NSInteger part;

- (id)initWithSubFile:(SubFile *)subFile;

@end