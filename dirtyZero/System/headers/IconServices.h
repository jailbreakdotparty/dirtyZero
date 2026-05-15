#ifndef IconServices_h
#define IconServices_h

@class ISIconResourceLocator, NSString;

@protocol ISIconCacheServiceProtocol <NSObject>
- (void)copyIconBitmapCacheConfigurationWithReply:(void (^)(NSURL *, NSString *, NSString *))reply;
- (void)clearCachedItemsForBundeID:(NSString *)bundleID reply:(void (^)(_Bool, NSError *))reply;
- (void)getIconBitmapDataWithResourceLocator:(ISIconResourceLocator *)locator variant:(int)variant options:(int)options reply:(void (^)(_Bool, NSData *))reply;
@end

#endif /* IconServices_h */
