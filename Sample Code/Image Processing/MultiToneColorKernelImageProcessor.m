//
//  MultiToneColorKernelImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 20/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MultiToneColorKernelImageProcessor.h"

@interface MultiToneFilter : CIFilter
@property (nonatomic, strong) CIImage *inputImage;
@end

@implementation MultiToneFilter
- (CIColorKernel *)kernel {
    static CIColorKernel *kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [CIColorKernel kernelWithString:@" \
                  kernel vec4 multiTone ( __sample pixel, __color lightTint, __color darkTint ) {              \
                  vec3 rgb = unpremultiply(pixel).rgb;                    \
                  float L = 0.299*rgb.r + 0.587*rgb.g + 0.114*rgb.b;      \
                  return premultiply(mix(darkTint, lightTint, L));        \
                  }                                                         \
                  "];
    });
    return kernel;
}

- (CIImage *)outputImage {
    CIImage *filtered = nil;
    if (nil != self.inputImage) {
        
        CIColor *lightTint = [CIColor colorWithRed:1.0 green:0.5 blue:0.78 alpha:1.0];
        CIColor *darkTint = [CIColor colorWithRed:0.08 green:0.35 blue:0.25 alpha:1.0];
        
        filtered = [[self kernel] applyWithExtent:self.inputImage.extent
                                        arguments:@[self.inputImage, lightTint, darkTint]];
    }
    return filtered;
}

@end

@implementation MultiToneColorKernelImageProcessor

- (CIImage *)filteredImage:(CIImage *)inputImage {
    MultiToneFilter *filter = [MultiToneFilter new];
    filter.inputImage = inputImage;
    return filter.outputImage;
}

- (BOOL)usesSRGBColorSpace {
    return NO;
}
@end
