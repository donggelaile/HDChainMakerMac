//
//  HDChainMaker.m
//  HDChainMakerMac
//
//  Created by HaoDong chen on 2019/3/18.
//  Copyright © 2019 CHD. All rights reserved.
//

#import "HDChainMaker.h"
#import <objc/runtime.h>
#import <AppKit/NSOpenPanel.h>
static BOOL isOpenReadonlyProperty = NO;
#define HDClassRegex @"@interface[\\S\\s]*?@end"//匹配一个类
#define HDClassNameRegex @"(?<=@interface[\\s+])([\\w]+?)(?=\\s*:)"//匹配类名
#define HDMethodsOfInitRegex @"((-|\\+)\\s*\\(\\s*(instancetype|%@\\s*\\*)\\s*\\))\\s*([\\s\\S])+?;"//匹配所有初始化方法
#define HDPropertyRegex @"(@property)([\\s\\S]+?)(;)"//匹配属性


@interface HDRegexHelper :NSObject
@end

@implementation HDRegexHelper
+ (void)regexWithPattern:(NSString*)pattern needRegexStr:(NSString*)oriStr matches:(void(^)(NSString*machStr,NSTextCheckingResult * _Nullable hd_result,BOOL * _Nonnull hd_stop))matchCb
{
    if (!oriStr || !pattern) {
        return;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:nil];
    [regex enumerateMatchesInString:oriStr options:kNilOptions range:NSMakeRange(0,oriStr.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSString *match = [oriStr substringWithRange:result.range];
        if (matchCb) {
            matchCb(match,result,stop);
        }
    }];
}
+ (NSString*)regexWithPattern:(NSString*)regex template:(NSString*)template needRegexStr:(NSString*)oriStr
{
    if (!oriStr || !regex) {
        return nil;
    }
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regex options:kNilOptions error:nil];
    NSString *result = [regExp stringByReplacingMatchesInString:oriStr options:0 range:NSMakeRange(0, oriStr.length) withTemplate:template];
    return result;
}
+ (NSString*)regexFirstMatchWithPattern:(NSString*)regex needRegexStr:(NSString*)oriStr
{
    if (!oriStr || !regex) {
        return nil;
    }
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regex options:kNilOptions error:nil];
    NSTextCheckingResult *res = [regExp firstMatchInString:oriStr options:kNilOptions range:NSMakeRange(0, oriStr.length)];
    return [oriStr substringWithRange:res.range];
}
+ (BOOL)regexIsMatchWithPattern:(NSString*)regex needRegexStr:(NSString*)oriStr
{
    if (!oriStr || !regex) {
        return NO;
    }
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regex options:kNilOptions error:nil];
    NSRange firstMatchR = [regExp rangeOfFirstMatchInString:oriStr options:kNilOptions range:NSMakeRange(0, oriStr.length)];
    return firstMatchR.location != NSNotFound && firstMatchR.length != 0;
}
+ (NSString*)regexReplaceWithPattern:(NSString*)regex needReplaceStr:(NSString*)oriStr withReplacement:(NSString*)replacement
{
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regex options:kNilOptions error:nil];
    return [regExp stringByReplacingMatchesInString:oriStr options:kNilOptions range:NSMakeRange(0, [oriStr length]) withTemplate:replacement];
}
@end


@interface HDArgument:NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@end
@implementation HDArgument
@end

@interface HDMethod : NSObject
@property (nonatomic, strong, readonly) NSString *oriStr;
@property (nonatomic, strong, readonly) NSString *methodName;
@property (nonatomic, strong, readonly) NSString *retType;
@property (nonatomic, strong, readonly) NSMutableArray<HDArgument*> *args;
- (instancetype)initWithOriStr:(NSString*)oriStr;
@end

@implementation HDMethod
- (instancetype)initWithOriStr:(NSString *)oriStr
{
    if (self = [super init]) {
        if (oriStr) {
            _oriStr = oriStr;
            [self _updateMethodName];
            [self _updateMethodRetType];
            [self _updateArgs];
        }
    }
    return self;
}

- (void)_updateMethodName
{
    //解析函数名
}
- (void)_updateMethodRetType
{
    //解析返回值类型
    
}
- (void)_updateArgs
{
    //解析参数
    
}
@end



@interface HDProperty : NSObject
@property (nonatomic, strong, readonly) NSString *oriStr;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL isReadonly;
- (instancetype)initWithOriStr:(NSString*)oriStr;

@end

@implementation HDProperty
- (instancetype)initWithOriStr:(NSString *)oriStr
{
    if (self = [super init]) {
        if (oriStr) {
            _oriStr = oriStr;
            [self _updateType];
            [self _updateName];
            [self _updateIsReadonly];
        }
    }
    return self;
}

- (void)_updateType
{
    _type = [self getNeedStrByTemplate:2];
    _type = [HDRegexHelper regexReplaceWithPattern:@"\\s+" needReplaceStr:_type withReplacement:@" "];
    
}
- (void)_updateName
{
    _name = [self getNeedStrByTemplate:3];
    if ([HDRegexHelper regexIsMatchWithPattern:@"null" needRegexStr:_name]) {//__nullable __nonnull
        _name = [HDRegexHelper regexFirstMatchWithPattern:@"\\s+\\w+" needRegexStr:_name];
    }
    _name = [HDRegexHelper regexFirstMatchWithPattern:@"\\w+" needRegexStr:_name];
}
- (void)_updateIsReadonly
{
    _isReadonly = [HDRegexHelper regexIsMatchWithPattern:@"readonly" needRegexStr:_oriStr];
}
- (NSString*)getNeedStrByTemplate:(NSInteger)groupIndex
{
    if (groupIndex<=0 || groupIndex>3) {
        return nil;
    }
    NSString *hdGroupSeperator = @"--------------------------";
    NSString *template = [NSString stringWithFormat:@"$1%@$2%@$3",hdGroupSeperator,hdGroupSeperator];
    
    BOOL isContainX = [HDRegexHelper regexIsMatchWithPattern:@"\\*" needRegexStr:_oriStr];
    BOOL isContainKuoHao = [HDRegexHelper regexIsMatchWithPattern:@"\\)" needRegexStr:_oriStr];
    
    NSString *regex = @"";
    if (isContainKuoHao) {
        if (isContainX) {
            regex = @"(@property[\\s\\S]*?\\)\\s*)([\\s\\S]*?\\*\\s*)(\\w+)"; //以*结尾的
        }else{
            regex = @"(@property[\\s\\S]*?\\)\\s*)([\\s\\S]*?\\s+\\**)(\\w+)";//类型后带空格的
        }
    }else{
        regex = @"(@property[\\s\\S]*?\\s*)([\\s\\S]*?\\s+\\**)(\\w+)";//不带()的
    }
    NSString *temp = [HDRegexHelper regexWithPattern:regex template:template needRegexStr:_oriStr];
    NSArray *tempArr = [temp componentsSeparatedByString:hdGroupSeperator];
    if (!tempArr.count) {
        return nil;
    }
    __block NSString *res = tempArr[(groupIndex-1)%tempArr.count];
    
    [HDRegexHelper regexWithPattern:@"[^;]+" needRegexStr:res matches:^(NSString *machStr, NSTextCheckingResult * _Nullable hd_result, BOOL * _Nonnull hd_stop) {
        res = machStr;
        *hd_stop = YES;
    }];
    return res;
}
@end


@interface HDChainMakerHelper : NSObject
@property (nonatomic, strong, readonly) NSString *allClsStr;
@property (nonatomic, strong, readonly) NSString  *  clsName;//类名
@property (nonatomic, strong, readonly) NSMutableArray <HDMethod*> * __nonnull methodsOfinit;//初始化方法
@property (nonatomic, strong, readonly) NSMutableArray<HDProperty*> *props;//属性
@property (nonatomic, strong, readonly) NSMutableString *finalHfileStr;
@property (nonatomic, strong, readonly) NSMutableString *finalMfileStr;

@property (nonatomic, strong, readonly) NSString *helperClassName;
@property (nonatomic, strong, readonly) NSString *finalCategoryClsName;
@end

@implementation HDChainMakerHelper
@synthesize helperClassName = _helperClassName;
@synthesize finalCategoryClsName = _finalCategoryClsName;
- (NSString *)helperClassName
{
    if (!_helperClassName) {
        _helperClassName = [NSString stringWithFormat:@"HD%@Maker",_clsName];
    }
    return _helperClassName;
}
- (NSString *)finalCategoryClsName
{
    if (!_finalCategoryClsName) {
        _finalCategoryClsName = [NSString stringWithFormat:@"%@+HDChainMaker",_clsName];
    }
    return _finalCategoryClsName;
}
- (instancetype)initWithAllClsStr:(NSString*)allClsStr
{
    if (self=[super init]) {
        if (allClsStr) {
            _allClsStr = allClsStr;
            _clsName = [self _getClassName];
            _methodsOfinit = [self _getMethodsOfInit];
            _props = [self _getPropertys];
            
            _finalHfileStr = @"".mutableCopy;
            _finalMfileStr = @"".mutableCopy;
        }
    }
    return self;
}

#pragma mark - 获取类名
- (NSString*)_getClassName
{
    if (!_allClsStr) {
        return nil;
    }
    __block NSString *clsName;
    [HDRegexHelper regexWithPattern:HDClassNameRegex needRegexStr:_allClsStr matches:^(NSString *machStr, NSTextCheckingResult * _Nullable result, BOOL * _Nonnull stop) {
        clsName = machStr;
        *stop = YES;
        
    }];
    return clsName;
}
#pragma mark - 获取初始化方法列表
- (NSMutableArray<HDMethod*>*)_getMethodsOfInit
{
    NSMutableArray<HDMethod*> *methods = @[].mutableCopy;
    if (!_clsName || !_allClsStr) {
        return methods;
    }
    //NSString*s1=  [NSString stringWithFormat:@"(\\+\\s*\\(\\s*%@\\s*\\*\\))\\s*([\\s\\S])+?;",cls];
    NSString*regex=  [NSString stringWithFormat:HDMethodsOfInitRegex,_clsName];
    [HDRegexHelper regexWithPattern:regex needRegexStr:_allClsStr matches:^(NSString *machStr, NSTextCheckingResult * _Nullable hd_result, BOOL * _Nonnull hd_stop) {
        HDMethod *method = [[HDMethod alloc]initWithOriStr:machStr];
        [methods addObject:method];
    }];
    
    return methods;
}

#pragma mark 获取属性列表
- (NSMutableArray<HDProperty*>*)_getPropertys
{
    NSMutableArray<HDProperty*>* propertys = @[].mutableCopy;
    [HDRegexHelper regexWithPattern:HDPropertyRegex needRegexStr:_allClsStr matches:^(NSString *machStr, NSTextCheckingResult * _Nullable hd_result, BOOL * _Nonnull hd_stop) {
        HDProperty *prop = [[HDProperty alloc] initWithOriStr:machStr];
        [propertys addObject:prop];
    }];
    
    return propertys;
}

#pragma mark - 生成最终文件
- (void)generateFinalFile
{
    [self _generateHFile];
    [self _generateMFile];
    [self _openFinderAndWrite];
}
- (void)_openFinderAndWrite
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setMessage:@"选择保存地址"];

    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK)
        {
            NSString *path = [[panel URL] path];
            NSString *hPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",self.finalCategoryClsName]];
            NSString *mPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",self.finalCategoryClsName]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:hPath contents:[self.finalHfileStr dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
            [fileManager createFileAtPath:mPath contents:[self.finalMfileStr dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//            [[self.finalHfileStr dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
            
        }
    }];

}

#pragma mark - 生成h文件
- (void)_generateHFile
{
    [self _addCreateLog:_finalHfileStr];
    [self _addHeaderContain];
    [self _createHelperClassForH];
    [self _createCategoryForH];
}
- (void)_addHeaderContain
{
    NSString *append = @"";
    if ([HDRegexHelper regexIsMatchWithPattern:@"^NS" needRegexStr:_clsName]) {
        append = @"#import <Foundation/Foundation.h>";
    }else if ([HDRegexHelper regexIsMatchWithPattern:@"^UI" needRegexStr:_clsName]){
        append = @"#import <UIKit/UIKit.h>";
    }else{
        append = [NSString stringWithFormat:@"#import \"%@.h\"",_clsName];
    }
    [_finalHfileStr appendString:append];
    [_finalHfileStr appendString:@"\n\n"];
}
- (void)_createHelperClassForH
{
    [_finalHfileStr appendFormat:@"@interface %@ : NSObject\n",self.helperClassName];//添加类头
    //添加属性
    NSString *proPre = [NSString stringWithFormat:@"@property (nonatomic, strong, readonly) %@* ",self.helperClassName];
    [_props enumerateObjectsUsingBlock:^(HDProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name && obj.type && (isOpenReadonlyProperty || !obj.isReadonly)) {
            NSString *hd_proper_name = [@"hd_" stringByAppendingString:obj.name];
            NSString *oneProperty = [NSString stringWithFormat:@"%@ (^%@)(%@ %@);\n",proPre,hd_proper_name,obj.type,obj.name];
            [self->_finalHfileStr appendString:oneProperty];
        }
    }];
    //添加类尾
    [_finalHfileStr appendString:@"@end\n\n"];

}
- (void)_createCategoryForH
{
    [_finalHfileStr appendFormat:@"@interface %@ (HDChainMaker)\n",_clsName];
    [_finalHfileStr appendFormat:@"+ (%@*)hd_make%@:(void (^)(%@*make))maker;\n",_clsName,_clsName,self.helperClassName];
    [_finalHfileStr appendFormat:@"@end\n"];
}


#pragma mark - 生成m文件
- (void)_generateMFile
{
    [self _addCreateLog:_finalMfileStr];
    [self _addImportFile];
    [self _createHelperClassForM];
    [self _createHelperClsImpForM];
    [self _createCategoryImp];
}
- (void)_addImportFile
{
    [_finalMfileStr appendFormat:@"#import \"%@.h\"\n\n",self.finalCategoryClsName];
}
- (void)_createHelperClassForM
{
    [_finalMfileStr appendFormat:@"@interface %@()\n",self.helperClassName];
    NSString *proPre = @"@property (nonatomic) ";
    [_props enumerateObjectsUsingBlock:^(HDProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name && obj.type && (isOpenReadonlyProperty || !obj.isReadonly)) {
            NSString *oneProperty = [NSString stringWithFormat:@"%@ %@ %@;\n",proPre,obj.type,obj.name];
            [self->_finalMfileStr appendString:oneProperty];
        }
    }];
    [_finalMfileStr appendFormat:@"%@ NSMutableDictionary *keysSetedMap;\n",proPre];
    [_finalMfileStr appendString:@"@end\n\n"];
}
- (void)_createHelperClsImpForM
{
    [_finalMfileStr appendFormat:@"@implementation %@\n",self.helperClassName];
    
    //keysSetedMap的懒加载
    [_finalMfileStr appendFormat:@"- (NSMutableDictionary *)keysSetedMap\n{\n\t if (!_keysSetedMap) {\n\t\t _keysSetedMap = @{}.mutableCopy;\n\t}\n\t return _keysSetedMap;\n}\n"];
    
    //generateObj函数开始
    [_finalMfileStr appendFormat:@"- (%@ *)generateObj\n{\n",_clsName];
    [_finalMfileStr appendFormat:@"\t %@ *obj = [%@ new];\n",_clsName,_clsName];
    [_props enumerateObjectsUsingBlock:^(HDProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name && obj.type && (isOpenReadonlyProperty || !obj.isReadonly)) {
            NSString *setImp = [NSString stringWithFormat:@"obj.%@ = self.%@",obj.name,obj.name];
            if (obj.isReadonly) {
                //isKindOfClass 判断的是 参数1 -> isa 或 isa -> superclass(直至nil) 是否是 参数2
                //所以判断类对象是否是某个类时 后面传的是元类对象
                NSString *realType = [HDRegexHelper regexFirstMatchWithPattern:@"\\s*\\w+" needRegexStr:obj.type];
                BOOL isObjcClass = [NSClassFromString(realType) isKindOfClass:object_getClass([NSObject class])];
                //非OC对象封装为NSNumber 才能kvc赋值(自定义结构体可能不支持)
                NSString *setedValue = isObjcClass?[NSString stringWithFormat:@"self.%@",obj.name]:[NSString stringWithFormat:@"@(self.%@)",obj.name];
                setImp = [NSString stringWithFormat:@"[obj setValue:%@ forKeyPath:@\"%@\"]",setedValue,obj.name];
            }
            
            [self->_finalMfileStr appendFormat:@"\t if (self.keysSetedMap[@\"%@\"]) %@;\n",obj.name,setImp];
        }
    }];
    [_finalMfileStr appendString:@"\t return obj;\n}\n"];
    //generateObj函数结束
    
    //每个propers的block函数
    [_props enumerateObjectsUsingBlock:^(HDProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name && obj.type && (isOpenReadonlyProperty || !obj.isReadonly)) {
            NSMutableString *temp = self->_finalMfileStr;
            NSString *setImp = [NSString stringWithFormat:@"self.%@ = %@",obj.name,obj.name];;
            [temp appendFormat:@"-(%@* (^)(%@))hd_%@\n{\n",self.helperClassName,obj.type,obj.name];
            [temp appendFormat:@"\t return ^(%@ %@){\n\t\t %@;\n\t\t self.keysSetedMap[@\"%@\"] = @(YES);\n\t\t return self;\n\t};\n}\n",obj.type,obj.name,setImp,obj.name];
        }
    }];
    [_finalMfileStr appendString:@"@end\n\n"];
}
- (void)_createCategoryImp
{
    [_finalMfileStr appendFormat:@"@implementation %@ (HDChainMaker)\n",_clsName];
    [_finalMfileStr appendFormat:@"+ (%@ *)hd_make%@:(void(^)(HD%@Maker*make))maker\n{\n\t HD%@Maker *hdMaker = [HD%@Maker new];\n\t if (maker) {\n\t\t maker(hdMaker);\n\t}\n\t return [hdMaker generateObj];\n}\n",_clsName,_clsName,_clsName,_clsName,_clsName];
    [_finalMfileStr appendString:@"@end\n"];
}

- (void)_addCreateLog:(NSMutableString*)toAddStr
{
    if (![toAddStr isKindOfClass:[NSMutableString class]]) {
        return;
    }
    NSDateFormatter *formater = [NSDateFormatter new];
    [formater setDateFormat:@"yyyy/MM/dd"];
    NSString *createTime = [formater stringFromDate:[NSDate date]];
    [toAddStr appendFormat:@"\n\n// Created by HDChainMaker on %@ \n\n",createTime];
}
@end


@implementation HDChainMaker

+ (void)parseObjcHFile:(NSString*)h_file isOpenReadonlyPro:(BOOL)isOpenRNPro
{
    if (!h_file) {
        return;
    }
    isOpenReadonlyProperty = isOpenRNPro;
    //解析出一个类
    [HDRegexHelper regexWithPattern:HDClassRegex needRegexStr:h_file matches:^(NSString *machStr, NSTextCheckingResult * _Nullable hd_result, BOOL * _Nonnull hd_stop) {
        [self _generateHDChainHelpByClassParseStr:machStr];
        *hd_stop = YES;//只解析第一个
    }];
}

#pragma mark - 通过解析的一个类信息生成一个辅助对象
+ (void)_generateHDChainHelpByClassParseStr:(NSString*)classParStr
{
    HDChainMakerHelper *helper = [[HDChainMakerHelper alloc] initWithAllClsStr:classParStr];
    [helper generateFinalFile];
}



@end
