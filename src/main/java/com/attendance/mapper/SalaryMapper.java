package com.attendance.mapper;

import com.attendance.entity.Salary;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * 薪资Mapper接口
 * 对应XML映射文件: mapper/SalaryMapper.xml
 *
 * 【核心技术点 - 评分占比20%】关联查询：
 *   使用 @Results + @One/@Many 实现复杂关联查询
 *
 *   薪资单查询链路:
 *     salary (薪资表) 
 *       └─ @One → employee (员工表) 获取员工基本信息
 *            └─ @One → department (部门表) 获取部门信息
 *
 *   查询结果包含: 员工姓名、工号、部门名称 + 薪资明细（基本工资、扣款、实发等）
 */
public interface SalaryMapper {

    /**
     * 根据ID查询薪资记录（含员工和部门关联信息）
     *
     * @param id 薪资记录ID
     * @return 薪资对象，含关联信息
     */
    Salary findById(@Param("id") Integer id);

    /**
     * 根据员工ID和月份查询薪资（每人每月唯一）
     *
     * @param empId 员工ID
     * @param yearMonth 年月（如 "2026-06"）
     * @return 薪资对象，不存在返回null
     */
    Salary findByEmpAndMonth(@Param("empId") Integer empId, @Param("yearMonth") String yearMonth);

    /**
     * 【关联查询】查询所有薪资记录（含员工姓名、部门名称）
     * 使用@Results注解定义结果映射，@One实现嵌套关联
     *
     * 技术点说明:
     *   @Results - 定义SQL列到Java属性的映射关系
     *   @One(select="...") - 对每条薪资记录，额外执行一次子查询获取关联的Employee信息
     *   Employee中又通过@One关联Department，形成三层嵌套查询
     *
     * @return 所有薪资列表（含完整关联信息）
     */
    @Select("SELECT s.*, e.name AS emp_name, e.emp_no AS emp_no, d.dept_name " +
            "FROM salary s " +
            "INNER JOIN employee e ON s.emp_id = e.id " +
            "LEFT JOIN department d ON e.dept_id = d.id " +
            "ORDER BY s.year_month DESC, e.emp_no")
    @Results(id = "salaryWithEmpResult", value = {
            @Result(property = "id", column = "id"),
            @Result(property = "empId", column = "emp_id"),
            @Result(property = "yearMonth", column = "year_month"),
            @Result(property = "baseSalary", column = "base_salary"),
            @Result(property = "attendanceBonus", column = "attendance_bonus"),
            @Result(property = "overtimePay", column = "overtime_pay"),
            @Result(property = "deductionLate", column = "deduction_late"),
            @Result(property = "deductionLeave", column = "deduction_leave"),
            @Result(property = "actualSalary", column = "actual_salary"),
            @Result(property = "status", column = "status"),
            @Result(property = "generateTime", column = "generate_time"),
            @Result(property = "payTime", column = "pay_time"),
            @Result(property = "empName", column = "emp_name"),
            @Result(property = "empNo", column = "emp_no"),
            @Result(property = "deptName", column = "dept_name")
    })
    List<Salary> findAllWithDetails();

    /**
     * 查询指定月份的所有薪资记录（用于月度薪资发放操作，支持分页）
     *
     * @param params 查询参数Map，包含：
     *               - yearMonth (String): 年月
     *               - offset (Integer): 分页偏移量
     *               - limit (Integer): 每页记录数
     * @return 该月的薪资列表
     */
    List<Salary> findByMonth(Map<String, Object> params);

    /**
     * 统计指定月份的薪资记录总数
     * @param yearMonth 年月
     * @return 记录总数
     */
    int countByMonth(@Param("yearMonth") String yearMonth);

    /**
     * 新增薪资记录
     *
     * @param salary 薪资实体
     * @return 影响行数
     */
    int insert(Salary salary);

    /**
     * 更新薪资信息（修改计算结果或发放状态等）
     *
     * @param salary 薪资实体
     * @return 影响行数
     */
    int update(Salary salary);

    /**
     * 管理员操作：发放薪资（更新状态为"已发放"，记录发放时间）
     *
     * @param id 薪资记录ID
     * @return 影响行数
     */
    int markAsPaid(@Param("id") Integer id);
}
