package com.attendance.service;

import com.attendance.entity.Employee;

/**
 * 员工服务接口
 */
public interface EmployeeService {
    /** 员工登录验证（按姓名） */
    Employee login(String name, String password);
    /** 根据ID查询 */
    Employee findById(Integer id);
}
