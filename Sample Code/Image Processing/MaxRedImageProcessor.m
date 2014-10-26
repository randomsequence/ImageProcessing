//
//  MaxRedImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MaxRedImageProcessor.h"

@implementation MaxRedImageProcessor

- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height {
    for (size_t y=0; y<height; y++) {
        for (size_t x=0; x<width; x++) {
            pixel->red = 255;
            pixel++;
        }
    }
}

@end
