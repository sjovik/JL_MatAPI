//
//  SearchVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-23.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "SearchVC.h"
#import "ResultListTVC.h"

@interface SearchVC ()

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic) DBProtocol *dbProtocol;

@end

@implementation SearchVC

-(void) searchFoodCompleted:(NSArray *)results {
    
    // NSLog(@"%@", results);
    self.searchResults = results;
    
    // [self.dbProtocol searchItems:results forNutrient:@"energyKj"];
    [self performSegueWithIdentifier:@"Show Result List" sender:self];
    [self.loadingIndicator stopAnimating];
    self.searchButton.hidden = NO;
    
}




- (IBAction)onSearch:(id)sender {
    
    if (self.searchField.text) {
        [self.dbProtocol searchFood:self.searchField.text];
    }
    self.searchButton.hidden = YES;
    [self.loadingIndicator startAnimating];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
