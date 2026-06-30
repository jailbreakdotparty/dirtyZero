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

#endif /* bridge_h */
