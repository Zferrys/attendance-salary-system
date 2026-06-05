package com.attendance.servlet;

import com.attendance.entity.*;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.mapper.LeaveRequestMapper;
import com.attendance.service.SalaryService;
import com.attendance.service.impl.SalaryServiceImpl;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 员工端Servlet（员工功能控制器）
 *
 * 用途: 处理员工端的所有请求，通过action参数分发到不同方法
 *
 * 功能模块:
 *   - dashboard:    员工首页仪表盘
 *   - clockIn:      上班打卡
 *   - clockOut:     下班打卡
 *   - attendView:   查看考勤日历
 *   - applyLeave:   提交请假申请
 *   - leaveList:    查看请假记录
 *   - salaryView:   查看薪资详情
 *
 * 请求映射: /employee
 */
@WebServlet("/employee")
public class EmployeeServlet extends HttpServlet {

    private SalaryService salaryService = new SalaryServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        
        try {
            // 通过反射分发请求到对应的处理方法
            if (action == null || action.isEmpty()) {
                dashboard(req, resp);
                return;
            }
            
            switch (action) {
                case "dashboard":   dashboard(req, resp); break;
                case "clockIn":     clockIn(req, resp); break;
                case "clockOut":    clockOut(req, resp); break;
                case "attendView":  attendView(req, resp); break;
                case "applyLeave":  applyLeave(req, resp); break;
                case "leaveList":   leaveList(req, resp); break;
                case "salaryView":  salaryView(req, resp); break;
                case "cancelLeave": cancelLeave(req, resp); break;
                default:            dashboard(req, resp); break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "操作失败：" + e.getMessage());
            req.getRequestDispatcher("/views/employee/dashboard.jsp").forward(req, resp);
        }
    }

    /** 员工首页仪表盘 */
    private void dashboard(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper attendMapper = session.getMapper(AttendRecordMapper.class);
            
            // 获取当月考勤统计
            String yearMonth = new SimpleDateFormat("yyyy-MM").format(new Date(System.currentTimeMillis()));
            Map<String, Object> stats = attendMapper.countByStatus(emp.getId(), yearMonth);
            req.setAttribute("attendStats", stats);

            // 获取最近5条考勤记录
            Map<String, Object> params = new HashMap<>();
            params.put("empId", emp.getId());
            List<AttendRecord> recentRecords = attendMapper.findByConditions(params);
            if (recentRecords.size() > 5) recentRecords = recentRecords.subList(0, 5);
            req.setAttribute("recentRecords", recentRecords);

            req.getRequestDispatcher("/views/employee/dashboard.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 【核心】上班打卡
     * 业务逻辑：
     *   1. 查询今天是否已有考勤记录
     *   2. 有记录 → 已打过卡，提示错误
     *   3. 无记录 → INSERT新记录，判断是否迟到（>=9:00为迟到）
     */
    private void clockIn(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        Date today = new Date(new java.util.Date().getTime());
        
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);

            // 检查今日是否已打卡
            AttendRecord existing = mapper.findByEmpAndDate(emp.getId(), today);
            if (existing != null && existing.getCheckInTime() != null) {
                req.setAttribute("msg", "今日已打卡！请勿重复操作。");
                req.setAttribute("msgType", "warning");
            } else {
                Timestamp now = new Timestamp(System.currentTimeMillis());
                
                AttendRecord record = new AttendRecord();
                record.setEmpId(emp.getId());
                record.setWorkDate(today);
                record.setCheckInTime(now);
                
                // 判断是否迟到：9点之后算迟到
                Calendar cal = Calendar.getInstance();
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                if (hour >= 9) {
                    record.setStatus("迟到");
                    req.setAttribute("msgType", "warning");
                    req.setAttribute("msg", "打卡成功！但您迟到了。");
                } else {
                    record.setStatus("正常");
                    req.setAttribute("msgType", "success");
                    req.setAttribute("msg", "上班打卡成功！加油！");
                }

                if (existing != null) {
                    // 已有下班签退记录但无上班记录（异常情况），更新
                    record.setId(existing.getId());
                    mapper.update(record);
                } else {
                    mapper.insert(record);
                }
                session.commit();
            }
            
            dashboard(req, resp); // 打完卡回到首页
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 下班打卡
     * 业务逻辑：
     *   1. 查询今天的记录
     *   2. 已有记录且无下班时间 → UPDATE更新下班时间和状态
     *   3. 判断早退：18:00之前离开算早退
     */
    private void clockOut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        Date today = new Date(new java.util.Date().getTime());

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            AttendRecord existing = mapper.findByEmpAndDate(emp.getId(), today);

            if (existing == null || existing.getCheckInTime() == null) {
                req.setAttribute("msg", "请先完成上班打卡！");
                req.setAttribute("msgType", "warning");
            } else if (existing.getCheckOutTime() != null) {
                req.setAttribute("msg", "今日已完成上下班打卡！");
                req.setAttribute("msgType", "info");
            } else {
                Timestamp now = new Timestamp(System.currentTimeMillis());
                
                // 计算工作时长（小时）
                long diffMs = now.getTime() - existing.getCheckInTime().getTime();
                double hours = diffMs / (1000.0 * 60 * 60);
                BigDecimal workHours = BigDecimal.valueOf(hours).setScale(1, BigDecimal.ROUND_HALF_UP);

                // 判断早退：18点之前下班
                Calendar cal = Calendar.getInstance();
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                String status = hour < 18 ? "早退" : "正常";
                
                existing.setCheckOutTime(now);
                existing.setStatus(status);
                existing.setWorkHours(workHours);
                mapper.update(existing);
                session.commit();

                req.setAttribute("msgType", status.equals("早退") ? "warning" : "success");
                req.setAttribute("msg", "下班打卡成功！今日工作" + workHours + "小时。" +
                        (status.equals("早退") ? "(注意：您早退了)" : ""));
            }
            
            dashboard(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 查看月度考勤日历 */
    private void attendView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            List<AttendRecord> records = mapper.findByEmpAndMonth(emp.getId(), yearMonth);
            Map<String, Object> stats = mapper.countByStatus(emp.getId(), yearMonth);
            
            req.setAttribute("records", records);
            req.setAttribute("stats", stats);
            req.setAttribute("yearMonth", yearMonth);
            req.getRequestDispatcher("/views/employee/attend_view.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 提交请假申请
     * 参数: leaveType, startDate, endDate, days, reason
     */
    private void applyLeave(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        String leaveType = req.getParameter("leaveType");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");
        String reason = req.getParameter("reason");

        if (leaveType == null || startDateStr == null || endDateStr == null ||
            reason == null || reason.trim().isEmpty()) {
            req.setAttribute("errorMsg", "请完整填写请假信息！");
            req.getRequestDispatcher("/views/employee/apply_leave.jsp").forward(req, resp);
            return;
        }

        try {
            Date start = Date.valueOf(startDateStr);
            Date end = Date.valueOf(endDateStr);
            long days = (end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000) + 1;

            LeaveRequest request = new LeaveRequest();
            request.setEmpId(emp.getId());
            request.setLeaveType(leaveType);
            request.setStartDate(start);
            request.setEndDate(end);
            request.setDays((int) days);
            request.setReason(reason.trim());

            SqlSession session = MyBatisUtils.getSession();
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            mapper.insert(request);
            session.commit();
            MyBatisUtils.closeSession(session);

            req.setAttribute("msgType", "success");
            req.setAttribute("msg", "请假申请提交成功，等待主管审批！");
            leaveList(req, resp);
        } catch (Exception e) {
            req.setAttribute("errorMsg", "提交失败：" + e.getMessage());
            req.getRequestDispatcher("/views/employee/apply_leave.jsp").forward(req, resp);
        }
    }

    /** 查看自己的请假列表（支持分页） */
    private void leaveList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        SqlSession session = MyBatisUtils.getSession();
        try {
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            Map<String, Object> params = new HashMap<>();
            params.put("empId", emp.getId());
            
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);
            
            List<LeaveRequest> list = mapper.findByConditions(params);
            int totalCount = mapper.countByConditions(params);
            
            req.setAttribute("leaveList", list);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            req.getRequestDispatcher("/views/employee/leave_list.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 撤销请假申请 */
    private void cancelLeave(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));
        SqlSession session = MyBatisUtils.getSession();
        try {
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            mapper.cancel(id);
            session.commit();
            resp.sendRedirect(req.getContextPath() + "/employee?action=leaveList");
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 查看薪资详情 */
    private void salaryView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        Salary salary = salaryService.findByEmpAndMonth(emp.getId(), yearMonth);
        req.setAttribute("salary", salary);
        req.setAttribute("yearMonth", yearMonth);
        req.getRequestDispatcher("/views/employee/salary_view.jsp").forward(req, resp);
    }

    // ==================== 工具方法 ====================

    /**
     * 解析分页参数
     * @return int[3]: [page, offset, pageSize]
     */
    private int[] parsePageParams(HttpServletRequest req) {
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(req.getParameter("page")); if (page < 1) page = 1; } catch (Exception e) {}
        try { pageSize = Integer.parseInt(req.getParameter("pageSize")); if (pageSize < 1) pageSize = 10; } catch (Exception e) {}
        int offset = (page - 1) * pageSize;
        return new int[]{page, offset, pageSize};
    }

    /**
     * 设置分页属性到 request
     */
    private void setPageAttributes(HttpServletRequest req, int page, int pageSize, int totalCount) {
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("totalPages", (int) Math.ceil((double) totalCount / pageSize));
    }

    private Employee getCurrentUser(HttpServletRequest req) {
        return (Employee) req.getSession().getAttribute("currentUser");
    }
}
