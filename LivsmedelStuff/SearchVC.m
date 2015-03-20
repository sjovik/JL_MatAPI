//
//  SearchVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-23.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "SearchVC.h"
#import "ResultListTVC.h"
#import "UIColor+GraphKit.h"

@interface SearchVC ()
@property (nonatomic) DBProtocol *dbProtocol;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *searchingIndicator;
@property (nonatomic) CGPoint searchIndicatorStartPoint;

@property (nonatomic) UIDynamicAnimator *animator;
@property (weak, nonatomic) IBOutlet UIImageView *sign;
@property (nonatomic) UIGravityBehavior *gravity;
@property (nonatomic) UIAttachmentBehavior *attachToAnchor;
@property (nonatomic) UIDynamicItemBehavior *item;

@end

@implementation SearchVC

-(void) searchFoodCompleted:(NSArray *)results {
    
    self.searchResults = results;
    [self stopSearchIndicatorAnimation];
    [self performSegueWithIdentifier:@"Show Result List" sender:self];
    
}


- (void)stopSearchIndicatorAnimation {
    [UIView animateKeyframesWithDuration:0.3
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(1.0f, 1.0f);
                                  self.searchingIndicator.transform = scaleTrans;
                                  self.searchingIndicator.center = self.searchIndicatorStartPoint;                         }
                              completion:^(BOOL finished){
                                  self.searchingIndicator.hidden = YES;
                              }];
}


- (void)animateSearchingIndicator {
    self.searchingIndicator.hidden = NO;
    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.searchingIndicator.center = CGPointMake(self.searchField.frame.size.width ,self.searchingIndicator.center.y);
                     }
                     completion:NULL];
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(5.0f, 1.0f);
                         self.searchingIndicator.transform = scaleTrans;
                     }
                     completion:NULL];
}

- (IBAction)onSearch:(id)sender {
    
    [self animateSearchingIndicator];

    [self.dbProtocol searchFood:self.searchField.text];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
    
    self.searchIndicatorStartPoint = self.searchingIndicator.center;
    
    // Animations
    self.sign.center = CGPointMake(self.view.frame.origin.x - 100, self.view.frame.size.height / 2);
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.sign]];
    self.gravity.magnitude = 0.2;
    self.item = [[UIDynamicItemBehavior alloc] initWithItems:@[self.sign]];
    self.item.density = 0.5;
    self.attachToAnchor = [[UIAttachmentBehavior alloc] initWithItem:self.sign offsetFromCenter:UIOffsetMake(0, -50) attachedToAnchor:CGPointMake(self.view.frame.size.width / 2, self.view.frame.origin.y)];
    self.attachToAnchor.length = self.view.frame.size.height / 2;
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.attachToAnchor];
    [self.animator addBehavior:self.item];
    
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Show Result List"]) {
        ResultListTVC *rtvc = [segue destinationViewController];
        rtvc.title = self.searchField.text;
        rtvc.results = self.searchResults;
    }
    
}


@end
