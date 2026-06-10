package com.attendance.service.impl;

import com.attendance.entity.Employee;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.service.EmployeeService;
import com.attendance.utils.MyBatisUtils;
import com.attendance.utils.PasswordUtil;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

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

    @Override
    public List<Employee> findAllWithDept() {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(EmployeeMapper.class).findAllWithDept();
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<Employee> findByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(EmployeeMapper.class).findByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int countByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(EmployeeMapper.class).countByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int insert(Employee employee) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(EmployeeMapper.class).insert(employee);
            session.commit();
            return rows;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int update(Employee employee) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(EmployeeMapper.class).update(employee);
            session.commit();
            return rows;
        } catch (Exception e) {
            session.rollback();
            throw new RuntimeException("员工信息更新失败", e);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public boolean deleteById(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(EmployeeMapper.class).deleteById(id);
            session.commit();
            return rows > 0;
        } catch (Exception e) {
            session.rollback();
            throw new RuntimeException("员工删除失败", e);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public String findMaxEmpNoByPrefix(String prefixLike) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(EmployeeMapper.class).findMaxEmpNoByPrefix(prefixLike);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
