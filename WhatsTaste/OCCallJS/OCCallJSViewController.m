//
//  OCCallJSViewController.m
//  JavaScriptCore-Demo
//
//  Created by Jakey on 14/12/26.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "OCCallJSViewController.h"
#import "DefineMacro.h"

@interface OCCallJSViewController ()

@end

@implementation OCCallJSViewController

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
    self.title = @"oc call js";
    self.context = [[JSContext alloc] init];
    [self.context evaluateScript:[self loadJsFile:DEMO_JS]];

}

- (NSString *)loadJsFile:(NSString*)stringURL
{
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
//    NSLog(@"[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] = %@", [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]);
    
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendToJS:(id)sender {
    NSNumber *inputNumber = [NSNumber numberWithInteger:[self.textField.text integerValue]];
    JSValue *function = [self.context objectForKeyedSubscript:@"factorial"];
    JSValue *result = [function callWithArguments:@[inputNumber]];
    self.showLable.text = [NSString stringWithFormat:@"%@", [result toNumber]];
}


@end
