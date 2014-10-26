//
//  MasterViewController.m
//  Image Processing
//
//  Created by Johnnie Walker on 25/09/2014.
//  Copyright (c) 2014 Random Sequence. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ImageProcessor.h"
#import "MaxRedImageProcessor.h"
#import "MonoChromeImageProcessor.h"
#import "TintImageProcessor.h"
#import "MultiToneImageProcessor.h"
#import "MaxRedGLImageProcessor.h"
#import "MuliToneGLImageProcessor.h"
#import "MultiToneColorCubeImageProcessor.h"
#import "MultiToneColorKernelImageProcessor.h"
#import "FalseColorImageProcessor.h"

@interface MasterViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

enum {
    RED_MAX=0,
    MONO,
    TINT,
    MULTITONE,
    RED_MAX_GL,
    MULTITONE_GL,
    MULTITONE_COLOR_CUBE,
    MULTITONE_COLOR_KERNEL,
    FALSE_COLOR,
    ROW_COUNT
};

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.queue = [NSOperationQueue new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        UIImage *image = [UIImage imageNamed:@"hanging-valley.jpg"];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ImageProcessor *imageProcessor = nil;
        switch (indexPath.row) {
            case RED_MAX:
                imageProcessor = [[MaxRedImageProcessor alloc] initWithImage:image];
                break;
                
            case MONO:
                imageProcessor = [[MonoChromeImageProcessor alloc] initWithImage:image];
                break;
                
            case TINT:
                imageProcessor = [[TintImageProcessor alloc] initWithImage:image];
                break;
                
            case MULTITONE:
                imageProcessor = [[MultiToneImageProcessor alloc] initWithImage:image];
                break;
                
            case MULTITONE_GL:
                imageProcessor = [[MuliToneGLImageProcessor alloc] initWithImage:image];
                break;
                
            case MULTITONE_COLOR_CUBE:
                imageProcessor = [[MultiToneColorCubeImageProcessor alloc] initWithImage:image];
                break;
                
            case MULTITONE_COLOR_KERNEL:
                imageProcessor = [[MultiToneColorKernelImageProcessor alloc] initWithImage:image];
                break;
                
            case FALSE_COLOR:
                imageProcessor = [[FalseColorImageProcessor alloc] initWithImage:image];
                break;
                
            case RED_MAX_GL:
                imageProcessor = [[MaxRedGLImageProcessor alloc] initWithImage:image];
                break;
        }
        
        if (nil != imageProcessor) {
            [self.queue addOperation:imageProcessor];            
        }
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        controller.title = [self titleAtIndexPath:indexPath];
        controller.imageProcessor = imageProcessor;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ROW_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleAtIndexPath:indexPath];
    
    return cell;
}

- (NSString *)titleAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = nil;
    
    switch (indexPath.row) {
        case RED_MAX:
            name = @"Maximum red";
            break;
            
        case RED_MAX_GL:
            name = @"Maximum red (OpenGL)";
            break;
            
        case MONO:
            name = @"Monochrome";
            break;
            
        case TINT:
            name = @"Tint";
            break;
            
        case MULTITONE:
            name = @"Multitone";
            break;
            
        case MULTITONE_GL:
            name = @"Multitone (OpenGL)";
            break;
            
        case MULTITONE_COLOR_CUBE:
            name = @"Multitone (CIColorCube)";
            break;
            
        case MULTITONE_COLOR_KERNEL:
            name = @"Multitone (CIColorKernel)";
            break;
            
        case FALSE_COLOR:
            name = @"False Color";
            break;
    }
    return name;
}

@end
