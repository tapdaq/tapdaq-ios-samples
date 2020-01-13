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

NSString *NSStringFromAdType(TDAdTypes adType) {
    switch (adType) {
        case TDAdTypeInterstitial:
            return @"Static Interstitial";
        case TDAdTypeVideo:
            return @"Video Interstitial";
        case TDAdTypeRewardedVideo:
            return @"Rewarded Video";
        case TDAdTypeBanner:
            return @"Banner";
        case TDAdTypeMediatedNative:
            return @"Native";
        default:
            return @"Unknown";
    }
}

NSString *NSStringFromBannerSize(TDMBannerSize size) {
    switch (size) {
        case TDMBannerStandard:
            return @"Standard";
        case TDMBannerMedium:
            return @"Medium";
        case TDMBannerLarge:
            return @"Large";
        case TDMBannerSmartPortrait:
            return @"Smart Portrait";
        case TDMBannerSmartLandscape:
            return @"Smart Landscape";
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
@property (copy, nonatomic) NSArray *adTypes;
@property (copy, nonatomic) NSArray *bannerSizes;
@property (strong, nonatomic) UIView *bannerView;
@property (strong, nonatomic) TDMediatedNativeAd *nativeAd;
// State
@property (assign, nonatomic) TDMBannerSize selectedBannerSize;
@property (assign, nonatomic) TDAdTypes selectedAdType;
@property (strong, nonatomic) NSString *placementTag;
@end

@implementation MediationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    self.adTypes = @[ @(TDAdTypeInterstitial),
                      @(TDAdTypeVideo),
                      @(TDAdTypeRewardedVideo),
                      @(TDAdTypeBanner),
                      @(TDAdTypeMediatedNative) ];
    self.bannerSizes = @[ @(TDMBannerStandard),
                          @(TDMBannerSmartPortrait),
                          @(TDMBannerSmartLandscape),
                          @(TDMBannerMedium),
                          @(TDMBannerLarge),
                          @(TDMBannerLeaderboard),
                          @(TDMBannerFull)];
    self.selectedBannerSize = [self.bannerSizes.firstObject integerValue];
    self.selectedAdType = [self.adTypes.firstObject integerValue];
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

        if (self.selectedAdType == TDAdTypeBanner) {
            self.textFieldPlacementTag.text = TDPTagDefault;
        } else {
            self.textFieldPlacementTag.text = self.placementTag;
        }
        
        if (self.selectedAdType == TDAdTypeBanner || self.selectedAdType == TDAdTypeMediatedNative) {
            if (self.viewBannerContainer.subviews.count == 0) {
                isLoadEnabled = isLoadEnabled && YES;
                [self.buttonShow setTitle:@"Show" forState:UIControlStateNormal];
            } else {
                isLoadEnabled = NO;
                [self.buttonShow setTitle:@"Hide" forState:UIControlStateNormal];
            }
        }
        
        if (self.selectedAdType == TDAdTypeBanner) {
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
    switch (self.selectedAdType) {
        case TDAdTypeInterstitial:
            return [Tapdaq.sharedSession isInterstitialReadyForPlacementTag:self.placementTag];
        case TDAdTypeVideo:
            return [Tapdaq.sharedSession isVideoReadyForPlacementTag:self.placementTag];
        case TDAdTypeRewardedVideo:
            return [Tapdaq.sharedSession isRewardedVideoReadyForPlacementTag:self.placementTag];
        case TDAdTypeBanner:
            return self.bannerView != nil;
        case TDAdTypeMediatedNative:
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
    if (self.selectedAdType != TDAdTypeBanner) {
        [self.logView log:@"Loading %@ for tag %@...", NSStringFromAdType(self.selectedAdType), self.placementTag];
    }
    switch (self.selectedAdType) {
        case TDAdTypeInterstitial: {
            [Tapdaq.sharedSession loadInterstitialForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDAdTypeVideo: {
            [Tapdaq.sharedSession loadVideoForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDAdTypeRewardedVideo: {
            [Tapdaq.sharedSession loadRewardedVideoForPlacementTag:self.placementTag delegate:self];
            break;
        }
        case TDAdTypeBanner: {
            
            [self.logView log:@"Loading %@ %@ for tag %@...",NSStringFromBannerSize(self.selectedBannerSize), NSStringFromAdType(self.selectedAdType), TDPTagDefault];
            [Tapdaq.sharedSession loadBannerWithSize:self.selectedBannerSize completion:^(UIView *newBannerView) {
                self.bannerView = newBannerView;
                [self.logView log:@"Did load Banner"];
                [self update];
            }];
            break;
        }
        case TDAdTypeMediatedNative: {
            [Tapdaq.sharedSession loadNativeAdInViewController:self placementTag:self.placementTag options:TDMediatedNativeAdOptionsAdChoicesTopRight delegate:self];
            break;
        }
        default:
            break;
    }
}

- (void)showCurrentAdType {
    NSString *logMessage = [NSString stringWithFormat:@"Showing %@ for tag %@...", NSStringFromAdType(self.selectedAdType), self.placementTag];
    
    switch (self.selectedAdType) {
        case TDAdTypeInterstitial: {
            [Tapdaq.sharedSession showInterstitialForPlacementTag:self.placementTag];
            break;
        }
        case TDAdTypeVideo: {
            [Tapdaq.sharedSession showVideoForPlacementTag:self.placementTag];
            break;
        }
        case TDAdTypeRewardedVideo: {
            [Tapdaq.sharedSession showRewardedVideoForPlacementTag:self.placementTag hashedUserId:@"mediation_sample_user_id"];
            break;
        }
        case TDAdTypeBanner: {
            if (self.bannerView != nil && self.viewBannerContainer.subviews.count == 0) {
                [self showAdView:self.bannerView];
            } else {
                logMessage = nil;
                self.bannerView = nil;
                [self hideAdView];
            }
            break;
        }
        case TDAdTypeMediatedNative: {
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
    [self.logView log:@"Hidden %@ for tag %@", NSStringFromAdType(self.selectedAdType), self.placementTag];
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

- (void)didRefreshBanner {
    [self.logView log:@"Did refresh banner"];
}

#pragma mark - TDAdRequestDelegate

- (void)didLoadAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did load ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
    if ([adRequest isKindOfClass:TDNativeAdRequest.class]) {
        self.nativeAd = [(TDNativeAdRequest *)adRequest nativeAd];
    }
    [self update];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToLoadWithError:(TDError * _Nullable)error {
    [self.logView log:@"Did fail to load ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, error.localizedDescription];
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
    [self.logView log:@"Did fail to display ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, errorString];
}

- (void)willDisplayAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Will display ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
}

- (void)didDisplayAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did display ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
}

- (void)didCloseAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did close ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
    [self update];
}

#pragma mark TDClickableAdRequestDelegate
- (void)didClickAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did click ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
}

#pragma mark TDRewardedVideoAdRequestDelegate
- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didValidateReward:(TDReward * _Nonnull)reward {
    [self.logView log:@"Validated reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? @"TRUE" : @"FALSE", reward.hashedUserId, reward.customJson];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToValidateReward:(TDReward * _Nonnull)reward {
    [self.logView log:@"Failed to validate reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? @"TRUE" : @"FALSE", reward.hashedUserId, reward.customJson];
}

#pragma mark TDBannerAdRequestDelegate
- (void)didRefreshBannerForAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did refresh ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
}

#pragma mark - Getters/Setters
- (void)setSelectedAdType:(TDAdTypes)selectedAdType {
    _selectedAdType = selectedAdType;
    self.textFieldAdUnit.text = NSStringFromAdType(selectedAdType);
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
    } else if (textField == self.textFieldPlacementTag && self.selectedAdType == TDAdTypeBanner) {
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
            [self.pickerViewAdUnit selectRow:[self.adTypes indexOfObject:@(self.selectedAdType)] inComponent:0 animated:NO];
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
    return self.adTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pickerViewBannerSize) {
        return NSStringFromBannerSize([self.bannerSizes[row] integerValue]);
    }
    return NSStringFromAdType([self.adTypes[row] integerValue]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerViewBannerSize) {
        self.selectedBannerSize = [self.bannerSizes[row] integerValue];
    } else {
        self.selectedAdType = [self.adTypes[row] integerValue];
    }
    [self update];
}
@end
