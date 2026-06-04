# 员工考勤与薪资管理系统

> 🎓 基于 **MyBatis + Druid** 的 Java Web 考勤薪资管理系统 | Servlet/JSP + Maven 架构

![Java](https://img.shields.io/badge/Java-1.8-blue)
![Tomcat](https://img.shields.io/badge/Tomcat-8.x%2F9.x-orange)
![MyBatis](https://img.shields.io/badge/MyBatis-3.5.13-red)
![MySQL](https://img.shields.io/badge/MySQL-5.7%2B-4479A1)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 目录

- [项目概述](#项目概述)
- [系统功能](#系统功能)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [数据库设计](#数据库设计)
- [核心业务逻辑](#核心业务逻辑)
- [快速开始](#快速开始)
- [测试账号](#测试账号)
- [技术亮点](#技术亮点)
- [功能截图](#功能截图)

---

## 📖 项目概述

员工考勤与薪资管理系统，实现企业日常人事管理数字化。支持**管理员、主管、员工**三种角色，覆盖员工管理、考勤打卡、请假审批、薪资核算发放等完整业务流程。

### 系统架构

```
┌─────────────────────────────────────────────┐
│              前端 (JSP + CSS)                 │
├──────┬──────────┬──────────┬────────────────┤
│ Admin│ Manager  │ Employee │  MiniApp       │
│ 管理  │ 主管端   │ 员工端    │  小程序端       │
├──────┴──────────┴──────────┴────────────────┤
│          Servlet 控制器层                     │
│  LoginServlet / AdminServlet /               │
│  ManagerServlet / EmployeeServlet /          │
│  MiniAppServlet                              │
├─────────────────────────────────────────────┤
│         Service 服务层                        │
│  EmployeeService / SalaryService             │
├─────────────────────────────────────────────┤
│        MyBatis 持久化层                       │
│  Mapper 接口 + XML 映射文件                    │
├─────────────────────────────────────────────┤
│      Druid 连接池 → MySQL 数据库              │
└─────────────────────────────────────────────┘
```

---

## ✨ 系统功能

### 👨‍💼 管理员端 (`/admin`)
| 功能模块 | 说明 |
|---------|------|
| 📊 数据概览 | 员工总数、部门总数仪表盘 |
| 👥 员工管理 | 增删改查、按姓名/部门搜索 |
| 📎 批量导入 | Excel 文件批量导入员工，自动分配工号 |
| 📅 考勤管理 | 查看全员考勤、按部门/日期/状态筛选、编辑/删除考勤记录 |
| 💰 薪资生成 | 自动计算并生成月度薪资 |
| 💳 薪资发放 | 一键发放，自动发送邮件通知员工 |
| 📈 薪资报表 | 月度薪资统计：总额、已发放/未发放、各项明细 |

### 👔 主管端 (`/manager`)
| 功能模块 | 说明 |
|---------|------|
| 📋 待审批 | 查看待审批请假申请 |
| ✅ 请假审批 | 批准/拒绝员工的请假请求 |
| 👥 团队考勤 | 查看本部门员工考勤统计 |
| 📊 成员管理 | 查看部门成员考勤详情 |
| 💰 薪资查看 | 查看本部门员工薪资 |

### 👷 员工端 (`/employee`)
| 功能模块 | 说明 |
|---------|------|
| ⏰ 打卡签到 | 上班/下班打卡，自动判断迟到/早退 |
| 📅 考勤日历 | 月度考勤记录日历视图 |
| 📝 请假申请 | 提交请假（事假/病假/年假） |
| 📋 请假记录 | 查看请假申请历史及审批状态 |
| 💰 薪资查看 | 查看月度薪资详情 |

### 📱 小程序端 (`/miniapp`)
| 功能模块 | 说明 |
|---------|------|
| 🔐 小程序登录 | 工号+密码登录 |
| ⏰ 打卡 | 移动端打卡（上班/下班） |
| 📅 考勤记录 | 查看考勤历史 |
| 📝 请假申请 | 移动端请假 |
| 👤 我的 | 个人信息 |
| 💰 薪资查看 | 移动端查看薪资 |

---

## 🛠 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| JDK | Java | 1.8+ |
| Web 服务器 | Apache Tomcat | 8.x / 9.x |
| ORM 框架 | MyBatis | 3.5.13 |
| 数据库连接池 | Alibaba Druid | 1.2.16 |
| 数据库 | MySQL | 5.7.x / 8.0.x |
| 日志框架 | Log4j2 | 2.20.0 |
| JSON 工具 | Google Gson | 2.10.1 |
| Excel 处理 | Apache POI | 4.1.2 |
| 文件上传 | Commons FileUpload | 1.4 |
| 邮件发送 | JavaMail | 1.6.2 |
| 密码加密 | MD5 (自定义工具类) | - |
| 前端 | JSP + JSTL + CSS | - |

---

## 📁 项目结构

```
attendance-salary-system/
├── pom.xml                              # Maven 依赖配置
├── README.md                            # 本文档
├── salary_test_data.sql                 # 薪资测试数据
├── update_email.sql                     # 邮箱字段更新脚本
├── test.xlsx                            # Excel导入测试文件
│
└── src/
    └── main/
        ├── java/com/attendance/
        │   ├── entity/                  # 实体类（5个）
        │   │   ├── Department.java      #   部门
        │   │   ├── Employee.java        #   员工（含role角色字段）
        │   │   ├── AttendRecord.java    #   考勤记录
        │   │   ├── LeaveRequest.java    #   请假申请
        │   │   └── Salary.java          #   薪资
        │   │
        │   ├── mapper/                  # MyBatis Mapper接口（5个）
        │   │   ├── DepartmentMapper.java
        │   │   ├── EmployeeMapper.java      #   动态SQL多条件查询
        │   │   ├── AttendRecordMapper.java  #   动态SQL+增删改
        │   │   ├── LeaveRequestMapper.java
        │   │   └── SalaryMapper.java
        │   │
        │   ├── service/                 # 服务层
        │   │   ├── EmployeeService.java
        │   │   ├── SalaryService.java
        │   │   └── impl/
        │   │       ├── EmployeeServiceImpl.java
        │   │       └── SalaryServiceImpl.java  # 核心薪资计算算法
        │   │
        │   ├── servlet/                 # Servlet控制器（5个）
        │   │   ├── LoginServlet.java        # 登录/登出
        │   │   ├── AdminServlet.java        # 管理员端（17个action）
        │   │   ├── ManagerServlet.java      # 主管端
        │   │   ├── EmployeeServlet.java     # 员工端
        │   │   └── MiniAppServlet.java      # 小程序端
        │   │
        │   ├── filter/
        │   │   └── AuthFilter.java      # 权限认证过滤器
        │   │
        │   └── utils/                   # 工具类（5个）
        │       ├── MyBatisUtils.java    # MyBatis会话管理
        │       ├── EmailUtil.java       # 邮件发送工具
        │       ├── ExcelImportUtil.java # Excel导入解析
        │       ├── MD5Util.java         # MD5加密
        │       └── WebUtils.java        # Web请求工具
        │
        ├── resources/
        │   ├── init.sql                 # 数据库初始化脚本
        │   ├── mybatis-config.xml       # MyBatis核心配置
        │   ├── druid.properties         # Druid连接池配置
        │   ├── log4j2.xml               # Log4j2日志配置
        │   └── mapper/                  # MyBatis XML映射（5个）
        │       ├── DepartmentMapper.xml
        │       ├── EmployeeMapper.xml
        │       ├── AttendRecordMapper.xml
        │       ├── LeaveRequestMapper.xml
        │       └── SalaryMapper.xml
        │
        └── webapp/
            ├── WEB-INF/
            │   └── web.xml              # Web部署描述符
            │
            ├── views/                   # JSP视图（35个）
            │   ├── common/              # 公共页面（登录/错误页）
            │   ├── admin/               # 管理员端（8个页面）
            │   ├── manager/             # 主管端（7个页面）
            │   ├── employee/            # 员工端（5个页面）
            │   └── miniapp/             # 小程序端（6个页面）
            │
            └── assets/                  # 静态资源
                ├── css/style.css        # 全局样式
                └── js/common.js         # 通用脚本
```

---

## 🗄 数据库设计

数据库名：`attendance_salary`（字符集 `utf8mb4`）

### 5张核心表

| 表名 | 说明 | 关键约束 |
|------|------|---------|
| **department** | 部门表 | `dept_name` UNIQUE |
| **employee** | 员工表 | `emp_no` UNIQUE, FK → department, 含 `role` 角色字段 |
| **attend_record** | 考勤记录表 | UNIQUE(emp_id, work_date), FK → employee |
| **leave_request** | 请假申请表 | FK → employee(emp_id, approver_id) |
| **salary** | 月度薪资表 | UNIQUE(emp_id, year_month), FK → employee |

### employee 表角色设计

| 角色 | 工号前缀 | 权限范围 |
|------|---------|---------|
| `ADMIN` | A 开头 | 所有功能（员工管理/考勤管理/薪资发放/报表） |
| `MANAGER` | M 开头 | 本部门审批/团队考勤查看 |
| `EMPLOYEE` | E 开头 | 打卡/请假/查看个人考勤和薪资 |

---

## 🧮 核心业务逻辑

### 考勤状态判定

```
上班打卡时间 >= 09:00:00  → 迟到
下班打卡时间 <= 18:00:00  → 早退
两者都正常                → 正常
当天无打卡记录             → 缺勤
```

### 薪资计算公式

```
全勤奖条件 = 无迟到 + 无请假 + 无缺勤 → 发放 300元

实际工资 = 基本工资 + 全勤奖 + 加班费
         - 迟到扣款(次数 × 月薪/21.75/8)
         - 请假扣款(月薪/21.75 × 请假天数)
```

### 工号自动分配

批量导入或新增员工时，系统根据角色前缀自动分配工号：
- 查询该前缀下的最大工号（如 E005）
- 自动递增生成新工号（如 E006）

---

## 🚀 快速开始

### 环境要求

- **JDK 1.8+**
- **Apache Tomcat 8.x / 9.x**
- **MySQL 5.7+ / 8.0**
- **IntelliJ IDEA**（推荐）

### 部署步骤

**1. 克隆项目**

```bash
git clone git@github.com:Zferrys/attendance-salary-system.git
cd attendance-salary-system
```

**2. 创建数据库**

```sql
-- 修改 init.sql 中的数据库连接密码（默认为 zph）
-- 然后执行：
mysql -u root -p < src/main/resources/init.sql
```

**3. 配置数据库连接**

编辑 `src/main/resources/druid.properties`：

```properties
jdbc.url=jdbc:mysql://localhost:3306/attendance_salary?useUnicode=true&characterEncoding=utf8
jdbc.username=root
jdbc.password=你的数据库密码
```

**4. 配置邮件发送（可选）**

编辑 `src/main/java/com/attendance/utils/EmailUtil.java`，配置发件邮箱信息。薪资发放时将自动发送邮件通知员工。

**5. IDEA 配置 Tomcat 运行**

```
1. 用 IDEA 打开项目目录
2. Run → Edit Configurations → + → Tomcat Server → Local
3. Deployment → + → Artifact → attendance-salary-system:war exploded
4. Application context: /
5. 启动 Tomcat，访问 http://localhost:8080
```

---

## 🔑 测试账号

| 角色 | 工号 | 姓名 | 密码 | 权限说明 |
|------|------|------|------|---------|
| 管理员 | A001 | 管理员 | admin888 | 全部功能 |
| 主管 | M001 | 陈主管 | 123456 | 审批请假、查看团队考勤 |
| 员工 | E001 | 张三 | 123456 | 打卡、请假、查看个人记录 |
| 员工 | E002 | 李四 | 123456 | 同上 |
| 员工 | E003 | 王五 | 123456 | 同上 |
| 员工 | E004 | 赵六 | 123456 | 同上 |
| 员工 | E005 | 孙七 | 123456 | 同上 |

> 💡 密码使用 MD5 加密存储，请勿直接修改数据库中的密码字段

---

## 💡 技术亮点

### MyBatis 核心技术

| 技术点 | 实现方式 | 应用场景 |
|--------|---------|---------|
| **动态SQL** | `<if>`, `<where>`, `<set>` XML标签 | 考勤/员工多条件组合查询 |
| **动态SQL注解** | `@SelectProvider` | 考勤灵活筛选 |
| **关联查询** | `@One`, `@Results` | 薪资→员工→部门三级嵌套 |
| **resultMap** | XML `<resultMap>` + `<association>` | 复杂关联映射 |
| **批量操作** | MyBatis + Druid事务 | Excel批量导入员工 |

### 系统设计亮点

- ✅ **三端分离**：管理员/主管/员工 + 小程序端，四种视图完全独立
- ✅ **角色权限**：基于工号前缀自动分配角色，AuthFilter 统一拦截
- ✅ **MD5加密**：密码安全存储
- ✅ **邮件通知**：薪资发放自动发送邮件
- ✅ **Excel导入**：支持批量导入员工数据
- ✅ **考勤智能判定**：自动识别迟到/早退/正常/缺勤
- ✅ **薪资自动计算**：含全勤奖、迟到扣款、请假扣款完整公式
- ✅ **响应式UI**：CSS卡片式布局，状态徽章，移动端友好

---

## 📊 功能截图

### 管理员端
- 数据概览仪表盘 → `/admin?action=dashboard`
- 员工管理列表 → `/admin?action=empList`
- 考勤管理（编辑/删除） → `/admin?action=attendanceList`
- 薪资管理与发放 → `/admin?action=salaryList`
- 月度薪资报表 → `/admin?action=salaryReport`

### 员工端
- 打卡签到 → `/employee?action=clock`
- 考勤日历 → `/employee?action=attendView`
- 请假申请 → `/employee?action=applyLeave`
- 薪资查看 → `/employee?action=salaryView`

### 小程序端
- 小程序登录 → `/views/miniapp/login.jsp`
- 打卡页面 → `/views/miniapp/clock.jsp`
- 考勤记录 → `/views/miniapp/records.jsp`

---

## 📝 License

MIT License - 仅供学习参考使用

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！
