//
//  ImageProcessor.h
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//
@import UIKit;

@interface ImageProcessor : NSOperation
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *outputImage;
- (instancetype)initWithImage:(UIImage *)image;
- (UIImage *)processImage:(UIImage *)inputImage;
@end
