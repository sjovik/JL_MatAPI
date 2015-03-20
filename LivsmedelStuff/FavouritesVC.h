//
//  FavouritesVC.h
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-13.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKBarGraph.h"
#import "DBProtocol.h"

@interface FavouritesVC : UIViewController<GKBarGraphDataSource, DBDelegate>

@end
