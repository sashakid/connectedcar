//
//  AnnotationView.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "AnnotationView.h"
#import "User.h"
#import "RouteManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface AnnotationView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end

@implementation AnnotationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
    }
    
    self.frame = CGRectMake(0, 0, 230, 75);
    
    return self;
}

- (void)setVehicle:(Vehicle *)vehicle {
    _titleLabel.text = [NSString stringWithFormat:@"%@ %@", vehicle.make, vehicle.model];
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:vehicle.photoURL]]
                      placeholderImage:nil
                               success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                   _imageView.image = image;
                               }
                               failure:nil];
    _addressLabel.text = vehicle.location.address;
    _colorView.backgroundColor = [self colorFromHexString:vehicle.color];
}

#pragma mark - Helpers

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
