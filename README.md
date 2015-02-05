# trans-with-pandoc

这是一个实用的Pandoc过滤器，是我为了方便文档翻译工作而开发的小工具。

Pandoc是一个强大的结构化文本处理工具，可以方便的在各种文档格式之间进
行转换。你可以到[pandoc官网](http://johnmacfarlane.net/pandoc/)了解
更多关于它的信息。

过滤器同时依赖于haskell运行环境。

## 使用方法

Pandoc过滤器一般通过在pandoc中指定`--filter`参数来执行。

详细的使用方法请参考pandoc的[使用手册](http://johnmacfarlane.net/pandoc/scripting.html#json-filters)。

本过滤器由haskell脚本`translate.hs`实现。脚本请求一个参数，从标准输
入读入JSON格式的Pandoc文本，输出处理后的JSON格式。参数用来指明要翻译
的语言，过滤器会遍历文本中的CodeBlock对象，将具有`trans`属性且取值和
指定语言相同的代码区块按Markdown语法解析并插入文本；而将`trans`属性
的取值和指定语言不同的代码区块忽略。

由于过滤器请求一个参数，所以不能直接用指定`--filter`参数的方式执行。

你可以通过指定过滤器为本目录下针对特定语言的bash脚本来执行。这会在
bash脚本内部调用`translate.hs`并传递命令行参数。

比如：


    pandoc example.md -t html -o example-en.html --filter trans.en


而脚本`trans.en`中的内容是这样的：


    #!/bin/bash
    
    ./translate.hs en


你当然也可以仿照这样都方式写一个你自己的脚本。

我们还有一种更灵活的方式来调用过滤器，那就是使用管道描述符（`|`）:


    pandoc -f markdown -t json example.md | \
    ./translate.hs en | \
    pandoc -f json -t html -o example-en.html


你也可以直接运行本目录下的Makefile文件，这会将我们的示例文档
`example.md`析出为`en`和`zh`两种语言的html文件。就像这样：


    make

这个Makefile文件非常简单，你很容易看懂并修改它，让它按你期望的方式工
作。

## 关于文档格式

如果你要使用该过滤器来处理你的翻译文档，你的翻译文档应该符合一定的格
式要求，使得过滤器能够正确的工作。

首先，它需要是符合[Pandoc的Markdown语法](http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown)。

其次，你的文档中可能希望有一些公共的部分（比如标题或作者）。这些部分
你只需要用普通方式书写即可。

> 这里的普通方式指的就是普通的符合 Pandoc Markdown 语法的方式，并不
> 是要求一定要用 Plain Text 来书写。

当一段文字你只希望它出现在特定语言版本中时，你需要用CodeBlock将它引
用起来，并加上`trans=<lang>`的属性，其中`<lang>`为某种特定语言。

譬如这样：


    ~~~~~ {trans=zh}
    > 这段文字只会在`zh`的语言版本中出现
    ~~~~~

如果你细心，会发现代码块中可以包含Markdown的语法。因为过滤器可以将这
样定义的代码块中的Markdown语法解析。比如上面的代码块在`zh`版中就会被
解析为一个区块引用。

你可以查看一份我们的示例文件`example.md`以了解更多。
