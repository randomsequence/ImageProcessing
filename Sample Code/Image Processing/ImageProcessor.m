//
//  ImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "ImageProcessor.h"

@interface ImageProcessor ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *outputImage;
@end

@implementation ImageProcessor

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)inputImage {
    return inputImage;
}

- (void)main {
    self.outputImage = [self processImage:self.image];
}

@end
