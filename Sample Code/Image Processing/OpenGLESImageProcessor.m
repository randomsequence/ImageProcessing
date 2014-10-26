//
//  OpenGLESImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 19/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "OpenGLESImageProcessor.h"

@import OpenGLES;
@import UIKit;

@interface OpenGLESImageProcessor () {
    NSString *_fragmentShaderString;
    
    GLuint _fragmentShader;
    GLuint _vertexShader;
    GLuint _program;

    GLint _positionAttribute;
    GLint _textureCoordinateAttribute;
    GLint _inputTextureUniform;
}
@property (nonatomic, strong) EAGLContext *context;
@end

void freeImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

void releasePixelBuffer(void *info, const void *data, size_t size) {
    CVPixelBufferRef pixelBuffer = info;
    if (pixelBuffer) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        CFRelease(pixelBuffer);
    }
}

@implementation OpenGLESImageProcessor

- (instancetype)initWithImage:(UIImage *)image fragmentShader:(NSString *)fragmentShaderString; {
    self = [super initWithImage:image];
    if (self) {
        _fragmentShaderString = [fragmentShaderString copy];
    }
    return self;
}

- (void)dealloc
{
}

- (UIImage *)processImage:(UIImage *)inputImage {
    GLuint inputTexture = 0;
    {
        // setup
        [self setupContext];
        [self compileShaders];
        
        glUseProgram(_program);
        
        inputTexture = [self textureFromImage:inputImage];
    }
    
    UIImage *output = nil;
    {
        glBindTexture(GL_TEXTURE_2D, 0);
        
        CGFloat scale = self.image.scale;
        CGSize size = CGSizeApplyAffineTransform(self.image.size, CGAffineTransformMakeScale(scale, scale));
        GLsizei width = (GLsizei) size.width;
        GLsizei height = (GLsizei) size.height;
        
        GLuint framebuffer;
        
        CVPixelBufferRef pixelBuffer = NULL;
        CVOpenGLESTextureRef textureRef = NULL;
        
        if ([self makeTextureFrameBuffer:size frameBuffer:&framebuffer pixelBuffer:&pixelBuffer texture:&textureRef]) {
            glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
            
            glViewport(0, 0, width, height);
            glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, inputTexture);
            glUniform1i(_inputTextureUniform, 0);
            
            static const GLfloat vertices[] = {
                -1, 1,
                1, 1,
                -1, -1,
                1, -1
            };
            
            static const GLfloat texCoords[] = {
                0.0, 1.0,
                1.0, 1.0,
                0.0, 0.0,
                1.0, 0.0
            };
            
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            
            glVertexAttribPointer(_positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, vertices);
            glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
            
            glEnableVertexAttribArray(_positionAttribute);
            glEnableVertexAttribArray(_textureCoordinateAttribute);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            glEnableVertexAttribArray(0);
            glEnableVertexAttribArray(0);
            
            glBindTexture(GL_TEXTURE_2D, 0);
            
            glFlush();
            glFinish();
            
            {
#if TARGET_IPHONE_SIMULATOR
                // copy the image from the framebuffer
                // you almost certainly don't want to do this. Instead, create a CVOpenGLESTextureRef and render to that
                {
                size_t dataSize = width*height*4;
                GLubyte *buffer = (GLubyte *) malloc(dataSize);
                glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);

                CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, dataSize, freeImageData);
                int bytesPerRow = width*4;
#else
                CVReturn success = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
                if (success == kCVReturnSuccess) {
                    CFRetain(pixelBuffer);
                    CGDataProviderRef provider = CGDataProviderCreateWithData(pixelBuffer,
                                                                              CVPixelBufferGetBaseAddress(pixelBuffer),
                                                                              CVPixelBufferGetDataSize(pixelBuffer),
                                                                              releasePixelBuffer);
                    
                    int bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
#endif
                    int bitsPerComponent = 8;
                    int bitsPerPixel = 32;
                    
                    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
                    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
                    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
                    
                    // make the cgimage
                    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
                    output = [UIImage imageWithCGImage:imageRef];
                    
                    CGDataProviderRelease(provider);
                    CGColorSpaceRelease(colorSpaceRef);
                    CGImageRelease(imageRef);
                }
            }
            
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
            glDeleteFramebuffers(1, &framebuffer);
        }

        if (pixelBuffer) CFRelease(pixelBuffer);
        if (textureRef) CFRelease(textureRef);
    }
    
    {
        // teardown
        if (inputTexture)
            glDeleteTextures(1, &inputTexture);
        
        if (_fragmentShader)
            glDeleteShader(_fragmentShader);
        
        if (_vertexShader)
            glDeleteShader(_vertexShader);
        
        if (_program)
            glDeleteProgram(_program);
        
        self.context = nil;
    }
    
    return output;
}

- (void)setupContext {
    
    if (nil != self.context) {
        return;
    }
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    self.context = [[EAGLContext alloc] initWithAPI:api];
    if (!self.context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)compileShaders {
    _vertexShader = [self compileShader:self.vertexShaderString withType:GL_VERTEX_SHADER];
    _fragmentShader = [self compileShader:self.fragmentShaderString withType:GL_FRAGMENT_SHADER];
    
    _program = glCreateProgram();
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    glLinkProgram(_program);
    
    GLint linkSuccess;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
        [self logProgramInfo:_program];
    
    glUseProgram(_program);
    _positionAttribute = glGetAttribLocation(_program, "position");
    _textureCoordinateAttribute = glGetAttribLocation(_program, "inputTextureCoordinate");
    _inputTextureUniform =  glGetUniformLocation(_program, "inputImageTexture");  // This assumes a name of "inputImageTexture" for the fragment shader
}

- (NSString *)fragmentShaderString {
    if (nil == _fragmentShaderString) {
        _fragmentShaderString = @"precision mediump float;      \
        void main()                                             \
        {                                                       \
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);                \
        }";
    }
    return _fragmentShaderString;
}

- (NSString *)vertexShaderString {
    return
    @"                                                      \
    attribute vec4 position;                                \
    attribute vec2 inputTextureCoordinate;                  \
    varying vec2 textureCoordinate;                         \
    void main()                                             \
    {                                                       \
    gl_Position = position;                             \
    textureCoordinate = inputTextureCoordinate;      \
    }";
}
    
#pragma mark - helpers

- (GLuint)textureFromImage:(UIImage *)image {

    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(context);
    
    free(imageData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}

- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType {
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)logProgramInfo:(GLint)program {
    GLchar messages[256];
    glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
    NSString *messageString = [NSString stringWithUTF8String:messages];
    NSLog(@"%@", messageString);
    exit(1);
}

- (BOOL)makeTextureFrameBuffer:(CGSize)size frameBuffer:(GLuint *)frameBuffer pixelBuffer:(CVPixelBufferRef *)pixelBuffer texture:(CVOpenGLESTextureRef *)texture {
    NSDictionary *attrs = @{(NSString *) kCVPixelBufferIOSurfacePropertiesKey: @{},
                            (NSString *) kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
                            (NSString *) kCVPixelBufferCGImageCompatibilityKey: @(YES),
                            };
    
    size_t width = ceil(size.width);
    size_t height = ceil(size.height);
    
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width,
                        height,
                        kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef) attrs,
                        pixelBuffer);
    
    CVOpenGLESTextureCacheRef textureCache;
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                 NULL,
                                 self.context,
                                 NULL,
                                 &textureCache);
    
    CVOpenGLESTextureCacheCreateTextureFromImage (
                                                  kCFAllocatorDefault,
                                                  textureCache,
                                                  *pixelBuffer,
                                                  NULL,
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA,
                                                  width,
                                                  height,
                                                  GL_RGBA,
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  texture);
    
    CFRelease(textureCache);
    
    glBindTexture(CVOpenGLESTextureGetTarget(*texture),
                  CVOpenGLESTextureGetName(*texture));
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glGenFramebuffers(1, frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, *frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D, CVOpenGLESTextureGetName(*texture), 0);
    
    glBindTexture(CVOpenGLESTextureGetTarget(*texture),
                  0);
    
#ifdef DEBUG
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return NO;
    }
#endif
    
    return YES;
}

- (BOOL)makeTextureFrameBuffer:(CGSize)size frameBuffer:(GLuint *)frameBuffer texture:(GLuint *)texture {
    // you almost certainly don't want to do this. Instead, create a CVOpenGLESTextureRef and render to that
    glGenFramebuffers(1, frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, *frameBuffer);
    
    glGenTextures(1, texture);
    glBindTexture(GL_TEXTURE_2D, *texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  (GLsizei) ceil(size.width), (GLsizei) ceil(size.height), 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, *texture, 0);
    
#ifdef DEBUG
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
        return NO;
    }
#endif
    
    return YES;
}

@end
