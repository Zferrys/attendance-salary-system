package com.attendance.service.impl;

import com.attendance.entity.AttendRecord;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.service.AttendRecordService;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 考勤记录服务实现类
 *
 * 统一管理 SqlSession 生命周期，所有考勤数据库操作均通过此服务。
 */
public class AttendRecordServiceImpl implements AttendRecordService {

    @Override
    public AttendRecord findByEmpAndDate(Integer empId, Date workDate) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).findByEmpAndDate(empId, workDate);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<AttendRecord> findByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).findByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int countByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).countByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public AttendRecord findById(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).findById(id);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<AttendRecord> findByEmpAndMonth(Integer empId, String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).findByEmpAndMonth(empId, yearMonth);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public Map<String, Object> countByStatus(Integer empId, String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(AttendRecordMapper.class).countByStatus(empId, yearMonth);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int insert(AttendRecord record) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(AttendRecordMapper.class).insert(record);
            session.commit();
            return rows;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int update(AttendRecord record) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(AttendRecordMapper.class).update(record);
            session.commit();
            return rows;
        } catch (Exception e) {
            session.rollback();
            throw new RuntimeException("考勤记录更新失败", e);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public boolean deleteById(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(AttendRecordMapper.class).deleteById(id);
            session.commit();
            return rows > 0;
        } catch (Exception e) {
            session.rollback();
            throw new RuntimeException("考勤记录删除失败", e);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
