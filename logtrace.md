# 日志收集与分析

**问题域**

- 日志分布式追踪
- 业务/系统告警
- 日志分析
- 日志查询
- 日志收集

**约束**

- 日志输出性能影响 尽量控制在 25%左右(主要取决于整个业务链日志输出量级)
- 日志查询应该在30s内返回结果
- 日志查询需要支持 关键字 全文搜索/且关系/或关系
- 告警规则支持自定义,支持分组,分级等特性
- 监控应提供全局数据可视化展示
- 日志数据存储默认为一周,应特别留意集群数据量与集群算力的比例
- 作为基础设施/应用开发/业务监控分析的重要的可靠的信息源
- 日志字段分隔符支持自定义,Debug模式应该检查非法字符输出比如字段分隔符



**业务日志格式**

- traceid   一级信息
- pspanid  一级信息
- spanid     一级信息
- 时间          一级信息
- 主机名      一级信息
- 服务名       一级信息  (针对容器服务特殊性,可以省略)
- 文件名       一级信息
- 行数           一级信息
- 日志等级   一级信息
- 响应码       一级信息
- 信息类型   一级信息 枚举类型: request/response/body
- 日志主体信息    一级信息



二级信息处理

日志主体信息: (需要考虑信息安全吗? 比如客户姓名/手机号/邮箱地址/住址/银行卡号/身份证信息等等)



日志输出服务以包的形式提供

1. id值 以context值域形式在服务之间传递
2. 日志主体信息输出的功能需求以日志包形式提供
3. 技术选型: 基本输出log包,选用zap,封装一层, 提供一个样板log包, 可以自由实现



需要交付的成果:

- 一个能满足日志输出需求且性能不错的日志包
- 一个解析日志服务
- 一个日志数据查询后端服务
- 一个前端数据查询页面(可能需要根据用户角色不同,来组织数据层次访问权限)
- 一个protobuffer生成器插件

需要支撑的基础设施:

​        强大稳定的EFK基础支撑



日志收集/管理/系统维护

丁丁



响应码设计

| 业务/系统 | 甲/乙方 | 系统编号 | 模块编号 | 错误等级 | 具体错误编号 |
| :-------: | :-----: | :------: | :------: | :------: | :----------: |
|     1     |    1    |    2     |    2     |    1     |      4       |



**日志分析**

- 动态生成分布式日志链
- 支持日志展开浏览模式
- 以traceid为单位定期分析日志数据,生成时序数据存入时序数据库或保存在ES集群里
- 告警系统





扩展话题:

1. K8S集群日志/中间件/数据库/硬件监控    日志 收集/分析/告警
2. K8S集群证书时间问题 (自动升级需要验证)
3. 监控系统的建立



监控体系的建立

从业务监控入手,到应用程序监控,到K8S集群健康度监控到硬件层监控,都应用有效的监控起来,才能为故障诊断提供足够的信息源

业务监控:  难做

系统监控: CPU  内存  磁盘  负载  文件描述符

服务监控:  存活 /服务健康状态(包含 内存/CPU/GC)

日志监控: 也是一个复杂的难题

网络监控: 主要针对各网卡流量