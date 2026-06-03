package com.attendance.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * 薪资实体类（持久化类）
 * 对应数据库表: salary
 *
 * 用途: 记录员工每月的薪资计算结果和发放状态。
 *
 * 薪资计算规则（核心算法，在Service层实现）:
 *
 *   1. 应出勤天数 = 当月工作日数（排除周末和法定节假日）
 *   2. 实际出勤天数 = 正常打卡天数（status='正常'）
 *   3. 迟到扣款 = 迟到次数 × (基本工资 / 21.75 / 8 × 1小时)
 *      说明: 21.75 = 月平均工作日 = (365 - 104双休) / 12
 *   4. 请假扣款 = (基本工资 / 21.75) × 请假天数
 *   5. 全勤奖:
 *      - 条件: 无迟到、无请假、无缺勤 → 发放300元
 *      - 否则: 不发全勤奖
 *   6. 实际工资 = 基本工资 + 全勤奖 + 加班补贴 - 迟到扣款 - 请假扣款
 *
 * 发放状态流转:
 *   "未发放" → 管理员点击"薪资发放" → "已发放"（记录pay_time）
 */
public class Salary implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 薪资记录ID（主键，自增） */
    private Integer id;

    /** 员工ID（外键关联employee表） */
    private Integer empId;

    /**
     * 薪资月份，格式: "2026-06"
     * 联合唯一键的一部分：每人每月只有一条薪资记录
     */
    private String yearMonth;

    /** 当月基本工资（从employee.baseSalary复制或调整） */
    private BigDecimal baseSalary;

    /**
     * 全勤奖（默认0.00）
     * 满足全勤条件时发放300元
     */
    private BigDecimal attendanceBonus;

    /** 加班补贴（根据实际加班情况计算） */
    private BigDecimal overtimePay;

    /** 迟到扣款总额 */
    private BigDecimal deductionLate;

    /** 请假扣款总额 */
    private BigDecimal deductionLeave;

    /** 实际应发工资（最终到手金额） */
    private BigDecimal actualSalary;

    /**
     * 发放状态枚举:
     *   "未发放" - 薪资已计算但未发放（默认）
     *   "已发放" - 管理员确认发放完成
     */
    private String status;

    /** 薪资生成时间 */
    private Timestamp generateTime;

    /** 实际发放时间（发放时由系统自动记录） */
    private Timestamp payTime;

    // ==================== 非数据库字段 ====================

    /** 员工姓名（关联查询填充） */
    private String empName;
    
    /** 员工工号 */
    private String empNo;
    
    /** 部门名称 */
    private String deptName;
    
    /** 迟到次数（用于展示，非数据库字段） */
    private Integer lateCount;
    
    /** 缺勤次数 */
    private Integer absentCount;
    
    /** 请假总天数 */
    private Integer leaveDays;

    /** 关联的员工对象（用于嵌套查询） */
    private Employee employee;

    // ==================== 构造方法 ====================
    public Salary() {}

    public Salary(Integer empId, String yearMonth, BigDecimal baseSalary,
                  BigDecimal actualSalary, String status) {
        this.empId = empId;
        this.yearMonth = yearMonth;
        this.baseSalary = baseSalary;
        this.actualSalary = actualSalary;
        this.status = status;
    }

    // ==================== Getter & Setter 方法 ====================
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getEmpId() { return empId; }
    public void setEmpId(Integer empId) { this.empId = empId; }

    public String getYearMonth() { return yearMonth; }
    public void setYearMonth(String yearMonth) { this.yearMonth = yearMonth; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public BigDecimal getAttendanceBonus() { return attendanceBonus; }
    public void setAttendanceBonus(BigDecimal attendanceBonus) { this.attendanceBonus = attendanceBonus; }

    public BigDecimal getOvertimePay() { return overtimePay; }
    public void setOvertimePay(BigDecimal overtimePay) { this.overtimePay = overtimePay; }

    public BigDecimal getDeductionLate() { return deductionLate; }
    public void setDeductionLate(BigDecimal deductionLate) { this.deductionLate = deductionLate; }

    public BigDecimal getDeductionLeave() { return deductionLeave; }
    public void setDeductionLeave(BigDecimal deductionLeave) { this.deductionLeave = deductionLeave; }

    public BigDecimal getActualSalary() { return actualSalary; }
    public void setActualSalary(BigDecimal actualSalary) { this.actualSalary = actualSalary; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getGenerateTime() { return generateTime; }
    public void setGenerateTime(Timestamp generateTime) { this.generateTime = generateTime; }

    public Timestamp getPayTime() { return payTime; }
    public void setPayTime(Timestamp payTime) { this.payTime = payTime; }

    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }

    public String getEmpNo() { return empNo; }
    public void setEmpNo(String empNo) { this.empNo = empNo; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    public Integer getLateCount() { return lateCount; }
    public void setLateCount(Integer lateCount) { this.lateCount = lateCount; }

    public Integer getAbsentCount() { return absentCount; }
    public void setAbsentCount(Integer absentCount) { this.absentCount = absentCount; }

    public Integer getLeaveDays() { return leaveDays; }
    public void setLeaveDays(Integer leaveDays) { this.leaveDays = leaveDays; }

    public Employee getEmployee() { return employee; }
    public void setEmployee(Employee employee) { this.employee = employee; }

    @Override
    public String toString() {
        return "Salary{" +
                "id=" + id + ", empId=" + empId +
                ", yearMonth='" + yearMonth + '\'' +
                ", baseSalary=" + baseSalary +
                ", actualSalary=" + actualSalary +
                ", status='" + status + '\'' +
                '}';
    }
}
