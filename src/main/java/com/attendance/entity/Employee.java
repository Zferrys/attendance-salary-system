package com.attendance.entity;

import java.io.Serializable;
import java.sql.Date;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 员工实体类（持久化类）
 * 对应数据库表: employee
 *
 * 用途: 存储公司所有员工的基本信息，包括：
 *       - 基本信息（姓名、工号、密码）
 *       - 组织信息（部门、职位）
 *       - 薪资信息（基本工资）
 *       - 入职/离职时间
 *
 * 扩展字段（非数据库字段，用于关联查询结果）:
 *   - deptName: 关联的部门名称
 *   - department: 关联的Department对象
 *   - attendList: 当月考勤记录列表
 *   - salaryList: 薪资列表
 */
public class Employee implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 员工ID（主键，自增） */
    private Integer id;

    /** 员工工号（唯一标识，如 E001） */
    private String empNo;

    /** 员工姓名 */
    private String name;

    /** 登录密码 */
    private String password;

    /** 所属部门ID（外键关联department表） */
    private Integer deptId;

    /** 职位/岗位名称 */
    private String position;

    /** 角色：ADMIN管理员/MANAGER主管/EMPLOYEE员工 */
    private String role;

    /** 邮箱地址 */
    private String email;

    /** 基本工资（元/月） */
    private BigDecimal baseSalary;

    /** 入职日期 */
    private Date entryDate;

    /** 离职日期（NULL表示在职） */
    private Date leaveDate;

    // ==================== 非数据库字段：用于关联查询 ====================

    /** 部门名称（关联查询时由Mapper填充） */
    private String deptName;

    /** 部门对象（@One关联查询时填充） */
    private Department department;

    /** 考勤记录列表（用于展示员工考勤详情） */
    private List<AttendRecord> attendList;

    // ==================== 构造方法 ====================
    public Employee() {}

    public Employee(String empNo, String name, String password) {
        this.empNo = empNo;
        this.name = name;
        this.password = password;
    }

    // ==================== Getter & Setter 方法 ====================
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getEmpNo() { return empNo; }
    public void setEmpNo(String empNo) { this.empNo = empNo; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Integer getDeptId() { return deptId; }
    public void setDeptId(Integer deptId) { this.deptId = deptId; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public Date getEntryDate() { return entryDate; }
    public void setEntryDate(Date entryDate) { this.entryDate = entryDate; }

    public Date getLeaveDate() { return leaveDate; }
    public void setLeaveDate(Date leaveDate) { this.leaveDate = leaveDate; }

    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }

    public Department getDepartment() { return department; }
    public void setDepartment(Department department) { this.department = department; }

    public List<AttendRecord> getAttendList() { return attendList; }
    public void setAttendList(List<AttendRecord> attendList) { this.attendList = attendList; }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id + ", empNo='" + empNo + '\'' +
                ", name='" + name + '\'' +
                ", position='" + position + '\'' +
                ", baseSalary=" + baseSalary +
                ", deptName=" + deptName + '}';
    }
}
