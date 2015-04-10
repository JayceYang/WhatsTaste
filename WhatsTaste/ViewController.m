//
//  ViewController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "ViewController.h"

#import "DefineMacro.h"
#import "JavaScriptController.h"

@interface ViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *nativeView;
@property (weak, nonatomic) IBOutlet UITextField *nativeTextField;
@property (strong, nonatomic) JavaScriptController *javaScriptController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"sample.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeWeb:(id)sender {
    NSLog(@"Java script task begins");
    [self.javaScriptController callJavaScriptMethod:@"changeInputFromNative" arguments:@{@"data": self.nativeTextField.text} completionHandler:^(NSDictionary *arguments) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Web的内容已经改变了，并告知了我！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"arguments:%@", arguments);
        NSLog(@"Java script task ends");
    }];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 以 html title 设置 导航栏 title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    // Undocumented access to UIWebView's JSContext
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self) weakSelf = self;
    JavaScriptController *controller = [JavaScriptController javaScriptControllerWithContext:context taskHandler:^(NSString *method, NSDictionary *arguments) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([method isEqualToString:@"changeColor"]) {
                NSInteger aRedValue = arc4random()%255;
                NSInteger aGreenValue = arc4random()%255;
                NSInteger aBlueValue = arc4random()%255;
                UIColor *randomColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
                strongSelf.nativeView.backgroundColor = randomColor;
            }
            NSLog(@"Native task begins");
            NSLog(@"method:%@", method);
            NSLog(@"arguments:%@", arguments);
            NSLog(@"Native task ends");
        });
        
        NSLog(@"Callback to java script");
        if (strongSelf.javaScriptController.completionHandlerToJavaScript) {
            strongSelf.javaScriptController.completionHandlerToJavaScript(arguments);
        }
    }];
    self.javaScriptController = controller;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
