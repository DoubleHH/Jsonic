# JsonMagic 一个 Json 转 Model 的工具

[掘金文章链接](https://juejin.cn/post/6923848407446454285)

### v1.1.6 Update！
🧨🧨喜大普奔🧨🧨 ：2021-02-06 v1.1.6 发布!

内容：
1. 新增 Json 转 Objective-C 功能；
2. 重构输出部分，使自定义输出更简单；

## 前言

JsonMagic 是 Mac 上用于将 Json 数据转换成类定义代码的应用。转换的代码可以有多种，包括 Swift，Kotlin，Java。另外还支持将 Kotlin Model 转换成 Swift Model。适合客户端，Java 后端工程师，当然如果自定义，只要有 Model 化需求的开发均可使用。

项目由个人使用 Swift 语言编写，已开源。感兴趣的码友们可以 fork 改成适合自己的工具。[代码地址点我](https://github.com/DoubleHH/Jsonic)，里面有 DMG 文件，可以直接下载使用。

文章大纲如下：
1. 应用背景；
2. 应用特点；
3. 使用介绍；
4. 代码框架 & 用户自定义输出；
5. 结语；

## 应用背景

应用最大的初衷是减少软件开发中将 Json 转换为 Model 这个重复性且没多少技术含量的工作时间，提升开发工作效率。程序猿工资在所有行业里不算低，上班时间宝贵。多出的时间咱们可以用来深入学学技术提升自我，亦或是纯粹看NBA、刷B站，心情也是极好的。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/197869fda22148678e361f4de5cdae38~tplv-k3u1fbpfcp-zoom-1.image)

Json model 化目的是使数据易于阅读，便于处理。在应用开发中十分常见，最多的场景是将服务端数据转换为客户端便于使用的Model类。转换内容主要是两个部分，一是将字典节点转化为类，其次将字典内的 key 值转换为类的字段名，而字段的类型就是 key 对应的 value 类型。

这个过程十分机械化，完全可用程序自动转换。在 iOS 平台这方面的工具不多，且大多是命令行工具，对于习惯界面开发的同学来讲不够友好。安卓平台却有不少好用的工具，体验最好的是 Android Studio 插件。在 Android Studio 内便可完成 Json 转 Model 的过程。

为什么还要自己捣鼓新的工具？

![](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn%2F20171026%2Ff5ae-fynhhay5517510.png&refer=http%3A%2F%2Fn.sinaimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614673549&t=05c201f60f1277e9d7e90be5ec429f75)

总结：首先，对于 iOS 来说，没有界面的友好的工具；
其次 iOS 和 Android 两个平台所有的工具对于 Json 数据的整理、容错能力不够好。主要体现在逗号，注释：

1. 逗号。数组内最后一个对象后面的逗号，或者对象内最后一个属性的逗号，目前市面上的工具解析都会报错。
    例如：以下例子无法正常生成
    
    ```Json
    {
    	"name": "zhang san",
    	"address_list ": [
    		{
    			"code": 12345,
    			"receiver_name": "li si",
    			"receiver_address": "北京市海淀区",
    		},
    	],
    	"city_code": "010",
    }
    ```
    
    非法逗号出现的地方：
    1. address_list第一个元素的 },
    2. "receiver_address": "北京市海淀区",
    3. "city_code": "010",

1. 注释。JSON 数据有时候会被加上一些注释便于阅读，目前市面上的工具解析都会报错。
    例如：以下例子无法正常生成
    
    ```Json
    {
    	"name": "zhang san",
    	"address_list ": [
    		{
    		  // 地址编码
    			"code": 12345,
    			"receiver_name": "li si", // 接受者名称
    			"receiver_address": "北京市海淀区" // 接受者地址
    		}
    	],
    	"city_code": "010" // 城市代码
    }
    ```

而 JsonMagic 就是要解决这两个问题。

## 应用特点

JsonMagic 特点总结如下：

1. 常见非法逗号容错；
2. 规范注释容错；
3. iOS & Android 统一化。集成 iOS 和 Android 两个平台的转换工作。支持转 Swift 代码，Kotlin 代码，Java 代码。还支持 Kotlin Model 转换成 Swift Model;
4. 自定义转换能力。代码开源，且将 JSON 抽象化，开发者只需要关心最后的转换部分；
5. Kotlin 可选择的注解。可勾选是否 `SerializedName` or `JsonProperty`;

## 使用介绍

应用启动后，界面如下图：

![16120833275232.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ad0b73d40a234482810b364806e362e0~tplv-k3u1fbpfcp-zoom-1.image)

中间比较大的区域，左边是用户输入的 Json 数据，右边是生成的 Model 数据。

其他操作部分，分为五大块，按照标的数字：

1. 选择需要转换的代码，默认是 Swift。Json to Swift, Json to Kotlin...;
2. 可以指定后缀，默认是 Model；需要填入 Model 的名称，不带后缀的；
3. 点击 Run 就开始生成，生成的代码在 Model大框内。成功与失败的状态会在底部展示；
4. 对结果的操作。比如`Copy Model`拷贝到剪切板。后者是生成文件；
5. 如果想看解析的过程，可以点击Log按钮，会有弹窗；

**成功状态图示：**

![16120775592857.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc68de10d98340dcb7f60308d76262fd~tplv-k3u1fbpfcp-zoom-1.image)

**未填 Model 名称失败状态图示：**

![16120776302050.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ece163e28cb2426a8d138d4c89ab5d69~tplv-k3u1fbpfcp-zoom-1.image)

**有多余注释，逗号但解析成功状态图示：**

![16120777885660.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e708165909d4bd9ba453463dd679bea~tplv-k3u1fbpfcp-zoom-1.image)

## 代码架构 & 自定义 Model 化

Json化的代码主要分为三个过程，如图：

![16120794697003.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d158f24c58474f5c8c2a2d1677803812~tplv-k3u1fbpfcp-zoom-1.image)

* 首先对 Json 进行预处理，检查必要的输入，移除注释等；
* 其次将 Json 转换为自定义的对象，使用 `Jsonic.DataType` 保存；
  
    ```Swift
    internal indirect enum DataType: Equatable {
            static func == (lhs: Jsonic.DataType, rhs: Jsonic.DataType) -> Bool {
                return lhs.swiftDescription == rhs.swiftDescription
            }
            
            case string, int, long, double, bool, unknown
            case array(itemType: DataType)
            case object(name: String, properties: [PropertyDefine])
            ...
    ```
* 最后根据不同的生成类型，生成不同的输出代码；
  
    ```Swift
    public enum OutputType {
        public struct KotlinConfig {
            /// should output SerializedName
            var isSerializedNameEnable: Bool
            /// should output JsonProperty
            var isJsonPropertyEnable: Bool
        }
        
        case swift
        case kotlin(config: KotlinConfig)
        case java
        ...
    ```

### 自定义输出

从整体架构来看，自定义输出只需要关心最后一步 Output。只需要两步：

1. 增加一种 OutputType 类型；
2. 定义 class 与 property 输出；

是不是比把大象放进冰箱简单一些~ 

![16120800880268.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bb1127bfc1c4f8d9118d53c4f8555df~tplv-k3u1fbpfcp-zoom-1.image)

以转 Swift 举例：
第一步，增加 Swift 类型：

```Swift
public enum OutputType {
    ...
    case swift
    case kotlin(config: KotlinConfig)
    case java
    ...
```

第二步，增加自定义 model 转换代码（新增`SwiftOutput`类并继承`Modelable`接口）：

```Swift
class SwiftOutput: Modelable {
    typealias ModelConfig = DefaultModelConfig
    
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: DefaultModelConfig?) -> String {
        var text = "class \(name): Codable {\n"
        for property in properties {
            let typeDescription = dataTypeDescription(type: property.type)
            text += "    var \(property.name): \(typeDescription)?\n"
        }
        text += "}"
        return text
    }
    
    func dataTypeDescription(type: Jsonic.DataType) -> String {
        switch type {
        case .string:
            return "String"
        case .int:
            return "Int"
        case .long:
            return "Int64"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .unknown:
            return "String"
        case .object(let name, _):
            return name
        case .array(let itemType):
            let typeDescription = dataTypeDescription(type: itemType)
            return "Array<" + typeDescription + ">"
        }
    }
}
```


### Modelable 接口

`Modelable` 接口定义了个性化输出需要实现的两个方法：

```
protocol Modelable {
    associatedtype ModelConfig
    func modelDescription(name: String, properties: [Jsonic.PropertyDefine], config: ModelConfig?) -> String
    func dataTypeDescription(type: Jsonic.DataType) -> String
}
```

`modelDescription` 定义如何格式化输出 Model；

`dataTypeDescription` 定义每个基础or高级类型的格式化输出；

`ModelConfig` 是界面里自定义的个性化属性配置，目前只有 Kotlin 转换有；


## 最后

几年前自己也是用的命令行（Python）来转换 Model，最近刚好契机将其界面化，并且使用 Swift 代码进行重写。代码可能会有 bug，大家可多多留言，我会尽快修复。当然各位码友也可以 fork 后自己升级改动，不过还是希望有问题能够反馈，这样能够帮助到更多的同学。Happy Coding~

![](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Ftc.sinaimg.cn%2Fmaxwidth.800%2Ftc.service.weibo.com%2Fmmbiz_qpic_cn%2Ff5a81d7c7d829d94eac1d700f01c3059.jpg&refer=http%3A%2F%2Ftc.sinaimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614675632&t=883cc1f721ab6bd4baf10093ce5f8b2f)