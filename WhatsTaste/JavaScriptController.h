//
//  JavaScriptController.h
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^JavaScriptControllerTaskHandler)(NSString *method, NSDictionary *arguments);
typedef void (^JavaScriptControllerCompletionHandler)(NSDictionary *arguments);

@protocol JavaScriptControllerJSExport <JSExport>

- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments;
- (void)callNativeMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JSValue *)completionHandler;

@end

@interface JavaScriptController : NSObject <JavaScriptControllerJSExport>

@property (readonly, strong, nonatomic) JSContext *context;
@property (readonly, copy, nonatomic) JavaScriptControllerCompletionHandler completionHandlerToJavaScript;

/*
 The taskHandler will perform on main thread
 */
+ (instancetype)javaScriptControllerWithContext:(JSContext *)context taskHandler:(JavaScriptControllerTaskHandler)taskHandler;
- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments;
- (void)callJavaScriptMethod:(NSString *)method arguments:(NSDictionary *)arguments completionHandler:(JavaScriptControllerCompletionHandler)completionHandler;

@end
