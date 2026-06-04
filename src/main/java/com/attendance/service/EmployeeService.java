package com.attendance.service;

import com.attendance.entity.Employee;

/**
 * 员工服务接口
 */
public interface EmployeeService {
    /** 员工登录验证（按工号） */
    Employee loginByEmpNo(String empNo, String password);
    /** 根据ID查询 */
    Employee findById(Integer id);
}
