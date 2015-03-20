//
//  InspectFoodVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-12.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "InspectFoodVC.h"
#import "FavouritesVC.h"
#import "Utilities.h"

@interface InspectFoodVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) DBProtocol *dbProtocol;
@property (nonatomic) NSDictionary *food;
@property (weak, nonatomic) IBOutlet UITextView *textField;

@end

@implementation InspectFoodVC

#pragma mark database

-(void)searchFoodDetailsCompleted:(NSDictionary *)result {
    self.food = result;
    
    NSDictionary *nutrientValues = result[@"nutrientValues"];
    NSMutableString *valuesText = [[NSMutableString alloc] init];
    [valuesText appendString:@"Näringsvärden: \n\n"];
    
    for(NSString *key in [nutrientValues allKeys]) {
        NSString *value = [NSString stringWithFormat:@"%@: %@\n",key, [nutrientValues objectForKey:key]];
        [valuesText appendString:value];
    }
    self.textField.text = valuesText;
}

#pragma mark image

-(NSString*)imagePath {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = dirs[0];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",[self.foodNumber stringValue], @".png"];
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return path;
}

- (IBAction)addImage:(UITapGestureRecognizer *)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] &&
        ![UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum]
        ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot add image"
                                                            message:@"We didn't find a camera or image album to pick from"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) saveImage:(UIImage*)image {
    // save to filecache for app.
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    BOOL success = [imageData writeToFile:self.imagePath atomically:YES];
    if(!success) {
        NSLog(@"failed to save image to cache");
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickedImage = [Utilities imageWithImage:info[UIImagePickerControllerEditedImage]
                                        scaledToSize:CGSizeMake(self.view.frame.size.width,
                                                                self.view.frame.size.height / 2)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = pickedImage;
    [self saveImage:pickedImage];
}

#pragma mark misc

- (IBAction)addFavourite:(UITapGestureRecognizer *)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favourites = [defaults objectForKey:@"favourites"];
    BOOL alreadyFav = NO;
    
    if (favourites.count < 1) {
        favourites = @[@{@"name" : self.title,
                         @"number" : self.foodNumber}];
    } else {
        for (NSDictionary *food in favourites) {
            if ([food[@"number"] isEqualToNumber:self.foodNumber]) alreadyFav = YES;
        }
        if (!alreadyFav) {
            favourites = [favourites arrayByAddingObject:@{@"name" : self.title,
                                                           @"number" : self.foodNumber}];
        }
    }
    
    if (!alreadyFav) {
        [defaults setObject:favourites forKey:@"favourites"];
        [defaults synchronize];
        UITabBarItem *tbi = [[self.tabBarController.tabBar items] objectAtIndex:1];
        tbi.badgeValue = @"+";
    }
}

#pragma mark onload
-(BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@", self.foodNumber];
    
    UIImage *savedImage = [UIImage imageWithContentsOfFile:self.imagePath];
    
    if (savedImage) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.image = savedImage;
    }
    
    self.dbProtocol = [[DBProtocol alloc] init];
    self.dbProtocol.delegate = self;
    [self.dbProtocol searchFoodDetails:self.foodNumber];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
