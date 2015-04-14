//
//  JavaScriptController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "JavaScriptController.h"
#import "WebViewController.h"

@interface JavaScriptController ()

@property (strong, nonatomic) JSContext *context;

@end

@implementation JavaScriptController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialization code
        self.context = nil;
        self.webViewController = nil;
    }
    return self;
}

#pragma mark - Public

+ (instancetype)javaScriptControllerWithContext:(JSContext *)context webViewController:(UIViewController *)webViewController {
    return [self javaScriptControllerWithContext:context webViewController:webViewController completionHandler:nil];
}

+ (instancetype)javaScriptControllerWithContext:(JSContext *)context webViewController:(UIViewController *)webViewController completionHandler:(JavaScriptControllerCompletionHandler)completionHandler {
    JavaScriptController *controller = [[JavaScriptController alloc] init];
    controller.context = context;
    controller.context[@"native"] = controller;
    controller.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"exception: %@", exceptionValue);
    };
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"native_bridge" withExtension:@"js"];
    NSString *scriptCode = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    [controller.context evaluateScript:scriptCode];
    
    controller.webViewController = webViewController;
    return controller;
}

#pragma mark - Native calls java script

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments {
    [self callJavaScriptMethod:method arguments:arguments completionHandler:nil];
}

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JavaScriptControllerCompletionHandler)completionHandler {
    if (method.length > 0) {
        JSValue *function = [self.context objectForKeyedSubscript:method];
        NSMutableArray *safeArguments = [@[] mutableCopy];
        if (arguments) {
            [safeArguments addObject:arguments];
        }
        if (completionHandler) {
            [safeArguments addObject:completionHandler];
        }
        [function callWithArguments:safeArguments];
    }
}

#pragma mark - Java script calls native

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments {
    [self callNativeMethod:method arguments:arguments completionHandler:nil];
}

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JSValue *)completionHandler {
//    NSLog(@"method:%@", method);
//    NSLog(@"arguments:%@", arguments);
//    NSLog(@"completionHandler:%@", completionHandler);
    if (method.length > 0) {
        JavaScriptControllerCompletionHandler jsCompletionHandler;
        if (completionHandler) {
            jsCompletionHandler = ^(NSDictionary *arguments) {
                NSMutableArray *safeArguments = [@[] mutableCopy];
                if (arguments) {
                    [safeArguments addObject:arguments];
                }
                [completionHandler callWithArguments:safeArguments];
            };
        }
        SEL destSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:completionHandlerToJavaScript:", method]);
        NSMethodSignature *methodSegnature = [[self.webViewController class] instanceMethodSignatureForSelector:destSelector];
        if (!methodSegnature) {
            if (jsCompletionHandler) {
                jsCompletionHandler(@{@"error": [NSString stringWithFormat:@"There is no %@ method in native", method]});
            }
            return;
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSegnature];
        [invocation setTarget:self.webViewController];
        [invocation setSelector:destSelector];
        [invocation setArgument:&arguments atIndex:2];
        if (jsCompletionHandler) {
            [invocation setArgument:&jsCompletionHandler atIndex:3];            
        }
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
}

@end
