//
//  TDNativeAdView.m
//  Tapdaq
//
//  Copyright © 2019 Tapdaq. All rights reserved.
//

#import "TDNativeAdView.h"
#import <Tapdaq/Tapdaq.h>

@interface TDNativeAdView ()
@property (strong, nonatomic) UIView *viewIcon;
@property (strong, nonatomic) UILabel *labelTitle;
@property (strong, nonatomic) UIButton *buttonCallToAction;
@property (strong, nonatomic) UIView *viewContainerMediaView;

@property (strong, nonatomic) NSLayoutConstraint *viewContainerMediaViewAspectRatioConstraint;
@end

@implementation TDNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        _viewIcon = [[UIView alloc] initWithFrame:CGRectZero];
        _viewIcon.layer.cornerRadius = 16;
        _viewIcon.layer.masksToBounds = true;
        _viewIcon.clipsToBounds = true;
        
        _labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelTitle.font = [UIFont systemFontOfSize:12];
        
        _buttonCallToAction = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonCallToAction.titleLabel.font = [UIFont systemFontOfSize:14];
        _buttonCallToAction.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
        _buttonCallToAction.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 12);
        _buttonCallToAction.layer.cornerRadius = 3;
        
        _viewContainerMediaView = [[UIView alloc] initWithFrame:CGRectZero];
        
        
        for (UIView *view in @[ _viewIcon ,_labelTitle, _buttonCallToAction, _viewContainerMediaView ]) {
            view.translatesAutoresizingMaskIntoConstraints = false;
            [self addSubview:view];
        }
        NSInteger padding = 10;
        id metrics = @{ @"padding" : @(padding),
                        @"iconSide" : @80
                        };
        
        id views = @{ @"viewIcon" : _viewIcon,
                      @"labelTitle" : _labelTitle,
                      @"buttonCallToAction" : _buttonCallToAction,
                      @"viewContainerMediaView" : _viewContainerMediaView,
                      };
        
        NSMutableArray *allConstraints = NSMutableArray.array;
        id horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[viewIcon(iconSide)]-padding-[labelTitle]-padding-|" options:0 metrics:metrics views:views];
        [allConstraints addObjectsFromArray:horizontalConstraints];
        
        id verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[viewIcon(iconSide)]-padding-[viewContainerMediaView(0@250)]|" options:0 metrics:metrics views:views];
        [allConstraints addObjectsFromArray:verticalConstraints];
        
        id verticalLimitingConstrants = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[viewIcon]-(>=padding)-|" options:0 metrics:metrics views:views];
        [allConstraints addObjectsFromArray:verticalLimitingConstrants];
        
        id horizontalMediaViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0@250)-[viewContainerMediaView]-(0@250)-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views];
        [allConstraints addObjectsFromArray:horizontalMediaViewConstraints];
        
        id iconAndTitleAlignVerticallyConstraint = [NSLayoutConstraint constraintWithItem:_viewIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_labelTitle attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [allConstraints addObject:iconAndTitleAlignVerticallyConstraint];
        
        id iconAndCallToActionAlignVerticallyConstraint = [NSLayoutConstraint constraintWithItem:_viewIcon attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_buttonCallToAction attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [allConstraints addObject:iconAndCallToActionAlignVerticallyConstraint];
        
        id buttonCallToActionHeightConstraint = [NSLayoutConstraint constraintWithItem:_buttonCallToAction attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [allConstraints addObject:buttonCallToActionHeightConstraint];
        
        id buttonCallToActionTrailingConstraint = [NSLayoutConstraint constraintWithItem:_buttonCallToAction attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-padding];
        [allConstraints addObject:buttonCallToActionTrailingConstraint];
        
        _viewContainerMediaViewAspectRatioConstraint = [NSLayoutConstraint constraintWithItem:_viewContainerMediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_viewContainerMediaView attribute:NSLayoutAttributeHeight multiplier:1.5 constant:0];
        [allConstraints addObject:_viewContainerMediaViewAspectRatioConstraint];
        _viewContainerMediaViewAspectRatioConstraint.active = false;
        
        id mediaViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:_viewContainerMediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [allConstraints addObject:mediaViewCenterXConstraint];
        
        [self addConstraints:allConstraints];
    }
    return self;
}
    

- (void)setNativeAd:(TDMediatedNativeAd *)nativeAd {
    _nativeAd = nativeAd;
    self.labelTitle.text = nativeAd.title;
    [self.buttonCallToAction setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    if (nativeAd.iconView != nil) {
        nativeAd.iconView.translatesAutoresizingMaskIntoConstraints = false;
        [self.viewIcon addSubview:nativeAd.iconView];
        id verticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{ @"view" : nativeAd.iconView }];
        id horizontalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{ @"view" : nativeAd.iconView }];
        [self.viewIcon addConstraints:verticalConstrains];
        [self.viewIcon addConstraints:horizontalConstrains];
    }
    
    if (nativeAd.mediaView != nil) {
        _viewContainerMediaViewAspectRatioConstraint.active = true;
        [self.viewContainerMediaView addSubview:nativeAd.mediaView];
        nativeAd.mediaView.translatesAutoresizingMaskIntoConstraints = false;
        nativeAd.mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        id verticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:nil views:@{ @"view" : nativeAd.mediaView }];
        id horizontalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|" options:0 metrics:nil views:@{ @"view" : nativeAd.mediaView }];
        id centerXConstraint = [NSLayoutConstraint constraintWithItem:nativeAd.mediaView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewContainerMediaView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.viewContainerMediaView addConstraints:verticalConstrains];
        [self.viewContainerMediaView addConstraints:horizontalConstrains];
        [self.viewContainerMediaView addConstraint:centerXConstraint];
    } else {
        _viewContainerMediaViewAspectRatioConstraint.active = false;
    }
    [nativeAd registerView:self.labelTitle type:TDMediatedNativeAdViewTypeHeadline];
    [nativeAd registerView:self.buttonCallToAction type:TDMediatedNativeAdViewTypeCallToAction];
    [nativeAd registerView:self.viewIcon type:TDMediatedNativeAdViewTypeLogo];
    
    [self layoutIfNeeded];
}

@end
