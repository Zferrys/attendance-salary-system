package com.attendance.service;

import com.attendance.entity.Department;

import java.util.List;

/**
 * 部门服务接口
 *
 * 封装部门相关的查询操作。
 */
public interface DepartmentService {

    /** 查询所有部门列表 */
    List<Department> findAll();
}
