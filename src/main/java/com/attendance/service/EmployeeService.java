package com.attendance.service;

import com.attendance.entity.Employee;

import java.util.List;
import java.util.Map;

/**
 * 员工服务接口
 *
 * 封装员工登录、CRUD、查询等全部业务逻辑。
 */
public interface EmployeeService {
    /** 员工登录验证（按工号） */
    Employee loginByEmpNo(String empNo, String password);
    /** 根据ID查询 */
    Employee findById(Integer id);
    /** 更新用户密码 */
    void updatePassword(Integer id, String newPassword);
    /** 查询所有员工（含部门信息） */
    List<Employee> findAllWithDept();
    /** 多条件组合查询（支持分页） */
    List<Employee> findByConditions(Map<String, Object> params);
    /** 统计符合条件的员工数 */
    int countByConditions(Map<String, Object> params);
    /** 新增员工 */
    int insert(Employee employee);
    /** 更新员工信息 */
    int update(Employee employee);
    /** 删除员工（逻辑删除） */
    boolean deleteById(Integer id);
    /** 查询指定前缀的最大工号 */
    String findMaxEmpNoByPrefix(String prefixLike);
}
