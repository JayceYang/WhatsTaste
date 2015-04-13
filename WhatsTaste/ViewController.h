//
//  ViewController.h
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewController.h"

@protocol TestJSExport<JSExport>
JSExportAs
(calculateForJS  /** handleFactorialCalculateWithNumber 作为js方法的别名 */,
 - (void)handleFactorialCalculateWithNumber:(NSNumber *)number
 );

@end



@interface ViewController : WebViewController<TestJSExport>
@end
