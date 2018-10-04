//
//  ViewController.h
//  NativeAds
//
//  Created by Nick Reffitt on 15/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tapdaq/Tapdaq.h>

@interface ViewController : UIViewController <TapdaqDelegate>

@property (nonatomic, strong) IBOutlet UIButton *loadNativeAdBtn;
@property (nonatomic, strong) IBOutlet UIButton *showNativeAdBtn;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UITextView *textView;

- (IBAction)loadNativeAd:(id)sender;
- (IBAction)showNativeAd:(id)sender;

@end

