//
//  CoreImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 20/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "CoreImageProcessor.h"

@implementation CoreImageProcessor
- (UIImage *)processImage:(UIImage *)inputImage {
    CIImage *input = [CIImage imageWithCGImage:inputImage.CGImage];
    
    CIFilter *linearToSRGB = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
    [linearToSRGB setValue:input forKey: kCIInputImageKey];

    CIImage *colorCorrectedInput = ([self usesSRGBColorSpace]) ? linearToSRGB.outputImage : input;
    
    CIImage *filtered = [self filteredImage:colorCorrectedInput];
    
    CIFilter *SRGBToLinear = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
    [SRGBToLinear setValue:filtered forKey: kCIInputImageKey];
    
    filtered = ([self usesSRGBColorSpace]) ? SRGBToLinear.outputImage : filtered;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outputRef = [context createCGImage:filtered fromRect:filtered.extent];
    UIImage *output = [UIImage imageWithCGImage:outputRef];
    CGImageRelease(outputRef);
    
    return output;
}

- (CIImage *)filteredImage:(CIImage *)inputImage {
    return inputImage;
}

- (BOOL)usesSRGBColorSpace {
    return YES;
}
@end
