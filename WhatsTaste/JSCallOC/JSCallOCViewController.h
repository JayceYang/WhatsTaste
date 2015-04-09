//
//  JSCallOCViewController.h
//  JavaScriptCore-Demo
//
//  Created by Jakey on 14/12/26.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewController.h"

typedef void (^TCompletionBlock)(id result);


@protocol TestJSExport<JSExport>
JSExportAs
(calculateForJS  /** handleFactorialCalculateWithNumber 作为js方法的别名 */,
 - (void)handleFactorialCalculateWithNumber:(NSNumber *)number
 );
- (void)showAlert:(NSString *)str;
- (void)addSubViewMethod:(JSValue *) completionBlock;
@end



@interface JSCallOCViewController : WebViewController<TestJSExport>
@end
