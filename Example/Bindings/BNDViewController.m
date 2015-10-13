//
//  BNDViewController.m
//  Bindings
//
//  Created by Darren Clark on 10/13/2015.
//  Copyright (c) 2015 Darren Clark. All rights reserved.
//

#import "BNDViewController.h"
#import "Bindings_Example-Swift.h"

@interface BNDViewController ()

@property (nonatomic, strong) TestViewModel *viewModel;

@end

@implementation BNDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.viewModel = [[TestViewModel alloc] init];
    NSLog(@"%@", [self.viewModel valueForKeyPath:@"name"]);
    
    [self.viewModel addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    [self.viewModel useFullName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"%@:  %@ -> %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
