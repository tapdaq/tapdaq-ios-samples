//
//  MediationViewController.m
//  Mediation
//
//  Created by Dmitry Dovgoshliubnyi on 01/04/2019.
//

#import "MediationViewController.h"
#import "Constants.h"
#import "LogView.h"
#import "TDNativeAdView.h"
#import <Tapdaq/Tapdaq.h>


NSString *NSStringFromBannerSize(TDMBannerSize size) {
    switch (size) {
        case TDMBannerStandard:
            return @"Standard";
        case TDMBannerMedium:
            return @"Medium";
        case TDMBannerLarge:
            return @"Large";
        case TDMBannerSmart:
            return @"Smart";
        case TDMBannerLeaderboard:
            return @"Leaderboard";
        case TDMBannerFull:
            return @"Full";
        default:
            return @"Unknown";
    }
}

@interface MediationViewController () <TapdaqDelegate, TDAdRequestDelegate, TDClickableAdRequestDelegate,  TDDisplayableAdRequestDelegate, TDRewardedVideoAdRequestDelegate, TDBannerAdRequestDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
// View
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAdUnit;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPlacementTag;
@property (strong, nonatomic) UITextField *textFieldDummy;
@property (strong, nonatomic) UITextField *textFieldBannerSizeDummy;
@property (strong, nonatomic) UIPickerView *pickerViewAdUnit;
@property (strong, nonatomic) UIPickerView *pickerViewBannerSize;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoad;
@property (weak, nonatomic) IBOutlet UIButton *buttonShow;
@property (weak, nonatomic) IBOutlet LogView *logView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAdHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *viewBannerContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelPlacementTag;
// Data
@property (copy, nonatomic) NSArray *adUnits;
@property (copy, nonatomic) NSArray *bannerSizes;
@property (strong, nonatomic) UIView *bannerView;
@property (strong, nonatomic) TDMediatedNativeAd *nativeAd;
// State
@property (assign, nonatomic) TDMBannerSize selectedBannerSize;
@property (assign, nonatomic) TDAdUnit selectedAdUnit;
@property (strong, nonatomic) NSString *placementTag;
@end

@implementation MediationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    self.adUnits = @[ @(TDUnitStaticInterstitial),
                      @(TDUnitVideoInterstitial),
                      @(TDUnitRewardedVideo),
                      @(TDUnitBanner),
                      @(TDUnitMediatedNative) ];
    self.bannerSizes = @[ @(TDMBannerStandard),
                          @(TDMBannerSmart),
                          @(TDMBannerMedium),
                          @(TDMBannerLarge),
                          @(TDMBannerLeaderboard),
                          @(TDMBannerFull)];
    self.selectedBannerSize = [self.bannerSizes.firstObject integerValue];
    self.selectedAdUnit = [self.adUnits.firstObject integerValue];
    self.placementTag = self.textFieldPlacementTag.text = TDPTagDefault;
    
    self.textFieldDummy = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.textFieldDummy];
    self.pickerViewAdUnit = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerViewAdUnit.dataSource = self;
    self.pickerViewAdUnit.delegate = self;
    self.textFieldDummy.inputView = self.pickerViewAdUnit;
    
    self.textFieldBannerSizeDummy = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.textFieldBannerSizeDummy];
    self.pickerViewBannerSize = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerViewBannerSize.dataSource = self;
    self.pickerViewBannerSize.delegate = self;
    self.textFieldBannerSizeDummy.inputView = self.pickerViewBannerSize;
    
    self.labelVersion.text = [NSString stringWithFormat:@"Tapdaq SDK v%@", Tapdaq.sharedSession.sdkVersion];
    [self update];
}

- (void)update {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
        self.buttonShow.enabled = [[Tapdaq sharedSession] isInitialised] && [self isCurrentAdTypeReady];
        BOOL isLoadEnabled = [[Tapdaq sharedSession] isInitialised];

        if (self.selectedAdUnit == TDUnitBanner) {
            self.textFieldPlacementTag.text = TDPTagDefault;
        } else {
            self.textFieldPlacementTag.text = self.placementTag;
        }
        
        if (self.selectedAdUnit == TDUnitBanner || self.selectedAdUnit == TDUnitMediatedNative) {
            if (self.viewBannerContainer.subviews.count == 0) {
                isLoadEnabled = isLoadEnabled && YES;
                [self.buttonShow setTitle:@"Show" forState:UIControlStateNormal];
            } else {
                isLoadEnabled = NO;
                [self.buttonShow setTitle:@"Hide" forState:UIControlStateNormal];
            }
        }
        
        if (self.selectedAdUnit == TDUnitBanner) {
            self.labelPlacementTag.text = @"Banner Size:";
            self.textFieldPlacementTag.text = NSStringFromBannerSize(self.selectedBannerSize);
        } else {
            self.labelPlacementTag.text = @"Placement Tag:";
        }
        self.buttonLoad.enabled = isLoadEnabled;
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - Tapdaq
- (void)setupTapdaq {
    TDProperties *properties = [Tapdaq.sharedSession properties];
    if(properties == nil) {
        properties = TDProperties.defaultProperties;
    }
    properties.logLevel = TDLogLevelDebug;
    [properties registerTestDevices:[[TDTestDevices alloc] initWithNetwork:TDMAdMob testDevices:[[NSMutableArray alloc] initWithObjects:kAdMobTestDevice, nil]]];
    [properties registerTestDevices:[[TDTestDevices alloc] initWithNetwork:TDMFacebookAudienceNetwork testDevices:[[NSMutableArray alloc] initWithObjects:kFANTestDevice, nil]]];
    
    Tapdaq.sharedSession.delegate = self;
    [Tapdaq.sharedSession setApplicationId:kAppId clientKey:kClientKey properties:properties];
    [self.logView log:@"Loading config for:\n    App ID: %@\n    Client Key: %@", kAppId, kClientKey];
}

- (BOOL)isCurrentAdTypeReady {
    switch (self.selectedAdUnit) {
        case TDUnitStaticInterstitial:
            return [Tapdaq.sharedSession isInterstitialReadyForPlacementTag:self.placementTag];
        case TDUnitVideoInterstitial:
            return [Tapdaq.sharedSession isVideoReadyForPlacementTag:self.placementTag];
        case TDUnitRewardedVideo:
            return [Tapdaq.sharedSession isRewardedVideoReadyForPlacementTag:self.placementTag];
        case TDUnitBanner:
            return self.bannerView != nil;
        case TDUnitMediatedNative:
            return self.nativeAd != nil;
        default:
            return NO;
    }
}

- (void)loadCurrentAdType {
    if (self.placementTag.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Placement Tag cannot be empty." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:closeAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    if (self.selectedAdUnit != TDUnitBanner) {
        [self.logView log:@"Loading %@ for tag %@...", NSStringFromAdUnit(self.selectedAdUnit), self.placementTag];
    }
    switch (self.selectedAdUnit) {
        case TDUnitStaticInterstitial: {
            [Tapdaq.sharedSession loadInterstitialForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDUnitVideoInterstitial: {
            [Tapdaq.sharedSession loadVideoForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDUnitRewardedVideo: {
            [Tapdaq.sharedSession loadRewardedVideoForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDUnitBanner: {
            
            [self.logView log:@"Loading %@ %@ for tag %@...",NSStringFromBannerSize(self.selectedBannerSize), NSStringFromAdUnit(self.selectedAdUnit), TDPTagDefault];
            [Tapdaq.sharedSession loadBannerForPlacementTag:TDPTagDefault withSize:self.selectedBannerSize delegate:self];
            break;
        }
        case TDUnitMediatedNative: {
            [Tapdaq.sharedSession loadNativeAdInViewController:self placementTag:self.placementTag options:TDMediatedNativeAdOptionsAdChoicesTopRight delegate:self];
            break;
        }
        default:
            break;
    }
}

- (void)showCurrentAdType {
    NSString *logMessage = [NSString stringWithFormat:@"Showing %@ for tag %@...", NSStringFromAdUnit(self.selectedAdUnit), self.placementTag];
    
    switch (self.selectedAdUnit) {
        case TDUnitStaticInterstitial: {
            [Tapdaq.sharedSession showInterstitialForPlacementTag:self.placementTag];
            break;
        }
        case TDUnitVideoInterstitial: {
            [Tapdaq.sharedSession showVideoForPlacementTag:self.placementTag];
            break;
        }
        case TDUnitRewardedVideo: {
            [Tapdaq.sharedSession showRewardedVideoForPlacementTag:self.placementTag];
            break;
        }
        case TDUnitBanner: {
            if (self.bannerView != nil && self.viewBannerContainer.subviews.count == 0) {
                [self showAdView:self.bannerView];
            } else {
                logMessage = nil;
                self.bannerView = nil;
                [self hideAdView];
            }
            break;
        }
        case TDUnitMediatedNative: {
            if (self.nativeAd != nil && self.viewBannerContainer.subviews.count == 0) {
                TDNativeAdView *adView = [[TDNativeAdView alloc] init];
                adView.nativeAd = self.nativeAd;
                [self showAdView:adView];
                [self.nativeAd setAdView:adView];
                [self.nativeAd trackImpression];
            } else {
                logMessage = nil;
                self.nativeAd = nil;
                [self hideAdView];
            }
            break;
        }
        default:
            break;
    }
    [self.logView log:logMessage];
}

- (void)showAdView:(UIView *)adView {
    [self.viewBannerContainer addSubview:adView];
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    self.viewAdHeightConstraint.constant = CGRectGetHeight(adView.frame) == 0 ? 250 : CGRectGetHeight(adView.frame);
    id views = @{ @"adView" : adView };
    id verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[adView]|" options:0 metrics:nil views:views];
    id horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[adView]|" options:0 metrics:nil views:views];
    [self.viewBannerContainer addConstraints:verticalConstraints];
    [self.viewBannerContainer addConstraints:horizontalConstraints];
    [self update];
}

- (void)hideAdView {
    if (self.viewBannerContainer.subviews.count == 0 ) { return; }
    [self.logView log:@"Hidden %@ for tag %@", NSStringFromAdUnit(self.selectedAdUnit), self.placementTag];
    self.viewAdHeightConstraint.constant = 0;
    for (UIView *subview in self.viewBannerContainer.subviews) { [subview removeFromSuperview]; }
    [self update];
}

#pragma mark - TapdaqDelegate
- (void)didLoadConfig {
    [self.logView log:@"Did load config"];
    [self update];
}

- (void)didFailToLoadConfigWithError:(NSError *)error {
    [self.logView log:@"Did fail to load config with error: %@", error.localizedDescription];
    [self update];
}

#pragma mark - TDAdRequestDelegate

- (void)didLoadAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did load ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
    if ([adRequest isKindOfClass:TDNativeAdRequest.class]) {
        self.nativeAd = [(TDNativeAdRequest *)adRequest nativeAd];
    } else if ([adRequest isKindOfClass:TDBannerAdRequest.class]) {
        self.bannerView = [(TDBannerAdRequest *)adRequest bannerView];
        [self.logView log:@"Did load Banner"];
        [self update];
    }
    [self update];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToLoadWithError:(TDError * _Nullable)error {
    [self.logView log:@"Did fail to load ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, error.localizedDescription];
}

#pragma mark TDDisplayableAdRequestDelegate
- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToDisplayWithError:(TDError * _Nullable)error {
    NSMutableString *errorString = [[NSMutableString alloc] init];
    [errorString appendString:error.localizedDescription];
    for (NSString *network in error.subErrors.allKeys) {
        [errorString appendFormat:@"\n    %@:", network];
        for (NSError *subError in error.subErrors) {
            [errorString appendFormat:@"\n      -> %@", subError.localizedDescription];
        }
    }
    [self.logView log:@"Did fail to display ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, errorString];
}

- (void)willDisplayAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Will display ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
}

- (void)didDisplayAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did display ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
}

- (void)didCloseAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did close ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
    [self update];
}

#pragma mark TDClickableAdRequestDelegate
- (void)didClickAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did click ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
}

#pragma mark TDRewardedVideoAdRequestDelegate
- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didValidateReward:(TDReward * _Nonnull)reward {
    [self.logView log:@"Validated reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? @"TRUE" : @"FALSE", reward.hashedUserId, reward.customJson];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToValidateReward:(TDReward * _Nonnull)reward {
    [self.logView log:@"Failed to validate reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? @"TRUE" : @"FALSE", reward.hashedUserId, reward.customJson];
}

#pragma mark TDBannerAdRequestDelegate
- (void)didRefreshBannerForAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did refresh ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
}

- (void)didFailToRefreshBannerForAdRequest:(TDBannerAdRequest *)adRequest withError:(TDError *)error {
    [self.logView log:@"Did fail to refresh ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag];
}

#pragma mark - Getters/Setters
- (void)setSelectedAdUnit:(TDAdUnit)selectedAdUnit {
    _selectedAdUnit = selectedAdUnit;
    self.textFieldAdUnit.text = NSStringFromAdUnit(selectedAdUnit);
}

#pragma mark - Actions

- (IBAction)actionButtonInitialiseTapped:(id)sender {
    [self setupTapdaq];
}
#pragma mark Button Debugger
- (IBAction)actionButtonDebuggerTapped:(id)sender {
    [self.view endEditing:YES];
    [Tapdaq.sharedSession presentDebugViewController];
}
#pragma mark Button Load
- (IBAction)actionButtonLoadTapped:(id)sender {
    [self.view endEditing:YES];
    [self loadCurrentAdType];
}

#pragma mark Button Show
- (IBAction)actionButtonShowTapped:(id)sender {
    [self.view endEditing:YES];
    [self showCurrentAdType];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.textFieldAdUnit) {
        [self.textFieldDummy becomeFirstResponder];
        self.nativeAd = nil;
        self.bannerView = nil;
        [self hideAdView];
        return NO;
    } else if (textField == self.textFieldPlacementTag && self.selectedAdUnit == TDUnitBanner) {
        [self.textFieldBannerSizeDummy becomeFirstResponder];
        self.nativeAd = nil;
        self.bannerView = nil;
        [self hideAdView];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.textFieldDummy) {
            [self.pickerViewAdUnit selectRow:[self.adUnits indexOfObject:@(self.selectedAdUnit)] inComponent:0 animated:NO];
    } else if (textField == self.textFieldBannerSizeDummy) {
        [self.pickerViewAdUnit selectRow:[self.bannerSizes indexOfObject:@(self.selectedBannerSize)] inComponent:0 animated:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.textFieldPlacementTag) {
        NSString *currentText = textField.text;
        NSString *newText = [currentText stringByReplacingCharactersInRange:range withString:string];
        BOOL shouldChange = [TDPlacement isValidTag:newText] || newText.length == 0;
        if (shouldChange) {
            self.placementTag = newText;
            [self update];
        }
        return shouldChange;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    if (textField == self.textFieldPlacementTag) {
        [self update];
    }
    return YES;
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pickerViewBannerSize) {
        return self.bannerSizes.count;
    }
    return self.adUnits.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pickerViewBannerSize) {
        return NSStringFromBannerSize([self.bannerSizes[row] integerValue]);
    }
    return NSStringFromAdUnit([self.adUnits[row] integerValue]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerViewBannerSize) {
        self.selectedBannerSize = [self.bannerSizes[row] integerValue];
    } else {
        self.selectedAdUnit = [self.adUnits[row] integerValue];
    }
    [self update];
}
@end
