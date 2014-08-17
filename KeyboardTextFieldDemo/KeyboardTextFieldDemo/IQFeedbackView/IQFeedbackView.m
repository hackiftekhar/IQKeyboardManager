//
//  IQFeedbackView.m
//  IQPhotoEditor
//
//  Created by Iftekhar on 06/10/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQFeedbackView.h"
#import "DALinedTextView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIImage+ImageEffects.h"

@interface IQFeedbackView ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@end

@implementation IQFeedbackView
{
	UIImage *defaultImage;
	IQFeedbackCompletion _completionHandler;
	UIViewController *_currentController;
	
	UIView *backgroundView;
	
	UINavigationBar *navigationBar;
	id textViewFeedback;
    
	
	UIButton *buttonImageAttached;
    
    CGFloat keyboardHeight;
}

@synthesize message = _message;
@synthesize image = _image;


- (id)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage*)image cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle
{
	self = [self init];
	
	if (self)
	{
		UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:title];
		
		if ([doneButtonTitle length])
		{
			UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:doneButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
            if(!IOS_7_OR_GREATER)
                [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont boldSystemFontOfSize:0],UITextAttributeFont,
                                          [UIColor darkGrayColor],UITextAttributeTextColor,
                                          [UIColor blackColor],UITextAttributeTextShadowColor,
                                          [NSValue valueWithUIOffset:UIOffsetMake(-1, -1)],UITextAttributeTextShadowOffset,
                                          nil] forState:UIControlStateNormal];

            
			[navigationItem setRightBarButtonItem:doneButton animated:YES];
		}
		
		if ([cancelButtonTitle length])
		{
			UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonClicked:)];
            if(!IOS_7_OR_GREATER)
                [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont boldSystemFontOfSize:0],UITextAttributeFont,
                                                [UIColor darkGrayColor],UITextAttributeTextColor,
                                                [UIColor blackColor],UITextAttributeTextShadowColor,
                                                [NSValue valueWithUIOffset:UIOffsetMake(-1, -1)],UITextAttributeTextShadowOffset,
                                                nil] forState:UIControlStateNormal];
			[navigationItem setLeftBarButtonItem:cancelButton animated:YES];
		}
		
		[navigationBar setItems:[NSArray arrayWithObject:navigationItem]];
		
		[self setTitle:title];
		[self setMessage:message];
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setFrame:CGRectMake(10, -204, 300, 254)];
		[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin)];
		[self.layer setCornerRadius:7.0];
		[self setClipsToBounds:YES];
        
        defaultImage = [UIImage imageNamed:@"addImage"];
		
		navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        
        if(IOS_7_OR_GREATER){
            UIImageView *blurredBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [[UIScreen mainScreen] bounds].size.height)];
            blurredBackgroundView.image = [self blurredSnapshot];
            [self addSubview: blurredBackgroundView];
            
            
            UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            interpolationHorizontal.minimumRelativeValue = @-7.0;
            interpolationHorizontal.maximumRelativeValue = @7.0;
            
            UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            interpolationVertical.minimumRelativeValue = @-7.0;
            interpolationVertical.maximumRelativeValue = @7.0;
            
            [self addMotionEffect:interpolationHorizontal];
            [self addMotionEffect:interpolationVertical];
            
        }
        else{
            [self setBackgroundColor:[UIColor whiteColor]];
            
            [navigationBar setTintColor:[UIColor whiteColor]];
            [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont boldSystemFontOfSize:0],UITextAttributeFont,
                                                   [UIColor darkGrayColor],UITextAttributeTextColor,
                                                   [UIColor blackColor],UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(-1, -2)],UITextAttributeTextShadowOffset,
                                                   nil]];
        }
		
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)     keyboardHeight = 216;
        else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)  keyboardHeight = 264;
    

		[navigationBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
		[self addSubview:navigationBar];

        
        if(!IOS_7_OR_GREATER){
            textViewFeedback = [[DALinedTextView alloc] initWithFrame:CGRectMake(5, 49, 205, 200)];
            
        }
        else{
            textViewFeedback = [[UITextView alloc] initWithFrame:CGRectMake(5, 49, 205, 200)];
            ((UITextView *)textViewFeedback).backgroundColor = [UIColor clearColor];
        }
        
		[textViewFeedback setDataDetectorTypes:(UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink)];
		[textViewFeedback setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
		[textViewFeedback setAutocorrectionType:UITextAutocorrectionTypeNo];
		[textViewFeedback setKeyboardAppearance:UIKeyboardAppearanceAlert];
		[textViewFeedback setFont:[UIFont systemFontOfSize:15.0]];
		[self addSubview:textViewFeedback];

		buttonImageAttached = [[UIButton alloc] initWithFrame:CGRectMake(215, 49, 80, 80)];
		[buttonImageAttached setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
        [buttonImageAttached.layer setShadowColor:[UIColor blackColor].CGColor];
        [buttonImageAttached.layer setShadowOffset:CGSizeMake(-1, -3)];
        [buttonImageAttached.layer setShadowOpacity:1];
        [buttonImageAttached.layer setShadowRadius:2];
		[buttonImageAttached setImage:defaultImage forState:UIControlStateNormal];
		[buttonImageAttached.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[buttonImageAttached addTarget:self action:@selector(buttonImageClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:buttonImageAttached];
		
		backgroundView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
		[backgroundView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
		[backgroundView setBackgroundColor:[UIColor clearColor]];
		[backgroundView addSubview:self];
		
		[self setCanAddImage:YES];
		[self setCanEditText:YES];
    }
    return self;
}


-(void)setTitle:(NSString *)title
{
	_title = title;
	
	[navigationBar.topItem setTitle:title];
}

-(void)setMessage:(NSString *)message
{
	_message = message;
	
	[textViewFeedback setText:message];
	
	if (_canEditText == NO)
	{
//		[_currentController];
	}
	
}

-(NSString *)message
{
	return ((UITextView *)textViewFeedback).text;
}

-(void)setImage:(UIImage *)image
{
	_image = image;
	
	if (_image == nil)	[buttonImageAttached setImage:defaultImage forState:UIControlStateNormal];
	else				[buttonImageAttached setImage:_image forState:UIControlStateNormal];
}

-(UIImage *)image
{
	if (buttonImageAttached.currentImage == nil || [buttonImageAttached.currentImage isEqual:defaultImage])
	{
		return nil;
	}
	else
	{
		return buttonImageAttached.currentImage;
	}
}

-(void)setCanEditImage:(BOOL)canEditImage
{
    _canEditImage = canEditImage;
    [buttonImageAttached setEnabled:_canEditImage];
}

-(void)setCanAddImage:(BOOL)canAddImage
{
	_canAddImage = canAddImage;
    
	CGRect textFrame = ((UITextView *) textViewFeedback).frame;
	
	if (_canAddImage == YES)
	{
		[textViewFeedback setFrame:CGRectMake(textFrame.origin.x, textFrame.origin.y, 205, textFrame.size.height)];
		[buttonImageAttached setHidden:NO];
	}
	else
	{
		[textViewFeedback setFrame:CGRectMake(textFrame.origin.x, textFrame.origin.y, 290, textFrame.size.height)];
		[buttonImageAttached setHidden:YES];
	}
}

-(void)setCanEditText:(BOOL)canEditText
{
	_canEditText = canEditText;
	
    //if(!IOS_7_OR_GREATER)
        [textViewFeedback setEditable:_canEditText];
}


-(void)buttonImageClicked:(UIButton*)button
{
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	[controller setDelegate:self];
	[_currentController presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[self setImage:image];
	[picker dismissViewControllerAnimated:YES completion:^{
		[textViewFeedback becomeFirstResponder];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:^{
		[textViewFeedback becomeFirstResponder];
	}];
}


-(void)doneButtonClicked:(UIBarButtonItem*)button
{
	if (_completionHandler)
	{
		_completionHandler(NO, [self message], [self image]);
	}
}

-(void)cancelButtonClicked:(UIBarButtonItem*)button
{
	if (_completionHandler)
	{
		_completionHandler(YES, nil, nil);
	}
}

-(void)show
{
    CGFloat offset = (IOS_7_OR_GREATER)? 0 : 20;
    
	if (_canEditText)
	{
 		[self setCenter:CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds)-offset-keyboardHeight/2)];
	}
	else
	{
		[self setCenter:CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds)-offset)];
	}
}

-(void)showInViewController:(UIViewController*)controller completionHandler:(IQFeedbackCompletion)completionHandler
{
	_currentController = controller;
	_completionHandler = completionHandler;
    
    CGSize viewSize = controller.view.bounds.size;
    
    [self setFrame:CGRectMake(viewSize.width*0.05, -(viewSize.height-keyboardHeight-20), viewSize.width*0.90, viewSize.height-keyboardHeight-20)];

	[controller.view addSubview:backgroundView];
	
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self show];
		[backgroundView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
	} completion:^(BOOL finished) {
	}];
	[textViewFeedback becomeFirstResponder];
}

-(void)dismiss
{
	[textViewFeedback resignFirstResponder];
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGSize viewSize = self.superview.bounds.size;
        [self setFrame:CGRectMake(viewSize.width*0.05, -(viewSize.height-keyboardHeight-40), viewSize.width*0.90, viewSize.height-keyboardHeight-40)];
		[backgroundView setBackgroundColor:[UIColor clearColor]];
	} completion:^(BOOL finished) {
		[backgroundView removeFromSuperview];
	}];
}


//This function courtesy of: http://damir.me/posts/ios7-blurring-techniques
-(UIImage *)blurredSnapshot
{
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        // Create the image context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
        
        // There he is! The new API method
        [self drawViewHierarchyInRect:self.frame afterScreenUpdates:YES];
        
        // Get the snapshot
        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Now apply the blur effect using Apple's UIImageEffect category
        UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
        
        // Or apply any other effects available in "UIImage+ImageEffects.h"
        // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
        // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
        
        // Be nice and clean your mess up
        UIGraphicsEndImageContext();
        
        return blurredSnapshotImage;
    }
    else
    {
        return nil;
    }
}


@end
