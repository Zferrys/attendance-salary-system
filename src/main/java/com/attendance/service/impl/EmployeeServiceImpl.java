package com.attendance.service.impl;

import com.attendance.entity.Employee;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.service.EmployeeService;
import com.attendance.utils.MD5Util;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

/**
 * 员工服务实现类
 * 处理员工登录、信息查询等业务逻辑
 */
public class EmployeeServiceImpl implements EmployeeService {

    @Override
    public Employee login(String name, String password) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            // 先根据姓名查询员工
            Employee emp = mapper.loginByName(name);
            // 密码验证：先MD5比对（新数据），再明文比对（兼容旧数据）
            if (emp != null && MD5Util.verify(password, emp.getPassword())) {
                return emp;
            }
            return null;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public Employee findById(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            return mapper.findById(id);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
