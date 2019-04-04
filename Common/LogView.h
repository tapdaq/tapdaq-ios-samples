//
//  LogView.h
//  TapdaqExamples
//
//  Created by Dmitry Dovgoshliubnyi on 03/04/2019.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogView : UIView
- (void)log:(NSString *)format, ...;
- (void)log:(NSString *)format args:(va_list)args;
@end

NS_ASSUME_NONNULL_END
