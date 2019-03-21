//
//  NSFont+HDChainMaker.h
//  HDChainMakerMac
//
//  Created by HaoDong chen on 2019/3/18.
//  Copyright © 2019 CHD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDNSViewMaker : NSObject
@property (nonatomic, strong, readonly) void(^hd_frame)(NSRect frame);
@end


@interface NSView (HDChainMaker)
+ (NSView*)hd_makeNSView:(void(^)(HDNSViewMaker*make))maker;
@end

NS_ASSUME_NONNULL_END
