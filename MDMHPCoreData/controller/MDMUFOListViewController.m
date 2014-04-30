//
//  MDMUFOViewController.m
//  MDMHPCoreData
//
//  Created by Matthew Morey (http://matthewmorey.com) on 10/16/13.
//  Copyright (c) 2013 Matthew Morey. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "MDMUFOListViewController.h"
#import "MDMPersistenceStack.h"
#import "MDMFetchedResultsTableDataSource.h"
#import "UFOSighting+Additions.h"
#import "MDMAppDelegate.h"
#import "MDMDetailViewController.h"
#import "MDMUFOSightingCell.H"
#import "UFOSighting+Additions.h"
#import "NSDictionary+MDMAdditions.h"
#import "MDMUFOSightingImportOperation.h"
#import "MDMAppDelegate.h"

static const NSUInteger MDM_TAG_IMPORT_ALERTVIEW = 1;

@interface MDMUFOListViewController () <UIAlertViewDelegate>{
    NSMutableData * jsonData;
    UIRefreshControl *refreshControl;
}

@property (nonatomic, strong) MDMFetchedResultsTableDataSource *dataSource;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;

@end

@implementation MDMUFOListViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importOperationComplete)
                                                 name:MDM_NOTIFICATION_IMPORT_OPERATION_COMPLETE
                                               object:nil];
    
   refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self setRefreshControl:refreshControl];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.operationQueue removeObserver:self forKeyPath:@"operationCount"];
}

#pragma mark - UITableViewDataSource

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    _managedObjectContext = managedObjectContext;
    [self setupTableDataSource];
}

- (void)setupTableDataSource {
    
    NSAssert(self.managedObjectContext, @"ASSERT: Forgot to set managed object context");
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[UFOSighting entityName]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:UFO_KEY_COREDATA_GUID ascending:NO]]];
    
    // Reduce memory usuage by setting a batch size
    //     a value double the amount of items shown on
    //     screen is a good starting point.
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    
    self.dataSource = [[MDMFetchedResultsTableDataSource alloc] initWithTableView:self.tableView fetchedResultsController:fetchedResultsController];
    
    __typeof(self) __weak weakSelf = self;
    self.dataSource.configureCellBlock = ^(MDMUFOSightingCell *cell, UFOSighting *sighting) {
        [weakSelf configureCell:cell withUFOSighting:sighting];
    };
    
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

- (void)configureCell:(MDMUFOSightingCell *)cell withUFOSighting:(UFOSighting *)sighting {
    
    NSURL *url = [NSURL URLWithString:sighting.avatar];
    cell.shapeImageView.image =  [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    cell.name.text = sighting.name;
    cell.text.text = sighting.text;
}

#pragma mark - Import Operations

- (NSOperationQueue *)operationQueue {
    
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return _operationQueue;
}

- (void)importOperationComplete {
    
    [self performSelectorOnMainThread:@selector(setupTableDataSource) withObject:nil waitUntilDone:NO];
       dispatch_async(dispatch_get_main_queue(), ^{
           [refreshControl endRefreshing];
    });

}

- (void)createImportOperation {
    
    //
    // I don't really like relying on the app delegate here, any ideas on a better approach?
    //
    
    // This could also be a network request
    
    
    
    NSURL *networkURL = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
    
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: networkURL];
	
    // [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
	[theRequest setHTTPMethod:@"GET"];
	
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	if( theConnection !=NULL ){
		jsonData = [[NSMutableData alloc] init];
	}
}
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)newData
{
    [jsonData appendData:newData];
}
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    NSLog(@"Error 1 %@",[error description]);
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    MDMAppDelegate *appDelegate = (MDMAppDelegate *)[[UIApplication sharedApplication] delegate];

    MDMUFOSightingImportOperation *importOperation = [[MDMUFOSightingImportOperation alloc]
                                                      initWithPersistenceStack:appDelegate.stack                                            importData:jsonData];
    
    importOperation.progressBlock = ^(CGFloat progress) {
        NSLog(@"Progress: %f", progress);
    };
    [self.operationQueue addOperation:importOperation];
}

#pragma mark - IBAction

- (IBAction)importButtonTapped:(id)sender {
    
    if ([self.operationQueue operationCount] < 1) {
        [self createImportOperation];
    } else {
        [self showImportAlertView];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)showImportAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cancel Import"
                                                        message:@"Import operation is currently running. Would you like to cancel it?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertView.tag = MDM_TAG_IMPORT_ALERTVIEW;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == MDM_TAG_IMPORT_ALERTVIEW) {
        switch (buttonIndex) {
            case 1:
                [self.operationQueue cancelAllOperations];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"operationCount"]) {
        [self performSelectorOnMainThread:@selector(updateImportButtonTextWithChange:) withObject:change waitUntilDone:NO];
    }
}

- (void)updateImportButtonTextWithChange:(NSDictionary *)change {
    
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if ([newValue integerValue] > 0) {
        self.importButton.title = @"Cancel";
    } else {
        self.importButton.title = @"Import";
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[MDMDetailViewController class]]) {
        MDMDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.sighting = self.dataSource.selectedItem;
    }
}
#pragma mark - refresh

- (void)refresh:(id)sender
{
    NSLog(@"Refreshing");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.operationQueue operationCount] < 1) {
            [self createImportOperation];
        } else {
            [self showImportAlertView];
        }
    });

   
}
@end
