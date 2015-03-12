//
//  InspectFoodVC.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-12.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "InspectFoodVC.h"

@interface InspectFoodVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation InspectFoodVC

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
    
    // save to cameraroll
    // UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    [self saveImage:self.imageView.image];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@", self.foodNumber];
    NSLog(@"%@", self.imagePath);
    
    UIImage *savedImage = [UIImage imageWithContentsOfFile:self.imagePath];
    
    if (savedImage) {
        self.imageView.image = savedImage;
    } else {
        NSLog(@"Failed to load cached image");
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
