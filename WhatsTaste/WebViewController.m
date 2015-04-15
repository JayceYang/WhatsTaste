//
//  WebViewController.m
//  WhatsTaste
//
//  Created by arvin.tan on 4/9/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "WebViewController.h"
#import "DeviceHardware.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.destinationURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    JavaScriptController *controller = [JavaScriptController javaScriptControllerWithContext:context webViewController:self];
    self.javaScriptController = controller;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Load webview with error: %@", error);
}


#pragma mark - JS methods

- (void)pushWebViewController:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler {
    NSString *destinationURL = arguments[@"destinationURL"];
    NSString *title = arguments[@"title"];
    
    WebViewController *newWebController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebViewController"];
    newWebController.destinationURL = [NSURL URLWithString:destinationURL];
    newWebController.title = title;
    [self.navigationController pushViewController:newWebController animated:YES];
    if (completionHandler) {
        completionHandler(nil);
    }
}

- (void)getPlatformInfomation:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler {
    if (!completionHandler) {
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"SystemName"] = [UIDevice currentDevice].systemName;
    info[@"SystemVersion"] = [UIDevice currentDevice].systemVersion;
    info[@"Scale"] = [NSString stringWithFormat:@"%f", [UIScreen mainScreen].scale];
    info[@"DeviceName"] = [DeviceHardware platformString];
    completionHandler(info);
}

- (void)imagePicker:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler {
    
}

@end
