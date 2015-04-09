//
//  JavaScriptController.h
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

extern NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodNameKey;
extern NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodIdentifierKey;
extern NSString * const CallNativeCompletionHandlerJavaScriptInfoArgumentsKey;

extern NSString * const CallJavaScriptCompletionHandlerKey;

@interface JavaScriptController : NSObject <JSExport>

#pragma mark - Java script calls native

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments;

/*
 info-> {
    "methodName": "callbackMethodName"
    "methodIdentifier": 0
    "arguments": {
        "value": 1024
    }
 }
 */
- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandlerJavaScriptInfo:(NSDictionary *)info;

#pragma mark - Native calls java script

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments;

- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(void (^)(NSString *methodName, NSString *methodIdentifier, NSError *error))completionHandler;

@end
