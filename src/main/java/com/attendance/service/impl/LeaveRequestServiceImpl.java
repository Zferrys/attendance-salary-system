package com.attendance.service.impl;

import com.attendance.entity.LeaveRequest;
import com.attendance.mapper.LeaveRequestMapper;
import com.attendance.service.LeaveRequestService;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

/**
 * 请假申请服务实现类
 *
 * 统一管理 SqlSession 生命周期，所有请假数据库操作均通过此服务。
 */
public class LeaveRequestServiceImpl implements LeaveRequestService {

    @Override
    public List<LeaveRequest> findByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(LeaveRequestMapper.class).findByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int countByConditions(Map<String, Object> params) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            return session.getMapper(LeaveRequestMapper.class).countByConditions(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int insert(LeaveRequest request) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(LeaveRequestMapper.class).insert(request);
            session.commit();
            return rows;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public boolean approve(Integer id, String status, Integer approverId) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(LeaveRequestMapper.class).approve(id, status, approverId);
            session.commit();
            return rows > 0;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public boolean cancel(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            int rows = session.getMapper(LeaveRequestMapper.class).cancel(id);
            session.commit();
            return rows > 0;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
