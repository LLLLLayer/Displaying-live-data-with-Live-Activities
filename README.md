# 实时活动(Live Activity) - 在锁定屏幕和灵动岛上显示应用程序的实时数据

> 本文参考、翻译并实现 [Apple‘s documentation activitykit displaying live data with live activities](https://developer.apple.com/news/?id=ttuz9vwq) 内容，文章涉及的项目代码可以从[这里](https://github.com/LLLLLayer/Displaying-live-data-with-Live-Activities)获取。

## 概述

**实时活动(Live Activity)** 在 iPhone 锁定屏幕和灵动岛中显示 App 的实时数据，能帮助用户跟踪 App 的内容。

要提供 Live Activity，开发者需要将代码添加到新的或现有的小组件中。Live Activity 使用了 [WidgetKit](https://developer.apple.com/documentation/WidgetKit) 的功能，并使用 [SwiftUI](https://developer.apple.com/documentation/SwiftUI) 编写界面。而 [ActivityKit](https://developer.apple.com/documentation/activitykit) 的作用是处理 Live Activity 的<span data-word-id="36379614" class="abbreviate-word">生命周期</span>：开发者使用它的 API 来进行请求、更新和结束实时活动。

> 实时活动功能和 ActivityKit 将包含在今年晚些时候推出的 iOS 16.1 中。


## 实时活动要求或限制
时活动还会一直保留在锁定屏幕上，直到用户主动将其移除，或交由系统在四小时后将其移除。**即实时活动会灵动上岛最多保留八小时，在锁定屏幕上最多保留十二小时**。

- **更新**

每个实时活动运行在自己的沙盒中，与小组件不同的是，它**无法访问网络**或接**收位置更新**。开发者若要更新实时活动的动态数据，请在 App 中使用 ActivityKit 框架或允许实时活动接收远程推送通知。但需要注意，ActivityKit 更新和远程推送通知更新的更新动态数据大小**不能超过 4KB**。

- **样式**

实时活动针对锁定屏幕和灵动岛提供了不同的视图。锁定屏幕可以出现在所有支持 iOS 16 的设备上。而灵动岛在支持设备上，使用以下视图显示实时活动：紧凑前视图、紧凑尾视图、最小视图和扩展视图。

当用户触摸灵动岛，且灵动岛中有紧凑或最小视图，同时实时活动更新时，会出现扩展视图。在不支持灵动岛的设备上，扩展视图显示为实时活动更新的横幅。

为确保系统可以在每个位置显示 App 的实时活动，开发者必须**支持所有视图**。

## 为 App 添加对实时活动的支持

描述实时活动界面的代码是 App 的小组件的一部分。如果开发者已经在 App 中提供小组件，则可以将实时活动的界面代码添加到现有的小组件中，并且可以在小组件和实时活动之间重用部分代码。但尽管实时活动利用了 WidgetKit 的功能，但它们**并不是小组件**。与更新小组件界面的 timeline 机制相比，开发者只能使用 ActivityKit 或远程推送通知来更新实时活动。

> 开发者也可以创建一个小组件来实现实时活动，而无需提供小部件。但请尽可能考虑同时提供小组件和实时活动，以满足用户的需求。

本文将参考 Apple 的开发文档，实现实时活动。

### 创建项目并为 App 添加对实时活动的支持

创建项目 `LiveActivities` 并为项目添加新 Target，选择 `Widget Extension`:

| ![image-20220916214530113.png](http://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74e30b724b4640deb737cd6ffdd8aaa6~tplv-k3u1fbpfcp-watermark.image?) | ![image-20220916215239411.png](http://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bea78ba27cef4de5b822e7ceedb1ea31~tplv-k3u1fbpfcp-watermark.image?) | ![image-20220916215036844.png](http://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f4b7c5c2630b4e549e53b8761d1c98fd~tplv-k3u1fbpfcp-watermark.image?) |
| :----------------------------------------------------------: | ------------------------------------------------------------ | ------------------------------------------------------------ |

可以将其命名 `LiveActivitiesWidget`，暂时不需要勾选 `Include Configuration Intent`，单击 Finsih 并同意 Activate scheme 对话框：




| ![image-20220916215416018.png](http://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/600b0dfda87a49bc86884fb68fb274a4~tplv-k3u1fbpfcp-watermark.image?) | ![image-20220916215448651.png](http://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0725bbdc74b43bcb9695f5fc583afa5~tplv-k3u1fbpfcp-watermark.image?) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |

在 `info.plist` 添加 `NSSupportsLiveActivities ` key，并设置为`YES`：

![image-20220916220349762.png](http://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4f5457a8eb304a8aa8fb8e3ed0e5eff7~tplv-k3u1fbpfcp-watermark.image?)

### 定义实时活动的静态和动态数据

在为 App 的实时活动创建配置对象之前，首先通过实现 [`ActivityAttributes`](https://developer.apple.com/documentation/activitykit/activityattributes) (描述实时活动的内容的协议)来描述实时活动将展示的数据。它的声明如下：

```swift
public protocol ActivityAttributes : Decodable, Encodable {

    /// The associated type that describes the dynamic content of a Live Activity.
    ///
    /// The dynamic data of a Live Activity that's encoded by `ContentState` can't exceed 4KB.
    associatedtype ContentState : Decodable, Encodable, Hashable
}
```

除了包括实时活动中出现的静态数据，开发者还可以使用 `ActivityAttributes` 来声明所需的自定义 `Activity.ContentState` 类型，该类型描述 App 的实时活动的动态数据。

我们将以一个披萨外卖行程为例，新建一个 `PizzaDeliveryAttributes.swift` 文件并添加以下内容：

```swift
import Foundation
import ActivityKit

struct PizzaDeliveryAttributes: ActivityAttributes {
    public typealias PizzaDeliveryStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var driverName: String
        var deliveryTimer: ClosedRange<Date>
    }

    var numberOfPizzas: Int
    var totalAmount: String
    var orderNumber: String
}
```

在上面的示例中，`PizzaDeliveryAttributes` 描述了以下静态数据：订购的比萨饼数量、客户需要支付的金额以及订单号。

注意代码是如何定义 `Activity.ContentState `来封装动态数据的：送披萨的司机的名字和预计送达时间。

此外，该示例定义了类型别名 `PizzaDeliveryStatus` 以使代码更具描述性和易于阅读。

### 创建实时活动配置

接着，我们需要添加代码，在小组件的实现中返回 `ActivityConfiguration`。以下使用上一个示例中的 `PizzaDeliveryAttributes` 结构来配置我们的事实活动：

```swift
import SwiftUI
import WidgetKit

@main
struct LiveActivitiesWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PizzaDeliveryAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            // ...
        }
    }
}
```

假如我们的 App 已经提供了小组件，请将实时活动添加到 `WidgetBundle` 里。 如果没有 `WidgetBundle`，例如 App 当前只提供一个小组件，请按照[创建 Widget Extension](https://developer.apple.com/documentation/WidgetKit/Creating-a-Widget-Extension) 中的描述创建一个 `WidgetBundle`，然后将实时活动添加到其中，例如：

```swift
@main
struct LiveActivitiesWidgets: WidgetBundle {
    var body: some Widget {
        FavoritePizzaWidget()

        if #available(iOS 16.1, *) {
            PizzaDeliveryLiveActivity()
        }
    }
}
```

### 创建锁定屏幕视图

要创建实时活动的界面，我们可以在之前创建的 Widget Extension 中使用 SwiftUI。与小组件类似，我们无需为实时活动提供界面的大小，而是**让系统确定适当的尺寸**。

新建文件 `LockScreenLiveActivityView.swift`，并添加以下代码，使用 SwiftUI 视图描述`PizzaDeliveryAttributes` 的信息：

```swift
import WidgetKit
import SwiftUI

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PizzaDeliveryAttributes>
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(context.state.driverName) is on their way with your pizza!")
            Spacer()
            HStack {
                Spacer()
                Label {
                    Text("\(context.attributes.numberOfPizzas) Pizzas")
                } icon: {
                    Image(systemName: "bag")
                        .foregroundColor(.indigo)
                }
                .font(.title2)
                Spacer()
                Label {
                    Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .monospacedDigit()
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.indigo)
                }
                .font(.title2)
                Spacer()
            }
            Spacer()
        }
        .activitySystemActionForegroundColor(.indigo)
        .activityBackgroundTint(.cyan)
    }
}
```

> 这里需要注意，如果其高度超过 160，系统可能会截断锁定屏幕上的实时活动。

### 创建紧凑和最小的视图

在支持实时活动的设备的灵动岛上，当 App 开始一个实时活动并且它是唯一一个活跃的实时活动时，紧凑前视图和尾视图一起出现，在灵动岛中形成一个有凝聚力的视图。当多个实时活动处于活动状态时(无论是来自我们的 App 还是来自多个 App)，系统会选择哪些实时活动可见，并显示两个最小视图：一个最小视图显示附加到灵动岛，而另一个显示为分离的样式。

默认情况下，灵动岛中的紧凑视图和最小视图使用黑色背景颜色和白色文本。 使用 [keylineTint(_:)](https://developer.apple.com/documentation/WidgetKit/DynamicIsland/keylineTint(_:)) 修改器将可选的色调应用到灵动岛，例如青色，稍后我们会看到。

以下示例展示了披萨外卖应用程序如何使用 SwiftUI 视图提供所需的紧凑和最小视图：

```swift
@main
struct LiveActivitiesWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PizzaDeliveryAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded view.
                // ...
                
            } compactLeading: {
                Label {
                    Text("\(context.attributes.numberOfPizzas) Pizzas")
                } icon: {
                    Image(systemName: "bag")
                        .foregroundColor(.indigo)
                }
                .font(.caption2)
            } compactTrailing: {
                Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                    .multilineTextAlignment(.center)
                    .frame(width: 40)
                    .font(.caption2)
            } minimal: {
                VStack(alignment: .center) {
                    Image(systemName: "timer")
                    Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.caption2)
                }
            }
            .keylineTint(.cyan)
        }
    }
}
```

### 创建扩展视图

除了紧凑和最小视图之外，我们还必须支持扩展视图。当用户触摸并持有一个紧凑或最小的视图时，扩展视图会出现，并且也会短显示实时活动更新。当我们更新实时活动时，没有灵动岛的设备也会将扩展视图显示为横幅。 使用 [`DynamicIslandExpandedRegionPosition`](https://developer.apple.com/documentation/WidgetKit/DynamicIslandExpandedRegionPosition) 指定我们希望的灵动岛扩展区域位置。以下示例显示了披萨外卖应用程序如何创建其扩展视图：

```swift
@main
struct PizzaDeliveryWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PizzaDeliveryAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded view.
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.attributes.numberOfPizzas) Pizzas", systemImage: "bag")
                        .foregroundColor(.indigo)
                        .font(.title2)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text(timerInterval: context.state.deliveryTimer, countsDown: true)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(.indigo)
                    }
                    .font(.title2)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.driverName) is on their way!")
                        .lineLimit(1)
                        .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Button {
                        // Deep link into your app.
                    } label: {
                        Label("Call driver", systemImage: "phone")
                    }
                    .foregroundColor(.indigo)
                }
            } compactLeading: {
                // Create the compact leading view.
                // ...
            } compactTrailing: {
                // Create the compact trailing view.
                // ...
            } minimal: {
                // Create the minimal view.
                // ...
            }
            .keylineTint(.yellow)
        }
    }
}
```

> 这里也需要注意，如果灵动岛的高度超过 160，系统可能会截断灵动岛中的实时活动。

为了呈现展开的实时活动中出现的视图，系统将展开的视图划分为不同的区域。请注意上述示例如何返回一个指定多个 `DynamicIslandExpandedRegion` 对象的灵动岛。传递以下 `DynamicIslandExpandedRegionPosition` 值以在展开视图中的指定位置布置内容：

- **center** 将内容置于 TrueDepth 摄像头下方。

- **leading** 将内容沿展开的实时活动的前沿放置在 TrueDepth 摄像头旁边，并在其下方包裹其他内容。

- **trailing** 将内容沿展开的实时活动的后缘放置在 TrueDepth 摄像头旁边，并在其下方包裹其他内容。

- **bottom** 将内容置于 leading、trailing 和 center 之下。


![image-20220917033045844.png](http://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/706baa22c19440b2a1145a86511d3080~tplv-k3u1fbpfcp-watermark.image?)

为了呈现展开的实时活动中出现的内容，系统首先确定 center 内容的宽度，同时考虑 leading 和 trailing 内容的最小宽度。 然后系统根据其垂直位置放置 leading 和 trailing 内容并确定其大小。默认情况下， leading 和 trailing 接相等水平空间。

![image-20220917033103851.png](http://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/515cfa954d724262850237299c8c7a5c~tplv-k3u1fbpfcp-watermark.image?)

我们可以通过将优先级传递给 [`init(_:priority:content:)`](https://developer.apple.com/documentation/WidgetKit/DynamicIslandExpandedRegion/init(_:priority:content:)) 初始化程序来告诉系统优先考虑 `DynamicIslandExpandedRegion` 视图之一。 系统以灵动岛的全宽呈现具有最高优先级的视图。

> 如果内容太宽而无法出现在 TrueDepth 相机旁边的 leading 位置，请使用 [belowIfTooWide](https://developer.apple.com/documentation/WidgetKit/DynamicIslandExpandedRegionVerticalPlacement/belowIfTooWide) 修饰符来渲染 TrueDepth 相机下方的 leading 内容。

### 使用自定义颜色

默认情况下，系统使用默认的文本色和最适合用户锁定屏幕的实时活动的背景颜色。如果要设置自定义色调颜色，请使用 [`activityBackgroundTint(_:)`](https://developer.apple.com/documentation/SwiftUI/View/activityBackgroundTint(_:)) 视图修饰符。此外，使用 [`activitySystemActionForegroundColor(_:)`](https://developer.apple.com/documentation/SwiftUI/View/activitySystemActionForegroundColor(_:)) 视图修饰符来定义系统在锁定屏幕上实时活动旁边显示的辅助操作按钮的文本颜色。

要设置自定义的半透明背景色，请使用 [`opacity(_:)`](https://developer.apple.com/documentation/SwiftUI/Color/opacity(_:)) 视图修饰符或指定一个不透明背景颜色。

> 在 Always-On Retina 显示屏的设备上，系统会调暗屏幕以延长电池寿命，并在锁定屏幕上呈现实时活动，就像在暗模式下一样。 使用 SwiftUI 的 `isLuminanceReduced` 环境值来检测 Always On 并使用在 Always On 中看起来很棒的图像。

### 确保实时活动可用

实时活动仅在 iPhone 上可用。如果我们的 App 可在多个平台上使用并提供小组件，请确保实时活动在运行时可用。此外，用户可以在“设置”应用中选择停用应用的实时活动。

要查看实时活动是否可用以及用户是否允许我们的 App 使用实时活动：

- 使用 [`areActivitiesEnabled`](https://developer.apple.com/documentation/activitykit/activityauthorizationinfo/areactivitiesenabled) 同步的确定 App 是否可以启动实时活动；

- 通过使用 [`activityEnablementUpdates`](https://developer.apple.com/documentation/activitykit/activityauthorizationinfo/activityenablementupdates-swift.property) 异步序列观察应用是否可以启动实时活动。

> 一个应用可以启动多个实时活动，而一个设备可以运行多个 App 的实时活动。除了确保实时活动可用之外，在开始、更新或结束实时活动时请注意处理可能出现的错误。例如，启动实时活动可能会失败，因为用户的设备可能已达到其运行实时活动的限制。

### 开始实时活动

当应用程序在前台时，我们可以在应用程序代码中使用 [`request(attributes:contentState:pushType:)`](https://developer.apple.com/documentation/activitykit/activity/request(attributes:contentstate:pushtype:)) 函数启动实时活动。它将开发者创建的 `attributes` 和 `contentState` 作为参数来提供显示在实时活动中的初始值，并告诉系统哪些数据是动态的。如果我们使用远程推送通知来更新实时活动，还需要提供 `pushType` 参数。

更新 LiveActivities 中的 `ContentView.swift` 以下代码示例从前面的示例中为披萨外卖启动了一个新的实时活动：

```swift
import SwiftUI
import ActivityKit

struct ContentView: View {
    let minutes = 12
    @State var deliveryActivity: Activity<PizzaDeliveryAttributes>? = nil
    var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .onAppear {
            if #available(iOS 16.1, *) {
                let future = Calendar.current.date(byAdding: .minute, value: (minutes), to: Date())!
                let date = Date.now...future
                let initialContentState = PizzaDeliveryAttributes.ContentState(driverName: "Layer", deliveryTimer:date)
                let activityAttributes = PizzaDeliveryAttributes(numberOfPizzas: 3, totalAmount: "$66.66", orderNumber: "12345")
                do {
                    deliveryActivity = try Activity.request(attributes: activityAttributes, contentState: initialContentState)
                    print("Requested a pizza delivery Live Activity \(String(describing: deliveryActivity?.id ?? "nil")).")
                } catch (let error) {
                    print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                }
            }
        }
    }
}
```

请注意上面的代码片段不传递 `pushType` 参数，在不使用远程推送通知的情况下更新其内容。它还将返回的`deliveryActivity` 存储，可用于更新和结束实时活动。有关使用远程推送通知更新您的实时活动的更多信息，请参阅 [Updating and ending your Live Activity with remote push notifications](https://developer.apple.com/documentation/activitykit/update-and-end-your-live-activity-with-remote-push-notifications)。

> 我们只能在应用程序处于前台时从 App 启动实时活动。 但是我们可以在 App 在后台运行时更新或结束实时活动，例如通过使用后台任务。


![iShot_2022-09-17_15.27.00.gif](http://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/23155131b5134d988b9a963b425b54c2~tplv-k3u1fbpfcp-watermark.image?)

启动多个实时活动：

![iShot_2022-09-17_15.29.08.gif](http://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ab1e7e22d565458ea4c99a416f1cb370~tplv-k3u1fbpfcp-watermark.image?)

### 更新实时活动

当我们从 App 启动实时活动时，使用启动实时活动时收到的 Activity 对象的 [`update(using:)`](https://developer.apple.com/documentation/activitykit/activity/update(using:)) 函数更新显示在实时活动中的数据。要检索 App 当前活动的实时活动，请使用 [activities](https://developer.apple.com/documentation/activitykit/activity/activities)。

例如，披萨配送可以更新显示配送状态的实时活动，其中包含新的配送时间和新的司机。它还可以使用 [`update(using:alertConfiguration:)`](https://developer.apple.com/documentation/activitykit/activity/update(using:alertconfiguration:)) 函数在 iPhone 和 Apple Watch 上显示提示，告诉用户新的实时活动内容，在 `Button("Order pizza!"){}` 后添加以下代码：

```swift
Button("Update!") {
    if #available(iOS 16.1, *) {
        let future = Calendar.current.date(byAdding: .minute, value: (Int(minutes / 2)), to: Date())!
        let date = Date.now...future
        let updatedDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Layer's brother", deliveryTimer: date)
        let alertConfiguration = AlertConfiguration(title: "Delivery Update", body: "Your pizza order will immediate delivery.", sound: .default)
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await deliveryActivity?.update(using: updatedDeliveryStatus, alertConfiguration: alertConfiguration)
        }
    }
}
```

在点击“Update!”的 5 秒后，配送员和时间都发生了改变，同时有录屏无法很好表现的提醒效果：


![iShot_2022-09-17_15.43.29.gif](http://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a8f32ac0961483abe028dc72e254efc~tplv-k3u1fbpfcp-watermark.image?)

> 在 Apple Watch 上，系统使用提醒的标题和正文。在 iPhone 上，系统不会显示常规提醒，而是显示灵动岛中展开的实时活动。 在不支持灵动岛的设备上，系统会在主屏幕上显示一个横幅，该横幅使用 App 的实时活动的扩展视图。

### 带有动画的内容更新

当我们定义实时活动的界面时，系统会忽略任何动画修饰符——例如，`withAnimation(_:_:)` 和 `animation(_:value:)`——并改用系统的动画时间。但当实时活动的动态内容发生变化时，系统会执行一些动画。

- 文本视图通过模糊的内容过渡动画展示内容变化，并且系统为图像和 SF Symbols 做动画的内容过渡。

- 如果开发者根据内容或状态更改用户界面，进行添加或删除视图，视图会淡入淡出。

- 可以使用以下视图转换来配置这些内置转换：[`opacity`](https://developer.apple.com/documentation/SwiftUI/AnyTransition/opacity ) 、[`move(edge:)`](https://developer.apple.com/documentation/SwiftUI/AnyTransition/move(edge:))、 [`slide`](https://developer.apple.com/documentation/SwiftUI/AnyTransition/slide)、[`push(from:)`](https://developer.apple.com/documentation/SwiftUI/AnyTransition/push(from:))

- 使用 [`numericText(countsDown:) `](https://developer.apple.com/documentation/SwiftUI/ContentTransition/numericText(countsDown:)) 实现计时效果的文本。

> 在配备 Always On Retina 显示屏的设备上，为例保持 Always On 时的电量，系统不会执行动画。可以在动画内容更改之前使用 SwiftUI 的 `isLuminanceReduced` 环境值来检测是否开启 Always On。

### 在 App 中结束实时活动

始终在关联的任务或实时事件结束后，结束实时活动的展示。已结束的实时活动将保留在锁定屏幕上，直到用户将其删除或系统自动将其删除。自动删除取决于开发者提供给 [`end(using:dismissalPolicy:) `](https://developer.apple.com/documentation/activitykit/activity/end(using:dismissalpolicy:)) 函数的解除策略。

此外，始终包含更新的 `Activity.ContentState` 以确保实时活动在结束后显示最新和最终的内容。这很重要，因为实时活动可能还会在锁定屏幕上保持一段时间的可见。

继续在 `Button("Update!") {}` 后添加代码：

```swift
Button("I do not want it!!") {
    if #available(iOS 16.1, *) {
        let finalDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "Anne Johnson", deliveryTimer: Date.now...Date())
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await deliveryActivity?.end(using:finalDeliveryStatus, dismissalPolicy: .default)
        }
    }
}
```

上面的示例使用默认解除策略。因此，实时活动结束后会在锁定屏幕上显示一段时间，以便用户浏览手机以查看最新信息。用户可以随时选择移除实时活动，或者系统在活动结束四小时后自动移除。要立即删除锁定屏幕的结束实时活动，请使用 [`.immediate`](https://developer.apple.com/documentation/activitykit/activityuidismissalpolicy/immediate)。或者，使用[ `after(_:)` ](https://developer.apple.com/documentation/activitykit/activityuidismissalpolicy/after(_:))指定四小时内的日期。

用户可以随时从锁定屏幕中删除 App 的实时活动。这只会结束 App 的实时活动的展示，但不会结束或取消用户启动实时活动的操作。例如用户可以从锁定屏幕中删除他们的披萨外卖的实时活动，但这不会取消披萨订单。

当用户或系统移除实时活动时，`ActivityState` 更改为 [`ActivityState.dismissed`](https://developer.apple.com/documentation/activitykit/activitystate/dismissed)。

### 使用远程推送通知更新或结束实时活动

除了使用 ActivityKit 从 App 更新和结束实时活动之外，我们还可以使用从服务器发送到 Apple 推送通知服务 (APN) 的远程推送通知更新或结束实时活动。 要了解有关使用远程推送通知更新实时活动的更多信息，请参阅 [Updating and ending your Live Activity with remote push notifications](https://developer.apple.com/documentation/activitykit/update-and-end-your-live-activity-with-remote-push-notifications)。

### 跟踪更新

像上面的例子，当我们启动实时活动时，ActivityKit 返回一个 Activity 对象。 除了唯一标识每个实时活动的 id 之外，还提供序列来观察内容状态、活动状态和 Push token 的更新。使用相应的序列在 App 中接收更新，使 App 和 实时活动保持同步：

- 要观实时活动的状态，例如确定它是处于活动状态还是已经结束，使用  [`activityStateUpdates`](https://developer.apple.com/documentation/activitykit/activity/activitystateupdates-swift.property)。

- 要观察实时活动内容的变化，使用 [`contentState`](https://developer.apple.com/documentation/activitykit/activity/contentstate-swift.property)。

- 要观察实时活动的 Push token 的变化，使用 [`pushTokenUpdates`](https://developer.apple.com/documentation/activitykit/activity/pushtokenupdates-swift.property)。


### 获取实时活动列表

一个 App 可以启动多个实时活动。例如，体育应用程序可能允许用户为他们感兴趣的每个现场体育比赛启动一个 实时活动。如果 App 启动多个实时活动，请使用 [`activityUpdates`](https://developer.apple.com/documentation/activitykit/activity/activityupdates-swift.type.property) 函数获取有关 App 正在进行的活动的通知。跟踪正在进行的实时活动以确保 App 的数据与 ActivityKit 跟踪的正在运行的实时活动同步。

以下代码段显示了披萨外卖如何检索正在进行的活动列表：

```swift
// Fetch all ongoing pizza delivery Live Activities.
for await activity in Activity<PizzaDeliveryAttributes>.activityUpdates {
    print("Pizza delivery details: \(activity.attributes)")
}
```


获取所有活跃的实时活动列表的另一个方案是开发者手动维护正在进行的实时活动数据，并确保开发者不会让任何活动运行超过需要的时间。例如系统可能会停止我们的 App，或者我们的 App 可能会在实时活动处于活跃状态时崩溃。当应用下次启动时，检查是否有任何实时活动仍然处于活跃状态，更新存储的实时活动列表数据，并结束任何不再相关的实时活动。
