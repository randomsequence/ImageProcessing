//
//  MonoChromeImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MonoChromeImageProcessor.h"

u_int8_t mean(Pixel *pixel) {
    return (pixel->red
            + pixel->green
            + pixel->blue) / 3;
}

@implementation MonoChromeImageProcessor

- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height {
    u_int8_t L;
    for (size_t y=0; y<height; y++) {
        for (size_t x=0; x<width; x++) {
            L = luminance(pixel);
            pixel->red = L;
            pixel->green = L;
            pixel->blue = L;
            pixel++;
        }
    }
}

@end
