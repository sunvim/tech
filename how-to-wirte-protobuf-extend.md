# 编写protobuf插件扩展

 protobuf提供了描述格式标准，以及对应的格式解析工具及代码生成工具protoc。

由于protobuf支持众多不同编程语言，protoc被设计为插件式的程序，能够调用不同的插件，为.proto文件生成不同语言的执行框架代码。

### go语言的protobuf实现

项目地址：https://github.com/golang/protobuf

目录结构：

```
.
├── jsonpb             json相关
├── proto               proto文件解析库
├── protoc-gen-go      生成go代码的protoc插件实现     
│   ├── descriptor
│   ├── generator
│   │   ├── generator.go
│   ├── internal
│   │   └── grpc
│   │       ├── grpc.go       生成grpc相关代码的protoc插件实现
│   ├── link_grpc.go
│   ├── main.go       main()程序入口
│   ├── plugin
```

这个目录下执行make，会生成命令行程序protoc-gen-go，并且安装到$GOPATH/bin目录。

目前关注的主要是gRPC相关的代码生成功能，所以着重关注protoc-gen-go/{generator, internal}/目录中的两个文件，generator.go和grpc.go。

### generator.go

该文件定义了主要的插件interface：

```go
type Plugin interface {
     Name() string
     Init(gen *Generator)
     Generate(file *FileDescriptor)
     GenerateImports(file *FileDescriptor)
}

type Generator struct{}
```

这个Plugin 接口和Generator结构是自己写代码生成插件是必须的，需要特别关注。

其他的还定义了几个struct:

- type common struct{}
- type Descriptor struct{}
- type EnumDescriptor struct{}
- type ExtensionDescriptor struct{}
- type ImportDescriptor struct{}
- type FileDescriptor struct{}

这个文件实现了许多辅助方法和代码生成框架逻辑，再通过调用实现了Plugin接口的结构实现最终的代码生成。



### grpc.go

这是生成最终.proto文件对应的gRPC代码的代码。

主要功能是：

- 生成.proto文件中message对应的结构体。
- 生成.proto文件中service对应服务端的调用方法封装。
- 生成.proto文件中service对应客户端的调用方法封装。
- 生成.proto文件对应的描述元信息。

需要注意的是，代码中的g有时指的是grpc，有时指的generator，刚开始看的时候还有点小混乱。

其他是一些特别细节的，像参数处理，包名、服务名、方法名的接续组合使用等，需要的时候再详细看看。

重要的方法：

- Generate()
- GenerateImport()
- generateService()
- generateClientMethod()

### 扩展改造

目标：希望能够提供更简洁的客户端调用方式，以及与系统的有机整合。

protoc-gen-go实现非常完善，直接使用也非常方便，可以参考示例。

不过，如果希望能够更自动化地实现公共的规范的服务编写与管理，即使使用现有的生成代码，

也仍旧还需要做许多工作，而且protoc-gen-go生成的代码，只有几个简单的接口，

无法更多地使用protoc-gen-go生成的代码，像服务的元信息等，因为这些代码都是包内私有信息。

另外，protoc-gen-go还是有些功能支持不全面的，比如后面要使用的custom Options功能。

引用，https://groups.google.com/forum/#!topic/golang-nuts/hliqusMm1o4

经过不断实践测试，最后总结出来以下要扩展的部分，

- 允许外部提取server的元数据信息
- 扩展生成调用参数信息字典表
- 扩展生成调用返回值信息字典表
- 扩展生成版本号信息字典表
- 扩展生成更快捷的调用用方法封装。
- 扩展生成支持http协议的服务执行入口。
- 扩展生成支持http协议的客户端调用代码。

目前是在protoc-gen-go代码基础的实现的扩展实现，还可以使用完全自己开发的Plugin实现格式更好的代码生成插件。

其中有些扩展功能还依赖.proto文件的扩展，请参考后续的文档说明。

### .proto文件的扩展

方便在.proto文件中写入更多的元信息数据。

扩展在myoptions.proto文件中，扩展项包括文件层级的，服务层级的，方法层级的。

扩展项示例：

```protobuf
import "myoptions/myoptions.proto";

option (myoptions.PackageVersion) = "1.2.3";
option (myoptions.PackageDesc) = "desccccccccc";

Service Abc {
    option (myoptions.ServiceVersion) = "2.3.4";
    option (myoptions.ServerDesc) = "descccccccc";

     rpc (xxx) Bar returns (xxx) {
             option (myoptions.MethodVersion) = "5.6.7";
             option (myoptions.MethodDesc) = "desccccccccc"
     }
}
```

这些元信息对于实现更完整的服务体系是非常必须的，当然这个自定义选项也是非常灵活的，

在简单情况下，也可以选择不使用。

protobuf扩展源代码：     myoptions.proto

### .proto文件扩展的解析读取

protoc-gen-go现在还不支持custom option的读取与处理，https://groups.google.com/forum/#!topic/golang-nuts/hliqusMm1o4。

其实我需要一个运行时读取的custom option的方法。

好像虽然go包提供了读取filedescriptor的代码，但都是私有属性的代码，无法外部调用，可能需要复制一份出来。或者对其进行大的改造。

protobuf虽然在一定程度上简化了些工作，但要是需求超过这个现有的框架，可以说订制这块非常累人的，能以编程的方式提供的灵活性上非常弱。

在解析这块也是颇费周折，比如，为了获取扩展option的值，算是转了一个大弯。

情况是这样的，

使用了新的.proto文件，以提供扩展options功能。

然而问题是，protoc-gen-go对options的支持很弱，还在//TODO里。这其实还不是问题。

问题是在protoc-gen-go生成代码的时候，需要记录options的值，如果要记录options的值，就要从一些结构中取出。

所以提供了proto.GetExtersion()，可是一看参数，又需要ExtensionDesc的结构，这个结构是在生成完.proto文件才有的，在生成的时候无法取到（有可能有办法取到）。

只好hack了下源代码，直接给Extension结构添加了GetEnc()。为什么是GetEnc()，而不是GetVal()呢，只是因为在protoc-gen-go执行的过程中，它还是没有解析的值，是[]byte类型的。

如果要解析，你还是需要把ExtensionDesc结构传递过来。

最终，在protoc-gen-go中记录的未解析的[]byte值，在运行时再使用对应的ExtensionDesc结构解析吧。

从这个看起来，要想使用protobuf，并脱离protobuf现有的使用方式，会非常费劲的，有可能实现不了。

### 包dorpc/store:

添加两个全局变量，存储服务的元信息。

```go
var ServiceDescs = make([]*grpc.ServiceDesc, 0)
 var ServiceVersions = make(map[string]string, 0)
var MethodInTypes = make(map[string] reflect.Type, 0)
var MethodOutTypes = make(map[string] reflect.Type, 0)
var ServiceOptions = make(map[string]map[int][]byte, 0)

aty := reflect.TypeOf(SomeReq{})
bty := refelct.TypeOf(SomeResp{})

in := reflect.New(store.MethodInTypes[name]).Interface()
out := reflect.New(store.MethodOutTypes[name]).Interface()
```