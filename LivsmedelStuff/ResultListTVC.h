//
//  ResultListTVC.h
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-23.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBProtocol.h"

@interface ResultListTVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, DBDelegate>

@property (nonatomic) NSArray *results;
@property (nonatomic) NSMutableArray *nutrientValues;

@end
