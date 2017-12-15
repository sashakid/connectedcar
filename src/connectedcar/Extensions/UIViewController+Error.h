//
//  UIViewController+Error.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Error)

- (void)showErrorMessage:(NSString *)message;
- (void)showRetryErrorMessage:(NSString *)message retry:(void(^)())retry cancel:(void(^)())cancel;

@end
