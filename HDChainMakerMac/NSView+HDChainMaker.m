//
//  NSFont+HDChainMaker.m
//  HDChainMakerMac
//
//  Created by HaoDong chen on 2019/3/18.
//  Copyright © 2019 CHD. All rights reserved.
//

#import "NSView+HDChainMaker.h"

@interface HDNSViewMaker()
@property  (nonatomic) NSView *obj;
@property  (nonatomic) NSRect frame;
@property  (nonatomic) NSMutableDictionary *keysSetedMap;
//@property (nonatomic, assign) BOOL is;
@end
@implementation HDNSViewMaker
-(NSMutableDictionary *)keysSetedMap
{
    if (!_keysSetedMap) {
        _keysSetedMap = @{}.mutableCopy;
    }
    return _keysSetedMap;
}
- (NSView*)generateObj
{
    NSView *obj = [NSView new];
    if (self.keysSetedMap[@"frame"]) obj.frame = self.frame;
    return obj;
}
-(void (^)(NSRect))hd_frame
{
    return ^(NSRect frame){
        self.frame = frame;

//        objc_setAssociatedObject(self, <#const void * _Nonnull key#>, <#id  _Nullable value#>, <#objc_AssociationPolicy policy#>)
    };
}
@end

@implementation NSView (HDChainMaker)
+ (NSView*)hd_makeNSView:(void(^)(HDNSViewMaker*make))maker
{
    HDNSViewMaker *hdMaker = [HDNSViewMaker new];
    if (maker) {
        maker(hdMaker);
    }
    return [hdMaker generateObj];
}
@end
