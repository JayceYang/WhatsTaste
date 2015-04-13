//
//  JSCallOCViewController.m
//  JavaScriptCore-Demo
//
//  Created by Jakey on 14/12/26.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "JSCallOCViewController.h"
#import "DefineMacro.h"

@interface JSCallOCViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *jsCaculateResultLabel;

@end

@implementation JSCallOCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"js call oc";
    
#if 0 // use server html
//    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"JSCallOC.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:DEMO_HTML]];
    [self.webView loadRequest:request];
#else
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"JSCallOC.html"];
    self.destinationURL = [NSURL fileURLWithPath:path];
#endif
}

- (IBAction)nativeCallJS:(UIButton *)sender {
    NSLog(@"native call js");
    // Both ways work well.
#if 0
    [self.context evaluateScript:[NSString stringWithFormat:@"jsSquare(%@)", @(self.inputTextField.text.integerValue)]];
#else
    NSNumber *inputNumber = [NSNumber numberWithInteger:[self.inputTextField.text integerValue]];
    JSValue *function = [self.context objectForKeyedSubscript:@"jsSquare"];
    [function callWithArguments:@[inputNumber]];
    
    __weak typeof(self) weakSelf = self;
    [self.javaScriptController callJavaScriptMethod:@"calculateForNative" arguments:@{@"calculate": self.inputTextField.text} completionHandler:^(NSDictionary *arguments) {
        __strong typeof(self) strongSelf = weakSelf;
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Web的内容已经改变了，并告知了我！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
//        [alertView show];
        NSLog(@"arguments:%@", arguments);
        NSLog(@"Java script task ends");
        strongSelf.jsCaculateResultLabel.text = [NSString stringWithFormat:@"%@", [arguments objectForKey:@"squareValueResult"]];
    }];
#endif
}

#pragma mark - private func
- (void)setupJavaScriptControllerTaskHandler {
    [super setupJavaScriptControllerTaskHandler];
    
    [self.javaScriptControllerTaskHandlerDictionary setObject:[ ^NSDictionary *(NSDictionary *arguments) {
        
        float inputValue = [(NSNumber*)[arguments objectForKey:@"squareValue"] floatValue];
        return @{@"squareValueResult" : [NSNumber numberWithFloat:inputValue * inputValue]};
        
    } copy] forKey:@"calculate"];
    
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 以 html title 设置 导航栏 title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    // Undocumented access to UIWebView's JSContext
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self) weakSelf = self;
    JavaScriptController *controller = [JavaScriptController javaScriptControllerWithContext:context taskHandler:^(NSString *method, NSDictionary *arguments) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
                
            NativeFunction nativeFunction = [self.javaScriptControllerTaskHandlerDictionary objectForKey:method];
            NSDictionary * returnValue = nativeFunction(arguments);
            
            NSLog(@"Native task begins");
            NSLog(@"method:%@", method);
            NSLog(@"arguments:%@", arguments);
            NSLog(@"Native task ends");
            
            NSLog(@"Callback to java script");
            
            if (returnValue) {
                if (strongSelf.javaScriptController.completionHandlerToJavaScript) {
                    strongSelf.javaScriptController.completionHandlerToJavaScript(returnValue);
                }
            }
            
        });
        
    }];
    self.javaScriptController = controller;
}

#pragma mark - JSExport Methods

- (void)handleFactorialCalculateWithNumber:(NSNumber *)number {
    NSLog(@"%@", number);
    NSNumber *result = [self calculateFactorialOfNumber:number];
    NSLog(@"%@", result);
    [self.context[@"updateResult"] callWithArguments:@[result]];
}

- (void)showAlert:(NSString *)str {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"msg from js" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Factorial Method

- (NSNumber *)calculateFactorialOfNumber:(NSNumber *)number
{
    NSInteger i = [number integerValue];
    if (i < 0)
    {
        return [NSNumber numberWithInteger:0];
    }
    if (i == 0)
    {
        return [NSNumber numberWithInteger:1];
    }
    
    NSInteger r = (i * [(NSNumber *)[self calculateFactorialOfNumber:[NSNumber numberWithInteger:(i - 1)]] integerValue]);
    
    return [NSNumber numberWithInteger:r];
}



@end
