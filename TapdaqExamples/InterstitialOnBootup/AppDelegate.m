//
//  AppDelegate.m
//  InterstitialOnBootup
//
//  Created by Nick Reffitt on 22/12/2016.
//  Copyright © 2016 Tapdaq. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
@interface AppDelegate () <TapdaqDelegate, TDAdRequestDelegate, TDDisplayableAdRequestDelegate, TDClickableAdRequestDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    TDProperties *tapdaqProps = [[TDProperties alloc] init];
    [tapdaqProps setIsDebugEnabled:YES];
    
    [[Tapdaq sharedSession] setDelegate:self];
    
    [[Tapdaq sharedSession] setApplicationId:kAppId
                                   clientKey:kClientKey
                                  properties:tapdaqProps];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[Tapdaq sharedSession] isInitialised]) {
        [[Tapdaq sharedSession] loadInterstitialForPlacementTag:TDPTagDefault delegate:self];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - Private method

- (void)logMessage:(NSString *)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapdaqLogMessageNotification" object:nil userInfo:@{ @"message" : message }];
    
    NSLog(@"InterstitialOnBootup App: %@", message);
}

#pragma mark - TapdaqDelegate

- (void)didLoadConfig {
    [self logMessage:@"Tapdaq config loaded"];
    
    [[Tapdaq sharedSession] loadInterstitialForPlacementTag:TDPTagDefault delegate:self];
}

- (void)didFailToLoadConfigWithError:(TDError *)error {
    [self logMessage:[NSString stringWithFormat:@"Tapdaq config failed to load with error: %@", error.localizedDescription]];
}

#pragma mark - TDAdRequestDelegate
- (void)didLoadAdRequest:(TDAdRequest *)adRequest {
    [Tapdaq.sharedSession showInterstitialForPlacementTag:TDPTagDefault];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToLoadWithError:(TDError *)error {
    [self logMessage:[NSString stringWithFormat:@"Failed to load ad for placement: %@", adRequest.placement.tag]];
}

#pragma mark - TDDisplayableAdRequestDelegate

- (void)willDisplayAdRequest:(TDAdRequest *)adRequest {
    [self logMessage:[NSString stringWithFormat:@"Will display ad request for tag: %@", adRequest.placement.tag]];
}

- (void)didDisplayAdRequest:(TDAdRequest *)adRequest {
    [self logMessage:[NSString stringWithFormat:@"Did display ad request for tag: %@", adRequest.placement.tag]];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToDisplayWithError:(TDError *)error {
    [self logMessage:[NSString stringWithFormat:@"Failed to display: %@ with error: %@", adRequest.placement.tag, error.localizedDescription]];
}

- (void)didCloseAdRequest:(TDAdRequest *)adRequest {
    [self logMessage:[NSString stringWithFormat:@"Did close ad request for tag: %@", adRequest.placement.tag]];
}

#pragma mark - TDClickableAdRequestDelegate
- (void)didClickAdRequest:(TDAdRequest *)adRequest {
    [self logMessage:[NSString stringWithFormat:@"Did click ad request for tag: %@", adRequest.placement.tag]];

}
@end
