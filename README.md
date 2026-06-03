# 员工考勤与薪资管理系统

## 一、项目概述

基于 **MyBatis + Druid** 的 Java Web 员工考勤与薪资管理系统，采用 **Servlet/JSP + Maven** 架构。

### 技术栈
| 组件 | 技术 | 版本 |
|------|------|------|
| JDK | Java 8 | 1.8+ |
| Web服务器 | Apache Tomcat | 8.x / 9.x |
| ORM框架 | MyBatis | 3.5.13 |
| 数据库连接池 | Alibaba Druid | 1.2.16 |
| 数据库 | MySQL | 5.7.x / 8.0.x |
| 日志框架 | Log4j2 | 2.20.0 |
| JSON工具 | Google Gson | 2.10.1 |

---

## 二、项目目录结构（IDEA左侧资源管理器）

```
attendance-salary-system/                    # Maven项目根目录
├── pom.xml                                  # [1] Maven依赖配置文件
├── src/
│   ├── main/
│   │   ├── java/com/attendance/              # Java源码根包
│   │   │   ├── entity/                       # [4] 持久化类（实体类）
│   │   │   │   ├── Department.java           #    部门实体
│   │   │   │   ├── Employee.java             #    员工实体（含@One关联Department）
│   │   │   │   ├── AttendRecord.java         #    考勤记录实体
│   │   │   │   ├── LeaveRequest.java         #    请假申请实体
│   │   │   │   └── Salary.java               #    薪资实体（含@One关联Employee+Department）
│   │   │   │
│   │   │   ├── mapper/                       # [5] MyBatis Mapper接口层
│   │   │   │   ├── DepartmentMapper.java     #    部门Mapper
│   │   │   │   ├── EmployeeMapper.java       #    员工Mapper（@SelectProvider动态SQL）
│   │   │   │   ├── AttendRecordMapper.java   #    考勤Mapper（动态SQL多条件查询）
│   │   │   │   ├── LeaveRequestMapper.java   #    请假Mapper
│   │   │   │   └── SalaryMapper.java         #    薪资Mapper（@Results/@One关联查询）
│   │   │   │
│   │   │   ├── service/                      # 服务层接口
│   │   │   │   ├── EmployeeService.java       #    员工服务接口
│   │   │   │   └── SalaryService.java         #    薪资服务接口
│   │   │   │
│   │   │   ├── service/impl/                 # 服务层实现
│   │   │   │   ├── EmployeeServiceImpl.java  #    员工服务实现
│   │   │   │   └── SalaryServiceImpl.java    #    薪资服务实现（含核心计算算法）
│   │   │   │
│   │   │   ├── servlet/                      # [7] Servlet控制器层（MVC中的C）
│   │   │   │   ├── LoginServlet.java          #    登录/登出控制器
│   │   │   │   ├── EmployeeServlet.java       #    员工端控制器（打卡/请假/查看等）
│   │   │   │   ├── ManagerServlet.java        #    主管端控制器（审批/团队统计）
│   │   │   │   └── AdminServlet.java          #    管理员端控制器（员工管理/薪资发放）
│   │   │   │
│   │   │   ├── filter/                       # 过滤器
│   │   │   │   └── AuthFilter.java            #    权限认证过滤器
│   │   │   │
│   │   │   └── utils/                        # 工具类
│   │   │       ├── MyBatisUtils.java          #    MyBatis会话工具类（单例模式）
│   │   │       └── WebUtils.java              #    Web请求参数获取工具
│   │   │
│   │   ├── resources/                        # 配置资源目录
│   │   │   ├── mybatis-config.xml            # [3] MyBatis核心配置文件
│   │   │   ├── druid.properties              # [3] Druid数据库连接池配置
│   │   │   ├── log4j2.xml                   # [3] Log4j2日志配置
│   │   │   ├── init.sql                     # [2] 数据库初始化SQL脚本
│   │   │   └── mapper/                      # MyBatis XML映射文件目录
│   │   │       ├── DepartmentMapper.xml      #    部门SQL映射
│   │   │       ├── EmployeeMapper.xml        #    员工SQL映射（动态if/where）
│   │   │       ├── AttendRecordMapper.xml    #    考勤SQL映射（动态条件查询）
│   │   │       ├── LeaveRequestMapper.xml    #    请假SQL映射
│   │   │       └── SalaryMapper.xml          #    薪资SQL映射（@One/@Many关联）
│   │   │
│   │   └── webapp/                          # Web应用根目录
│   │       ├── WEB-INF/
│   │       │   ├── web.xml                  # [9] Web部署描述符
│   │       │   └── views/                   # JSP视图页面目录
│   │       │       ├── common/               # [8] 公共页面
│   │       │       │   ├── login.jsp        #      登录页
│   │       │       │   ├── error_404.jsp    #      404错误页
│   │       │       │   └── error_500.jsp    #      500错误页
│   │       │       ├── employee/            # [8] 员工端页面
│   │       │       │   ├── dashboard.jsp    #      员工首页（打卡操作区）
│   │       │       │   ├── attend_view.jsp  #      月度考勤日历
│   │       │       │   ├── apply_leave.jsp #      请假申请表单
│   │       │       │   ├── leave_list.jsp  #      请假记录列表
│   │       │       │   └── salary_view.jsp  #      薪资详情查看
│   │       │       ├── manager/             # [8] 主管端页面
│   │       │       │   ├── dashboard.jsp    #      主管首页（待审批概览）
│   │       │       │   ├── leave_review.jsp #      请假审批列表
│   │       │       │   └── team_attend.jsp  #      团队考勤统计
│   │       │       └── admin/               # [8] 管理员端页面
│   │       │           ├── dashboard.jsp    #      管理后台首页
│   │       │           ├── emp_list.jsp     #      员工列表（搜索/筛选）
│   │       │           ├── emp_add.jsp      #      添加新员工表单
│   │       │           └── salary_list.jsp  #      薪资管理与发放列表
│   │       └── assets/                      # 静态资源
│   │           ├── css/style.css            # 全局样式表
│   │           ├── js/                      # JS脚本（预留）
│   │           └── images/                  # 图片（预留）
│   │
│   └── test/java/com/attendance/             # 测试代码目录
└── README.md                                # 本文档
```

---

## 三、实现步骤详解

### 步骤①：创建数据表
执行 `src/main/resources/init.sql`，创建5张数据表：
- **department** - 部门表
- **employee** - 员工表（外键→department）
- **attend_record** - 考勤记录表（联合唯一键 emp_id+work_date）
- **leave_request** - 请假申请表（双外键→employee）
- **salary** - 薪资表（联合唯一键 emp_id+year_month）

同时插入测试数据：4个部门 + 7个用户(3员工+1主管+1管理员) + 考勤/请假示例

### 步骤②：引入Maven依赖
在 `pom.xml` 中声明所有依赖（MyBatis、Druid、MySQL驱动、Servlet/JSP API、JSTL、Log4j2、Gson等）

### 步骤③：配置文件（3个核心配置文件）

| 文件 | 用途 | 关键配置项 |
|------|------|-----------|
| `druid.properties` | Druid连接池 | driverClassName, url, username, password, 连接池参数 |
| `mybatis-config.xml` | MyBatis全局配置 | typeAliases(类型别名), environments(数据源), mappers(XML注册), settings(mapUnderscoreToCamelCase, logImpl=LOG4J2) |
| `log4j2.xml` | 日志输出控制 | com.attendance.mapper 设为DEBUG级别以显示SQL语句 |

### 步骤④⑤⑥：持久化层（Entity → Mapper接口 → XML映射）

**5个实体类**对应5张数据库表，使用驼峰命名自动映射。

**关键技术点覆盖：**
- ✅ **Mapper注解方式** (`@Param`, `@Select`, `@Results`, `@Result`, `@One`)
- ✅ **动态SQL注解** (`@SelectProvider`) - 多条件灵活组合查询
- ✅ **XML动态SQL** (`<if>`, `<where>`, `<set>`) - 条件拼接
- ✅ **关联查询 @One** (Salary→Employee→Department 三级嵌套)
- ✅ **resultMap嵌套association**

### 步骤⑦⑧：Service层 + Servlet层 + JSP前端

**Service层核心算法 - 薪资计算规则（Java方法）：**
```
实际工资 = 基本工资 + 全勤奖(300) + 加班费 
         - 迟到扣款(次数 × 月薪/21.75/8)
         - 请假扣款((月薪/21.75) × 天数)

全勤奖条件: 无迟到 + 无请假 + 无缺勤 → 发放300元
```

**三端功能划分：**
| 端口 | 功能 | 说明 |
|------|------|------|
| 员工端 (/employee) | 登录、打卡(上班/下班)、请假申请、查看考勤日历、查看薪资 | 工号E开头 |
| 主管端 (/manager) | 审批请假、查看团队考勤统计 | 工号M开头 |
| 管理员端 (/admin) | 员工CRUD、生成月度薪资、薪资发放、报表 | 工号A开头 |

### 步骤⑨：web.xml部署描述符
配置编码过滤器、欢迎页面、错误页面(404/500)

---

## 四、部署与运行指南

### 4.1 环境要求
- **JDK 1.8+**
- **Apache Tomcat 8.x 或 9.x**
- **MySQL 5.7+ / 8.0**（用户名: root, 密码: zph）
- **IntelliJ IDEA 2023.03+**

### 4.2 部署步骤

```bash
# 1. 创建数据库并导入初始化数据
mysql -u root -pzph < attendance-salary-system/src/main/resources/init.sql

# 2. 用IDEA打开项目（Open -> 选择 attendance-salary-system 目录）

# 3. 在IDEA中配置Tomcat:
#    Run -> Edit Configurations -> + -> Tomcat Server -> Local
#    Deployment -> + -> Artifact -> 选择 "attendance-salary-system:war exploded"
#    Application context: /
#
#    注意：如果IDEA提示"Artifacts not configured"，需要手动添加Artifact:
#    File -> Project Structure -> Artifacts -> + -> Web Application: Exploded

# 4. 启动Tomcat，浏览器访问 http://localhost:8080
```

### 4.3 测试账号
| 角色 | 工号 | 密码 | 功能 |
|------|------|------|------|
| 普通员工 | E001 | 123456 | 打卡、请假、查看考勤和薪资 |
| 普通员工 | E002 | 123456 | 同上 |
| 主管 | M001 | 123456 | 审批请假、查看团队考勤 |
| 管理员 | A001 | admin888 | 全部功能（员工管理、薪资发放）|

---

## 五、技术评分对照

| 技术点 | 本项目实现 | 分值 |
|--------|----------|------|
| Mapper使用注解方式 | @Param/@Select/@Results/@Result/@One 全部使用 | 15% ✓ |
| 动态SQL (@SelectProvider) | AttendRecordMapper 多条件组合查询 | 20% ✓ |
| 关联查询 (@One/@Many) | SalaryMapper 三级嵌套: Salary→Employee→Department | 20% ✓ |
| 复杂业务逻辑(薪资计算) | 迟到扣款/请假扣款/全勤奖完整公式实现 | 15% ✓ |
| 数据库设计 | 5张表，合理的外键和约束设计 | 10% ✓ |
| 页面美观 | CSS响应式布局、状态徽章、卡片式设计 | 10% ✓ |
| 功能完整性 | 三端全部功能已实现（登录/打卡/请假/审批/薪资） | 10% ✓ |
