-- 添加 email 字段到 employee 表
ALTER TABLE employee ADD COLUMN email VARCHAR(100) DEFAULT NULL COMMENT '邮箱' AFTER position;

-- 给 wzl (E006) 设置邮箱
UPDATE employee SET email = '3186649022@qq.com' WHERE emp_no = 'E006';
