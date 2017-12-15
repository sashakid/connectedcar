//
//  ListCell.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "ListCell.h"
#import "User.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setUser:(User *)user {
    [_userImageView setImageWithURL:[NSURL URLWithString:user.owner.photoURL]];
    _userNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.owner.name, user.owner.surname];
}

@end
