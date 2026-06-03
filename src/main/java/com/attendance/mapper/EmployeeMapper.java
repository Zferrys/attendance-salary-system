package com.attendance.mapper;

import com.attendance.entity.Employee;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.Map;

/**
 * 员工Mapper接口
 * 对应XML映射文件: mapper/EmployeeMapper.xml
 *
 * 核心功能:
 *   - 员工登录验证（按工号+密码查询）
 *   - 员工信息CRUD（含部门关联）
 *   - @One 关联查询 DepartmentMapper
 *
 * 技术点: 使用注解方式和XML方式混合定义SQL
 */
public interface EmployeeMapper {

    /**
     * 员工登录：根据工号查询员工（密码验证在Service层进行）
     *
     * @param empNo 工号
     * @return 员工对象，不存在返回null
     */
    Employee login(@Param("empNo") String empNo);

    /**
     * 员工登录：根据姓名查询员工（密码验证在Service层进行）
     *
     * @param name 姓名
     * @return 员工对象，不存在返回null
     */
    Employee loginByName(@Param("name") String name);

    /**
     * 根据ID查询员工
     *
     * @param id 员工ID
     * @return 员工对象
     */
    Employee findById(@Param("id") Integer id);

    /**
     * 查询所有员工列表（含部门名称）
     * 使用@One关联DepartmentMapper获取部门详情
     *
     * @return 员工列表
     */
    List<Employee> findAllWithDept();

    /**
     * 【动态SQL】多条件组合查询员工
     * 支持按姓名、部门ID、职位等条件灵活组合查询
     * 使用@SelectProvider实现动态SQL生成
     *
     * @param params 查询条件Map，可包含：
     *               - name (String): 员工姓名（模糊匹配）
     *               - deptId (Integer): 部门ID
     *               - position (String): 职位
     * @return 符合条件的员工列表
     */
    List<Employee> findByConditions(Map<String, Object> params);

    /**
     * 新增员工
     *
     * @param employee 员工实体
     * @return 影响行数
     */
    int insert(Employee employee);

    /**
     * 更新员工基本信息
     *
     * @param employee 员工实体（需包含id）
     * @return 影响行数
     */
    int update(Employee employee);

    /**
     * 删除员工（逻辑删除：设置离职日期）
     *
     * @param id 员工ID
     * @return 影响行数
     */
    int deleteById(@Param("id") Integer id);

    /**
     * 查询指定部门的员工列表（主管查看团队用）
     *
     * @param deptId 部门ID
     * @return 该部门下的员工列表
     */
    List<Employee> findByDeptId(@Param("deptId") Integer deptId);

    /**
     * 查询指定前缀下的最大工号（用于自动生成工号）
     *
     * @param prefixLike 前缀模糊匹配，如 "E%"、"M%"、"A%"
     * @return 最大工号，没有则返回null
     */
    String findMaxEmpNoByPrefix(@Param("prefixLike") String prefixLike);
}
