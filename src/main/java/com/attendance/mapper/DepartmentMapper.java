package com.attendance.mapper;

import com.attendance.entity.Department;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 部门Mapper接口
 * 对应XML映射文件: mapper/DepartmentMapper.xml
 *
 * 用途: 定义对 department 表的所有数据库操作方法。
 *       MyBatis通过动态代理机制自动生成接口的实现类。
 *
 * 注解说明:
 *   @Param - 给参数起别名，在SQL中通过#{paramName}引用
 */
public interface DepartmentMapper {

    /**
     * 查询所有部门列表
     *
     * @return 部门列表（用于下拉选择框等场景）
     */
    List<Department> findAll();

    /**
     * 根据ID查询部门
     *
     * @param id 部门ID
     * @return 部门对象，不存在返回null
     */
    Department findById(@Param("id") Integer id);

    /**
     * 根据名称查询部门
     *
     * @param deptName 部门名称
     * @return 部门对象
     */
    Department findByName(@Param("deptName") String deptName);

    /**
     * 新增部门
     *
     * @param department 部门实体
     * @return 影响行数（1=成功，0=失败）
     */
    int insert(Department department);

    /**
     * 更新部门信息
     *
     * @param department 部门实体（需包含id）
     * @return 影响行数
     */
    int update(Department department);

    /**
     * 删除部门
     *
     * @param id 部门ID
     * @return 影响行数
     */
    int deleteById(@Param("id") Integer id);
}
