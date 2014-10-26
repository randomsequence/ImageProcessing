//
//  MaxRedGLImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 20/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MaxRedGLImageProcessor.h"

@implementation MaxRedGLImageProcessor
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image fragmentShader:
            @"                                                      \
            varying lowp vec2 textureCoordinate;                    \
            uniform sampler2D inputImageTexture;                    \
            void main()                                             \
            {                                                       \
            mediump vec4 rgba = texture2D(inputImageTexture, textureCoordinate);           \
            rgba.b = 1.0;                                           \
            gl_FragColor = rgba;                \
            }"];
    if (self) {
    }
    return self;
}
@end
