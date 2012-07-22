//
//  stampCameraViewController.m
//  StampCamera
//
//  Created by 奥山 洋平 on 12/07/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "stampCameraViewController.h"

@interface stampCameraViewController ()

@end

@implementation stampCameraViewController
@synthesize picture;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setPicture:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)takePicture:(id)sender
{
    //カメラが利用できるか確認
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        //カメラかライブラリからの読み込み指定。カメラを指定
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        //トリミングなどを行うか否か
        [imagePickerController setAllowsEditing:NO];
        //Delegateをセット
        [imagePickerController setDelegate:self];
        
        //アニメーションをしてカメラを起動
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    } else {
        NSLog(@"Camera is Unable");
    }
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //撮影画像を取得
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    //撮影した写真をUIImageViewへ設定
    picture.image = originalImage;
    
    //検出器生成
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    
    //検出
    CIImage *cImage = [[CIImage alloc]initWithCGImage:originalImage.CGImage];
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray *array = [detector featuresInImage:cImage options:imageOptions];
    
    //過去のレイヤを全て消す
    for (UIView *subViews in picture.subviews) {
        [subViews removeFromSuperview];
    }
    
    //検出されたデータを取得
    for (CIFaceFeature *faceFeature in array) {
        //眼鏡画像追加処理へ
        [self drawMeganeImage:faceFeature];
    }
    
    //カメラUIを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) drawMeganeImage:(CIFaceFeature *)faceFeature
{
    if (faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition){
        
        //顔のサイズ情報を取得
        CGRect faceRect = [faceFeature bounds];
        //写真の向きで検出されたXとYを逆さにセットする
        float tmp = faceRect.size.width;
        faceRect.size.width = faceRect.size.height;
        faceRect.size.height = tmp;
        tmp = faceRect.origin.x;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = tmp;
        
        //比率計算
        float widthScale = picture.frame.size.width / picture.image.size.width;
        float heightScale = picture.frame.size.height / picture.image.size.height;
        //眼鏡画像のxとy,widthとheightのサイズを比率を合わせて変更
        faceRect.origin.x *= widthScale;
        faceRect.origin.y *= heightScale;
        faceRect.size.width *= widthScale;
        faceRect.size.height *= heightScale;
        
        //眼鏡のUIImagViewを作成
        UIImage *glassesImage = [UIImage imageNamed:@"megane2.png"];
        UIImageView *glassesImageView = [[UIImageView alloc]initWithImage:glassesImage];
        glassesImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //眼鏡画像のリサイズ
        glassesImageView.frame = faceRect;
        
        //眼鏡レイヤを撮影した写真に重ねる
        [picture addSubview:glassesImageView];
    }
}

@end
