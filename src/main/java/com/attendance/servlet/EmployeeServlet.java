package com.attendance.servlet;

import com.attendance.entity.*;
import com.attendance.service.*;
import com.attendance.service.impl.*;

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
 * 员工端Servlet（三层架构: Servlet → Service → Mapper → DB）
 */
@WebServlet("/employee")
public class EmployeeServlet extends HttpServlet {

    private final AttendRecordService attendRecordService = new AttendRecordServiceImpl();
    private final LeaveRequestService leaveRequestService = new LeaveRequestServiceImpl();
    private final SalaryService salaryService = new SalaryServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
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

        String yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        Map<String, Object> stats = attendRecordService.countByStatus(emp.getId(), yearMonth);
        req.setAttribute("attendStats", stats);

        Map<String, Object> params = new HashMap<>();
        params.put("empId", emp.getId());
        List<AttendRecord> recentRecords = attendRecordService.findByConditions(params);
        if (recentRecords.size() > 5) recentRecords = recentRecords.subList(0, 5);
        req.setAttribute("recentRecords", recentRecords);

        req.getRequestDispatcher("/views/employee/dashboard.jsp").forward(req, resp);
    }

    /** 上班打卡 */
    private void clockIn(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        Date today = new Date(new java.util.Date().getTime());

        AttendRecord existing = attendRecordService.findByEmpAndDate(emp.getId(), today);
        if (existing != null && existing.getCheckInTime() != null) {
            req.setAttribute("msg", "今日已打卡！请勿重复操作。");
            req.setAttribute("msgType", "warning");
        } else {
            Timestamp now = new Timestamp(System.currentTimeMillis());

            AttendRecord record = new AttendRecord();
            record.setEmpId(emp.getId());
            record.setWorkDate(today);
            record.setCheckInTime(now);

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
                record.setId(existing.getId());
                attendRecordService.update(record);
            } else {
                attendRecordService.insert(record);
            }
        }

        dashboard(req, resp);
    }

    /** 下班打卡 */
    private void clockOut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        Date today = new Date(new java.util.Date().getTime());

        AttendRecord existing = attendRecordService.findByEmpAndDate(emp.getId(), today);

        if (existing == null || existing.getCheckInTime() == null) {
            req.setAttribute("msg", "请先完成上班打卡！");
            req.setAttribute("msgType", "warning");
        } else if (existing.getCheckOutTime() != null) {
            req.setAttribute("msg", "今日已完成上下班打卡！");
            req.setAttribute("msgType", "info");
        } else {
            Timestamp now = new Timestamp(System.currentTimeMillis());

            long diffMs = now.getTime() - existing.getCheckInTime().getTime();
            double hours = diffMs / (1000.0 * 60 * 60);
            BigDecimal workHours = BigDecimal.valueOf(hours).setScale(1, BigDecimal.ROUND_HALF_UP);

            Calendar cal = Calendar.getInstance();
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            String status = hour < 18 ? "早退" : "正常";

            existing.setCheckOutTime(now);
            existing.setStatus(status);
            existing.setWorkHours(workHours);
            attendRecordService.update(existing);

            req.setAttribute("msgType", status.equals("早退") ? "warning" : "success");
            req.setAttribute("msg", "下班打卡成功！今日工作" + workHours + "小时。" +
                    (status.equals("早退") ? "(注意：您早退了)" : ""));
        }

        dashboard(req, resp);
    }

    /** 查看月度考勤日历 */
    private void attendView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getCurrentUser(req);
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        List<AttendRecord> records = attendRecordService.findByEmpAndMonth(emp.getId(), yearMonth);
        Map<String, Object> stats = attendRecordService.countByStatus(emp.getId(), yearMonth);

        req.setAttribute("records", records);
        req.setAttribute("stats", stats);
        req.setAttribute("yearMonth", yearMonth);
        req.getRequestDispatcher("/views/employee/attend_view.jsp").forward(req, resp);
    }

    /** 提交请假申请 */
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

            leaveRequestService.insert(request);

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
        Map<String, Object> params = new HashMap<>();
        params.put("empId", emp.getId());

        int[] pageInfo = parsePageParams(req);
        params.put("offset", pageInfo[1]);
        params.put("limit", pageInfo[2]);

        List<LeaveRequest> list = leaveRequestService.findByConditions(params);
        int totalCount = leaveRequestService.countByConditions(params);

        req.setAttribute("leaveList", list);
        setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
        req.getRequestDispatcher("/views/employee/leave_list.jsp").forward(req, resp);
    }

    /** 撤销请假申请 */
    private void cancelLeave(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));
        leaveRequestService.cancel(id);
        resp.sendRedirect(req.getContextPath() + "/employee?action=leaveList");
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

    private int[] parsePageParams(HttpServletRequest req) {
        int page = 1;
        int pageSize = 10;
        try { page = Integer.parseInt(req.getParameter("page")); if (page < 1) page = 1; } catch (Exception e) {}
        try { pageSize = Integer.parseInt(req.getParameter("pageSize")); if (pageSize < 1) pageSize = 10; } catch (Exception e) {}
        int offset = (page - 1) * pageSize;
        return new int[]{page, offset, pageSize};
    }

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
