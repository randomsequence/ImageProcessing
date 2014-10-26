//
//  TintImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "TintImageProcessor.h"

@implementation TintImageProcessor

- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height {
    
    Pixel tintColor;
    tintColor.red = 255;
    tintColor.green = 0;
    tintColor.blue = 128;
    
    u_int8_t luminance;
    for (size_t y=0; y<height; y++) {
        for (size_t x=0; x<width; x++) {
            luminance = ((pixel->red * 77) + (pixel->green * 151) + (pixel->blue * 28)) >> 8;
            pixel->red = (luminance * tintColor.red) >> 8;
            pixel->green = (luminance * tintColor.green) >> 8;
            pixel->blue = (luminance * tintColor.blue) >> 8;
            pixel++;
        }
    }
}

@end
