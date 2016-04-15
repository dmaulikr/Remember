//
//  AlertView+Input.m
//  Remember
//
//  Created by Keeton on 10/17/14.
//  Copyright (c) 2014 Solar Pepper Studios. All rights reserved.
//

#import "AlertView+Input.h"

@implementation AlertView_Input
@synthesize textField;
@synthesize enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [field setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:field];
        self.textField = field;
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
        [self setTransform:translate];
    }
    return self;
}

- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return textField.text;
}

@end
