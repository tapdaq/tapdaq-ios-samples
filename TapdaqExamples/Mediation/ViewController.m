//
//  ViewController.m
//  Mediation
//
//  Created by Nick Reffitt on 15/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import "ViewController.h"

NSString *AdTypeNameFromTDAdTypes(TDAdTypes types) {
    switch (types) {
        case TDAdTypeInterstitial:
            return @"interstitial";
        case TDAdTypeVideo:
            return @"video interstitial";
        case TDAdTypeRewardedVideo:
            return @"rewarded video";
        case TDAdTypeBanner:
            return @"banner";
        default:
            return @"unknown";
    }
}

static NSString *const kRewardNameKey = @"MyRewardName";
static NSString *const kRewardAmountKey = @"MyRewardAmount";
static NSString *const kRewardPayloadKey = @"MyRewardPayload";

@interface ViewController () <TapdaqDelegate, TDAdRequestDelegate, TDDisplayableAdRequestDelegate, TDClickableAdRequestDelegate, TDBannerAdRequestDelegate, TDRewardedVideoAdRequestDelegate>

@property (strong, nonatomic) TDMediationAdRequest *interstitialAdRequest;
@property (strong, nonatomic) TDMediationAdRequest *videoAdRequest;
@property (strong, nonatomic) TDMediationAdRequest *rewardedAdRequest;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[Tapdaq sharedSession] setDelegate:self];
    [self updateRewardUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    BOOL isInitialised = Tapdaq.sharedSession.isInitialised;
    
    self.loadInterstitialBtn.enabled = isInitialised;
    self.loadVideoBtn.enabled = isInitialised;
    self.loadRewardedBtn.enabled = isInitialised;
    self.loadBannerBtn.enabled = isInitialised;
    
    self.showInterstitialBtn.enabled = self.interstitialAdRequest.isReady;
    self.showVideoBtn.enabled = self.videoAdRequest.isReady;
    self.showRewardedBtn.enabled = self.rewardedAdRequest.isReady;
    
    self.showBannerBtn.enabled = self.adBanner != nil;
}

#pragma mark - Target action 

- (IBAction)loadAd:(UIButton *)sender
{
    if (sender == self.loadBannerBtn) {
        [[Tapdaq sharedSession] loadBannerWithSize:TDMBannerStandard completion:^(UIView *bannerView) {
            self.adBanner = bannerView;
        }];
    } else if (sender == self.loadInterstitialBtn) {
        [[Tapdaq sharedSession] loadInterstitialForPlacementTag:TDPTagDefault delegate:self];
    } else if (sender == self.loadVideoBtn) {
        [[Tapdaq sharedSession] loadVideoForPlacementTag:TDPTagDefault delegate:self];
    } else if (sender == self.loadRewardedBtn) {
        [[Tapdaq sharedSession] loadRewardedVideoForPlacementTag:TDPTagDefault delegate:self];
    }
}

- (IBAction)showAd:(UIButton *)sender
{
    if (sender == self.showInterstitialBtn) {
        [Tapdaq.sharedSession showInterstitialForPlacementTag:TDPTagDefault];
    } else if (sender == self.showVideoBtn) {
        [Tapdaq.sharedSession showVideoForPlacementTag:TDPTagDefault];
    } else if (sender == self.showRewardedBtn) {
        [Tapdaq.sharedSession showRewardedVideoForPlacementTag:TDPTagDefault];
    }
}

- (IBAction)showBanner:(id)sender
{
    NSInteger tagInt = [self.showBannerBtn tag];
    
    if (tagInt == 1) {
        [self.adBanner removeFromSuperview];
        
        [self.showBannerBtn setTag:0];
        [self.showBannerBtn setTitle:@"Show" forState:UIControlStateNormal];
        [self.showBannerBtn setEnabled:NO];
    } else {
        if (self.adBanner != nil) {
            
            CGPoint adBannerCenter = CGPointMake(self.bannerView.frame.size.width / 2,
                                                 self.bannerView.frame.size.height / 2);
            
            [self.adBanner setCenter:adBannerCenter];
            [self.bannerView addSubview:self.adBanner];
            [self.bannerView setNeedsDisplay];
            
            [self.showBannerBtn setTag:1];
            [self.showBannerBtn setTitle:@"Hide" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)showDebugger:(id)sender
{
    [[Tapdaq sharedSession] presentDebugViewController];
}

#pragma mark - Private methods

- (void)logMessage:(NSString *)message
{
    NSString *text = [self.textView text];
    NSString *textAddition = [NSString stringWithFormat:@"%@\n\n%@", message, text];
    [self.textView setText:textAddition];
    
    NSLog(@"Mediation App: %@", message);
}

- (void)updateRewardUI
{
    NSString *rewardName = [[NSUserDefaults standardUserDefaults] objectForKey:kRewardNameKey];
    NSNumber *rewardAmount = [[NSUserDefaults standardUserDefaults] objectForKey:kRewardAmountKey];
    
    if (!rewardName) {
        rewardName = @"Reward";
    }
    
    if (!rewardAmount) {
        rewardAmount = @(0);
    }
    
    [self.rewardName setText:rewardName];
    [self.rewardAmount setText:[rewardAmount stringValue]];
}

#pragma mark - TapdaqDelegate

- (void)didLoadConfig
{
    [self logMessage:@"Tapdaq config loaded"];
    [self updateUI];
}

- (void)didFailToLoadConfigWithError:(TDError *)error
{
    [self logMessage:@"Tapdaq config failed to load"];
    [self updateUI];
}

#pragma mark - TDAdRequestDelegate

- (void)didLoadAdRequest:(TDAdRequest *)adRequest
{
    [self logMessage:[NSString stringWithFormat:@"Did load \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
    if ([adRequest.placement.tag isEqualToString:TDPTagDefault]) {
        switch (adRequest.placement.adTypes) {
            case TDAdTypeInterstitial:
                self.interstitialAdRequest = (TDMediationAdRequest *)adRequest;
                break;
            case TDAdTypeVideo:
                self.videoAdRequest = (TDMediationAdRequest *)adRequest;
                break;
            case TDAdTypeRewardedVideo:
                self.rewardedAdRequest = (TDMediationAdRequest *)adRequest;
            default:
                break;
        }
    }
    [self updateUI];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToLoadWithError:(TDError *)error
{
    [self logMessage:[NSString stringWithFormat:@"Failed to load \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
    [self logMessage:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
}

#pragma mark - TDDisplayableAdRequestDelegate

- (void)willDisplayAdRequest:(TDAdRequest *)adRequest
{
    [self logMessage:[NSString stringWithFormat:@"Will display \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
}

- (void)didDisplayAdRequest:(TDAdRequest *)adRequest
{
    [self logMessage:[NSString stringWithFormat:@"Did display \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToDisplayWithError:(TDError *)error {
    [self logMessage:[NSString stringWithFormat:@"Failed to display \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
    [self logMessage:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
}

- (void)didCloseAdRequest:(TDAdRequest *)adRequest
{
    [self logMessage:[NSString stringWithFormat:@"Did Close \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
    [self updateUI];
}

#pragma mark - TDClickableAdRequestDelegate

- (void)didClickAdRequest:(TDAdRequest *)adRequest
{
    [self logMessage:[NSString stringWithFormat:@"Did Click \"%@\" - tag: \"%@\"", AdTypeNameFromTDAdTypes(adRequest.placement.adTypes), adRequest.placement.tag]];
}

#pragma mark - TDRewardedVideoAdRequestDelegate

- (void)adRequest:(TDAdRequest *)adRequest didValidateReward:(TDReward *)reward
{
    NSNumber *storedRewardAmount = [[NSUserDefaults standardUserDefaults] objectForKey:kRewardAmountKey];
    
    int storedRewardAmountInt = [storedRewardAmount intValue];
    int updatedRewardAmountInt = storedRewardAmountInt + reward.value;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(updatedRewardAmountInt) forKey:kRewardAmountKey];
    [[NSUserDefaults standardUserDefaults] setObject:reward.name forKey:kRewardNameKey];
    
    if (reward.customJson) {
        [[NSUserDefaults standardUserDefaults] setObject:reward.customJson forKey:kRewardPayloadKey];
    }
    
    [self updateRewardUI];
    
    [self logMessage:[NSString stringWithFormat:@"Received reward for tag:%@ name:%@ value:%d custom JSON: %@", adRequest.placement.tag, reward.name, reward.value, reward.customJson]];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToValidateReward:(TDReward * _Nonnull)reward
{
    [self logMessage:[NSString stringWithFormat:@"Failed to validate reward for tag: %@", adRequest.placement.tag]];

}
#pragma mark Banner delegate methods

- (void)didLoadBanner
{
    [self updateUI];
    [self logMessage:@"Did load banner"];
}

- (void)didClickBanner
{
    [self logMessage:@"Did click banner"];
}

- (void)didRefreshBanner
{
    [self logMessage:@"Did refresh banner"];
}

@end
