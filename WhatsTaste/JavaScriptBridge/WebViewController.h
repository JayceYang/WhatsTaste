//
//  WebViewController.h
//  WhatsTaste
//
//  Created by arvin.tan on 4/9/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JavaScriptController.h"

typedef NSDictionary * (^NativeFunction)(NSDictionary *arguments);

@interface WebViewController : UIViewController <UIWebViewDelegate>

+ (instancetype)webViewController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSURL *destinationURL;
@property (strong, nonatomic) JSContext *context;
@property (strong, nonatomic) JavaScriptController * javaScriptController;

#pragma mark - JS methods

- (void)pushWebViewController:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler;

- (void)getPlatformInfomation:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler;

- (void)imagePicker:(NSDictionary *)arguments completionHandlerToJavaScript:(void (^)(NSDictionary *))completionHandler;

@end
