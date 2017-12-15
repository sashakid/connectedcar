//
//  Owner.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Owner : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *photoURL;

@end
