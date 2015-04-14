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
    self.javaScriptControllerTaskHandlerDictionary = [NSMutableDictionary dictionary];
    
    [self setupJavaScriptControllerTaskHandler];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.destinationURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Functions

- (void)setupJavaScriptControllerTaskHandler {
    __weak typeof(self) weakSelf = self;
    
    [self.javaScriptControllerTaskHandlerDictionary setObject:[^NSDictionary * (NSDictionary *arguments) {
        __strong typeof(self) strongSelf = weakSelf;
        UIViewController* viewController = [[NSClassFromString(arguments[@"viewController"]) alloc] init];//这个地方以后安卓和iOScontroller所对应的类名可能不一样，arguments[@"viewController"]获取的应该只是一个类所对应的映射值
        NSString *destinationURL = arguments[@"destinationURL"];
        NSString *title = arguments[@"title"];
        viewController.title = title;
        [strongSelf pushNewWebControllerWithURL:destinationURL title:title];
        return nil;
    } copy] forKey:@"pushWebViewControllerTitle"];
    
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

@end
