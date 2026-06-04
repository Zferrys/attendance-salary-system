package com.attendance.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * 考勤记录实体类（持久化类）
 * 对应数据库表: attend_record
 *
 * 用途: 记录员工每天的打卡签到/签退情况。
 *       每个员工每天只能有一条考勤记录（由联合唯一键约束）。
 *
 * 核心业务逻辑:
 *   - 打卡判断：每天只能打卡2次（上班+下班），需检查是否已打卡
 *   - 状态判定：
 *     * 上班时间 >= 09:00 → 迟到
 *     * 下班时间 <= 18:00 → 早退
 *     * 两者都正常 → 正常
 *     * 无记录 → 缺勤
 *
 * 字段说明:
 *   - empId: 员工ID
 *   - workDate: 工作日期
 *   - checkInTime / checkOutTime: 上下班打卡时间
 *   - status: 考勤状态枚举（正常/迟到/早退/缺勤）
 */
public class AttendRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 记录ID（主键，自增） */
    private Integer id;

    /** 员工ID（外键关联employee表） */
    private Integer empId;

    /** 工作日期（如 2026-06-02） */
    private Date workDate;

    /** 上班打卡时间（如 2026-06-02 08:55:00） */
    private Timestamp checkInTime;

    /** 下班打卡时间 */
    private Timestamp checkOutTime;

    /**
     * 当日考勤状态:
     *   "正常" - 按时上下班
     *   "迟到" - 上班超过9点
     *   "早退" - 下班早于18点
     *   "缺勤" - 无打卡记录
     */
    private String status;

    /** 实际工作时长（小时），默认0.0 */
    private BigDecimal workHours;

    // ==================== 非数据库字段：用于关联查询 ====================
    
    /** 员工姓名（关联查询填充） */
    private String empName;
    
    /** 员工工号 */
    private String empNo;

    /** 部门名称（关联查询填充） */
    private String deptName;

    // ==================== 构造方法 ====================
    public AttendRecord() {}

    public AttendRecord(Integer empId, Date workDate, Timestamp checkInTime,
                        Timestamp checkOutTime, String status, BigDecimal workHours) {
        this.empId = empId;
        this.workDate = workDate;
        this.checkInTime = checkInTime;
        this.checkOutTime = checkOutTime;
        this.status = status;
        this.workHours = workHours;
    }

    // ==================== Getter & Setter 方法 ====================

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getEmpId() { return empId; }
    public void setEmpId(Integer empId) { this.empId = empId; }

    public Date getWorkDate() { return workDate; }
    public void setWorkDate(Date workDate) { this.workDate = workDate; }

    public Timestamp getCheckInTime() { return checkInTime; }
    public void setCheckInTime(Timestamp checkInTime) { this.checkInTime = checkInTime; }

    public Timestamp getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(Timestamp checkOutTime) { this.checkOutTime = checkOutTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getWorkHours() { return workHours; }
    public void setWorkHours(BigDecimal workHours) { this.workHours = workHours; }

    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }

    public String getEmpNo() { return empNo; }
    public void setEmpNo(String empNo) { this.empNo = empNo; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    @Override
    public String toString() {
        return "AttendRecord{" +
                "id=" + id + ", empId=" + empId +
                ", workDate=" + workDate +
                ", status='" + status + '\'' +
                ", workHours=" + workHours +
                '}';
    }
}
