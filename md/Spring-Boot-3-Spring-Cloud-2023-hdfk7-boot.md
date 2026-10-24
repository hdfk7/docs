# 基于 Spring Boot 3 和 Spring Cloud 2023 的微服务基础框架 hdfk7-boot

在搭建微服务项目时，很多时间并不是花在业务代码上，而是花在基础设施整合上。比如父 POM 版本管理、Nacos 注册中心和配置中心、OpenFeign、Gateway、MyBatis-Plus、Redis、Redisson、Kafka、统一返回结果、统一异常处理、日志链路追踪、接口文档等。

这些能力每个项目都会用到，但如果每次都重新整合，不仅效率低，也容易出现版本不兼容、配置不统一、基础能力重复造轮子的问题。

`hdfk7-boot` 就是为了解决这类问题而整理的一套微服务基础框架。当前 `master` 分支对应的是 Spring Boot 3 和 Spring Cloud 2023 版本线，框架自身版本为 `3.0.3`，适合作为 Spring Boot 3 微服务项目的基础模板。

## 项目定位

`hdfk7-boot` 是一套基于 `Spring Boot 3.3.13`、`Spring Cloud 2023.0.6`、`Spring Cloud Alibaba 2023.0.3.4` 和 `Java 21` 构建的微服务项目基础框架。

它不是一个具体业务系统，而是一套面向微服务项目的基础工程。

它主要提供：

1. 统一的父 POM 和依赖版本管理；
2. 项目间共享的基础协议、模型、异常和注解；
3. 通用 starter，封装基础组件和自动配置；
4. Nacos、OpenFeign、LoadBalancer、Gateway 等服务治理能力；
5. MyBatis-Plus 代码生成器依赖封装；
6. Gateway 和普通 Web 服务两个空白示例工程。

对于新项目来说，可以直接基于这套结构改造出自己的业务工程，减少前期技术整合成本。

## 技术栈与版本

当前 `master` 分支主要版本如下：

| 组件 | 版本 |
| --- | --- |
| Spring Boot | `3.3.13` |
| Spring Cloud | `2023.0.6` |
| Spring Cloud Alibaba | `2023.0.3.4` |
| Java | `21` |
| hdfk7 parent | `3.0.3` |
| hdfk7 common | `3.0.3` |
| hdfk7 discovery | `3.0.3` |
| hdfk7 common-sdk | `3.0.3` |
| hdfk7 generator | `3.0.3` |

项目还集成了 MyBatis-Plus、Redisson、Hutool、MapStruct、Knife4j、SkyWalking、Kafka、RabbitMQ、XXL-JOB、EasyExcel 等常用依赖。

需要注意的是，README 中特别提到：该版本是在 SkyWalking 9.5 上适配的，Gateway 需要手动配置 `spring-cloud-starter-gateway` 版本为 `4.1.1` 及以下，否则 SkyWalking 可能不生效。

## 模块结构

项目主要模块如下：

| 模块 | 说明 |
| --- | --- |
| `hdfk7-boot-starter-parent` | 项目父包，统一管理依赖和插件 |
| `hdfk7-common-sdk` | 项目间共享 SDK 聚合模块 |
| `hdfk7-base-proto` | 基础模型、分页模型、统一返回、异常、注解 |
| `hdfk7-common-proto` | 公共协议扩展模块 |
| `hdfk7-boot-starter-common` | 通用组件 starter |
| `hdfk7-boot-starter-discovery` | 服务发现、配置中心、负载均衡、OpenFeign 等配置 |
| `hdfk7-code-generator` | 基于 MyBatis-Plus Generator 的代码生成器依赖封装 |
| `hdfk7-gateway` | Gateway 网关示例 |
| `hdfk7-module` | 普通 Web 服务示例 |

整体结构可以分成三层：

1. 基础层：`parent`、`common-sdk`、`base-proto`；
2. 能力层：`starter-common`、`starter-discovery`、`code-generator`；
3. 示例层：`gateway`、`module`。

这样的分层比较适合企业内部沉淀基础框架：公共协议归公共协议，自动配置归 starter，业务项目只按需引入。

## 父 POM：统一依赖版本

`hdfk7-boot-starter-parent` 继承自 Spring Boot 官方 parent：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.13</version>
    <relativePath/>
</parent>
```

同时它统一管理了 Spring Cloud、Spring Cloud Alibaba、Redisson、MapStruct、Knife4j、MyBatis-Plus、Hutool、SkyWalking、XXL-JOB、EasyExcel 等依赖版本。

业务工程继承该 parent 后，就可以避免在每个模块里重复维护版本号：

```xml
<parent>
    <groupId>cn.hdfk7.boot</groupId>
    <artifactId>hdfk7-boot-starter-parent</artifactId>
    <version>3.0.3</version>
</parent>
```

这对多模块项目尤其重要，因为微服务系统中模块越多，依赖版本漂移的风险越高。

## common-sdk：公共协议与基础模型

`hdfk7-common-sdk` 是公共 SDK 聚合模块，下面包含：

- `hdfk7-base-proto`
- `hdfk7-common-proto`

其中 `hdfk7-base-proto` 提供了比较核心的基础能力：

- `BaseModel`
- `Page`
- `PageModel`
- `Result<T>`
- `ResultCode`
- `BaseException`
- `ResubmitCheck`
- `BaseMapstruct`

统一返回结果由 `Result<T>` 和 `ResultCode` 共同承担，业务接口可以保持一致的响应结构：

```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

异常体系中包含：

- `BaseException`
- `UnauthorizedException`
- `TokenInvalidException`
- `RemoteCallException`
- `ResubmitException`
- `ServiceDowngradeException`

这些异常可以配合全局异常处理器使用，让业务代码只需要抛出明确的业务异常，最终响应格式由框架统一处理。

## starter-common：通用基础能力

`hdfk7-boot-starter-common` 是通用组件 starter，依赖 `hdfk7-common-proto`，并以 `provided` 方式适配 Redis、Kafka、RabbitMQ、Redisson、Sentinel、WebFlux、XXL-JOB、MyBatis-Plus 等组件。

该 starter 的自动配置入口是：

```text
cn.hdfk7.boot.starter.common.BootStarterCommonAutoConfiguration
```

它包含的典型能力有：

1. MyBatis-Plus 分页组件；
2. 雪花算法 ID 生成组件；
3. `IdUtil` ID 工具；
4. Kafka 消息发送工具；
5. RabbitMQ 消息发送工具；
6. IP 获取工具；
7. 参数校验组件；
8. XXL-JOB 执行器配置；
9. Sentinel MVC 限流返回处理；
10. Sentinel Gateway 限流返回处理；
11. 日志切面基类；
12. 防重复提交切面基类。

其中防重复提交能力通过 `@ResubmitCheck` 注解和 `ResubmitCheckAspect` 配合实现，底层使用 Redisson 分布式锁控制重复请求。

业务模块可以像示例工程一样继承框架切面：

```java
@Aspect
@Component
public class ResubmitCheckAspect extends cn.hdfk7.boot.starter.common.aspect.ResubmitCheckAspect {
    @Around("@annotation(resubmitCheck)")
    public Object doAround(ProceedingJoinPoint joinPoint, ResubmitCheck resubmitCheck) throws Throwable {
        return doTask(joinPoint, resubmitCheck);
    }
}
```

这样可以把通用防重逻辑放在 starter 中，业务工程只负责定义切点。

## starter-discovery：服务发现与网关联动

`hdfk7-boot-starter-discovery` 主要封装微服务发现相关能力，自动配置入口是：

```text
cn.hdfk7.boot.starter.discovery.BootStarterDiscoveryAutoConfiguration
```

该模块集成了：

- Nacos Config
- Nacos Discovery
- OpenFeign
- LoadBalancer
- Caffeine
- Spring Cloud Gateway Server

其中比较关键的是 `AbstractLoadbalancerEventListener` 和 `GatewayLoadbalancerEventListener`。

项目通过监听 Nacos 服务变化事件，在服务上线、下线或实例变更时发布刷新事件，让网关和负载均衡缓存能更及时地感知服务变化。

这类能力在微服务项目中很实用。否则服务实例已经变化，但网关或客户端缓存还没有及时刷新，就可能出现短时间路由不准确或请求失败的问题。

## 示例工程：普通服务

普通 Web 服务示例位于：

```text
example/hdfk7-module
```

启动类启用了 Mapper 扫描和 OpenFeign：

```java
@MapperScan("cn.hdfk7.app.module.infrastructure.mapper")
@EnableFeignClients
@SpringBootApplication
public class ModuleApplication {
}
```

配置文件中接入 Nacos：

```yaml
spring:
  application:
    name: module
  cloud:
    nacos:
      discovery:
        username: username
        password: password
        server-addr: ip:8848
      config:
        username: username
        password: password
        server-addr: ip:8848
        file-extension: yaml
  config:
    import:
      - nacos:${spring.application.name}?refreshEnabled=true
```

示例工程还包含全局异常处理器、日志切面、防重复提交切面等内容，可以作为普通业务服务的初始模板。

## 示例工程：网关

网关示例位于：

```text
example/hdfk7-gateway
```

启动类同样启用了 Feign：

```java
@EnableFeignClients
@SpringBootApplication
public class GatewayApplication {
}
```

网关侧包含：

- `GatewayFilter`
- `GlobalExceptionHandler`
- `GatewayController`
- `ApplicationProperties`

其中 `GlobalExceptionHandler` 实现了 `ErrorWebExceptionHandler`，用于处理 WebFlux 网关场景下的异常响应。它会把 `BaseException` 等异常转换为统一的 `Result` 结构。

`GatewayFilter` 则可以用于处理网关层的统一过滤逻辑，比如请求头、traceId、认证信息传递等。

## 代码生成器

`hdfk7-code-generator` 是基于 MyBatis-Plus Generator 整合的代码生成器依赖模块，包含：

- MySQL Driver
- MyBatis-Plus Generator
- MyBatis-Plus Extension
- Freemarker

它的定位不是运行时 starter，而是开发阶段辅助工具。

业务项目可以在需要生成实体、Mapper、Service、Controller 等模板代码时引入该模块，减少重复编写 CRUD 基础代码的成本。

## 项目亮点

第一，版本统一。

通过 `hdfk7-boot-starter-parent` 统一维护 Spring Boot、Spring Cloud 和周边组件版本，降低多模块项目的依赖冲突概率。

第二，公共协议独立。

统一返回、分页、异常、注解、MapStruct 基类等都放在公共 SDK 中，方便多个服务共享。

第三，starter 化封装。

Redis、Redisson、Kafka、RabbitMQ、Sentinel、XXL-JOB、MyBatis-Plus 等通用能力被封装在 starter 中，业务服务按需引入即可。

第四，兼顾普通服务和网关服务。

项目同时提供 `hdfk7-module` 和 `hdfk7-gateway` 示例，覆盖大多数微服务项目的基本形态。

第五，考虑链路追踪场景。

该版本适配 SkyWalking 9.5，并对 Gateway 版本兼容性做了说明，说明项目不是只做依赖堆叠，也关注实际运行时的可观测性问题。

## 适用场景

`hdfk7-boot` 适合以下场景：

1. 基于 Spring Boot 3 搭建微服务项目；
2. 需要统一多个服务的依赖版本；
3. 项目使用 Nacos 做注册中心和配置中心；
4. 项目需要 Gateway、OpenFeign、LoadBalancer；
5. 希望统一接口返回和异常处理；
6. 希望内置日志切面、防重复提交、分布式 ID 等基础能力；
7. 团队准备沉淀自己的 Java 微服务基础框架。

## 总结

`hdfk7-boot` 是一套基于 Spring Boot 3 的微服务基础脚手架。它把微服务项目中常见的基础能力进行了模块化整理，包括父 POM、公共 SDK、通用 starter、服务发现 starter、代码生成器，以及 Gateway 和普通 Web 服务示例。

它最大的价值在于减少新项目启动阶段的重复整合工作，让团队可以把更多精力放在业务建模和业务实现上。

如果你正在搭建 Spring Boot 3 + Spring Cloud + Nacos 的微服务项目，这个项目可以作为一个不错的基础模板参考。
