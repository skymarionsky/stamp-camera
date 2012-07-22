//
//  stampCameraViewController.h
//  StampCamera
//
//  Created by 奥山 洋平 on 12/07/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface stampCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *picture;
- (IBAction)takePicture:(id)sender;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (void) drawMeganeImage:(CIFaceFeature *)faceFeature;

@end
