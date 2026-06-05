package com.attendance.service;

import com.attendance.entity.Salary;

import java.util.List;
import java.util.Map;

/**
 * 薪资服务接口
 *
 * 用途: 定义薪资管理的所有业务方法，包括：
 *       - 薪资计算与生成
 *       - 薪资发放（标记状态）
 *       - 薪资查询与统计
 *       - 报表数据导出
 */
public interface SalaryService {

    /**
     * 为所有员工生成指定月份的薪资记录
     * 【核心算法】包含完整的薪资计算规则：
     *   1. 基本工资 = employee.baseSalary
     *   2. 迟到扣款 = 迟到次数 × (基本工资 / 21.75 / 8)
     *   3. 请假扣款 = (基本工资 / 21.75) × 已批准的请假天数
     *   4. 全勤奖 = 无迟到+无请假+无缺勤 ? 300 : 0
     *   5. 实际工资 = 基本工资 + 全勤奖 - 迟到扣款 - 请假扣款
     *
     * @param yearMonth 年月字符串（如 "2026-06"）
     * @return 生成的薪资记录数量
     */
    int generateMonthlySalaries(String yearMonth);

    /**
     * 发放指定薪资记录（更新状态为已发放）
     *
     * @param id 薪资记录ID
     * @return true=成功, false=失败或状态不正确
     */
    boolean paySalary(Integer id);

    /**
     * 查询所有薪资记录（含关联信息：员工姓名、部门）
     * 使用@One/@Many关联查询获取完整数据
     *
     * @return 薪资列表
     */
    List<Salary> findAll();

    /**
     * 查询指定月份的所有薪资记录
     *
     * @param yearMonth 年月
     * @return 该月的薪资列表
     */
    List<Salary> findByMonth(String yearMonth);

    /**
     * 分页查询指定月份的薪资记录
     *
     * @param yearMonth 年月
     * @param offset 偏移量
     * @param limit 每页条数
     * @return 该月的薪资分页列表
     */
    List<Salary> findByMonthPaged(String yearMonth, int offset, int limit);

    /**
     * 统计指定月份的薪资记录总数
     *
     * @param yearMonth 年月
     * @return 记录总数
     */
    int countByMonth(String yearMonth);

    /**
     * 根据ID查询单条薪资详情（含完整关联信息）
     *
     * @param id 薪资记录ID
     * @return 薪资对象
     */
    Salary findById(Integer id);

    /**
     * 根据员工ID和月份查询薪资记录（每人每月唯一）
     *
     * @param empId     员工ID
     * @param yearMonth 年月（如 "2026-06"）
     * @return 薪资对象，不存在返回null
     */
    Salary findByEmpAndMonth(Integer empId, String yearMonth);

    /**
     * 导出月度薪资报表数据
     * 包含每位员工的详细薪资明细和考勤汇总
     *
     * @param yearMonth 年月
     * @return 报表数据列表
     */
    List<Map<String, Object>> getSalaryReport(String yearMonth);
}
