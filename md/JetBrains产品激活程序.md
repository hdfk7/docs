# JetBrains产品激活程序

[ja-netfilter.jar](static/ja-netfilter.jar)

该程序需要配合产品自定义vm参数，修改javaagent，然后配合http://jets.idejihuo.com/v2/的激活码就可以完整激活了。

--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/ja-netfilter.jar=jetbrains
