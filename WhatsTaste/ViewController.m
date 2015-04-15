//
//  ViewController.m
//  WhatsTaste
//
//  Created by Jayce Yang on 15/4/2.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "ViewController.h"
#import "DefineMacro.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *jsCaculateResultLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userCurrentLocation;
@end

@implementation ViewController
@synthesize userCurrentLocation, locationManager;

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

#pragma mark - private functions
- (void)getLocationAddress:(CLLocation *)currentLocation completionHandler:(void (^)(NSString *))completionHandler {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@, %@", Address, Area, Country];
             NSLog(@"%@",CountryArea);
             completionHandler(CountryArea);
             [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": CountryArea}];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             //             CountryArea = NULL;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

#pragma mark - JS methods

- (void)calculate:(NSDictionary *)arguments completionHandlerToJavaScript:(JavaScriptControllerCompletionHandler)completionHandler {
    float inputValue = [(NSNumber*)[arguments objectForKey:@"squareValue"] floatValue];
    NSDictionary *resultDictionary = @{@"squareValueResult" : [NSNumber numberWithFloat:inputValue * inputValue]};
    if (completionHandler) {
        completionHandler(resultDictionary);
    }
}

- (void)getUserLocation:(NSDictionary *)arguments completionHandlerToJavaScript:(JavaScriptControllerCompletionHandler)completionHandler {
    
    if (!self.locationManager) {
        [self initLocationManager];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation]; //Will update location immediately
    }
    
    [self.jsCompletionHandlerDictionary setObject:completionHandler forKey:@"getUserLocation"];//不能同步获取到位置信息，需要将handler存放
    if (userCurrentLocation) {
        [self getLocationAddress:userCurrentLocation completionHandler:^(NSString *locationAddress) {
            [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": locationAddress}];
        }];
    }

}

#pragma mark - User Location
- (void) initLocationManager {
    self.locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": [NSString stringWithFormat:@"didFailWithError: %@", error]}];
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
            [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": @"User still thinking.."}];
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User hates you");
            [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": @"User hates you"}];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    userCurrentLocation = [locations objectAtIndex:0];
//    [locationManager stopUpdatingLocation];
    [self getLocationAddress:userCurrentLocation completionHandler:^(NSString *locationAddress) {
        [self callJSCompletionHandler:@"getUserLocation" arguments:@{@"getUserLocationResult": locationAddress}];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

@end
