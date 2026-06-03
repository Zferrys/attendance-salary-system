package com.attendance.entity;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * 请假申请实体类（持久化类）
 * 对应数据库表: leave_request
 *
 * 用途: 存储员工的请假申请信息及审批流程状态。
 *
 * 审批流程:
 *   1. 员工提交请假申请 → status = "待审批"
 *   2. 主管审批通过   → status = "已批准", 记录approver_id和approve_time
 *   3. 主管审批拒绝   → status = "已拒绝"
 *   4. 员工主动撤销   → status = "已撤销"
 *
 * 请假类型:
 *   - 事假: 扣除当日工资（日薪 × 天数）
 *   - 病假: 需提供证明，可能部分扣薪
 *   - 年假: 不扣薪资（有年假额度）
 */
public class LeaveRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请假单ID（主键，自增） */
    private Integer id;

    /** 申请人-员工ID（外键关联employee表） */
    private Integer empId;

    /**
     * 请假类型枚举:
     *   "事假" - 因私事请假（扣薪）
     *   "病假" - 因病请假
     *   "年假" - 年度带薪休假
     */
    private String leaveType;

    /** 请假开始日期 */
    private Date startDate;

    /** 请假结束日期 */
    private Date endDate;

    /** 请假天数 */
    private Integer days;

    /** 请假原因说明 */
    private String reason;

    /**
     * 审批状态枚举:
     *   "待审批" - 等待主管审核（默认）
     *   "已批准" - 主管同意
     *   "已拒绝" - 主管驳回
     *   "已撤销" - 申请人取消
     */
    private String status;

    /** 审批人ID（主管），外键关联employee表 */
    private Integer approverId;

    /** 审批时间 */
    private Timestamp approveTime;

    // ==================== 非数据库字段 ====================

    /** 申请人姓名（关联查询填充） */
    private String empName;
    
    /** 审批人姓名 */
    private String approverName;

    // ==================== 构造方法 ====================
    public LeaveRequest() {}

    public LeaveRequest(Integer empId, String leaveType, Date startDate,
                        Date endDate, Integer days, String reason) {
        this.empId = empId;
        this.leaveType = leaveType;
        this.startDate = startDate;
        this.endDate = endDate;
        this.days = days;
        this.reason = reason;
        this.status = "待审批"; // 新建默认为待审批
    }

    // ==================== Getter & Setter 方法 ====================
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getEmpId() { return empId; }
    public void setEmpId(Integer empId) { this.empId = empId; }

    public String getLeaveType() { return leaveType; }
    public void setLeaveType(String leaveType) { this.leaveType = leaveType; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public Integer getDays() { return days; }
    public void setDays(Integer days) { this.days = days; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getApproverId() { return approverId; }
    public void setApproverId(Integer approverId) { this.approverId = approverId; }

    public Timestamp getApproveTime() { return approveTime; }
    public void setApproveTime(Timestamp approveTime) { this.approveTime = approveTime; }

    public String getEmpName() { return empName; }
    public void setEmpName(String empName) { this.empName = empName; }

    public String getApproverName() { return approverName; }
    public void setApproverName(String approverName) { this.approverName = approverName; }

    @Override
    public String toString() {
        return "LeaveRequest{" +
                "id=" + id + ", empId=" + empId +
                ", leaveType='" + leaveType + '\'' +
                ", startDate=" + startDate + ", endDate=" + endDate +
                ", days=" + days + ", status='" + status + '\'' +
                '}';
    }
}
