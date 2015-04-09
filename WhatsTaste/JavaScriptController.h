//
//  JavaScriptController.h
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

//extern NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodNameKey;
//extern NSString * const CallNativeCompletionHandlerJavaScriptInfoMethodIdentifierKey;
//extern NSString * const CallNativeCompletionHandlerJavaScriptInfoArgumentsKey;
//
//extern NSString * const CallJavaScriptCompletionHandlerKey;

typedef void (^JavaScriptControllerCompletionHandler)(NSDictionary *arguments);

@protocol JavaScriptControllerJSExport <JSExport>

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments;
- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JSValue *)completionHandler;

@end

@interface JavaScriptController : NSObject <JavaScriptControllerJSExport>

@property (readonly, strong, nonatomic) JSContext *context;
@property (weak, nonatomic) id target;

//+ (instancetype)shareController;
+ (instancetype)javaScriptControllerWithContext:(JSContext *)context;
- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments;
- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JavaScriptControllerCompletionHandler)completionHandler;

@end
