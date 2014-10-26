//
//  MuliToneGLImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 20/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MuliToneGLImageProcessor.h"

@implementation MuliToneGLImageProcessor
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image fragmentShader:
            @"                                                      \
            varying lowp vec2 textureCoordinate;                    \
            uniform sampler2D inputImageTexture;                    \
            \
            const mediump vec4 lightTint = vec4(1.0, 0.5, 0.78, 1.0);  \
            const mediump vec4 darkTint = vec4(0.08, 0.35, 0.25, 1.0);  \
            \
            mediump vec4 multiTone(mediump vec4 pixel) {  \
            mediump float L = 0.299*pixel.r + 0.587*pixel.g + 0.114*pixel.b; \
            return mix(darkTint, lightTint, L); \
            } \
            \
            void main() {                                                       \
            mediump vec4 rgba = texture2D(inputImageTexture, textureCoordinate);           \
            gl_FragColor = multiTone(rgba);                \
            }"];
    if (self) {
    }
    return self;
}
@end
