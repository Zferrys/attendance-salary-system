package com.attendance.service.impl;

import com.attendance.entity.Department;
import com.attendance.mapper.DepartmentMapper;
import com.attendance.service.DepartmentService;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

/**
 * 部门服务实现类
 *
 * 统一管理 SqlSession 生命周期，所有部门数据库操作均通过此服务。
 */
public class DepartmentServiceImpl implements DepartmentService {

    @Override
    public List<Department> findAll() {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(DepartmentMapper.class).findAll();
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
