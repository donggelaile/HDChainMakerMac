
# HDChainMakerMac
## 这是什么？
HDChainMakerMac是一个跑在Mac上的程序，它是一个可以快速的对你现有的Objective-C类增加链式调用初始化的工具。
## 怎么用？
下载代码,运行 -> 将任意一个Objective-C的.h全选并复制 -> 粘贴到编辑框内 -> 点击开始 -> 自动生成该类的链式初始化类别。
## 示例
比如现在你复制了UILabel.h的所有代码，你可以原封不动的复制到编辑框来生成类别，也可以自己编辑后再生成。在编辑.h文件过程中，你可以删除一些不想要的属性，也可以从UIView(父类)中复制并添加一些想要增加的链式属性。比如像下面这样的经过自己精简的一个h文件。
```
@interface UILabel : UIView <NSCoding, UIContentSizeCategoryAdjusting>

@property(nullable, nonatomic,copy)   NSString           *text;            
@property(null_resettable, nonatomic,strong) UIFont      *font;            
@property(null_resettable, nonatomic,strong) UIColor     *textColor;       
@property(nullable, nonatomic,strong) UIColor            *shadowColor;  
@property(nonatomic)        CGSize             shadowOffset;    
@property(nonatomic)        NSTextAlignment    textAlignment;   
@property(nonatomic)        NSLineBreakMode    lineBreakMode;  
@property(nullable, nonatomic,copy)   NSAttributedString *attributedText NS_AVAILABLE_IOS(6_0);
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;
@property(nonatomic) UIBaselineAdjustment baselineAdjustment;

@property(nonatomic) CGRect            frame;
@property(nullable, nonatomic,copy)            UIColor          *backgroundColor UI_APPEARANCE_SELECTOR;

@end
```
其中frame，backgroundColor属性是从父类中抽取出来的，这个可以根据你个人的需要来添加或删除。
#### 对于readonly属性
1. 提供一个是否生成readonly属性链式构造的选择框，默认为NO
2. 对于系统的类不建议开启readonly的支持，因为对系统类的readonly属性赋值可能出现未知结果
3. 可能自己原本的类有几个readonly属性，然后提供了一个初始化方法向外暴露接口来构造对象。这种情况你可能需要开启对readonly属性的支持，此时内部会使用kvc对原对象的readonly属性赋值(需要确保原类 +(BOOL)accessInstanceVariablesDirectly 返回的是YES，未实现默认YES)


### 下面是具体的生成过程演示：
![](https://github.com/donggelaile/HDChainMakerMac/blob/master/ScreenShot/generateDemo.gif?raw=true)
### 以及如何使用生成的类别:
![](https://github.com/donggelaile/HDChainMakerMac/blob/master/ScreenShot/useDemo.gif?raw=true)

如果对您有帮助，还望给个✨✨

## LICENSE
MIT