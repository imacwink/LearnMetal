# HelloMetal

## 简介
-------------
> Metal 是 Apple 设备的一个底层图形 API，功能与 OpenGL 类似，支持图形渲染和 GPU 通用计算（并行计算），最近在和 Apple 的技术童鞋进行技术交流时，他们也表示了即将全面废弃 OpenGL，所以 Metal 将会成为 Apple 相关设备图形开发的唯一选择，Metal 的基础知识入门，比较推荐首先阅读 Metal 官方文档，如果英语不好的小伙伴建议阅读这位博主官方文档翻译版：https://www.jianshu.com/p/fe257f774c38， 工程中实际遇到的典型问题及其解决方案，建议阅读 By Example 系列：http://metalbyexample.com/。

### 为什么不干脆扩展 OpenGL ?

苹果是 OpenGL 架构审查委员会的成员，并且历史上也在 iOS 上提供过它们自己的 GL 扩展。但从内部改变 OpenGL 看起来是个困难的任务，因为它有着不同的设计目标。实际上，它必须有广泛的硬件兼容性以运行在很多不同的设备上。虽然 OpenGL 还在持续发展，但速度缓慢。

而 Metal 则本来就是只为了苹果的平台而创建的。即使基于协议的 API 最初看起来不太常见，但和其它框架配合的很好。Metal 是用 Objective-C 编写的，基于 Foundation，使用 GCD 在 CPU 和 GPU 之间保持同步。它是更先进的 GPU 管道的抽象，而 OpenGL 想达到这些的话只能完全重写。


### 何种需求应该使用 Metal ?

对于游戏从业者或者游戏引擎开发者来说，Metal 不是个好的选择。首先苹果官方的各种预制的封装 API 已经可以完美支持，无需去接触这种偏底层的 API；其次市面上还有功能更全面的 3D 游戏引擎，例如 Epic 的 UE4、UE5 或 U3D（Unity3D），两者都是完全跨平台的，开发者使用这些引擎，无需直接使用 Metal 的 API，就可以从 Metal 中获益，因为他们底层都已经封装了 Metal，让你的开发更加便利。

如果您是相机、短视频、视频编辑或直播 APP 从业者的化，您是需要编写基于底层图形 API 的渲染系统的，当然除了 Metal 以外其实还有 GL、GL ES 甚至跨平台的 Vulkan，GL 不仅支持包括 OSX，Windows，Linux 和 Android 在内的几乎所有平台，还有大量的教程，书籍和最佳实践指南等资料；反观 Metal，目前可以参考和学习的资源非常的有限，不过随着苹果渐渐的完善，文档和教程也越来越丰富；从另外一角度由于 GL 的限制，其性能与 Metal 相比并不占优势，Metal 是专门用来解决这些问题的。

假如您想要一个 iOS 上高性能的并行计算库，答案非常简单，Metal 是唯一的选择。OpenCL 在 iOS 上是私有框架，而 Core Image (使用了 OpenCL) 对这样的任务来说既不够强大又不够灵活。


### 使用 Metal 能带来的好处

Metal 的最大好处就是与 OpenGL ES 相比显著降低了消耗。在 OpenGL 中无论创建缓冲区还是纹理，OpenGL 都会复制一份以防止 GPU 在使用它们的时候被意外访问。出于安全的原因复制类似纹理和缓冲区这样的大的资源是非常耗时的操作。而 Metal 并不复制资源。开发者需要负责在 CPU 和 GPU 之间同步访问。幸运的是，苹果提供了另一个很棒的 API 使资源同步访问更加容易，那就是 Grand Central Dispatch。虽然使用 Metal 时仍然有些这方面的问题需要注意，但是一个在渲染时加载和卸载资源的先进的引擎，在避免额外的复制后能够获得更多的好处。

Metal 的另外一个好处是其预估 GPU 状态来避免多余的验证和编译。通常在 OpenGL 中，你需要依次设置 GPU 的状态，在每个绘制指令 (draw call) 之前需要验证新的状态。最坏的情况是 OpenGL 需要再次重新编译着色器 (shader) 以反映新的状态。当然，这种评估是必要的，但 Metal 选择了另一种方法。在渲染引擎初始化过程中，一组状态被烘焙 (bake) 至预估渲染的 路径 (pass) 中。多个不同资源可以共同使用该渲染路径对象，但其它的状态是恒定的。Metal 中一个渲染路径无需更进一步的验证，使 API 的消耗降到最低，从而大大增加每帧的绘制指令的数量。


## Metal API
-------------

### MTLDevice

一个 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象表示一个 GPU 能够执行的命令，与Metal交互所需的对象都来自于获取的 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) ，该 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice)  协议具有创建新的命令队列的能力，从内存分配缓冲区，创建纹理以及查询设备功能的方法，如果要获取系统上的首选系统设备，可以通过调用该 [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice)  函数获得。

### MTLResource

[MTLResource](https://developer.apple.com/documentation/metal/mtlresource) 用于存储未格式化存储器和格式化图像数据的 Metal 资源对象([MTLResource](https://developer.apple.com/documentation/metal/mtlresource))，有两种类型的 [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) 对象：

- [MLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer)  可以理解为一块连续的内存，它里面存储的数据，是没有格式、类型限制的，即可以存储任意类型的数据，是 GPU 可访问的专用容器，使图形渲染管道能够从中读取顶点数据。在 Metal 中用于存储顶点、着色器和计算状态数据。

- [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 首先从名字上看，站在开发者角度来，Texture 是一个名词，我们通常说的纹理，指的是一张二维的图片，把它像贴纸一样贴在视图上（采样 sample），使得屏幕显示出我们想要的样子，但在物理上，Texture 指的是 GPU 显存中一段连续的空间，用来存放图像数据。

### MTLFunction

一个 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction)  对象表示一个单独的功能，它以 Metal 着色语言编写，并在 GPU 上作为图形或计算流水线的一部分执行。

### MTLLibrary

一个 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 对象表示的一个或多个储存库  [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象。单个 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象表示使用着色语言编写的一个 Metal 函数。在Metal 着色语言源代码，使用一个 Metal 函数限定符任何功能（vertex，fragment，或kernel）可以通过一个代表 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 在一个库中的对象。没有这些函数限定符之一的 Metal 函数不能由 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象直接表示，尽管它可以由着色器中的另一个函数调用。

### MTLCommandQueue & MTLCommandBuffer

MTLCommandQueue 由 Device 创建，是整个 App 绘制的队列，而 Command Buffer 存放每次渲染的指令，即包含了每次渲染所需要的信息，直到指令被提交到 GPU 执行。Command Queue 用于创建和组织 MTLCommandBuffer，其内部存在着多个Command Buffer，并且保证指令（Command Buffer）有序地发送到 GPU。

Command Buffer 是“一次性对象”，不支持重用。一旦 Command Buffer 被提交执行，唯一能做的是等待 Command Buffer 被调度或完成。

- Command Buffers 是从 Command Queue 里创建的
- Command Encoders 将渲染指令 Command 填充到 Command Buffers
- Command Buffers 将数据提交到 GPU
- GPU开始执行，呈现结果

### MTLCommandEncoder

编码器(Command Encoder)，将我们描述的高级指令，编码转换成 GPU 可以理解的低级指令(GPU Commands)，写入 Command Buffer 中。

Protocol | Description |  
------ | -------- | 
MTLRenderCommandEncoder | 用于图形渲染任务的编码器 |  
MTLComputeCommandEncoder | 用于计算任务的编码器 | 
MTLBlitCommandEncoder | 用于内存管理任务的编码器 |  
MTLParallelRenderCommandEncoder | 用于并行编码的多个图形渲染任务的编码器 | 

关于 Buffer，Texture，Command Encoder，Command Queue 之间的关系，其实官方的一张图，理得很清楚，大家可以去看一下官方文档（https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html）；