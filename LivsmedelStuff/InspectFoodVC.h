//
//  InspectFoodVC.h
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-12.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBProtocol.h"

@interface InspectFoodVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBDelegate>

@property (nonatomic) NSNumber* foodNumber;
@end
