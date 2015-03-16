//
//  InspectFoodVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-12.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "InspectFoodVC.h"
#import "FavouritesVC.h"

@interface InspectFoodVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) DBProtocol *dbProtocol;
@property (nonatomic) NSDictionary *food;
@property (weak, nonatomic) IBOutlet UITextView *textField;

@end

@implementation InspectFoodVC

-(void)searchFoodDetailsCompleted:(NSDictionary *)result {
    self.food = result;
    //self.textField.text = self.food[@"nutrientValues"];
    NSLog(@"%@", self.food[@"nutrientValues"]);
}

-(NSString*)imagePath {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = dirs[0];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",[self.foodNumber stringValue], @".png"];
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return path;
}
- (IBAction)addImage:(UITapGestureRecognizer *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)addFavourite:(UITapGestureRecognizer *)sender {
    UITabBarItem *tbi = [[self.tabBarController.tabBar items] objectAtIndex:1];
    tbi.badgeValue = @"1";
}

- (void) saveImage:(UIImage*)image {
    // save to file - cache for app.
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
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = pickedImage;
    // Save to cache
    [self saveImage:self.imageView.image];
    
    // save to cameraroll
    // UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@", self.foodNumber];
    NSLog(@"%@", self.imagePath);
    
    UIImage *savedImage = [UIImage imageWithContentsOfFile:self.imagePath];
    
    if (savedImage) {
        self.imageView.image = savedImage;
    } else {
        NSLog(@"Failed to load cached image");
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
