//
//  MDMDetailViewController.m
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

#import "MDMDetailViewController.h"
#import "UFOSighting+Additions.h"

@interface MDMDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *shapeImage;
@property (weak, nonatomic) IBOutlet UILabel *shapeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sightedLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *reportedLabel;

@end

@implementation MDMDetailViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)setupView {

    self.title = self.sighting.name;
   // NSURL *url = [NSURL URLWithString:self.sighting.avatar];
   // self.shapeImage.image =  [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.shapeImage.image =  [UIImage imageWithData:self.sighting.avatarImageData];
    
    self.descriptionTextView.text = self.sighting.text;
    self.shapeLabel.text=self.sighting.name;
    self.sightedLabel.text=self.sighting.guid;
    
}

@end
