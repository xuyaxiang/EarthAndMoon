//
//  ViewController.m
//  EarthAndMoon1
//
//  Created by enghou on 16/9/11.
//  Copyright © 2016年 xyxorigation. All rights reserved.
//

#import "ViewController.h"
#import "sphere.h"
@interface ViewController ()
@property(nonatomic,strong)GLKBaseEffect *baseEffect;
@property(nonatomic)GLKMatrixStackRef matrixStack;
@property(nonatomic,strong)GLKTextureInfo *info1;
@property(nonatomic,strong)GLKTextureInfo *info2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //将当前视图作为当前绘图上下文
    GLKView *view=(GLKView *)self.view;
    view.context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //设置清除颜色
    glClearColor(0, 0, 0, 1);
    //配置灯光以及与深度测试有关的参数
    self.baseEffect=[[GLKBaseEffect alloc]init];
    self.baseEffect.light0.enabled=GL_TRUE;
    self.baseEffect.useConstantColor=GL_TRUE;
    self.baseEffect.constantColor=GLKVector4Make(1, 1, 1, 2);
    self.baseEffect.light0.diffuseColor=GLKVector4Make(0.6, 0.7, 0.8, 1);
    self.baseEffect.light0.position=GLKVector4Make(-1.0f, 0, 0, 0);
    view.drawableDepthFormat=GLKViewDrawableDepthFormat16;
    //接下来开始绑定数据到数组缓存,并开启相关功能
    GLuint name;
    glGenBuffers(1, &name);//生成一个独一无二的名字
    glBindBuffer(GL_ARRAY_BUFFER, name);//将一个数组缓存绑定到该名字
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_STATIC_DRAW);//将数据放入缓存
    glEnableVertexAttribArray(GLKVertexAttribPosition);//开启相关功能
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), NULL);//设置数据的格式
    
    GLuint name1;
    glGenBuffers(1, &name1);
    glBindBuffer(GL_ARRAY_BUFFER, name1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereNormals), sphereNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), NULL);
    
    GLuint name2;
    glGenBuffers(1, &name2);
    glBindBuffer(GL_ARRAY_BUFFER, name2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), NULL);
    ///////////////////////////////////////////////////////////////////////////////
    //开始生成与纹理有关的数据
    CGImageRef image1=[UIImage imageNamed:@"Earth.jpg"].CGImage;
    _info1=[GLKTextureLoader textureWithCGImage:image1 options:@{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES]} error:nil];
    CGImageRef image2=[UIImage imageNamed:@"Moon"].CGImage;
    _info2=[GLKTextureLoader textureWithCGImage:image2 options:@{GLKTextureLoaderOriginBottomLeft:[NSNumber numberWithBool:YES]} error:nil];
   //初始化一个matrixStack，该堆栈将被用来对一个顶点数组实现变换
    _matrixStack=GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(_matrixStack, self.baseEffect.transform.modelviewMatrix);
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    static GLfloat degree=0;
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    const GLfloat  aspect =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix=GLKMatrix4MakeOrtho(-1, 1, -1/aspect,1/aspect, -5, 5);
    //绑定当前纹理
//    self.baseEffect.texture2d0.name=_info1.name;
//    self.baseEffect.texture2d0.target=_info1.target;
//    GLKMatrix4 xx=GLKMatrix4Identity;
//    xx=GLKMatrix4MakeScale(1, 1, 1);
//    xx=GLKMatrix4Rotate(xx,GLKMathDegreesToRadians(++degree) , 0, 1, 0);
//    xx=GLKMatrix4Translate(xx, 0, 0.5, 3);
//    self.baseEffect.transform.modelviewMatrix=xx;
//    [self.baseEffect prepareToDraw];
//    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
//    
//    self.baseEffect.texture2d0.name=_info2.name;
//    self.baseEffect.texture2d0.target=_info2.target;
//    self.baseEffect.transform.modelviewMatrix=GLKMatrix4MakeRotation(GLKMathDegreesToRadians(++degree), 0, 1, 0);
//    [self.baseEffect prepareToDraw];
//    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    
    self.baseEffect.texture2d0.name=_info1.name;
    self.baseEffect.texture2d0.target=_info1.target;
    //接下来开始构造一系列的变幻矩阵,先push，再pop,绘图完毕后要将变换矩阵复原，不是必须这么做。
    //一定要注意preparetodraw的调用时机，一定要等到所有数据都准备好后，包括一些变换才可以调用，一个preparetodraw后面的设置对绘图就无效了，除非再次调用一个preparetodraw
    GLKMatrixStackPush(_matrixStack);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    GLKMatrixStackRotate(_matrixStack, GLKMathDegreesToRadians(++degree), 0, 1, 0);
    self.baseEffect.transform.modelviewMatrix=GLKMatrixStackGetMatrix4(_matrixStack);
    [self.baseEffect prepareToDraw];
    GLKMatrixStackPop(_matrixStack);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    self.baseEffect.transform.modelviewMatrix=GLKMatrixStackGetMatrix4(_matrixStack);
    
    self.baseEffect.texture2d0.name=_info2.name;
    self.baseEffect.texture2d0.target=_info2.target;
    GLKMatrixStackPush(_matrixStack);
    GLKMatrixStackScale(_matrixStack, 0.25, 0.25, 0.25);
    GLKMatrixStackRotate(_matrixStack, GLKMathDegreesToRadians(++degree), 0, 1, 0);
    GLKMatrixStackTranslate(_matrixStack, 0, 0, 3);
    [self.baseEffect prepareToDraw];
    self.baseEffect.transform.modelviewMatrix=GLKMatrixStackGetMatrix4(_matrixStack);
    GLKMatrixStackPop(_matrixStack);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    self.baseEffect.transform.modelviewMatrix=GLKMatrixStackGetMatrix4(_matrixStack);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
