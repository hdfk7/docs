# JetBrains产品激活程序

[ja-netfilter.jar](..%2Fstatic%2Fja-netfilter.jar)

该程序需要配合产品自定义vm参数，修改javaagent位置就行。

-XX:ReservedCodeCacheSize=512m

-XX:+IgnoreUnrecognizedVMOptions

-XX:+UseG1GC

-XX:SoftRefLRUPolicyMSPerMB=50

-XX:CICompilerCount=2

-XX:+HeapDumpOnOutOfMemoryError

-XX:-OmitStackTraceInFastThrow

-ea

-Dsun.io.useCanonCaches=false

-Djdk.http.auth.tunneling.disabledSchemes=""

-Djdk.attach.allowAttachSelf=true

-Djdk.module.illegalAccess.silent=true

-Dkotlinx.coroutines.debug=off

-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log

-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof

--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED

-javaagent:/ja-netfilter.jar=jetbrains
