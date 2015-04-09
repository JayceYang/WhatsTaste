//
//  JSCallOCViewController.h
//  JavaScriptCore-Demo
//
//  Created by Jakey on 14/12/26.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport <JSExport>
- (void)callNativeMethod:(NSString *)method;
@end



@interface JSCallOCViewController : UIViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic) JSContext *context;
@end
