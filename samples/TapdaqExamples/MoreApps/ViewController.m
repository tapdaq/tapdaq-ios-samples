//
//  ViewController.m
//  MoreApps
//
//  Created by Nick Reffitt on 08/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Tapdaq sharedSession] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Target Actions

- (IBAction)showDebugger:(id)sender {
    [[Tapdaq sharedSession] presentDebugViewController];
}

- (IBAction)loadMoreApps:(id)sender
{
    /** 
     * You can either load the more apps popup like this:
     *
     * [[Tapdaq sharedSession] loadMoreApps];
     *
     * Or you can pass in a custom config to style the more apps popup, like so:
     */
    
    [[Tapdaq sharedSession] loadMoreAppsWithConfig:[self customMoreAppsConfig]];
}

- (IBAction)showMoreApps:(id)sender
{
    if ([[Tapdaq sharedSession] isMoreAppsReady]) {
        [[Tapdaq sharedSession] showMoreApps];
    }
}

#pragma mark - Private methods

- (TDMoreAppsConfig *)customMoreAppsConfig
{
    TDMoreAppsConfig *moreAppsConfig = [[TDMoreAppsConfig alloc] init];
    
    moreAppsConfig.headerText = @"More Games";
    moreAppsConfig.installedAppButtonText = @"Play";
    
    moreAppsConfig.headerTextColor = [UIColor whiteColor];
    moreAppsConfig.headerColor = [UIColor colorWithRed:3.f / 255.f green:3.f / 255.f blue:4.f / 255.f alpha:1.f];
    moreAppsConfig.headerCloseButtonColor = [UIColor colorWithRed:235.f / 255.f green:73.f / 255.f blue:77.f / 255.f alpha:1.f];
    moreAppsConfig.backgroundColor = [UIColor colorWithRed:33.f / 255.f green:33.f / 255.f blue:33.f / 255.f alpha:1.f];
    
    moreAppsConfig.appNameColor = [UIColor whiteColor];
    moreAppsConfig.appButtonColor = [UIColor colorWithRed:59.f / 255.f green:133.f / 255.f blue:37.f / 255.f alpha:1.f];
    moreAppsConfig.appButtonTextColor = [UIColor whiteColor];
    moreAppsConfig.installedAppButtonColor = [UIColor colorWithRed:40.f / 255.f green:90.f / 255.f blue:245.f / 255.f alpha:1.f];
    moreAppsConfig.installedAppButtonTextColor = [UIColor whiteColor];
    
    return moreAppsConfig;
}

- (void)logMessage:(NSString *)message
{
    NSString *text = [self.textView text];
    NSString *textAddition = [NSString stringWithFormat:@"%@\n\n%@", message, text];
    [self.textView setText:textAddition];
    
    NSLog(@"MoreApps App: %@", message);
}

#pragma mark - TapdaqDelegate

- (void)didLoadConfig
{
    [self.loadMoreAppsBtn setEnabled:YES];
    
    [self logMessage:@"didLoadConfig"];
}

- (void)didLoadMoreApps
{
    [self.showMoreAppsBtn setEnabled:YES];
    
    [self logMessage:@"didLoadMoreApps"];
}

- (void)didFailToLoadMoreApps
{
    [self logMessage:@"didFailToLoadMoreApps"];
}

- (void)willDisplayMoreApps
{
    [self logMessage:@"willDisplayMoreApps"];
}

- (void)didDisplayMoreApps
{
    [self.showMoreAppsBtn setEnabled:NO];
    
    [self logMessage:@"didDisplayMoreApps"];
}

- (void)didCloseMoreApps
{
    [self logMessage:@"didCloseMoreApps"];
}

@end
