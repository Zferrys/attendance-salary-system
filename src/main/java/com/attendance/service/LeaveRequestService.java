package com.attendance.service;

import com.attendance.entity.LeaveRequest;

import java.util.List;
import java.util.Map;

/**
 * 请假申请服务接口
 *
 * 封装请假申请提交、查询、审批、撤销等业务逻辑。
 */
public interface LeaveRequestService {

    /** 多条件查询（支持分页） */
    List<LeaveRequest> findByConditions(Map<String, Object> params);

    /** 统计符合条件的记录数 */
    int countByConditions(Map<String, Object> params);

    /** 提交请假申请 */
    int insert(LeaveRequest request);

    /** 主管审批（批准或拒绝） */
    boolean approve(Integer id, String status, Integer approverId);

    /** 员工撤销请假申请 */
    boolean cancel(Integer id);
}
