//
//  ResultListTVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-23.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "ResultListTVC.h"
#import "ResultTVCell.h"
#import "InspectFoodVC.h"

@interface ResultListTVC ()

@property (nonatomic) DBProtocol *dbProtocol;
@property (nonatomic) NSArray *filteredResults;
@property (nonatomic) BOOL isScrolling;
@property (nonatomic) BOOL shouldReload;
@property (nonatomic) BOOL shouldFetchNutrients;

@end

@implementation ResultListTVC

- (void)reloadVisibleCellData {
    self.shouldReload = NO;
    bool rowVisible = NO;
    
    NSArray *visibleCells = [self.tableView visibleCells];
    for (ResultTVCell *cell in visibleCells) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        if ([cell.descriptionLabel.text isEqualToString:@"Energi: Laddar..."] && self.nutrientValues.count > path.row) {
            rowVisible = YES;
        }
    }
    if (rowVisible) {
        [self.tableView reloadData];
    }
}

-(void)searchNutrientsCompleted:(NSArray *)result {
    [self.nutrientValues addObjectsFromArray:result];
    
    if(!self.isScrolling ) {
        [self reloadVisibleCellData];
    } else {
        self.shouldReload = YES;
    }
    
    if (self.shouldFetchNutrients) {
        [self fetchNutrients];
    }
    
}

// Scroll event - holds cell update until scroll is over.
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
}
- (void)stoppedScrolling {
    self.isScrolling = NO;
    if (self.shouldReload) {
        [self reloadVisibleCellData];
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stoppedScrolling];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stoppedScrolling];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.shouldFetchNutrients = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.nutrientValues.count < self.results.count) {
        self.shouldFetchNutrients = YES;
        [self fetchNutrients];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
    self.nutrientValues = [[NSMutableArray alloc] initWithCapacity:self.results.count];
    self.shouldFetchNutrients = YES;
    [self fetchNutrients];
}

- (void)fetchNutrients {
    
    if (self.nutrientValues.count < self.results.count) {
        NSArray *fetchTen = @[];
        
        if (self.nutrientValues.count + 10 < self.results.count) {
            fetchTen = [self.results subarrayWithRange:NSMakeRange(self.nutrientValues.count, 10)];
        } else {
            fetchTen = [self.results subarrayWithRange:NSMakeRange(self.nutrientValues.count, self.results.count - self.nutrientValues.count)];
        }
        
        [self.dbProtocol searchItems:fetchTen forNutrient:@"energyKj"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.results.count;
    }else return self.filteredResults.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@)", searchText];
    self.filteredResults = [self.results filteredArrayUsingPredicate:predicate];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *results;
    if (tableView == self.tableView) {
        results = self.results;
    }else {
        results = self.filteredResults;
    }
    
    ResultTVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MatApiResultCell" forIndexPath:indexPath];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", results[indexPath.row][@"name"]];
    
    if (self.nutrientValues.count > indexPath.row) {
        cell.descriptionLabel.text = [NSString stringWithFormat:@"Energi: %@",
                                      self.nutrientValues[indexPath.row]];
    } else {
        cell.descriptionLabel.text = [NSString stringWithFormat:@"Energi: %@", @"Laddar..."];
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([[segue identifier] isEqualToString:@"Inspect Food"]) {
        
        ResultTVCell *cell = (ResultTVCell*)sender;
        InspectFoodVC *ifvc = [segue destinationViewController];
        ifvc.title = cell.nameLabel.text;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        ifvc.foodNumber = self.results[path.row][@"number"];
    }
}


@end
