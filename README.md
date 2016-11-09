# PFMDB
将FMDB封装成面向对象存储框架，类似于JAVA的Hibernate

1、轻量级，使用简单；

2、默认主键是自增长主键incrementId，可自定义；

3、使用案例存放于ViewController。

ps：本框架由阅读JRDB源码而来。

# 使用方法

#### cocoapods
在Podfile添加

target :'[projectName]' do

pod 'PFMDB'

end


#### 手动
下载zip解压，将lib目录下的文件copy到项目中。


