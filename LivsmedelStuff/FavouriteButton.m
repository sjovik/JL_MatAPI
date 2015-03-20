//
//  FavouriteButton.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-17.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "FavouriteButton.h"
@implementation FavouriteButton

-(void) flip{
    
    if (self.isFlipped) {
        [UIView transitionWithView:self
                          duration:0.6f
                           options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            [self setBackgroundImage:self.image forState:UIControlStateNormal];
                            self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                        } completion:NULL];
    } else {
        [UIView transitionWithView:self
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            [self setBackgroundImage:nil forState:UIControlStateNormal];
                            self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                        } completion:NULL];
    }
    
    self.isFlipped = !self.isFlipped;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
