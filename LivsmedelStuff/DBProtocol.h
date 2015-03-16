//
//  DBHelper.h
//  LivsmedelStuff
//
//  Created by Johannes on 2015-02-25.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBDelegate <NSObject>
@optional

-(void) searchFoodCompleted:(NSArray*)results;
-(void) searchNutrientsCompleted:(NSArray*)result;
-(void) searchFoodDetailsCompleted:(NSDictionary*)result;
// -(void) fetchNutrientCompleted:(NSString*)result forIndexPath:(NSInteger)ndx;

@end

@interface DBProtocol : NSObject

@property (nonatomic, weak) id<DBDelegate> delegate;

-(void) searchFoodDetails:(NSNumber*)foodNumber;
-(void) searchFood:(NSString*)searchString;
-(void) searchItems:(NSArray *)items forNutrient:(NSString*)key;
// -(void) fetchNutrient:(NSString*)key forItem:(NSString*)number atIndexPath:(NSInteger)ndx;

@end
