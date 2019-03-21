//
//  ViewController.m
//  HDChainMakerMac
//
//  Created by HaoDong chen on 2019/3/18.
//  Copyright © 2019 CHD. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "HDChainMaker.h"
#import "NSView+HDChainMaker.h"
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setUI];
    // Do any additional setup after loading the view.
}
- (void)setUI
{
//    self.mainTextView.pla
    
    //backView
    NSScrollView *scrolleView = [[NSScrollView alloc]init];

    [self.view addSubview:scrolleView];
    
    
    //textView
    NSTextView *txView = [[NSTextView alloc]init];
    txView.string = @"默认";
    txView.delegate = self;
    [scrolleView setDocumentView:txView];
    
    
    
    //Layout
    [scrolleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(NSEdgeInsetsZero);
    }];
    
    [txView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(NSEdgeInsetsZero);
    }];

}

- (IBAction)beginClick:(id)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.innerTextView.string]) {
        [self loadPathContent:self.innerTextView.string];
    }else{
        [self dealFile:self.innerTextView.string];
    }
}

- (void)loadPathContent:(NSString*)path
{
    NSString *str = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
    if (!str) {
        [self makeToast:@"该路径获取到的内容为空!"];
        return;
    }
    self.innerTextView.string = str;
    
    [self dealFile:str];
}
- (void)dealFile:(NSString*)file
{
    if (!file || file.length == 0) {
        [self makeToast:@"内容不能为空"];
    }else{
        [HDChainMaker parseObjc_hFile:file];
    }
}


- (void)makeToast:(NSString*)toast
{
    NSTextField *label = [[NSTextField alloc] init];
    label.stringValue = toast;
    label.textColor = [NSColor whiteColor];
    label.backgroundColor = [NSColor redColor];
    label.font = [NSFont systemFontOfSize:30];
    if (@available(macOS 10.11, *)) {
        label.maximumNumberOfLines = 0;
    } else {
        // Fallback on earlier versions
    }
    [label setEditable:NO];
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.left.mas_greaterThanOrEqualTo(0);
        make.right.mas_lessThanOrEqualTo(0);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
    
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
