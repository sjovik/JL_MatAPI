//
//  CameraViewController.m
//  LivsmedelStuff
//
//  Created by Johannes on 2015-03-11.
//  Copyright (c) 2015 Johannes. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@property (nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CameraViewController

-(NSString*)createCachePath {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = dirs[0];
    NSString *path = [docDir stringByAppendingPathComponent:@"cached.png"];
    return path;
}

- (void) saveImagetToCache:(UIImage*)image {
    // save to file - cache for app.
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    BOOL success = [imageData writeToFile:[self createCachePath] atomically:YES];
    if(!success) {
        NSLog(@"failed to save image to cache");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = pickedImage;
    // save to cameraroll
    // UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);

    [self saveImagetToCache:self.imageView.image];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openCameraButton:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews {
    
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:self.createCachePath];
    
    if (cachedImage) {
        self.imageView.image = cachedImage;
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
