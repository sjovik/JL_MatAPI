//
//  FavouritesVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-13.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "FavouritesVC.h"
#import "InspectFoodVC.h"
#import "FavouriteButton.h"
#import "Utilities.h"
#import "UIColor+GraphKit.h"

@interface FavouritesVC ()
@property (nonatomic) DBProtocol *dbProtocol;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSArray *favourites;
@property (nonatomic) UIButton *inspectBtn;
@property (nonatomic) UIButton *compareBtn;
@property (nonatomic) FavouriteButton *favouriteBtn;

@property (nonatomic) GKBarGraph *graph;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (nonatomic) NSDictionary *compareFoodOne;
@property (nonatomic) NSDictionary *compareFoodTwo;
@property (nonatomic) BOOL compareSwitch;
@property (nonatomic) NSArray *compareValuesForGraph;
@end

@implementation FavouritesVC

#pragma mark dbcallback

-(void)searchFoodDetailsCompleted:(NSDictionary *)result {    
    
    self.compareSwitch = !self.compareSwitch;
    if (self.compareSwitch) {
        self.compareFoodOne = result;
        self.labelOne.text = result[@"name"];
        self.labelOne.textColor = [UIColor gk_turquoiseColor];
    } else {
        self.compareFoodTwo = result;
        self.labelTwo.text = result[@"name"];
        self.labelTwo.textColor = [UIColor gk_alizarinColor];
    }
    [self prepareComparison];
    [self.graph draw];
}


#pragma mark buttons
- (void)favouriteButtonClicked:(FavouriteButton*)sender {
    
    [sender flip];
    (self.favouriteBtn != sender) ? [self.favouriteBtn flip] : (self.favouriteBtn = nil);
    
    if (sender.isFlipped) {
        self.inspectBtn.center = CGPointMake(sender.center.x - sender.frame.size.width / 4,
                                             sender.center.y + sender.frame.size.height / 4);
        self.compareBtn.center = CGPointMake(sender.center.x + sender.frame.size.width / 4,
                                             sender.center.y + sender.frame.size.height / 4);
        self.compareBtn.hidden = NO;
        self.inspectBtn.hidden = NO;
        self.favouriteBtn = sender;
    } else {
        self.compareBtn.hidden = YES;
        self.inspectBtn.hidden = YES;
    }
}

- (void)inspectButtonClicked:(UIButton*)sender {
    [self performSegueWithIdentifier:@"Inspect Food" sender:self.favouriteBtn];
}

- (void)compareButtonClicked:(UIButton*)sender {
    
    [self.dbProtocol searchFoodDetails:self.favourites[[[sender.superview subviews] indexOfObject:self.favouriteBtn]][@"number"]];
    

    
}

- (UIButton*)setupOverlayButtonWithBackground:(UIImage*)image andSelector:(SEL)action {
    CGRect frame = CGRectMake(0, 0, 50, 50);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    btn.hidden = YES;
    [btn addTarget:self
            action:action
  forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)createOverlayButtons {
    
    self.inspectBtn = [self setupOverlayButtonWithBackground:[UIImage imageNamed:@"inspBtn"]
                                            andSelector:@selector(inspectButtonClicked:)];
    self.compareBtn = [self setupOverlayButtonWithBackground:[UIImage imageNamed:@"compBtn"]
                                            andSelector:@selector(compareButtonClicked:)];
    
    [self.scrollView addSubview:self.inspectBtn];
    [self.scrollView addSubview:self.compareBtn];
    
}

-(NSString*)imagePathForFood:(NSNumber*)foodNumber {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = dirs[0];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",[foodNumber stringValue], @".png"];
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return path;
}

#pragma mark graph

- (NSInteger)numberOfBars {
    return (self.compareFoodOne && self.compareFoodTwo) ? 8 : 4;
}

- (void)prepareComparison {
    NSArray *values = @[@"energyKcal", @"fat", @"carbohydrates", @"salt", @"sodium", @"fibre", @"saccharose"];
    
    if (!self.compareFoodTwo) {
        NSDictionary *nutrients1 = self.compareFoodOne[@"nutrientValues"];
        NSArray *singleFood = @[nutrients1[values[0]],
                                @([nutrients1[values[1]] floatValue] *10),
                                @([nutrients1[values[2]] floatValue] *10),
                                @( 100 - (
                                          ([nutrients1[values[1]] floatValue]) +        // fett
                                          ([nutrients1[values[2]] floatValue]) +        // kolhydrater
                                          ([nutrients1[values[3]] floatValue] * 10) +   // salt
                                          ([nutrients1[values[6]] floatValue]) +        // socker
                                          ([nutrients1[values[4]] floatValue] / 100) -  // sodium
                                          [nutrients1[values[5]] floatValue]            // fibrer
                                          )
                                )
                                ];
        self.compareValuesForGraph = singleFood;
    } else {
        NSDictionary *nutrients1 = self.compareFoodOne[@"nutrientValues"];
        NSDictionary *nutrients2 = self.compareFoodTwo[@"nutrientValues"];
        NSArray *compareFoods = @[nutrients1[values[0]],
                                  nutrients2[values[0]],
                                  @([nutrients1[values[1]] floatValue] *2),
                                  @([nutrients2[values[1]] floatValue] *2),
                                  @([nutrients1[values[2]] floatValue] *2),
                                  @([nutrients2[values[2]] floatValue] *2),
                                  @( 100 - (
                                            ([nutrients1[values[1]] floatValue]) +
                                            ([nutrients1[values[2]] floatValue]) +
                                            ([nutrients1[values[3]] floatValue] * 10) +
                                            ([nutrients1[values[6]] floatValue]) +
                                            ([nutrients1[values[4]] floatValue] / 100) -
                                            [nutrients1[values[5]] floatValue]
                                            )
                                  ),
                                  @( 100 - (
                                            ([nutrients2[values[1]] floatValue]) +
                                            ([nutrients2[values[2]] floatValue]) +
                                            ([nutrients2[values[3]] floatValue] * 10) +
                                            ([nutrients2[values[6]] floatValue]) +
                                            ([nutrients2[values[4]] floatValue] / 100) -
                                            [nutrients2[values[5]] floatValue]
                                            )
                                  )
                                  ];
        self.compareValuesForGraph = compareFoods;
    }
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return self.compareValuesForGraph[index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    return (self.compareFoodOne && self.compareFoodTwo) ? ((index & 1) ? [UIColor gk_alizarinColor]
                                                                       : [UIColor gk_turquoiseColor])
                                                        : [UIColor gk_turquoiseColor];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    return 0.5f;
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return (self.compareFoodOne && self.compareFoodTwo) ? @[@"kcal", @"", @"fett", @"", @"kolh", @"", @"nyttov", @""][index] : @[@"kcal", @"fett", @"kolh", @"nyttov"][index];
}

#pragma mark onload

- (void)createScrollMenu
{
    UIScrollView *newScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     self.view.frame.size.height/2 +10,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height/3)];
    int x = 10;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.favourites = [defaults objectForKey:@"favourites"];
    [newScrollView setBackgroundColor:[UIColor gk_silverColor]];
    
    for (int i = 0; i < self.favourites.count; i++) {
        UIImage *savedImage = [UIImage imageWithContentsOfFile:[self imagePathForFood:self.favourites[i][@"number"]]];
        
        FavouriteButton *button = [[FavouriteButton alloc] initWithFrame:CGRectMake(x, 5, 100, 100)];
        [button setTitle:[NSString stringWithFormat:@"%@", self.favourites[i][@"name"]] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor gk_silverColor]];
        if (savedImage) {
            UIImage *scaledImage = [Utilities imageWithImage:savedImage scaledToSize:CGSizeMake(100, 100)];
            [button setBackgroundImage:scaledImage forState:UIControlStateNormal];
            button.image = scaledImage;
        } else {
            UIImage *defaultImg = [UIImage imageNamed:@"button"];
            [button setBackgroundImage: defaultImg forState:UIControlStateNormal];
            button.image = defaultImg;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [button addTarget:self
                   action:@selector(favouriteButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        [newScrollView addSubview:button];
        
        x += button.frame.size.width + 5;
    }
    
    newScrollView.contentSize = CGSizeMake(x, newScrollView.frame.size.height);
    
    [self.view addSubview:newScrollView];
    [self.scrollView removeFromSuperview];
    self.scrollView = newScrollView;
    
    [self createOverlayButtons];
}


-(void)viewDidAppear:(BOOL)animated {

    if (self.navigationController.tabBarItem.badgeValue || !self.scrollView) {
        [self createScrollMenu];
    }
    [self.navigationController.tabBarItem setBadgeValue:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect frame = CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height / 3);
    self.graph = [[GKBarGraph alloc] initWithFrame:frame];
    self.graph.dataSource = self;
    [self.view addSubview:self.graph];
    
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Inspect Food"]) {
        UIButton *btn = sender;
        InspectFoodVC *ifvc = [segue destinationViewController];
        ifvc.title = btn.titleLabel.text;
        ifvc.foodNumber = self.favourites[[[btn.superview subviews] indexOfObject:sender]][@"number"];
    }
}


@end
