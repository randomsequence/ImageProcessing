//
//  MultiToneImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 30/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MultiToneImageProcessor.h"

@implementation MultiToneImageProcessor

u_int8_t multiTone(u_int8_t light, u_int8_t dark, u_int8_t luminance) {
    return (((255-luminance) * dark) + (luminance * light)) >> 8;
}

- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height {

    Pixel lightTint = {.red=255, .green=128, .blue=200};
    Pixel darkTint = {.red=22, .green=88, .blue=64};
    
    u_int8_t L;
    for (size_t y=0; y<height; y++) {
        for (size_t x=0; x<width; x++) {
            L = luminance(pixel);
            pixel->red = multiTone(lightTint.red, darkTint.red, L);
            pixel->green = multiTone(lightTint.green, darkTint.green, L);
            pixel->blue = multiTone(lightTint.blue, darkTint.blue, L);
            pixel++;
        }
    }
}

@end
