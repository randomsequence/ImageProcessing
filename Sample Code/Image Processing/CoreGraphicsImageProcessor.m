//
//  CoreGraphicsImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "CoreGraphicsImageProcessor.h"

u_int8_t luminance(Pixel *pixel) {
    return ((pixel->red * 77)
            + (pixel->green * 151)
            + (pixel->blue * 28)) >> 8;
}

@implementation CoreGraphicsImageProcessor

- (UIImage *)processImage:(UIImage *)inputImage {
    
    CGImageRef imageRef = self.image.CGImage;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo) kCGImageAlphaPremultipliedLast;
    
    size_t components = CGColorSpaceGetNumberOfComponents(colorSpace)+1;
    size_t bytesPerRow = components * width;
    
    void *data = malloc(bytesPerRow * height);
    CGContextRef context = CGBitmapContextCreate(data,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    Pixel *pixel = data;
    
    [self processPixels:pixel width:width height:height];
    
    CGImageRef outputImageRef = CGBitmapContextCreateImage(context);
    free(data);
    CGContextRelease(context);
    UIImage *outputImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:self.image.scale orientation:self.image.imageOrientation];
    CGImageRelease(outputImageRef);
    
    return outputImage;
}

- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height {
}

@end
