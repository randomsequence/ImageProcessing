//
//  CoreGraphicsImageProcessor.h
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "ImageProcessor.h"

typedef struct {
    u_int8_t red;
    u_int8_t green;
    u_int8_t blue;
    u_int8_t alpha;
} Pixel;
u_int8_t luminance(Pixel *pixel);

@interface CoreGraphicsImageProcessor : ImageProcessor
- (void)processPixels:(Pixel *)pixel width:(size_t)width height:(size_t)height;
@end
