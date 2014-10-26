//
//  OpenGLESImageProcessor.h
//  Image Processing
//
//  Created by Johnnie Walker on 19/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "ImageProcessor.h"

@interface OpenGLESImageProcessor : ImageProcessor
@property (nonatomic, copy, readonly) NSString *vertexShaderString;
@property (nonatomic, copy, readonly) NSString *fragmentShaderString;
- (instancetype)initWithImage:(UIImage *)image fragmentShader:(NSString *)fragmentShaderString;
@end
