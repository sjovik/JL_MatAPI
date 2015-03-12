//
//  DBHelper.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-25.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "DBProtocol.h"

@implementation DBProtocol

- (void)searchFood:(NSString *)searchString {
    
    NSString* urlString = [[NSString stringWithFormat:@"http://matapi.se/foodstuff/?query=%@", searchString]
                           stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                if (error) {
                                                    NSLog(@"Error in response: %@", error);
                                                    return;
                                                }
                                                NSError *parsingError;
                                                NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:kNilOptions
                                                                                                  error:&parsingError];
                                                
                                                if (!parsingError) {
                                                    NSArray *searchResults = json;
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.delegate searchFoodCompleted:searchResults];
                                                    });
                                                    
                                                } else NSLog(@"Couldn't parse json: %@", parsingError);
                                            }];
    [task resume];
    
}

-(void)fetchNutrient:(NSString *)key forItem:(NSString*)number atIndexPath:(NSInteger) ndx{
    
    
    NSString* urlString = [[NSString stringWithFormat:@"http://matapi.se/foodstuff/%@?nutrient=%@", number, key]
                           stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                if (error) {
                                                    NSLog(@"Error in response: %@", error);
                                                    return;
                                                }
                                                NSError *parsingError;
                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:kNilOptions
                                                                                                  error:&parsingError];
                                                if (!parsingError) {
                                                     // NSLog(@"result: %@", json[@"nutrientValues"]);
                                                    //dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.delegate fetchNutrientCompleted:json[@"nutrientValues"][@"energyKj"] forIndexPath:ndx];
                                                    // });
                                                    
                                                } else NSLog(@"Couldn't parse json: %@", parsingError);
                                            }];
    [task resume];
    
}


// Fungerar men tar lång tid att slutföra
-(void)searchItems:(NSArray *)items forNutrient:(NSString *)key {
    
    NSMutableArray *energyValues = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:1];
    
    NSBlockOperation *finished = [NSBlockOperation blockOperationWithBlock:^{
        
        // NSLog(@"finished: %@", energyValues);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate searchNutrientsCompleted:energyValues];
        });
    }];
    
    
    for (int i = 0; i < items.count; i++) {
        
        NSString *searchString = [NSString stringWithFormat:@"%@?nutrient=%@", items[i][@"number"], key];
        
        
        NSString* urlString = [NSString stringWithFormat:@"http://matapi.se/foodstuff/%@", searchString];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSBlockOperation *getNutrientOperation = [NSBlockOperation blockOperationWithBlock:^{
        
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSError *parsingError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&parsingError];
            if (!parsingError) {
                NSDictionary *nutrientValue = json[@"nutrientValues"];
                energyValues[i] = nutrientValue[key];
            } else { energyValues[i] = @"Error retrieving data"; }
        }];
        
        [queue addOperation:getNutrientOperation];
        [finished addDependency:getNutrientOperation];
    }
    [queue addOperation:finished];
}

@end























