//
//  HDChainMaker.h
//  HDChainMakerMac
//
//  Created by HaoDong chen on 2019/3/18.
//  Copyright © 2019 CHD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDChainMaker : NSObject
+ (void)parseObjcHFile:(NSString*)h_file isOpenReadonlyPro:(BOOL)isOpenRNPro;
@end

NS_ASSUME_NONNULL_END
