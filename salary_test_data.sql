-- ============================================================
-- 薪资测试数据生成脚本（4月、5月、6月）
-- 说明：为所有员工生成多月份非零测试薪资记录
-- 计算公式：实际工资 = 基本工资 + 全勤奖(300) - 迟到扣款 - 请假扣款
-- ============================================================
USE attendance_salary;

-- 删除已有的测试薪资记录（避免重复）
DELETE FROM salary WHERE `year_month` IN ('2026-04', '2026-05', '2026-06');

-- ==================== 2026年4月薪资数据 ====================
-- 张三(E001, id=1): 基本工资12000, 正常18天+迟到2天, 事假1天(已批准)
--   迟到扣款 = 2次 × (12000/21.75/8) = 137.93
--   请假扣款 = (12000/21.75) × 1 = 551.72
--   全勤奖 = 0 (有迟到和请假)
--   实际工资 = 12000 + 0 - 137.93 - 551.72 = 11310.35
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(1, '2026-04', 12000.00, 0.00, 0.00, 137.93, 551.72, 11310.35, '已发放', '2026-04-30 18:00:00');

-- 李四(E002, id=2): 基本工资11000, 正常20天+迟到1天, 无病假
--   迟到扣款 = 1次 × (11000/21.75/8) = 63.22
--   请假扣款 = 0
--   全勤奖 = 0 (有迟到)
--   实际工资 = 11000 + 0 - 63.22 = 10936.78
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(2, '2026-04', 11000.00, 0.00, 0.00, 63.22, 0.00, 10936.78, '已发放', '2026-04-30 18:00:00');

-- 王五(E003, id=3): 基本工资8000, 正常21天, 无迟到无请假 → 全勤奖300
--   实际工资 = 8000 + 300 = 8300.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(3, '2026-04', 8000.00, 300.00, 0.00, 0.00, 0.00, 8300.00, '已发放', '2026-04-30 18:00:00');

-- 赵六(E004, id=4): 基本工资9000, 正常19天+迟到3天, 事假2天
--   迟到扣款 = 3 × (9000/21.75/8) = 155.17
--   请假扣款 = (9000/21.75) × 2 = 827.59
--   实际工资 = 9000 - 155.17 - 827.59 = 8017.24
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(4, '2026-04', 9000.00, 0.00, 0.00, 155.17, 827.59, 8017.24, '已发放', '2026-04-30 18:00:00');

-- 孙七(E005, id=5): 基本工资15000, 正常20天+迟到1天
--   迟到扣款 = 1 × (15000/21.75/8) = 86.21
--   实际工资 = 15000 - 86.21 = 14913.79
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(5, '2026-04', 15000.00, 0.00, 0.00, 86.21, 0.00, 14913.79, '已发放', '2026-04-30 18:00:00');

-- 陈主管(M001, id=6): 基本工资20000, 正常21天全勤 → 全勤奖300
--   实际工资 = 20000 + 300 = 20300.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(6, '2026-04', 20000.00, 300.00, 0.00, 0.00, 0.00, 20300.00, '已发放', '2026-04-30 18:00:00');

-- 管理员(A001, id=7): 基本工资25000, 正常20天+迟到1天
--   迟到扣款 = 1 × (25000/21.75/8) = 143.68
--   实际工资 = 25000 - 143.68 = 24856.32
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(7, '2026-04', 25000.00, 0.00, 0.00, 143.68, 0.00, 24856.32, '已发放', '2026-04-30 18:00:00');


-- ==================== 2026年5月薪资数据 ====================
-- 张三(E001): 正常17天+迟到3天+早退1天, 病假2天(已批准)
--   迟到扣款 = 3 × (12000/21.75/8) = 206.90
--   请假扣款 = (12000/21.75) × 2 = 1103.45
--   实际工资 = 12000 - 206.90 - 1103.45 = 10689.65
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(1, '2026-05', 12000.00, 0.00, 0.00, 206.90, 1103.45, 10689.65, '已发放', '2026-05-31 18:00:00');

-- 李四(E002): 正常21天全勤 → 全勤奖300
--   实际工资 = 11000 + 300 = 11300.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(2, '2026-05', 11000.00, 300.00, 0.00, 0.00, 0.00, 11300.00, '已发放', '2026-05-31 18:00:00');

-- 王五(E003): 正常19天+迟到2天, 事假1天
--   迟到扣款 = 2 × (8000/21.75/8) = 91.95
--   请假扣款 = (8000/21.75) × 1 = 367.82
--   实际工资 = 8000 - 91.95 - 367.82 = 7540.23
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(3, '2026-05', 8000.00, 0.00, 0.00, 91.95, 367.82, 7540.23, '已发放', '2026-05-31 18:00:00');

-- 赵六(E004): 正常20天+迟到1天, 无请假
--   迟到扣款 = 1 × (9000/21.75/8) = 51.72
--   实际工资 = 9000 - 51.72 = 8948.28
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(4, '2026-05', 9000.00, 0.00, 0.00, 51.72, 0.00, 8948.28, '已发放', '2026-05-31 18:00:00');

-- 孙七(E005): 正常18天+迟到2天+早退2天, 年假3天(已批准，带薪不扣)
--   迟到扣款 = 2 × (15000/21.75/8) = 172.41
--   请假扣款 = 0 (年假带薪)
--   实际工资 = 15000 - 172.41 = 14827.59
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(5, '2026-05', 15000.00, 0.00, 0.00, 172.41, 0.00, 14827.59, '已发放', '2026-05-31 18:00:00');

-- 陈主管(M001): 正常20天+迟到1天
--   迟到扣款 = 1 × (20000/21.75/8) = 114.94
--   实际工资 = 20000 - 114.94 = 19885.06
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(6, '2026-05', 20000.00, 0.00, 0.00, 114.94, 0.00, 19885.06, '已发放', '2026-05-31 18:00:00');

-- 管理员(A001): 正常21天全勤 → 全勤奖300
--   实际工资 = 25000 + 300 = 25300.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(7, '2026-05', 25000.00, 300.00, 0.00, 0.00, 0.00, 25300.00, '已发放', '2026-05-31 18:00:00');


-- ==================== 2026年6月薪资数据 ====================
-- 张三(E001): 基本工资12000, 正常1天+迟到1天+早退1天, 年假3天(已批准)
--   迟到扣款 = 1 × (12000/21.75/8) = 68.97
--   请假扣款 = (12000/21.75) × 3 = 1655.17
--   实际工资 = 12000 - 68.97 - 1655.17 = 10275.86
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(1, '2026-06', 12000.00, 0.00, 0.00, 68.97, 1655.17, 10275.86, '未发放', NOW());

-- 李四(E002): 基本工资11000, 正常2天, 病假2天(待审批=不计入扣款)
--   迟到扣款 = 0
--   请假扣款 = 0 (待审批不扣)
--   全勤奖 = 300 (无迟到无请假)
--   实际工资 = 11000 + 300 = 11300.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(2, '2026-06', 11000.00, 300.00, 0.00, 0.00, 0.00, 11300.00, '未发放', NOW());

-- 王五(E003): 基本工资8000, 无考勤数据, 无请假
--   实际工资 = 8000.00
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(3, '2026-06', 8000.00, 0.00, 0.00, 0.00, 0.00, 8000.00, '未发放', NOW());

-- 赵六(E004): 基本工资9000, 无考勤数据, 无请假
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(4, '2026-06', 9000.00, 0.00, 0.00, 0.00, 0.00, 9000.00, '未发放', NOW());

-- 孙七(E005): 基本工资15000, 无考勤数据, 无请假
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(5, '2026-06', 15000.00, 0.00, 0.00, 0.00, 0.00, 15000.00, '未发放', NOW());

-- 陈主管(M001): 基本工资20000, 无考勤数据, 无请假
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(6, '2026-06', 20000.00, 0.00, 0.00, 0.00, 0.00, 20000.00, '未发放', NOW());

-- 管理员(A001): 基本工资25000, 无考勤数据, 无请假
INSERT INTO salary (emp_id, `year_month`, base_salary, attendance_bonus, overtime_pay, deduction_late, deduction_leave, actual_salary, status, generate_time) VALUES
(7, '2026-06', 25000.00, 0.00, 0.00, 0.00, 0.00, 25000.00, '已发放', NOW());


SELECT '薪资测试数据生成完成！' AS message;
SELECT `year_month`, COUNT(*) AS count, SUM(actual_salary) AS total FROM salary WHERE `year_month` IN ('2026-04','2026-05','2026-06') GROUP BY `year_month`;
