//
//  ViewController.h
//  Mediation
//
//  Created by Nick Reffitt on 15/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tapdaq/Tapdaq.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *bannerView;
@property (nonatomic, strong) UIView *adBanner;

@property (nonatomic, strong) IBOutlet UIButton *loadBannerBtn;
@property (nonatomic, strong) IBOutlet UIButton *loadInterstitialBtn;
@property (nonatomic, strong) IBOutlet UIButton *loadVideoBtn;
@property (nonatomic, strong) IBOutlet UIButton *loadRewardedBtn;

@property (nonatomic, strong) IBOutlet UIButton *showBannerBtn;
@property (nonatomic, strong) IBOutlet UIButton *showInterstitialBtn;
@property (nonatomic, strong) IBOutlet UIButton *showVideoBtn;
@property (nonatomic, strong) IBOutlet UIButton *showRewardedBtn;

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *rewardName;
@property (nonatomic, strong) IBOutlet UILabel *rewardAmount;

- (IBAction)loadAd:(UIButton *)sender;

- (IBAction)showAd:(UIButton *)sender;

- (IBAction)showBanner:(id)sender;

@end

