//
//  bridge.h
//  dirtyZero
//
//  Created by Skadz on 5/20/25.
//

#ifndef bridge_h
#define bridge_h

#import <Foundation/Foundation.h>

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (bool)openApplicationWithBundleID:(NSString*)bundleID;
@end

#import "darksword.h"
#import "offsets.h"
#import "utils.h"
#import "vnode.h"
#import "apfs.h"
#import "vfs.h"
#import "sbx.h"
#import "IconServices.h"
#import "rc.h"
#import "RemoteCall.h"

void test(NSString *path);

#endif /* bridge_h */
