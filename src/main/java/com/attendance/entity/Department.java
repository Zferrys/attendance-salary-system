package com.attendance.entity;

import java.io.Serializable;

/**
 * 部门实体类（持久化类）
 * 对应数据库表: department
 *
 * 用途: 存储公司的部门信息，作为员工表的关联数据。
 *       员工通过 dept_id 外键关联到此表。
 *
 * 字段说明:
 *   - id: 部门ID（主键，自增）
 *   - deptName: 部门名称（如：技术部、人事部）
 */
public class Department implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 部门ID（主键，自增） */
    private Integer id;

    /** 部门名称 */
    private String deptName;

    // ==================== 无参构造方法 ====================
    public Department() {}

    // ==================== 全参构造方法 ====================
    public Department(Integer id, String deptName) {
        this.id = id;
        this.deptName = deptName;
    }

    // ==================== Getter & Setter 方法 ====================

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getDeptName() {
        return deptName;
    }

    public void setDeptName(String deptName) {
        this.deptName = deptName;
    }

    // ==================== toString方法（便于调试输出） ====================
    @Override
    public String toString() {
        return "Department{" +
                "id=" + id +
                ", deptName='" + deptName + '\'' +
                '}';
    }
}
