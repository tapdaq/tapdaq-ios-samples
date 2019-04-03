//
//  MediationViewController.m
//  Mediation
//
//  Created by Dmitry Dovgoshliubnyi on 01/04/2019.
//

#import "MediationViewController.h"
#import "Constants.h"
#import "LogView.h"
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
        case TDAdTypeOfferwall:
            return @"Offerwall";
        case TDAdTypeMediatedNative:
            return @"Native";
        default:
            return @"Unknown";
    }
}

@interface MediationViewController () <TapdaqDelegate, TDAdRequestDelegate, UITextFieldDelegate, UITextPasteDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
// View
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAdUnit;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPlacementTag;
@property (strong, nonatomic) UITextField *textFieldDummy;
@property (strong, nonatomic) UIPickerView *pickerViewAdUnit;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoad;
@property (weak, nonatomic) IBOutlet UIButton *buttonShow;
@property (weak, nonatomic) IBOutlet LogView *logView;
// Data
@property (copy, nonatomic) NSArray *adTypes;

// State
@property (assign, nonatomic) TDAdTypes selectedAdType;
@property (strong, nonatomic) NSString *placementTag;
@end

@implementation MediationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupTapdaq];
}

- (void)setup {
    self.adTypes = @[ @(TDAdTypeInterstitial),
                      @(TDAdTypeVideo),
                      @(TDAdTypeRewardedVideo),
                      @(TDAdTypeBanner),
                      @(TDAdTypeOfferwall),
                      @(TDAdTypeMediatedNative) ];
    
    
    self.selectedAdType = [self.adTypes.firstObject integerValue];
    self.placementTag = self.textFieldPlacementTag.text = TDPTagDefault;
    
    self.textFieldDummy = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.textFieldDummy];
    self.pickerViewAdUnit = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerViewAdUnit.dataSource = self;
    self.pickerViewAdUnit.delegate = self;
    self.textFieldDummy.inputView = self.pickerViewAdUnit;
    self.labelVersion.text = [NSString stringWithFormat:@"Tapdaq SDK v%@", Tapdaq.sharedSession.sdkVersion];
    [self update];
}

- (void)update {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.buttonLoad.enabled = [[Tapdaq sharedSession] isInitialised];
        self.buttonShow.enabled = [[Tapdaq sharedSession] isInitialised] && [self isCurrentAdTypeReady];
        
        if (self.selectedAdType == TDAdTypeOfferwall || self.selectedAdType == TDAdTypeBanner) {
            self.textFieldPlacementTag.enabled = NO;
            self.textFieldPlacementTag.text = TDPTagDefault;
        } else {
            self.textFieldPlacementTag.enabled = YES;
            self.textFieldPlacementTag.text = self.placementTag;
        }
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - Tapdaq
- (void)setupTapdaq {
    TDProperties *properties = TDProperties.defaultProperties;
    properties.logLevel = TDLogLevelDebug;
    Tapdaq.sharedSession.delegate = self;
    [Tapdaq.sharedSession setApplicationId:kAppId clientKey:kClientKey properties:properties];
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
        case TDAdTypeOfferwall:
        case TDAdTypeMediatedNative:
        default:
            return NO;
    }
}

- (void)loadCurrentAdType {
    [self.logView log:@"Loading %@ for tag %@...", NSStringFromAdType(self.selectedAdType), self.placementTag];
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
            break;
        }
        case TDAdTypeOfferwall: {
            break;
        }
        case TDAdTypeMediatedNative: {
            break;
        }
        default:
            break;
    }
}

- (void)showCurrentAdType {
    [self.logView log:@"Showing %@ for tag %@...", NSStringFromAdType(self.selectedAdType), self.placementTag];
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
            [Tapdaq.sharedSession showRewardedVideoForPlacementTag:self.placementTag hashedUserId:@"hashed_user_id"];
            break;
        }
        case TDAdTypeOfferwall: {
            [Tapdaq.sharedSession showOfferwall];
            break;
        }
        default:
            break;
    }
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
    [self.logView log:@"Did load ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
    [self update];
}

- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToLoadWithError:(TDError * _Nullable)error {
    [self.logView log:@"Did fail to load ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, error.localizedDescription];
}

#pragma mark TDDisplayableAdRequestDelegate
- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didFailToDisplayWithError:(TDError * _Nullable)error {
    [self.logView log:@"Did fail to display ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, error.localizedDescription];
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

#pragma mark TDOfferwallAdRequestDelegate
- (void)adRequest:(TDAdRequest * _Nonnull)adRequest didReceiveOfferwallCredits:(NSDictionary * _Nullable)creditInfo {
    [self.logView log:@"Did receive credits ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];
}

- (void)didFailToReceiveOfferwallCreditsAdRequest:(TDAdRequest * _Nonnull)adRequest {
    [self.logView log:@"Did fail to receive credits ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag];

}
#pragma mark - Getters/Setters
- (void)setSelectedAdType:(TDAdTypes)selectedAdType {
    _selectedAdType = selectedAdType;
    self.textFieldAdUnit.text = NSStringFromAdType(selectedAdType);
}

#pragma mark - Actions

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
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.textFieldDummy) {
        [self.pickerViewAdUnit selectRow:[self.adTypes indexOfObject:@(self.selectedAdType)] inComponent:0 animated:NO];
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
    return self.adTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return NSStringFromAdType([self.adTypes[row] integerValue]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedAdType = [self.adTypes[row] integerValue];
    [self update];
}
@end
