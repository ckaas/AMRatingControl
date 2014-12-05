//
//  AMRatingControl.m
//  RatingControl
//


#import "AMRatingControl.h"


// Constants :
static const CGFloat kFontSize = 20;
static const NSInteger kStarWidthAndHeight = 20;
static const NSInteger kStarSpacing = 0;

static const NSString *kDefaultEmptyChar = @"☆";
static const NSString *kDefaultSolidChar = @"★";


@interface AMRatingControl (Private)

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating;

- (void)adjustFrame;
- (void)handleTouch:(UITouch *)touch;

@end


@implementation AMRatingControl
{
    BOOL _respondsToTranslatesAutoresizingMaskIntoConstraints;
    UIColor *_emptyColor, *_solidColor;
    NSInteger _maxRating;
}

/**************************************************************************************************/
#pragma mark - Getters & Setters

- (void)setMaxRating:(NSInteger)maxRating
{
    _maxRating = maxRating;
    if (_rating > maxRating) {
        _rating = maxRating;
    }
    [self adjustFrame];
    [self setNeedsDisplay];
}

- (void)setRating:(NSInteger)rating
{
    _rating = (rating < 0) ? 0 : rating;
    _rating = (rating > _maxRating) ? _maxRating : rating;
    [self setNeedsDisplay];
}

- (void)setStarWidthAndHeight:(NSUInteger)starWidthAndHeight
{
    _starWidthAndHeight = starWidthAndHeight;
    [self adjustFrame];
    [self setNeedsDisplay];
}

- (void)setStarSpacing:(NSUInteger)starSpacing
{
    _starSpacing = starSpacing;
    [self adjustFrame];
    [self setNeedsDisplay];
}

- (void)setEmptyImage:(UIImage *)emptyImage
{
    _emptyImage = emptyImage;
    [self setNeedsDisplay];
}

- (void)setSolidImage:(UIImage *)solidImage
{
    _solidImage = solidImage;
    [self setNeedsDisplay];
}

/**************************************************************************************************/
#pragma mark - Birth & Death

- (id)initWithLocation:(CGPoint)location andMaxRating:(NSInteger)maxRating
{
    return [self initWithLocation:location
                       emptyImage:nil
                       solidImage:nil
                       emptyColor:nil
                       solidColor:nil
                     andMaxRating:maxRating];
}

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
          andMaxRating:(NSInteger)maxRating
{
	return [self initWithLocation:location
                       emptyImage:emptyImageOrNil
                       solidImage:solidImageOrNil
                       emptyColor:nil
                       solidColor:nil
                     andMaxRating:maxRating];
}

- (id)initWithLocation:(CGPoint)location
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating
{
    return [self initWithLocation:location
                       emptyImage:nil
                       solidImage:nil
                       emptyColor:emptyColor
                       solidColor:solidColor
                     andMaxRating:maxRating];
}

- (void)dealloc
{
	_emptyImage = nil,
	_solidImage = nil;
    _emptyColor = nil;
    _solidColor = nil;
}

/**************************************************************************************************/
#pragma mark - Auto Layout

- (CGSize)intrinsicContentSize
{
    // if images are given we scale to whatever size was defined
    if (!_solidImage && ! _emptyImage){
        return CGSizeMake(_maxRating * _starWidthAndHeight + (_maxRating - 1) * _starSpacing,
                          _starWidthAndHeight);
    }
    return self.frame.size;
}


/**************************************************************************************************/
#pragma mark - View Lifecycle

- (void)drawRect:(CGRect)rect
{
	CGPoint currPoint = CGPointZero;
	
	for (int i = 0; i < _rating; i++)
	{
		if (_solidImage)
        {
            CGRect destinationRect = CGRectMake(currPoint.x, currPoint.y, self.frame.size.height, self.frame.size.height);
            [_solidImage drawInRect:destinationRect];
            currPoint.x += self.frame.size.height;
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _solidColor.CGColor);
            [kDefaultSolidChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:_starFontSize]];
            currPoint.x += (_starWidthAndHeight + _starSpacing);
        }
        
	}
	
	NSInteger remaining = _maxRating - _rating;
	
	for (int i = 0; i < remaining; i++)
	{
		if (_emptyImage)
        {
            CGRect destinationRect = CGRectMake(currPoint.x, currPoint.y, self.frame.size.height, self.frame.size.height);
			[_emptyImage drawInRect:destinationRect];
            currPoint.x += self.frame.size.height;
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _emptyColor.CGColor);
			[kDefaultEmptyChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:_starFontSize]];
            currPoint.x += (_starWidthAndHeight + _starSpacing);
        }
	}
}


/**************************************************************************************************/
#pragma mark - UIControl

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self handleTouch:touch];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self handleTouch:touch];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.editingDidEndBlock)
    {
        self.editingDidEndBlock(_rating);
    }
}


/**************************************************************************************************/
#pragma mark - Private Methods

- (void)initializeWithEmptyImage:(UIImage *)emptyImageOrNil
                      solidImage:(UIImage *)solidImageOrNil
                      emptyColor:(UIColor *)emptyColor
                      solidColor:(UIColor *)solidColor
                    andMaxRating:(NSInteger)maxRating
{
    _respondsToTranslatesAutoresizingMaskIntoConstraints = [self respondsToSelector:@selector(translatesAutoresizingMaskIntoConstraints)];
    
    _rating = 0;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _emptyImage = emptyImageOrNil;
    _solidImage = solidImageOrNil;
    _emptyColor = emptyColor;
    _solidColor = solidColor;
    _maxRating = maxRating;
    _starFontSize = kFontSize;
    _starWidthAndHeight = kStarWidthAndHeight;
    _starSpacing = kStarSpacing;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initializeWithEmptyImage:nil
                            solidImage:nil
                            emptyColor:nil
                            solidColor:nil
                          andMaxRating:0];
    }
    return self;
}


- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating
{
    if (self = [self initWithFrame:CGRectMake(location.x,
                                              location.y,
                                              (maxRating * kStarWidthAndHeight),
                                              kStarWidthAndHeight)])
	{
		[self initializeWithEmptyImage:emptyImageOrNil
                            solidImage:solidImageOrNil
                            emptyColor:emptyColor
                            solidColor:solidColor
                          andMaxRating:maxRating];
	}
	
	return self;
}

- (void)adjustFrame
{
    if (_respondsToTranslatesAutoresizingMaskIntoConstraints && !self.translatesAutoresizingMaskIntoConstraints)
    {
        [self invalidateIntrinsicContentSize];
    }
    else
    {
        if (_solidImage && _emptyImage){
            // just keep the frame we already have ;-)
        }else{
            CGRect newFrame = CGRectMake(self.frame.origin.x,
                                         self.frame.origin.y,
                                         _maxRating * _starWidthAndHeight + (_maxRating - 1) * _starSpacing,
                                         _starWidthAndHeight);
            self.frame = newFrame;
        }
    }
}

- (void)handleTouch:(UITouch *)touch
{
    CGFloat width = self.frame.size.width;
    CGRect section;
    CGFloat sectionWidth;
    if (! _solidImage && ! _emptyImage){
        sectionWidth = _starWidthAndHeight;
    }else{
        sectionWidth = self.frame.size.height;
    }

    section = CGRectMake(0, 0, sectionWidth, self.frame.size.height);
	
	CGPoint touchLocation = [touch locationInView:self];
	
	if (touchLocation.x < 0)
	{
		if (_rating != 0)
		{
			_rating = 0;
            if (self.editingChangedBlock)
            {
                self.editingChangedBlock(_rating);
            }
		}
	}
	else if (touchLocation.x > width)
	{
		if (_rating != _maxRating)
		{
			_rating = _maxRating;
            if (self.editingChangedBlock)
            {
                self.editingChangedBlock(_rating);
            }
		}
	}
	else
	{
		for (int i = 0 ; i < _maxRating ; i++)
		{
			if ((touchLocation.x > section.origin.x) && (touchLocation.x < (section.origin.x + sectionWidth)))
			{
				if (_rating != (i + 1))
				{
					_rating = i + 1;
                    if (self.editingChangedBlock)
                    {
                        self.editingChangedBlock(_rating);
                    }
				}
				break;
			}
			section.origin.x += (sectionWidth + _starSpacing);
		}
	}
	[self setNeedsDisplay];
}

@end
