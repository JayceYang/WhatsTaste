//
//  JavaScriptController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "JavaScriptController.h"

@interface JavaScriptController ()

@property (strong, nonatomic) JSContext *context;
@property (copy, nonatomic) JavaScriptControllerTaskHandler taskHandler;
@property (copy, nonatomic) JavaScriptControllerCompletionHandler completionHandlerToJavaScript;

@end

@implementation JavaScriptController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialization code
        self.context = nil;
        self.taskHandler = nil;
        self.completionHandlerToJavaScript = nil;
    }
    return self;
}

#pragma mark - Public

+ (instancetype)javaScriptControllerWithContext:(JSContext *)context taskHandler:(JavaScriptControllerTaskHandler)taskHandler {
    return [self javaScriptControllerWithContext:context taskHandler:taskHandler completionHandler:nil];
}

+ (instancetype)javaScriptControllerWithContext:(JSContext *)context taskHandler:(JavaScriptControllerTaskHandler)taskHandler completionHandler:(JavaScriptControllerCompletionHandler)completionHandler {
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
    
    controller.taskHandler = taskHandler;
    controller.completionHandlerToJavaScript = completionHandler;
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
        
        // Save completion handler first
        self.completionHandlerToJavaScript = ^(NSDictionary *arguments) {
            NSMutableArray *safeArguments = [@[] mutableCopy];
            if (arguments) {
                [safeArguments addObject:arguments];
            }
            if (completionHandler) {
                [safeArguments addObject:completionHandler];
            }
            [completionHandler callWithArguments:@[arguments]];
        };
        
        if ([NSThread isMainThread]) {
            if (self.taskHandler) {
                self.taskHandler(method, arguments);
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.taskHandler) {
                    self.taskHandler(method, arguments);
                }
            });
        }
    }
}

@end
