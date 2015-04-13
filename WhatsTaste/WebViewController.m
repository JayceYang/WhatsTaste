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
        UIViewController* viewController = [[NSClassFromString(arguments[@"viewController"]) alloc] init];
        NSString *destinationURL = arguments[@"destinationURL"];
        NSString *title = arguments[@"title"];
        viewController.title = title;
        [strongSelf pushNewWebControllerWithURL:destinationURL title:title];
        return nil;
    } copy] forKey:@"pushWebViewControllerTitle"];
    
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
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Load webview with error: %@", error);
}

@end
