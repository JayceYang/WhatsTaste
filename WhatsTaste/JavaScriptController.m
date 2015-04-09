//
//  JavaScriptController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "JavaScriptController.h"

NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodNameKey = @"nativeMethodName";
NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodIdentifierKey = @"nativeMethodIdentifier";
NSString * const CallNativeCompletionHandlerJavaScriptInfoArgumentsKey = @"nativeArguments";

NSString * const CallJavaScriptCompletionHandlerKey = @"javaScriptCompletionHandler";

@interface JavaScriptController ()

@property (strong, nonatomic) JSContext *context;

@end

@implementation JavaScriptController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

+ (instancetype)shareController {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (instancetype)javaScriptControllerWithContext:(JSContext *)context {
    JavaScriptController *controller = [[JavaScriptController alloc] init];
    controller.context = context;
    controller.context[@"native"] = controller;
    controller.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    return controller;
}

#pragma mark - Java script calls native

- (void)callNativeMethod:(NSString *)method {
    NSLog(@"method:%@", method);
}

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments {
    [self callNativeMethod:method arguments:arguments completionHandlerJavaScriptInfo:nil];
}

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandlerJavaScriptInfo:(NSDictionary *)info {
    NSLog(@"method:%@", method);
    NSLog(@"arguments:%@", arguments);
    NSLog(@"completionHandlerJavaScriptInfo:%@", info);
}

#pragma mark - Native calls java script

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments {
    [self callJavaScriptMethod:method arguments:arguments completionHandler:nil];
}

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(void (^)(NSString *methodName, NSString *methodIdentifier, NSError *error))completionHandler {
    JSValue *function = [self.context objectForKeyedSubscript:method];
    JSValue *completion = [[JSValue alloc] init];
    [completion setValue:completionHandler forKey:CallJavaScriptCompletionHandlerKey];
    [function callWithArguments:@[arguments, completion]];
}

@end
