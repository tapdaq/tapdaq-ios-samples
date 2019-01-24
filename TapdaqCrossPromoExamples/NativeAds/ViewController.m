//
//  ViewController.m
//  NativeAds
//
//  Created by Nick Reffitt on 15/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) TDNativeAdvert *nativeAdvert;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Tapdaq sharedSession] setDelegate:self];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdvert:)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showDebugger:(id)sender {
    [[Tapdaq sharedSession] presentDebugViewController];
}

- (IBAction)loadNativeAd:(id)sender
{
    [self removeNativeTapdaqAdvert];
    
    [[Tapdaq sharedSession] loadNativeAdvertForPlacementTag:TDPTagDefault
                                                     adType:TDNativeAdType1x1Large];
}

- (IBAction)showNativeAd:(id)sender
{
    TDNativeAdvert *nativeAdvert = [[Tapdaq sharedSession] getNativeAdvertForPlacementTag:TDPTagDefault
                                                                             adType:TDNativeAdType1x1Large];
    
    if (nativeAdvert && [nativeAdvert.creative isKindOfClass:[TDImageCreative class]]) {
        [self.imageView setImage:((TDImageCreative *)nativeAdvert.creative).image];
        [self.imageView setNeedsDisplay];

        [[Tapdaq sharedSession] triggerImpression:nativeAdvert];
        
        self.nativeAdvert = nativeAdvert;
        [self.showNativeAdBtn setEnabled:NO];
    }
}

#pragma mark - Private methods

- (IBAction)tapAdvert:(id)sender
{
    if (self.nativeAdvert) {
        [[Tapdaq sharedSession] triggerClick:self.nativeAdvert];
    }
}

- (void)removeNativeTapdaqAdvert
{
    [self.imageView setImage:nil];
    [self.imageView setNeedsDisplay];
    self.nativeAdvert = nil;
}

- (void)logMessage:(NSString *)message
{
    NSString *text = [self.textView text];
    NSString *textAddition = [NSString stringWithFormat:@"%@\n\n%@", message, text];
    [self.textView setText:textAddition];
    
    NSLog(@"NativeAds App: %@", message);
}

#pragma mark - TapdaqDelegate

- (void)didLoadConfig
{
    [self.loadNativeAdBtn setEnabled:YES];
    
    [self logMessage:@"didLoadConfig"];
}

- (void)didFailToLoadConfig
{
    [self logMessage:@"didFailToLoadConfig"];
}

- (void)didLoadNativeAdvertForPlacementTag:(NSString *)placementTag adType:(TDNativeAdType)nativeAdType
{
    if ([placementTag isEqualToString:TDPTagDefault] && nativeAdType == TDNativeAdType1x1Large) {
        [self.showNativeAdBtn setEnabled:YES];
    }
    
    [self logMessage:[NSString stringWithFormat:@"didLoadNativeAdvertForPlacementTag:%@ adType:%@",
                      placementTag, [self nativeAdTypeToString:nativeAdType]]];
}

- (void)didFailToLoadNativeAdvertForPlacementTag:(NSString *)placementTag adType:(TDNativeAdType)nativeAdType
{
    [self logMessage:[NSString stringWithFormat:@"didFailToLoadNativeAdvertForPlacementTag:%@ adType:%@",
                      placementTag, [self nativeAdTypeToString:nativeAdType]]];
}

#pragma mark - Misc

- (NSString *)nativeAdTypeToString:(TDNativeAdType)nativeAdType
{
    NSString *nativeAdTypeStr = kNativeAdTypeUnknown;

    if (nativeAdType == TDNativeAdType1x1Large) {
        nativeAdTypeStr = kNativeAdType1x1Large;
    } else if (nativeAdType == TDNativeAdType1x1Medium) {
        nativeAdTypeStr = kNativeAdType1x1Medium;
    } else if (nativeAdType == TDNativeAdType1x1Small) {
        nativeAdTypeStr = kNativeAdType1x1Small;
    } else if (nativeAdType == TDNativeAdType1x2Large) {
        nativeAdTypeStr = kNativeAdType1x2Large;
    } else if (nativeAdType == TDNativeAdType1x2Medium) {
        nativeAdTypeStr = kNativeAdType1x2Medium;
    } else if (nativeAdType == TDNativeAdType1x2Small) {
        nativeAdTypeStr = kNativeAdType1x2Small;
    } else if (nativeAdType == TDNativeAdType2x1Large) {
        nativeAdTypeStr = kNativeAdType2x1Large;
    } else if (nativeAdType == TDNativeAdType2x1Medium) {
        nativeAdTypeStr = kNativeAdType2x1Medium;
    } else if (nativeAdType == TDNativeAdType2x1Small) {
        nativeAdTypeStr = kNativeAdType2x1Small;
    } else if (nativeAdType == TDNativeAdType2x3Large) {
        nativeAdTypeStr = kNativeAdType2x3Large;
    } else if (nativeAdType == TDNativeAdType2x3Medium) {
        nativeAdTypeStr = kNativeAdType2x3Medium;
    } else if (nativeAdType == TDNativeAdType2x3Small) {
        nativeAdTypeStr = kNativeAdType2x3Small;
    } else if (nativeAdType == TDNativeAdType3x2Large) {
        nativeAdTypeStr = kNativeAdType3x2Large;
    } else if (nativeAdType == TDNativeAdType3x2Medium) {
        nativeAdTypeStr = kNativeAdType3x2Medium;
    } else if (nativeAdType == TDNativeAdType3x2Small) {
        nativeAdTypeStr = kNativeAdType3x2Small;
    } else if (nativeAdType == TDNativeAdType1x5Large) {
        nativeAdTypeStr = kNativeAdType1x5Large;
    } else if (nativeAdType == TDNativeAdType1x5Medium) {
        nativeAdTypeStr = kNativeAdType1x5Medium;
    } else if (nativeAdType == TDNativeAdType1x5Small) {
        nativeAdTypeStr = kNativeAdType1x5Small;
    } else if (nativeAdType == TDNativeAdType5x1Large) {
        nativeAdTypeStr = kNativeAdType5x1Large;
    } else if (nativeAdType == TDNativeAdType5x1Medium) {
        nativeAdTypeStr = kNativeAdType5x1Medium;
    } else if (nativeAdType == TDNativeAdType5x1Small) {
        nativeAdTypeStr = kNativeAdType5x1Small;
    }

    return nativeAdTypeStr;
}

@end
