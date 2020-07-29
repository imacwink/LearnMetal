//
//  ViewController.m
//  Texture-ObjC
//
//  Created by 王云刚 on 2020/7/16.
//

#import "ViewController.h"
#import "MetalContext.h"
#import "MetalView.h"
#import "Texture.h"
#import "TextureLoader.h"

@interface ViewController ()

@property (nonatomic, strong) MetalContext *mtlContext;
@property (nonatomic) MetalView *mtlView;
@property (nonatomic) Texture *textureRender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建 Metal 渲染需要的上下文信息;
    self.mtlContext = [MetalContext shareMetalContext];
    
    // 创建 Metal 渲染需要的视图窗口;
    self.mtlView = [[MetalView alloc] init];
    self.mtlView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.mtlView];
    
    // 创建真实渲染器，需要熏染一个三角形，同时需要将视图窗口的 Layer 信息传递给它;
    self.textureRender = [[Texture alloc] initWithLayer: self.mtlView.metalLayer context: self.mtlContext];
    [self.textureRender processDraw:[TextureLoader loadTexture:self.mtlContext.device assertName:@"test"]];
//    [self.textureRender processDraw:[TextureLoader loadTexture:self.mtlContext.device imageNamed:@"for-test-001.jpeg"]];
}

@end
