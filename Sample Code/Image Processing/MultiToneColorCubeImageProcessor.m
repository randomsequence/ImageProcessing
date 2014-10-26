//
//  MultiToneColorCubeImageProcessor.m
//  Image Processing
//
//  Created by Johnnie Walker on 20/10/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MultiToneColorCubeImageProcessor.h"

@implementation MultiToneColorCubeImageProcessor
- (CIImage *)filteredImage:(CIImage *)inputImage {
    
    const unsigned int size = 8;
    size_t cubeDataSize = size * size * size * sizeof (float) * 4;
    
    float *cubeData = (float *)malloc (cubeDataSize);
    float r,g,b, luminance, alpha, *c = cubeData;
        
    float lightTint[4] = {1.0, 0.5, 0.78, 1.0};
    float darkTint[4] = {0.08, 0.35, 0.25, 0.0};
    
    // Populate cube with a simple gradient going from 0 to 1
    for (int z = 0; z < size; z++){
        r = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            g = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                b = ((double)x)/(size-1); // Red value
                // 0.2125, 0.7154, 0.0721
                luminance = (r*0.302) + (g*0.592) + (b*0.110);
                
                alpha = ((lightTint[3] * luminance) + ((1.0 - luminance) * darkTint[3]));
                
                // Calculate premultiplied alpha values for the cube
                c[0] = alpha * ((lightTint[0] * luminance) + ((1.0 - luminance) * darkTint[0]));
                c[1] = alpha * ((lightTint[1] * luminance) + ((1.0 - luminance) * darkTint[1]));
                c[2] = alpha * ((lightTint[2] * luminance) + ((1.0 - luminance) * darkTint[2]));
                c[3] = alpha;
                c += 4; // advance our pointer into memory for the next color value
            }
        }
    }
    
    
    CIFilter *cube = [CIFilter filterWithName:@"CIColorCube"];
    [cube setDefaults];
    [cube setValue:inputImage forKey: kCIInputImageKey];
    [cube setValue:@(size) forKey:@"inputCubeDimension"];
    // Set data for cube
    [cube setValue:[NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES] forKey:@"inputCubeData"];
    
    CIFilter *blend = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [blend setValue:cube.outputImage forKey:kCIInputImageKey];
    [blend setValue:inputImage forKey:kCIInputBackgroundImageKey];
    
    return blend.outputImage;
}
@end
