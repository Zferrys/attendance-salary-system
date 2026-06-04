package com.attendance.servlet;

import com.attendance.entity.*;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.mapper.LeaveRequestMapper;
import com.attendance.service.SalaryService;
import com.attendance.service.impl.SalaryServiceImpl;
import com.attendance.utils.MD5Util;
import com.attendance.utils.MyBatisUtils;
import com.google.gson.Gson;
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
 * 打卡小程序 H5 端控制器
 * 
 * 用途: 为移动端 H5 打卡小程序提供 API 接口和页面渲染
 * 
 * 功能模块:
 *   - /miniapp → 登录页
 *   - /miniapp?action=login → 登录验证（JSON）
 *   - /miniapp?action=clock → 打卡页面（主界面）
 *   - /miniapp?action=clockIn → 上班打卡（JSON）
 *   - /miniapp?action=clockOut → 下班打卡（JSON）
 *   - /miniapp?action=todayStatus → 查询今日状态（JSON）
 *   - /miniapp?action=records → 考勤记录页面
 *   - /miniapp?action=monthRecords → 月度记录（JSON）
 * 
 * 请求映射: /miniapp
 */
@WebServlet("/miniapp")
public class MiniAppServlet extends HttpServlet {

    private SalaryService salaryService = new SalaryServiceImpl();
    private static final Gson gson = new Gson();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        String action = req.getParameter("action");

        try {
            if (action == null || action.isEmpty()) {
                showLoginPage(req, resp);
                return;
            }

            switch (action) {
                case "login":
                    doLogin(req, resp);
                    break;
                case "clock":
                    showClockPage(req, resp);
                    break;
                case "clockIn":
                    doClockIn(req, resp);
                    break;
                case "clockOut":
                    doClockOut(req, resp);
                    break;
                case "todayStatus":
                    getTodayStatus(req, resp);
                    break;
                case "records":
                    showRecordsPage(req, resp);
                    break;
                case "monthRecords":
                    getMonthRecords(req, resp);
                    break;
                case "logout":
                    doLogout(req, resp);
                    break;
                case "my":
                    showMyPage(req, resp);
                    break;
                case "leaveApply":
                    showLeaveApplyPage(req, resp);
                    break;
                case "submitLeave":
                    doSubmitLeave(req, resp);
                    break;
                case "salary":
                    showSalaryPage(req, resp);
                    break;
                case "salaryData":
                    getSalaryData(req, resp);
                    break;
                default:
                    showLoginPage(req, resp);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setContentType("application/json;charset=UTF-8");
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            resp.getWriter().write(gson.toJson(result));
        }
    }

    /** 显示登录页面 */
    private void showLoginPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/miniapp/login.jsp").forward(req, resp);
    }

    /** 显示打卡主页面 */
    private void showClockPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/miniapp");
            return;
        }
        req.setAttribute("user", emp);
        req.getRequestDispatcher("/views/miniapp/clock.jsp").forward(req, resp);
    }

    /** 显示考勤记录页面 */
    private void showRecordsPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/miniapp");
            return;
        }
        req.setAttribute("user", emp);
        req.getRequestDispatcher("/views/miniapp/records.jsp").forward(req, resp);
    }

    /** 登录验证（返回JSON） */
    private void doLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        String empNo = req.getParameter("empNo");
        String password = req.getParameter("password");

        if (empNo == null || empNo.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "请输入工号和密码！");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            Employee emp = mapper.login(empNo.trim());

            if (emp != null && MD5Util.verify(password.trim(), emp.getPassword())) {
                // 登录成功：存入 session 和返回用户信息
                req.getSession().setAttribute("miniAppUser", emp);
                
                result.put("success", true);
                result.put("message", "登录成功");
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", emp.getId());
                userInfo.put("empNo", emp.getEmpNo());
                userInfo.put("name", emp.getName());
                userInfo.put("position", emp.getPosition());
                result.put("user", userInfo);
            } else {
                result.put("success", false);
                result.put("message", "工号或密码错误！");
            }
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 上班打卡（返回JSON） */
    private void doClockIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("message", "请先登录！");
            result.put("needLogin", true);
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        Date today = new Date(new java.util.Date().getTime());
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            AttendRecord existing = mapper.findByEmpAndDate(emp.getId(), today);

            if (existing != null && existing.getCheckInTime() != null) {
                result.put("success", false);
                result.put("message", "今日已打卡，请勿重复操作！");
                result.put("alreadyClockedIn", true);
            } else {
                Timestamp now = new Timestamp(System.currentTimeMillis());
                AttendRecord record = new AttendRecord();
                record.setEmpId(emp.getId());
                record.setWorkDate(today);
                record.setCheckInTime(now);

                Calendar cal = Calendar.getInstance();
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                int minute = cal.get(Calendar.MINUTE);

                if (hour >= 9) {
                    record.setStatus("迟到");
                    result.put("isLate", true);
                    result.put("message", "打卡成功！但您迟到了。");
                } else {
                    record.setStatus("正常");
                    result.put("message", "打卡成功！新的一天加油！");
                }

                if (existing != null) {
                    record.setId(existing.getId());
                    mapper.update(record);
                } else {
                    mapper.insert(record);
                }
                session.commit();

                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
                result.put("success", true);
                result.put("time", sdf.format(now));
                result.put("status", record.getStatus());
            }
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 下班打卡（返回JSON） */
    private void doClockOut(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("message", "请先登录！");
            result.put("needLogin", true);
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        Date today = new Date(new java.util.Date().getTime());
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            AttendRecord existing = mapper.findByEmpAndDate(emp.getId(), today);

            if (existing == null || existing.getCheckInTime() == null) {
                result.put("success", false);
                result.put("message", "请先完成上班打卡！");
            } else if (existing.getCheckOutTime() != null) {
                result.put("success", false);
                result.put("message", "今日已完成上下班打卡！");
                result.put("alreadyClockedOut", true);
            } else {
                Timestamp now = new Timestamp(System.currentTimeMillis());
                long diffMs = now.getTime() - existing.getCheckInTime().getTime();
                double hours = diffMs / (1000.0 * 60 * 60);
                BigDecimal workHours = BigDecimal.valueOf(hours).setScale(1, BigDecimal.ROUND_HALF_UP);

                Calendar cal = Calendar.getInstance();
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                int minute = cal.get(Calendar.MINUTE);
                String status = (hour < 18) ? "早退" : "正常";

                existing.setCheckOutTime(now);
                existing.setStatus(status);
                existing.setWorkHours(workHours);
                mapper.update(existing);
                session.commit();

                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
                result.put("success", true);
                result.put("message", "下班打卡成功！今日工作 " + workHours + " 小时");
                result.put("time", sdf.format(now));
                result.put("workHours", workHours);
                result.put("status", status);
                result.put("isEarly", status.equals("早退"));
            }
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 查询今日打卡状态（返回JSON） */
    private void getTodayStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("needLogin", true);
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        Date today = new Date(new java.util.Date().getTime());
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            AttendRecord record = mapper.findByEmpAndDate(emp.getId(), today);

            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
            result.put("success", true);
            result.put("hasCheckedIn", record != null && record.getCheckInTime() != null);
            result.put("hasCheckedOut", record != null && record.getCheckOutTime() != null);
            
            if (record != null) {
                if (record.getCheckInTime() != null) {
                    result.put("checkInTime", sdf.format(record.getCheckInTime()));
                }
                if (record.getCheckOutTime() != null) {
                    result.put("checkOutTime", sdf.format(record.getCheckOutTime()));
                }
                result.put("status", record.getStatus());
                result.put("workHours", record.getWorkHours());
            }
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 获取月度考勤记录（返回JSON） */
    private void getMonthRecords(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("needLogin", true);
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper mapper = session.getMapper(AttendRecordMapper.class);
            List<AttendRecord> records = mapper.findByEmpAndMonth(emp.getId(), yearMonth);
            Map<String, Object> stats = mapper.countByStatus(emp.getId(), yearMonth);

            List<Map<String, Object>> recordList = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
            for (AttendRecord r : records) {
                Map<String, Object> item = new HashMap<>();
                item.put("workDate", r.getWorkDate().toString());
                item.put("checkInTime", r.getCheckInTime() != null ? sdf.format(r.getCheckInTime()) : null);
                item.put("checkOutTime", r.getCheckOutTime() != null ? sdf.format(r.getCheckOutTime()) : null);
                item.put("status", r.getStatus());
                item.put("workHours", r.getWorkHours());
                recordList.add(item);
            }

            result.put("success", true);
            result.put("records", recordList);
            result.put("stats", stats);
            result.put("yearMonth", yearMonth);
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 退出登录 */
    private void doLogout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        req.getSession().invalidate();
        // 带上 logout 参数，让登录页清除 localStorage 中的缓存账号
        resp.sendRedirect(req.getContextPath() + "/miniapp?logout");
    }

    /** 显示"我的"页面 */
    private void showMyPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/miniapp");
            return;
        }
        req.setAttribute("user", emp);
        req.getRequestDispatcher("/views/miniapp/my.jsp").forward(req, resp);
    }

    /** 显示请假申请页面 */
    private void showLeaveApplyPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/miniapp");
            return;
        }
        req.setAttribute("user", emp);
        req.getRequestDispatcher("/views/miniapp/leave_apply.jsp").forward(req, resp);
    }

    /** 显示薪资查询页面 */
    private void showSalaryPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            resp.sendRedirect(req.getContextPath() + "/miniapp");
            return;
        }
        req.setAttribute("user", emp);

        // 获取月份参数，默认当前月
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }
        req.setAttribute("yearMonth", yearMonth);

        // 服务端查询薪资数据
        Salary salary = salaryService.findByEmpAndMonth(emp.getId(), yearMonth);
        req.setAttribute("salary", salary);

        req.getRequestDispatcher("/views/miniapp/salary.jsp").forward(req, resp);
    }

    /** 提交请假申请（返回JSON） */
    private void doSubmitLeave(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("needLogin", true);
            result.put("message", "请先登录！");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String leaveType = req.getParameter("leaveType");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");
        String reason = req.getParameter("reason");

        if (leaveType == null || startDate == null || endDate == null || reason == null) {
            result.put("success", false);
            result.put("message", "请填写完整的请假信息！");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            LeaveRequest leave = new LeaveRequest();
            leave.setEmpId(emp.getId());
            leave.setLeaveType(leaveType.trim());
            Date start = Date.valueOf(startDate.trim());
            Date end = Date.valueOf(endDate.trim());
            leave.setStartDate(start);
            leave.setEndDate(end);
            long days = (end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000) + 1;
            leave.setDays((int) days);
            leave.setReason(reason.trim());
            leave.setStatus("待审批");

            mapper.insert(leave);
            session.commit();

            result.put("success", true);
            result.put("message", "请假申请已提交，请等待审批！");
        } catch (Exception e) {
            session.rollback();
            result.put("success", false);
            result.put("message", "提交失败：" + e.getMessage());
        } finally {
            MyBatisUtils.closeSession(session);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 获取薪资数据（返回JSON） */
    private void getSalaryData(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        Employee emp = getMiniAppUser(req);
        if (emp == null) {
            result.put("success", false);
            result.put("needLogin", true);
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        try {
            Salary salary = salaryService.findByEmpAndMonth(emp.getId(), yearMonth);
            if (salary != null) {
                Map<String, Object> salaryMap = new HashMap<>();
                salaryMap.put("totalSalary", salary.getActualSalary());
                salaryMap.put("baseSalary", salary.getBaseSalary());
                salaryMap.put("bonus", salary.getAttendanceBonus());
                salaryMap.put("overtimePay", salary.getOvertimePay());
                BigDecimal deduction = BigDecimal.ZERO;
                if (salary.getDeductionLate() != null) {
                    deduction = deduction.add(salary.getDeductionLate());
                }
                if (salary.getDeductionLeave() != null) {
                    deduction = deduction.add(salary.getDeductionLeave());
                }
                salaryMap.put("deduction", deduction);
                salaryMap.put("yearMonth", salary.getYearMonth());
                salaryMap.put("status", salary.getStatus());
                result.put("success", true);
                result.put("salary", salaryMap);
            } else {
                result.put("success", false);
                result.put("message", "该月暂无薪资数据");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "查询失败：" + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** 获取当前 H5 小程序登录用户 */
    private Employee getMiniAppUser(HttpServletRequest req) {
        return (Employee) req.getSession().getAttribute("miniAppUser");
    }
}
