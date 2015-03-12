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

@end

@implementation ResultListTVC

- (void)reloadVisibleCellData {
    self.shouldReload = NO;
    bool rowVisible = NO;
    
    NSArray *visibleCells = [self.tableView visibleCells];
    for (ResultTVCell *cell in visibleCells) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        if ([cell.descriptionLabel.text isEqualToString:@"Energi: Laddar..."] && self.nutrientValues.count > path.row) {
            NSLog(@"reloading row");
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
        NSLog(@"%@", @"db comp reloading...");
         [self reloadVisibleCellData];
     } else {
         self.shouldReload = YES;
     }
    [self fetchNutrients];
}

// Scroll event - holds cell update until scroll is over.
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrolling...");
    self.isScrolling = YES;
}
- (void)stoppedScrolling {
    self.isScrolling = NO;
    if (self.shouldReload) {
        NSLog(@"stopped scr reloading...");
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

/*
-(void)fetchNutrientCompleted:(NSString *)result forIndexPath:(NSInteger)ndx {
   
    NSLog(@"nutrientValues: %@", result);
    
    NSBlockOperation *finished = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"finished: %@", @"alla");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

    
    NSString *hej = [NSString stringWithFormat:@"%ld", (long)ndx];
    [self.nutrientValues setObject:result forKey:hej];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    
     NSLog(@"nutrientValues: %ld", (long)ndx);
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
    self.nutrientValues = [[NSMutableArray alloc] initWithCapacity:self.results.count];
    [self fetchNutrients];
}

- (void)fetchNutrients {
    
    if (self.nutrientValues.count < self.results.count) {
        NSArray *fetchTen = @[];
        
        if (self.nutrientValues.count + 10 < self.results.count) {
            // NSLog(@"%@", );
            fetchTen = [self.results subarrayWithRange:NSMakeRange(self.nutrientValues.count, 10)];
        } else {
            fetchTen = [self.results subarrayWithRange:NSMakeRange(self.nutrientValues.count, self.results.count - self.nutrientValues.count)];
        }
        
        [self.dbProtocol searchItems:fetchTen forNutrient:@"energyKj"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
