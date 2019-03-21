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
+ (void)parseObjc_hFile:(NSString*)h_file;
@end

NS_ASSUME_NONNULL_END
