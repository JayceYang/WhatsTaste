//
//  WebViewController.m
//  WhatsTaste
//
//  Created by arvin.tan on 4/9/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.javaScriptControllerTaskHandler = [NSMutableDictionary dictionary];
    
    [self setupJavaScriptControllerTaskHandler];
}

- (void)setupJavaScriptControllerTaskHandler {
    __weak typeof(self) weakSelf = self;
    
    [self.javaScriptControllerTaskHandler setObject:@"changeColor" forKey:^(NSDictionary *arguments) {
        
        __strong typeof(self) strongSelf = weakSelf;
        NSInteger aRedValue = arc4random()%255;
        NSInteger aGreenValue = arc4random()%255;
        NSInteger aBlueValue = arc4random()%255;
        UIColor *randomColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
        strongSelf.view.backgroundColor = randomColor;
        
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.destinationURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - JS methods

- (void)pushNewWebControllerWithURL:(NSString *)urlString title:(NSString *)title {
    WebViewController *newWebController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebViewController"];
    newWebController.destinationURL = [NSURL URLWithString:urlString];
    newWebController.title = title;
    [self.navigationController pushViewController:newWebController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    // Undocumented access to UIWebView's JSContext
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self) weakSelf = self;
    JavaScriptController *controller = [JavaScriptController javaScriptControllerWithContext:self.context taskHandler:^(NSString *method, NSDictionary *arguments) {
        
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NativeFunction nativeFunction = [self.javaScriptControllerTaskHandler objectForKey:method];
            nativeFunction(arguments);
            
//            if ([method isEqualToString:@"changeColor"]) {
//                NSInteger aRedValue = arc4random()%255;
//                NSInteger aGreenValue = arc4random()%255;
//                NSInteger aBlueValue = arc4random()%255;
//                UIColor *randomColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
////                strongSelf.nativeView.backgroundColor = randomColor;
//            }
//            NSLog(@"Native task begins");
//            NSLog(@"method:%@", method);
//            NSLog(@"arguments:%@", arguments);
//            NSLog(@"Native task ends");
        });
        
        NSLog(@"Callback to java script");
        if (strongSelf.javaScriptController.completionHandlerToJavaScript) {
            strongSelf.javaScriptController.completionHandlerToJavaScript(arguments);
        }
    }];
    self.javaScriptController = controller;
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Load webview with error: %@", error);
}

@end
