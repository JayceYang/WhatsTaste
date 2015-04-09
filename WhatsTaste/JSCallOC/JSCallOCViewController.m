//
//  JSCallOCViewController.m
//  JavaScriptCore-Demo
//
//  Created by Jakey on 14/12/26.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "JSCallOCViewController.h"
#import "DefineMacro.h"
#import "JavaScriptController.h"

@interface JSCallOCViewController ()

@property (strong, nonatomic) JavaScriptController *javaScriptController;

@end

@implementation JSCallOCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"js call oc";
    
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"JSCallOC.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:request];
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
        
        NSLog(@"Native task begins");
        NSLog(@"method:%@", method);
        NSLog(@"arguments:%@", arguments);
        NSLog(@"Native task ends");
        
        NSLog(@"Callback to java script");
        if (strongSelf.javaScriptController.completionHandlerToJavaScript) {
            strongSelf.javaScriptController.completionHandlerToJavaScript(arguments);
        }
        
//        NSLog(@"Java script task begins");
//        [strongSelf.javaScriptController callJavaScriptMethod:@"updateResult" arguments:@{@"data": @"20480"} completionHandler:^(NSDictionary *arguments) {
//            NSLog(@"arguments:%@", arguments);
//            NSLog(@"Java script task ends");
//        }];
    }];
    self.javaScriptController = controller;
    
    NSLog(@"Java script task begins");
    [controller callJavaScriptMethod:@"updateResult" arguments:@{@"data": @"2048"} completionHandler:^(NSDictionary *arguments) {
        NSLog(@"arguments:%@", arguments);
        NSLog(@"Java script task ends");
    }];
}

@end
