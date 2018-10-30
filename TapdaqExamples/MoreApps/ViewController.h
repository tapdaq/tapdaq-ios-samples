//
//  ViewController.h
//  MoreApps
//
//  Created by Nick Reffitt on 08/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tapdaq/Tapdaq.h>

@interface ViewController : UIViewController <TapdaqDelegate>

@property (nonatomic, strong) IBOutlet UIButton *loadMoreAppsBtn;
@property (nonatomic, strong) IBOutlet UIButton *showMoreAppsBtn;

@property (nonatomic, strong) IBOutlet UITextView *textView;

- (IBAction)loadMoreApps:(id)sender;
- (IBAction)showMoreApps:(id)sender;

@end

