package com.attendance.mapper;

import com.attendance.entity.LeaveRequest;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 请假申请Mapper接口
 * 对应XML映射文件: mapper/LeaveRequestMapper.xml
 *
 * 核心功能:
 *   - 请假申请的CRUD操作
 *   - 按状态筛选（待审批/已批准/已拒绝）
 *   - 主管审批（更新status、approver_id、approve_time）
 */
public interface LeaveRequestMapper {

    /**
     * 根据ID查询请假申请（含申请人姓名和审批人姓名）
     *
     * @param id 请假单ID
     * @return 请假对象，含关联信息
     */
    LeaveRequest findById(@Param("id") Integer id);

    /**
     * 【动态SQL】多条件查询请假申请列表（支持分页）
     *
     * 支持条件:
     *   - empId (Integer): 指定员工的请假记录
     *   - status (String): 筛选状态（待审批/已批准等）
     *   - approverId (Integer): 指定主管审批的记录
     *   - leaveType (String): 请假类型
     *   - offset (Integer): 分页偏移量
     *   - limit (Integer): 每页记录数
     *
     * @param params 条件Map
     * @return 请假列表
     */
    List<LeaveRequest> findByConditions(Map<String, Object> params);

    /**
     * 统计符合条件的请假记录总数
     * @param params 条件Map（与findByConditions使用相同的条件）
     * @return 记录总数
     */
    int countByConditions(Map<String, Object> params);

    /**
     * 新增请假申请
     *
     * @param request 请假实体
     * @return 影响行数
     */
    int insert(LeaveRequest request);

    /**
     * 主管审批：批准或拒绝请假申请
     * 更新 status + approver_id + approve_time
     *
     * @param id 请假单ID
     * @param status 审批结果（"已批准"/"已拒绝"）
     * @param approverId 审批人ID（主管ID）
     * @return 影响行数
     */
    int approve(@Param("id") Integer id, @Param("status") String status,
                @Param("approverId") Integer approverId);

    /**
     * 员工撤销自己的请假申请（仅限待审批状态的）
     *
     * @param id 请假单ID
     * @return 影响行数
     */
    int cancel(@Param("id") Integer id);
}
