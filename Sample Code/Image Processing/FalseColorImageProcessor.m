//
//  FalseColorImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 24/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "FalseColorImageProcessor.h"

@implementation FalseColorImageProcessor

- (CIImage *)filteredImage:(CIImage *)inputImage {
    CIFilter *falseColor = [CIFilter filterWithName:@"CIFalseColor"];
    [falseColor setValue:inputImage forKey:kCIInputImageKey];
    [falseColor setValue:[CIColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:1.0] forKey:@"inputColor1"];
    [falseColor setValue:[CIColor colorWithRed:0.08 green:0.35 blue:0.25 alpha:0.0] forKey:@"inputColor0"];
    
    // false colour ignores the alpha channel :(
    
    CIFilter *blend = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [blend setValue:falseColor.outputImage forKey:kCIInputImageKey];
    [blend setValue:inputImage forKey:kCIInputBackgroundImageKey];
    return blend.outputImage;
}

- (BOOL)usesSRGBColorSpace {
    return NO;
}
@end
