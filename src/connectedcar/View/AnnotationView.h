//
//  AnnotationView.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Vehicle;

@interface AnnotationView : UIView

@property (strong, nonatomic) Vehicle *vehicle;

@end
