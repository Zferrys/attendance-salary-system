-- ============================================================
-- 员工考勤与薪资管理系统 - 数据库初始化脚本
-- 数据库: MySQL 5.7 / 8.0
-- 字符集: utf8mb4 (支持中文和特殊字符)
-- 说明: 包含5张数据表 + 测试数据的完整建库脚本
-- ============================================================

-- 如果数据库不存在则创建
CREATE DATABASE IF NOT EXISTS attendance_salary DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE attendance_salary;

-- 临时关闭外键检查，避免删表时外键冲突
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 表1: department（部门表）
-- 用途: 存储公司的部门信息，员工表通过外键关联此表
-- 设计要点: deptName唯一约束，避免重复部门名
-- ============================================================
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '部门ID，主键自增',
    `dept_name` VARCHAR(50) NOT NULL COMMENT '部门名称',
    `manager_id` INT DEFAULT NULL COMMENT '部门主管员工ID，关联employee表',
    UNIQUE KEY `uk_dept_name` (`dept_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门信息表';

-- ============================================================
-- 表2: employee（员工表）
-- 用途: 存储公司所有员工的基本信息
-- 外键: dept_id 关联 department(id)
-- 设计要点: emp_no工号唯一；password存储MD5加密密码
-- ============================================================
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID，主键自增',
    `emp_no` VARCHAR(20) NOT NULL UNIQUE COMMENT '员工工号，唯一标识',
    `name` VARCHAR(50) NOT NULL COMMENT '员工姓名',
    `password` VARCHAR(100) NOT NULL COMMENT '登录密码（建议MD5加密）',
    `dept_id` INT NOT NULL COMMENT '所属部门ID，外键关联department表',
    `position` VARCHAR(50) NOT NULL COMMENT '职位/岗位名称',
    `role` VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE' COMMENT '角色：ADMIN管理员/MANAGER主管/EMPLOYEE员工',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱地址',
    `base_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '基本工资（元）',
    `entry_date` DATE NOT NULL COMMENT '入职日期',
    `leave_date` DATE DEFAULT NULL COMMENT '离职日期（NULL表示在职）',
    FOREIGN KEY (`dept_id`) REFERENCES `department`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工信息表';

-- ============================================================
-- 表3: attend_record（考勤记录表）
-- 用途: 记录员工每天的打卡签到/签退情况
-- 设计要点: 联合唯一键(emp_id, work_date)确保每人每天只能有一条记录
--           status字段区分打卡状态：正常、迟到、早退、缺勤
-- ============================================================
DROP TABLE IF EXISTS `attend_record`;
CREATE TABLE `attend_record` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID，主键自增',
    `emp_id` INT NOT NULL COMMENT '员工ID，外键关联employee表',
    `work_date` DATE NOT NULL COMMENT '工作日期',
    `check_in_time` DATETIME DEFAULT NULL COMMENT '上班打卡时间（如 2026-06-02 08:55:00）',
    `check_out_time` DATETIME DEFAULT NULL COMMENT '下班打卡时间',
    `status` ENUM('正常','迟到','早退','缺勤') DEFAULT '缺勤' COMMENT '当日考勤状态',
    `work_hours` DECIMAL(4,1) DEFAULT 0.0 COMMENT '实际工作时长（小时），默认0.0',
    FOREIGN KEY (`emp_id`) REFERENCES `employee`(`id`),
    -- 联合唯一键：同一员工同一天只有一条考勤记录（用于判断是否重复打卡）
    UNIQUE KEY `uk_emp_date` (`emp_id`, `work_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工考勤记录表';

-- ============================================================
-- 表4: leave_request（请假申请表）
-- 用途: 存储员工的请假申请及审批流程信息
-- 外键: emp_id 关联 employee(id)；approver 关联 employee(id)
-- 设计要点: status跟踪审批流程状态（待审批/已批准/已拒绝/已撤销）
-- ============================================================
DROP TABLE IF EXISTS `leave_request`;
CREATE TABLE `leave_request` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '请假单ID，主键自增',
    `emp_id` INT NOT NULL COMMENT '申请人-员工ID，外键关联employee表',
    `leave_type` ENUM('事假','病假','年假') NOT NULL COMMENT '请假类型（事假/病假/年假）',
    `start_date` DATE NOT NULL COMMENT '请假开始日期',
    `end_date` DATE NOT NULL COMMENT '请假结束日期',
    `days` INT NOT NULL COMMENT '请假天数',
    `reason` TEXT COMMENT '请假原因说明',
    `status` ENUM('待审批','已批准','已拒绝','已撤销') DEFAULT '待审批' COMMENT '审批状态',
    `approver_id` INT DEFAULT NULL COMMENT '审批人ID（主管），关联employee表',
    `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
    FOREIGN KEY (`emp_id`) REFERENCES `employee`(`id`),
    FOREIGN KEY (`approver_id`) REFERENCES `employee`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假申请表';

-- ============================================================
-- 表5: salary（薪资表/月度薪资发放表）
-- 用途: 记录员工每月的薪资计算结果和发放状态
-- 外键: emp_id 关联 employee(id)
-- 设计要点: 联合唯一键(emp_id, year_month)确保每人每月只发一次薪
--           包含基本工资+全勤奖+加班补贴-迟到扣款-请假扣款等明细
-- ============================================================
DROP TABLE IF EXISTS `salary`;
CREATE TABLE `salary` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '薪资记录ID，主键自增',
    `emp_id` INT NOT NULL COMMENT '员工ID，外键关联employee表',
    `year_month` VARCHAR(7) NOT NULL COMMENT '薪资月份，格式: 2026-06',
    `base_salary` DECIMAL(10,2) DEFAULT 0.00 COMMENT '当月基本工资',
    `attendance_bonus` DECIMAL(10,2) DEFAULT 0.00 COMMENT '全勤奖（无迟到无请假无缺勤时发放300元）',
    `overtime_pay` DECIMAL(10,2) DEFAULT 0.00 COMMENT '加班补贴',
    `deduction_late` DECIMAL(10,2) DEFAULT 0.00 COMMENT '迟到扣款（每次扣 = 基本工资 / 21.75 / 8 * 1）',
    `deduction_leave` DECIMAL(10,2) DEFAULT 0.00 COMMENT '请假扣款（日薪 × 请假天数）',
    `actual_salary` DECIMAL(10,2) DEFAULT 0.00 COMMENT '实际应发工资（最终到手金额）',
    `status` ENUM('未发放','已发放') DEFAULT '未发放' COMMENT '薪资发放状态',
    `generate_time` DATETIME DEFAULT NULL COMMENT '生成时间',
    `pay_time` DATETIME DEFAULT NULL COMMENT '实际发放时间',
    FOREIGN KEY (`emp_id`) REFERENCES `employee`(`id`),
    -- 联合唯一键：同一员工同一个月只产生一条薪资记录
    UNIQUE KEY `uk_emp_ym` (`emp_id`, `year_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工月度薪资表';

-- ============================================================
-- 插入测试数据 - 部门
-- ============================================================
INSERT INTO `department` (`dept_name`, `manager_id`) VALUES 
('技术部', NULL),   -- 主管ID将在employee插入后更新
('人事部', NULL),
('财务部', NULL),
('市场部', NULL);

-- 更新部门主管关联
UPDATE `department` SET `manager_id` = (SELECT `id` FROM `employee` WHERE `emp_no` = 'M001') WHERE `dept_name` = '技术部';

-- ============================================================
-- 插入测试数据 - 员工
-- 密码统一为: 123456 的明文（生产环境应使用MD5加密存储）
-- 角色分配: admin=管理员, manager=主管, emp=普通员工
-- ============================================================
INSERT INTO `employee` (`emp_no`, `name`, `password`, `dept_id`, `position`, `role`, `base_salary`, `entry_date`) VALUES
('E001', '张三', '123456', 1, 'Java开发工程师', 'EMPLOYEE', 12000.00, '2025-01-15'),
('E002', '李四', '123456', 1, '前端开发工程师', 'EMPLOYEE', 11000.00, '2025-03-01'),
('E003', '王五', '123456', 2, 'HR专员', 'EMPLOYEE', 8000.00, '2024-11-01'),
('E004', '赵六', '123456', 3, '会计', 'EMPLOYEE', 9000.00, '2024-08-10'),
('E005', '孙七', '123456', 4, '销售经理', 'EMPLOYEE', 15000.00, '2024-05-01'),
-- 主管账号（拥有审批权限，管理本部门员工）
('M001', '陈主管', '123456', 1, '技术部主管', 'MANAGER', 20000.00, '2023-06-01'),
-- 管理员账号（拥有最高权限，可管理所有主管和员工）
('A001', '管理员', 'admin888', 1, '系统管理员', 'ADMIN', 25000.00, '2023-01-01');

-- ============================================================
-- 插入测试数据 - 考勤记录（模拟2026年6月前几天的数据）
-- ============================================================
INSERT INTO `attend_record` (`emp_id`, `work_date`, `check_in_time`, `check_out_time`, `status`, `work_hours`) VALUES
-- 张三(E001, id=1): 正常打卡示例
(1, '2026-06-01', '2026-06-01 08:28:00', '2026-06-01 18:05:00', '正常', 9.6),
(1, '2026-06-02', '2026-06-02 09:05:00', '2026-06-02 18:30:00', '迟到', 9.4),
(1, '2026-06-03', '2026-06-03 08:30:00', '2026-06-03 17:50:00', '早退', 9.3),
-- 李四(E002, id=2):
(2, '2026-06-01', '2026-06-01 08:25:00', '2026-06-01 18:10:00', '正常', 9.7),
(2, '2026-06-02', '2026-06-02 08:32:00', '2026-06-02 18:00:00', '正常', 9.5);

-- ============================================================
-- 插入测试数据 - 请假申请
-- ============================================================
INSERT INTO `leave_request` (`emp_id`, `leave_type`, `start_date`, `end_date`, `days`, `reason`, `status`, `approver_id`, `approve_time`) VALUES
-- 张三请的事假（已批准）
(1, '年假', '2026-06-10', '2026-06-12', 3, '回老家探亲', '已批准', 7, NOW()),
-- 李四请的病假（待审批）
(2, '病假', '2026-06-15', '2026-06-16', 2, '感冒发烧需休息', '待审批', NULL, NULL),
-- 张三已撤销的请假
(1, '事假', '2026-06-20', '2026-06-20', 1, '个人事务', '已撤销', NULL, NULL);

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 提示: 数据库初始化完成！
SELECT '数据库 attendance_salary 初始化完成！' AS message;
SELECT COUNT(*) AS '部门数量' FROM department;
SELECT COUNT(*) AS '员工数量' FROM employee;
SELECT COUNT(*) AS '考勤记录数' FROM attend_record;
SELECT COUNT(*) AS '请假申请数' FROM leave_request;
