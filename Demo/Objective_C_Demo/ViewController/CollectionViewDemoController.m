//
//  CollectionViewDemoController.m
//  IQKeyboard
//
//  Created by Iftekhar on 29/10/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "CollectionViewDemoController.h"

@interface CollectionViewDemoController ()<UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TextFieldCollectionViewCell" forIndexPath:indexPath];
    
    UITextField *textField = (UITextField*)[cell viewWithTag:10];
    textField.placeholder = [NSString stringWithFormat:@"%ld, %ld", (long)indexPath.section, (long)indexPath.row];
    
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
