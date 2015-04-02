//
//  AppDelegate.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "AppDelegate.h"

#import "LMStackerController.h"
#import "LMStackerCustomAction.h"
#import "HexColor.h"

@interface AppDelegate ()

@end

NSString *DOMAIN_URL;
LMStackerController *homeNavController;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // URL of the web app
    DOMAIN_URL = @"http://localhost:3000";
    
    // 1.) Create a StackerController
    homeNavController = [[LMStackerController alloc] initWithURL:
                         [NSString stringWithFormat:@"%@%@", DOMAIN_URL, @"/design/index?x_right_button=search_button&x_left_button=bridge_demo&x_page_title=News+Feed"]];
    
    // 2.) Custom right button actions
    UIBarButtonItem *newPostButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showNewPostPage)];
    UIBarButtonItem *searchButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchPage)];
    UIBarButtonItem *bridgeDemoButton     = [[UIBarButtonItem alloc] initWithTitle:@"Bridge" style:UIBarButtonItemStyleBordered target:self action:@selector(showJSBridgePage)];
    UIBarButtonItem *sendMessageToBridge     = [[UIBarButtonItem alloc] initWithTitle:@"Fire" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMessageToBridge)];
    
    NSDictionary *buttonHandlers    = @{ @"new_post": newPostButton,
                                         @"search_button": searchButton,
                                         @"bridge_demo": bridgeDemoButton,
                                         @"send_msg_to_bridge": sendMessageToBridge  };
    homeNavController.buttonHandlers  = buttonHandlers;
    
    // 3.) Javascript Bridge handler
    [homeNavController registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    // 4.) Custom URL Actions
    LMStackerCustomAction *myCustomAction = [[LMStackerCustomAction alloc] init];
    [myCustomAction addTarget:self action:@selector(showCustomActionPage:) withParameter:self ];
    
    NSDictionary *customURLHandlers = @{ @"myAction" : myCustomAction };
    [homeNavController setCustomURLHandlers:customURLHandlers];
    
    
    // 5.) Theme the controller
    homeNavController.stackerBackgroundColor =  @"F0F1F2";
    homeNavController.rootPageTitleImage    = [UIImage imageNamed:@"logo.png"];
    homeNavController.statusBarLight        = YES;
    homeNavController.refreshSpinnerColor   = @"6F9FCD";
    homeNavController.loadingSpinnerColor   = @"1C3347";
    
    // 5.5) Extra theming (but not really Stacker specific)
    homeNavController.navigationBar.barTintColor   = [UIColor colorWithHexString:@"357ebd"];
    homeNavController.navigationBar.tintColor      = [UIColor colorWithHexString:@"FFFFFF"];
    [homeNavController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"FFFFFF"]}];
    
    // Alrighty, spin up the app!
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = homeNavController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Functions for the purpose of the demo:
// --------------------------------------

- (void)showCustomActionPage:(id)sender {
    UIViewController *myRootController = [[UIViewController alloc] init];
    myRootController.title = @"Custom Action";
    
    myRootController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeCustomActionPage)];
    
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:myRootController.view.bounds];
    myWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@%@", DOMAIN_URL, @"/design/custom_action"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
    [myWebView setScalesPageToFit:YES];
    [myWebView setBackgroundColor:[UIColor clearColor]];
    [myWebView setOpaque:NO];
    myWebView.scrollView.bounces = YES;
    [myRootController.view addSubview:myWebView];
    
    LMStackerBrowserController *newPostController = [[LMStackerBrowserController alloc] initWithRootViewController:myRootController];
    
    [self.window.rootViewController presentViewController:newPostController animated:YES completion:NULL];
}

- (void)closeCustomActionPage {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSearchPage {
    [homeNavController pushNewPage:[NSString stringWithFormat:@"%@%@", DOMAIN_URL, @"/design/search?x_page_title=Search"]];
}

- (void)showJSBridgePage {
    [homeNavController pushNewPage:[NSString stringWithFormat:@"%@%@", DOMAIN_URL, @"/design/bridge?x_page_title=JS+Bridge+Demo&x_right_button=send_msg_to_bridge"]];
}

- (void)showNewPostPage {
    [homeNavController pushNewPage:[NSString stringWithFormat:@"%@%@", DOMAIN_URL, @"/design/new_post?x_page_title=New+Post"]];
}

- (void)sendMessageToBridge {
    [homeNavController.bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
}

@end
