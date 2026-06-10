package com.attendance.service.impl;

import com.attendance.entity.Employee;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.service.EmployeeService;
import com.attendance.utils.MyBatisUtils;
import com.attendance.utils.PasswordUtil;
import org.apache.ibatis.session.SqlSession;

/**
 * 员工服务实现类 - 安全增强版
 *
 * 使用PBKDF2密码哈希替代MD5，兼容旧数据。
 */
public class EmployeeServiceImpl implements EmployeeService {

    @Override
    public Employee loginByEmpNo(String empNo, String password) {
        SqlSession session = null;
        try {
            session = MyBatisUtils.getSession();
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            Employee emp = mapper.login(empNo);

            if (emp == null) {
                return null;
            }

            // 密码验证：优先PBKDF2，兼容旧MD5和明文
            if (PasswordUtil.verify(password, emp.getPassword())) {
                return emp;
            }
            return null;
        } catch (Exception e) {
            System.err.println("[登录] 数据库异常 (工号: " + empNo + "): " + e.getMessage());
            throw new RuntimeException("系统繁忙，请稍后再试", e);
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

    @Override
    public void updatePassword(Integer id, String newPassword) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            // 构造只包含id和password的Employee对象，复用update方法
            Employee emp = new Employee();
            emp.setId(id);
            emp.setPassword(newPassword);
            mapper.update(emp);
            session.commit();
        } catch (Exception e) {
            session.rollback();
            throw new RuntimeException("密码更新失败", e);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
