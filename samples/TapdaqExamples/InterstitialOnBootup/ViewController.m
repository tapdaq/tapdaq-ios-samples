//
//  ViewController.m
//  InterstitialOnBootup
//
//  Created by Nick Reffitt on 22/12/2016.
//  Copyright © 2016 Tapdaq. All rights reserved.
//

#import "ViewController.h"
#import <Tapdaq/Tapdaq.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLog:) name:@"TapdaqLogMessageNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)receivedLog:(NSNotification *)notification {
    NSString *text = [self.textView text];
    NSString *message = notification.userInfo[@"message"];
    NSString *textAddition = [NSString stringWithFormat:@"%@\n\n%@", message, text];
    [self.textView setText:textAddition];
}

- (IBAction)showDebugger:(id)sender {
    [[Tapdaq sharedSession] presentDebugViewController];
}


@end
