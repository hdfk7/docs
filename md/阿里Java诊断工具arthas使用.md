# 安装
## 1.下载 

```
wget https://alibaba.github.io/arthas/arthas-boot.jar
```
## 2.用java -jar的方式启动

```
java -jar arthas-boot.jar
```
然后输入数字，选择你想要监听的应用，回车即可

#常用命令



## 1.stack
查看调用栈(运行后需要调用接口一次)

```
stack com.shzc.wzmg.service.IWzSaleChargeRelationService deleteWzSaleChargeRelationById
```
## 2.jad
反译代码(查看是否是最新代码)

```
jad com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl
```

仅反译指定的方法
```
jad com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl selectWzSaleChargeRelationById
```

## 3.sc

搜索类(解决ClassNotFoundException)

| 参数名称 | 参数说明 |
| --- | --- |
| class-pattern | 类名表达式匹配 |
| method-pattern | 方法名表达式匹配 |
| [d] | 	输出当前类的详细信息，包括这个类所加载的原始文件来源、类的声明、加载的ClassLoader等详细信息。如果一个类被多个ClassLoader所加载，则会出现多次 |


`sc [-d] *部分类名*`
`sc *WzSaleChargeRelation*`
查看类中的方法

```
sm com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl
sm com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl selectWzSaleChargeRelationById
```

##  4.watch
监测一个方法的入参和返回值
| 参数名称 | 参数说明 |
| --- | --- |
|class-pattern|	类名表达式匹配|
|method-pattern|	方法名表达式匹配|
|express|	观察表达式|
|condition-express|	条件表达式|
|[b]|	在方法调用之前观察|
||[e]|	在方法异常之后观察|
|[s]|	在方法返回之后观察|
|[f]|	在方法结束之后(正常返回和异常返回)观察，默认选项|
|[E]|	开启正则表达式匹配，默认为通配符匹配|
|[x:]|	指定输出结果的属性遍历深度，默认为 1|



```
watch com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl selectWzSaleChargeRelationList "{params,returnObj}" -x 2
```

## 5.trace
查看方法内部调用路径和耗时
| 参数名称 | 参数说明 |
| --- | --- |
|class-pattern|	类名表达式匹配|
|method-pattern|	方法名表达式匹配|
|condition-express|	条件表达式|
[E]	开启正则表达式匹配，默认为通配符匹配|
|[n:]|	命令执行次数|
|#cost|	方法执行耗时|


```
trace com.shzc.wzmg.service.impl.WzSaleChargeRelationServiceImpl selectWzSaleChargeRelationList
```




## 6.jobs
执行后台异步任务
线上有些问题是偶然发生的，这时就需要使用异步任务，把信息写入文件。
linux使用 & 指定命令去后台运行，使用 > 将结果重写到日志文件，以trace为例

```
trace -j cn.test.mobile.controller.order.OrderController getOrderInfo > test.out &
```
列出所有job

```
jobs
```
异步执行时间，默认为1天，如果要修改，使用options命令:
options可选参数 1d, 2h, 3m, 25s，分别代表天、小时、分、秒
```
options job-timeout 2d
```
kill——强制终止任务

```
kill 76
kill job 76 success
```

# 7.logger
查看logger信息，更新logger level

```
logger
 name                ROOT
 class               ch.qos.logback.classic.Logger
 classLoader         sun.misc.Launcher$AppClassLoader@18b4aac2
 classLoaderHash     14dad5dc #改日志级别时要用到它
 level               INFO
 effectiveLevel      INFO
```

更新日志级别

```
logger --name ROOT --level debug
或
logger -c 14dad5dc --name ROOT --level debug
```
## 8.dashboard
查看当前系统的实时数据面板 这个命令可以全局的查看jvm运行状态，比如内存和cpu占用情况

```
ID NAME                GROUP     PRIORI STATE %CPU   DELTA TIME   INTER DAEMON
36 File Watcher        main      5      RUNNA 12.48  0.624 13:29. false true
-1 C2 CompilerThread1  -         -1     -     0.31   0.015 1:5.03 false true
2  Reference Handler   system    10     WAITI 0.0    0.000 0:0.04 false true
3  Finalizer           system    8      WAITI 0.0    0.000 0:0.10 false true
4  Signal Dispatcher   system    9      RUNNA 0.0    0.000 0:0.00 false true
5  Attach Listener     system    5      RUNNA 0.0    0.000 0:0.01 false true
77 arthas-timer        system    5      WAITI 0.0    0.000 0:0.00 false true
80 arthas-NettyHttpTel system    5      RUNNA 0.0    0.000 0:0.06 false true
81 arthas-NettyWebsock system    5      RUNNA 0.0    0.000 0:0.00 false true
82 arthas-NettyWebsock system    5      RUNNA 0.0    0.000 0:0.00 false true
83 arthas-shell-server system    5      TIMED 0.0    0.000 0:0.01 false true
Memory           used  total max  usage GC
heap             326M  788M                                 40
ps_eden_space    219M  497M  621M       gc.ps_scavenge.time 2099
                 5M    25M   25M        (ms)
ps_old_gen       102M  266M       7.60% gc.ps_marksweep.cou 4
nonheap          155M  160M  -1         nt
code_cache       42M   42M   240M       gc.ps_marksweep.tim 1841
metaspace        101M  105M  -1         e(ms)
Runtime
os.name                                 Windows 7
os.version                              6.1
java.version                            1.8.0_40
```
ID: Java级别的线程ID，注意这个ID不能跟jstack中的nativeID一一对应 我们可以通过 thread id 查看线程的堆栈 信息

```
thread 2

"Reference Handler" Id=2 WAITING on java.lang.ref.Reference$Lock@6097faf9
    at java.lang.Object.wait(Native Method)
    -  waiting on java.lang.ref.Reference$Lock@6097faf9
    at java.lang.Object.wait(Object.java:502)
    at java.lang.ref.Reference$ReferenceHandler.run(Reference.java:157)
```

## 9.redefine
redefine jvm已加载的类 ，可以在不重启项目的情况下,热更新类
这个功能真的很强大，但是命令不一定会成功
假设我想修改OrderController里的某几行代码，然后热更新至jvm：

a. 反编译OrderController，默认情况下，反编译结果里会带有ClassLoader信息，通过--source-only选项，可以只打印源代码。方便和mc/redefine命令结合使用


```
jad --source-only cn.test.mobile.controller.order.OrderController > OrderController.java
```

生成的OrderController.java在哪呢，执行pwd就知道在哪个目录了

b. 查找加载OrderController的ClassLoader


```
sc -d cn.test.mobile.controller.order.OrderController | grep classLoaderHash
classLoaderHash   18b4aac2
```

c. 修改保存好OrderController.java之后，使用mc(Memory Compiler)命令来编译成字节码，并且通过-c参数指定ClassLoader


```
mc -c 18b4aac2 OrderController.java -d ./
```

d. 热更新刚才修改后的代码


```
redefine -c 18b4aac2 OrderController.class
redefine success, size: 1
```

然后代码就更新成功了。


