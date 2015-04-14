//
//  ViewController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "ViewController.h"
#import "DefineMacro.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *jsCaculateResultLabel;

@end

@implementation ViewController

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
    
#ifdef LOCAL_HTML // use server html
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"JSCallOC.html"];
    self.destinationURL = [NSURL fileURLWithPath:path];
#else
    self.destinationURL = [NSURL URLWithString:DEMO_HTML];
#endif
}

- (IBAction)nativeCallJS:(UIButton *)sender {
    NSLog(@"Native call JS");
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

#pragma mark - JSExport Methods

- (void)handleFactorialCalculateWithNumber:(NSNumber *)number {
    NSLog(@"%@", number);
    NSNumber *result = [self calculateFactorialOfNumber:number];
    NSLog(@"%@", result);
    [self.context[@"updateResult"] callWithArguments:@[result]];
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
