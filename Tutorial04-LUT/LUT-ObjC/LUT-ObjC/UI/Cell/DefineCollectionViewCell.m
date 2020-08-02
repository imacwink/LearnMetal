//
//  DefineCollectionViewCell.m
//  LUT-ObjC
//
//  Created by 王云刚 on 2020/8/1.
//
//
//
//                 .-~~~~~~~~~-._       _.-~~~~~~~~~-.
//             __.'              ~.   .~              `.__
//           .'//                  \./                  \\`.
//         .'//                     |                     \\`.
//       .'// .-~"""""""~~~~-._     |     _,-~~~~"""""""~-. \\`.
//     .'//.-"                 `-.  |  .-'                 "-.\\`.
//   .'//______.============-..   \ | /   ..-============.______\\`.
// .'______________________________\|/______________________________`.
//

#import "DefineCollectionViewCell.h"

@interface DefineCollectionViewCell ()

@property(strong, nonatomic) UIImageView * imageView;
@property(strong, nonatomic) UITextView * textView;

@end

@implementation DefineCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., frame.size.width, frame.size.height)];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

@end
