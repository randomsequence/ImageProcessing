//
//  DetailViewController.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageProcessor.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setImageProcessor:(ImageProcessor *)imageProcessor {
    _imageProcessor = imageProcessor;
    
    if (imageProcessor.isFinished) {
        self.image = imageProcessor.outputImage;
    } else {
        __weak typeof(self) weakSelf = self;
        __weak typeof(imageProcessor) weakOp = imageProcessor;
        imageProcessor.completionBlock = ^{
            UIImage *outputImage = weakOp.outputImage;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                weakSelf.image = outputImage;
            }];
        };
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
#if TARGET_IPHONE_SIMULATOR
    NSString *file = [[NSString stringWithFormat:@"~/Documents/%@.jpg", NSStringFromClass([self class])] stringByExpandingTildeInPath];
    [UIImageJPEGRepresentation(image, 0.9) writeToFile:file atomically:NO];
#endif
}

- (UIImage *)image {
    return self.imageView.image;
}
@end
