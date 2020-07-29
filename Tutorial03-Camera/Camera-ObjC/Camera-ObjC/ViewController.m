//
//  ViewController.m
//  Camera-ObjC
//
//  Created by 王云刚 on 2020/7/18.
//

#import "ViewController.h"
#import "CameraEngine.h"
#import "MetalContext.h"
#import "MetalView.h"
#import "Texture.h"
#import "TextureLoader.h"

@interface ViewController () <CameraEngineDelegate>

@property (nonatomic, strong) MetalContext *mtlContext;
@property (nonatomic) MetalView *mtlView;
@property (nonatomic) Texture *textureRender;

@property (nonatomic, strong) CameraEngine *cameraEngine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObserver];
    
    // 创建 Metal 渲染需要的上下文信息;
    self.mtlContext = [MetalContext shareMetalContext];
    
    // 创建 Metal 渲染需要的视图窗口;
    self.mtlView = [[MetalView alloc] init];
    
    // 根据相机采集的分辨率设置绘制区域;
    float cameraW = 720.0f;
    float cameraH = 1280.0f;
    float frameW = self.view.frame.size.width;
    float frameH = self.view.frame.size.height;
    float realW = frameW;
    float realH = cameraH * frameW / cameraW;
    float orginX = 0.0f;
    float orginY = (frameH - realH) / 2.0f;
    
    self.mtlView.frame = CGRectMake(orginX, orginY, realW, realH);
    [self.view addSubview:self.mtlView];
    
    // 创建真实渲染器，需要熏染一个三角形，同时需要将视图窗口的 Layer 信息传递给它;
    self.textureRender = [[Texture alloc] initWithLayer: self.mtlView.metalLayer context: self.mtlContext];
    
    // 创建相机;
    self.cameraEngine = [[CameraEngine alloc] initCE];
    self.cameraEngine.delegate = self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive {
    [self.cameraEngine stopCE];
}

- (void)didBecomeActive {
    [self.cameraEngine startCE];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    [self.cameraEngine startCE];
}

- (void)didOutputVideoBuffer:(CVPixelBufferRef)vpBuffer {
    if(vpBuffer) {
        [self.textureRender processDraw:[self.mtlContext textureFromPixelBuffer: vpBuffer]];
    }
}

@end
