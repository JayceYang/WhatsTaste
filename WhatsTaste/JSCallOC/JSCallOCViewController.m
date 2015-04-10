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

- (void)setupJavaScriptControllerTaskHandler {
    [super setupJavaScriptControllerTaskHandler];
    __weak typeof(self) weakSelf = self;
    
    [self.javaScriptControllerTaskHandler setObject:@"changeText" forKey:^(NSDictionary *arguments) {
        
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.inputTextField.text = arguments[@"text"];
        
    }];
    
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
#endif
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [super webViewDidFinishLoad:webView];
//    
//    // 以 html title 设置 导航栏 title
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    
//    // 打印异常
//    self.context.exceptionHandler =
//    ^(JSContext *context, JSValue *exceptionValue)
//    {
//        context.exception = exceptionValue;
//        NSLog(@"%@", exceptionValue);
//    };
//    
//    // 以 JSExport 协议关联 native 的方法
//    self.context[@"native"] = self;
//    
//    // 以 block 形式关联 JavaScript function    
//    __block typeof(self) weakSelf = self;
//    self.context[@"addSubView"] =
//    ^(NSString *viewname)
//    {
//        CGRect frame = weakSelf.view.frame;
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
//        view.backgroundColor = [UIColor redColor];
//        UISwitch *sw = [[UISwitch alloc]init];
//        [view addSubview:sw];
//        [weakSelf.view addSubview:view];
//    };
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self) weakSelf = self;
    JavaScriptController *controller = [JavaScriptController javaScriptControllerWithContext:self.context taskHandler:^(NSString *method, NSDictionary *arguments) {
        
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NativeFunction nativeFunction = [self.javaScriptControllerTaskHandler objectForKey:method];
            nativeFunction(arguments);
        });
        
        NSLog(@"Callback to java script");
        if (strongSelf.javaScriptController.completionHandlerToJavaScript) {
            strongSelf.javaScriptController.completionHandlerToJavaScript(arguments);
        }
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
