//
//  FavouriteButton.h
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-17.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteButton : UIButton

@property (nonatomic) BOOL isFlipped;
@property (nonatomic) UIImage *image;

-(void) flip;

@end
