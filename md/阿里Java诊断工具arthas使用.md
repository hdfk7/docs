# Arthas 使用笔记

记录 Java 应用诊断时常用的命令。下面的 `com.example.OrderService`、`getOrder` 和 ClassLoader 哈希均为示例，需替换成目标应用的实际值。

## 启动

从 [Arthas 官方下载页](https://arthas.aliyun.com/doc/download.html) 获取 `arthas-boot.jar`，在目标机器启动：

```bash
java -jar arthas-boot.jar
```

选择目标 Java 进程。观察命令启动后，通常还需要触发一次对应请求才能看到结果。

## 查找类与方法

```text
sc -d com.example.OrderService
sm com.example.OrderService
sm com.example.OrderService getOrder
```

`sc -d` 可查看类来源和 ClassLoader 信息；`sm` 查看方法。类名不确定时可用通配符搜索，如 `sc '*OrderService*'`。

## stack：查看调用栈

```text
stack com.example.OrderService getOrder -n 5
```

用于确认方法由哪条调用路径触发，`-n` 限制输出次数。

## jad：反编译已加载代码

```text
jad com.example.OrderService
jad com.example.OrderService getOrder
```

适合核对运行中的代码。若同名类存在于多个 ClassLoader 中，需要结合 `sc -d` 的结果定位。

## watch：观察参数与返回值

```text
watch com.example.OrderService getOrder '{params,returnObj,throwExp}' -x 2 -n 5
```

| 参数 | 用途 |
| --- | --- |
| `-b` | 方法执行前观察 |
| `-s` | 正常返回后观察 |
| `-e` | 抛出异常后观察 |
| `-f` | 方法结束后观察，包含正常返回与异常 |
| `-x` | 对象展开深度 |
| `-n` | 输出次数上限 |

观察入参、返回值时，避免将凭据或个人数据写入共享日志。

## trace：查看内部调用耗时

```text
trace com.example.OrderService getOrder '#cost > 100' -n 5
```

只观察耗时大于 100 毫秒的调用。`trace` 主要展示目标方法内部第一层调用，不会自动递归展开整条链路。

## 后台任务与日志

在 Arthas 控制台使用 `&` 将命令放到后台，使用重定向保存结果：

```text
trace com.example.OrderService getOrder -n 10 > trace.out &
jobs
```

终止任务时使用 `jobs` 输出中的实际任务编号：

```text
kill 1
```

需要长时间观察时，再按实际需求调整后台任务超时：

```text
options job-timeout 2h
```

## logger：查看和修改日志级别

```text
logger
logger --name ROOT --level DEBUG
```

如果存在多个日志上下文，可用输出中的实际 ClassLoader 哈希指定：

```text
logger -c 18b4aac2 --name ROOT --level DEBUG
```

排查结束后，恢复修改前记录的日志级别。

## dashboard 与 thread

```text
dashboard
thread 2
```

`dashboard` 查看 JVM、线程和内存概况。`thread` 后的编号应来自当前应用，它是 Java 线程编号，不能直接替代系统原生线程 ID。

## 热更新：单独评估后再操作

`mc` 可在内存中编译代码；`redefine` 可替换已加载类的定义。这类操作会改变运行中应用的行为，不应当作常规查询命令直接执行。

标准 JVM 热替换不能任意增加、删除字段或方法，且 `redefine` 的修改不能通过 `reset` 恢复。具体操作应先确认 ClassLoader、准备原始字节码与恢复方案，并在测试环境验证。

参考：[Arthas 命令列表](https://arthas.aliyun.com/doc/commands.html)、[trace](https://arthas.aliyun.com/doc/trace.html)、[redefine](https://arthas.aliyun.com/doc/redefine.html)。
