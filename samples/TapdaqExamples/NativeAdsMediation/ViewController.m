//
//  ViewController.m
//  NativeAdsMediation
//
//  Created by Dmitry Dovgoshliubnyi on 03/04/2018.
//  Copyright © 2018 Tapdaq. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import <Tapdaq/Tapdaq.h>

@interface ViewController () <TapdaqDelegate, TDAdRequestDelegate>
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialContextLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;
@property (weak, nonatomic) IBOutlet UIButton *callToActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIView *smallAdView;
@property (weak, nonatomic) IBOutlet UILabel *smallTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallSubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallStarsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *smallCallToActionButton;

@property (weak, nonatomic) IBOutlet UIButton *loadLargeAdButton;
@property (weak, nonatomic) IBOutlet UIButton *loadSmallAdButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TDPlacement *placement  = [[TDPlacement alloc] initWithAdTypes:TDAdTypeMediatedNative forTag:TDPTagDefault];
    
    TDPlacement *placementMainMenu  = [[TDPlacement alloc] initWithAdTypes:TDAdTypeMediatedNative forTag:@"main_menu"];
    
    TDProperties *properties = [TDProperties defaultProperties];
    [properties registerPlacement:placement];
    [properties registerPlacement:placementMainMenu];
    
    properties.logLevel = TDLogLevelDebug;
    
    Tapdaq.sharedSession.delegate = self;
    [Tapdaq.sharedSession setApplicationId:kAppId clientKey:kClientKey properties:properties];
    
    self.adView.layer.shadowColor = UIColor.blackColor.CGColor;
    self.adView.layer.shadowOffset = CGSizeMake(1, 1);
    self.adView.layer.shadowOpacity = 0.12;
    self.adView.layer.shadowRadius = 5;
    
    self.smallAdView.layer.shadowColor = UIColor.blackColor.CGColor;
    self.smallAdView.layer.shadowOffset = CGSizeMake(1, 1);
    self.smallAdView.layer.shadowOpacity = 0.12;
    self.smallAdView.layer.shadowRadius = 5;
    
    
}

- (IBAction)loadLargeAd:(id)sender {
    [Tapdaq.sharedSession loadNativeAdInViewController:self placementTag:TDPTagDefault options:TDMediatedNativeAdOptionsAdChoicesTopRight delegate:self];
}

- (IBAction)loadSmallAd:(id)sender {
    [Tapdaq.sharedSession loadNativeAdInViewController:self placementTag:@"main_menu" options:TDMediatedNativeAdOptionsAdChoicesBottomRight delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadConfig {
    self.loadSmallAdButton.enabled = true;
    self.loadLargeAdButton.enabled = true;
}

- (void)didFailToLoadConfigWithError:(TDError *)error {
    NSLog(@"Failed to load config: %@", error.localizedDescription);
}

- (void)didLoadAdRequest:(TDAdRequest *)adRequest {
    if ([adRequest isKindOfClass:[TDNativeAdRequest class]]) {
        TDNativeAdRequest *nativeAdRequest = (TDNativeAdRequest *)adRequest;
        
        TDMediatedNativeAd *nativeAd = nativeAdRequest.nativeAd;
        
        if (nativeAd != nil) {
            if ([nativeAdRequest.placement.tag isEqualToString:TDPTagDefault]) {
                self.adView.hidden = false;
                [nativeAd setAdView:self.adView];
                [nativeAd registerView:self.callToActionButton type:TDMediatedNativeAdViewTypeCallToAction];
                [nativeAd registerView:self.titleLabel type:TDMediatedNativeAdViewTypeHeadline];
                [nativeAd registerView:self.iconImageView type:TDMediatedNativeAdViewTypeLogo];
                [nativeAd registerView:self.imageView type:TDMediatedNativeAdViewTypeImageView];
                [nativeAd registerView:self.priceLabel type:TDMediatedNativeAdViewTypePrice];
                [nativeAd registerView:self.starsLabel type:TDMediatedNativeAdViewTypeStarRating];
                [nativeAd registerView:self.subtitleLabel type:TDMediatedNativeAdViewTypeSubtitle];
                [nativeAd.icon getAsyncImage:^(UIImage * iconImage) {
                    self.iconImageView.image = iconImage;
                }];
                [nativeAd.images.firstObject getAsyncImage:^(UIImage * image) {
                    self.imageView.image = image;
                }];
                self.titleLabel.text = nativeAd.title;
                self.subtitleLabel.text = nativeAd.subtitle;
                self.bodyLabel.text = nativeAd.body;
                self.priceLabel.text = nativeAd.price;
                self.socialContextLabel.text = nativeAd.socialContext;
                self.callToActionButton.hidden = nativeAd.callToAction == nil;
                self.callToActionButton.userInteractionEnabled = false;
                [self.callToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];
                
                self.starsLabel.text = [NSString stringWithFormat:@"%f", nativeAd.starRating.doubleValue];
                [nativeAd trackImpression];
            } else if ([nativeAdRequest.placement.tag isEqualToString:@"main_menu"]) {
                self.smallAdView.hidden = false;
                [nativeAd setAdView:self.smallAdView];
                [nativeAd registerView:self.smallCallToActionButton type:TDMediatedNativeAdViewTypeCallToAction];
                [nativeAd registerView:self.smallTitleLabel type:TDMediatedNativeAdViewTypeHeadline];
                [nativeAd registerView:self.smallIconImageView type:TDMediatedNativeAdViewTypeLogo];
                [nativeAd registerView:self.smallSubtitleLabel type:TDMediatedNativeAdViewTypeSubtitle];
                [nativeAd.icon getAsyncImage:^(UIImage * iconImage) {
                    self.smallIconImageView.image = iconImage;
                }];
                self.smallTitleLabel.text = nativeAd.title;
                self.smallSubtitleLabel.text = nativeAd.subtitle;
                self.smallCallToActionButton.hidden = nativeAd.callToAction == nil;
                self.smallCallToActionButton.userInteractionEnabled = false;
                [self.smallCallToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];
                
                [nativeAd trackImpression];
            }
        }
        
    }
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToLoadWithError:(TDError *)error {
    NSLog(@"Failed to load an ad: %@", error.localizedDescription);
}
@end
