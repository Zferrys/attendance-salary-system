package com.attendance.servlet;

import com.attendance.entity.*;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.mapper.LeaveRequestMapper;
import com.attendance.service.SalaryService;
import com.attendance.service.impl.SalaryServiceImpl;
import com.attendance.utils.MD5Util;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 主管端Servlet（主管功能控制器）
 *
 * 功能模块:
 *   - dashboard:    主管首页
 *   - teamAttend:   查看团队考勤统计
 *   - leaveReview:  审批下属的请假申请
 */
@WebServlet("/mgr")
public class ManagerServlet extends HttpServlet {

    private SalaryService salaryService = new SalaryServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            switch (action == null ? "dashboard" : action) {
                case "dashboard":   dashboard(req, resp); break;
                case "teamAttend":  teamAttend(req, resp); break;
                case "leaveReview": leaveReview(req, resp); break;
                case "approveLeave":approveLeave(req, resp); break;
                case "salaryView":  salaryView(req, resp); break;
                case "empList":     empList(req, resp); break;
                case "empEdit":     empEdit(req, resp); break;
                case "empUpdate":   empUpdate(req, resp); break;
                case "empDelete":   empDelete(req, resp); break;
                case "memberAttend":memberAttend(req, resp); break;
                case "attendUpdate":attendUpdate(req, resp); break;
                default:           dashboard(req, resp); break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    /** 主管仪表盘：显示待审批数量和团队概况 */
    private void dashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        SqlSession session = MyBatisUtils.getSession();
        
        try {
            LeaveRequestMapper leaveMapper = session.getMapper(LeaveRequestMapper.class);
            
            // 统计待审批请假数
            Map<String, Object> params = new HashMap<>();
            params.put("status", "待审批");
            List<LeaveRequest> pendingList = leaveMapper.findByConditions(params);
            req.setAttribute("pendingCount", pendingList.size());
            
            // 最近5条待审批记录
            if (pendingList.size() > 5) pendingList = pendingList.subList(0, 5);
            req.setAttribute("pendingLeaves", pendingList);

            req.getRequestDispatcher("/views/manager/dashboard.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 查看团队考勤统计：展示部门员工的考勤情况（支持分页） */
    private void teamAttend(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }
        
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            AttendRecordMapper attendMapper = session.getMapper(AttendRecordMapper.class);

            // 分页获取同部门员工
            Map<String, Object> params = new HashMap<>();
            params.put("deptId", manager.getDeptId());
            params.put("role", "EMPLOYEE");
            
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);
            
            List<Employee> teamMembers = empMapper.findByConditions(params);
            int totalCount = empMapper.countByConditions(params);
            
            // 获取当前页每个成员当月考勤统计
            for (Employee member : teamMembers) {
                Map stats = attendMapper.countByStatus(member.getId(), yearMonth);
                member.setAttendList(attendMapper.findByEmpAndMonth(member.getId(), yearMonth));
            }

            req.setAttribute("teamMembers", teamMembers);
            req.setAttribute("yearMonth", yearMonth);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            req.getRequestDispatcher("/views/manager/team_attend.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 查看待审批的请假申请列表（支持分页）
     * 主管可以查看所有"待审批"状态的请假申请并进行审批操作
     */
    private void leaveReview(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        SqlSession session = MyBatisUtils.getSession();
        try {
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            Map<String, Object> params = new HashMap<>();
            params.put("status", "待审批");
            
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);
            
            List<LeaveRequest> list = mapper.findByConditions(params);
            int totalCount = mapper.countByConditions(params);
            
            req.setAttribute("leaveList", list);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            req.getRequestDispatcher("/views/manager/leave_review.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 审批请假申请（批准或拒绝）
     * 参数: id (请假单ID), status (已批准/已拒绝)
     */
    private void approveLeave(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));
        String status = req.getParameter("status"); // "已批准" 或 "已拒绝"
        Employee manager = getCurrentUser(req);

        SqlSession session = MyBatisUtils.getSession();
        try {
            LeaveRequestMapper mapper = session.getMapper(LeaveRequestMapper.class);
            int rows = mapper.approve(id, status, manager.getId());
            session.commit();
            
            if (rows > 0) {
                req.setAttribute("msg", "审批成功！状态已更新为：" + status);
            } else {
                req.setAttribute("errorMsg", "审批失败，可能该申请已被处理。");
            }
            leaveReview(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 查看团队员工列表（支持分页） */
    private void empList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            
            Map<String, Object> params = new HashMap<>();
            params.put("deptId", manager.getDeptId());
            params.put("role", "EMPLOYEE");
            
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);
            
            List<Employee> teamMembers = empMapper.findByConditions(params);
            int totalCount = empMapper.countByConditions(params);
            
            req.setAttribute("teamMembers", teamMembers);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            req.getRequestDispatcher("/views/manager/emp_list.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 编辑员工：显示编辑表单（GET请求） */
    private void empEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        Integer empId = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            // 校验该员工是否属于主管的部门
            if (emp == null || !emp.getDeptId().equals(manager.getDeptId())) {
                req.setAttribute("errorMsg", "无权编辑该员工信息！");
                empList(req, resp);
                return;
            }

            req.setAttribute("editEmp", emp);
            req.getRequestDispatcher("/views/manager/emp_edit.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 更新员工信息（POST请求） */
    private void empUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        Integer empId = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String position = req.getParameter("position");
        String baseSalaryStr = req.getParameter("baseSalary");

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            // 校验权限
            if (emp == null || !emp.getDeptId().equals(manager.getDeptId())) {
                req.setAttribute("errorMsg", "无权修改该员工信息！");
                empList(req, resp);
                return;
            }

            // 更新字段
            emp.setName(name.trim());
            if (password != null && !password.isEmpty()) {
                emp.setPassword(MD5Util.md5(password.trim()));
            }
            if (email != null && !email.isEmpty()) {
                emp.setEmail(email.trim());
            }
            emp.setPosition(position.trim());
            if (baseSalaryStr != null && !baseSalaryStr.isEmpty()) {
                emp.setBaseSalary(java.math.BigDecimal.valueOf(Double.parseDouble(baseSalaryStr)));
            }

            empMapper.update(emp);
            session.commit();
            req.setAttribute("msg", "员工 " + name + " 信息更新成功！");
            empList(req, resp);
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "更新失败：" + e.getMessage());
            empList(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 删除员工（逻辑删除：设置离职日期） */
    private void empDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        Integer empId = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            // 校验权限
            if (emp == null || !emp.getDeptId().equals(manager.getDeptId())) {
                req.setAttribute("errorMsg", "无权删除该员工！");
                empList(req, resp);
                return;
            }

            empMapper.deleteById(empId);
            session.commit();
            req.setAttribute("msg", "员工 " + emp.getName() + "（" + emp.getEmpNo() + "）已删除！");
            empList(req, resp);
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "删除失败：" + e.getMessage());
            empList(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 主管查看自己的薪资 */
    private void salaryView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        Salary salary = salaryService.findByEmpAndMonth(manager.getId(), yearMonth);
        req.setAttribute("salary", salary);
        req.setAttribute("yearMonth", yearMonth);
        req.getRequestDispatcher("/views/manager/salary_view.jsp").forward(req, resp);
    }

    /** 主管查看指定下属的考勤明细 */
    private void memberAttend(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        Integer empId = Integer.parseInt(req.getParameter("empId"));
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            AttendRecordMapper attendMapper = session.getMapper(AttendRecordMapper.class);

            // 校验该员工是否属于主管的部门
            Employee member = empMapper.findById(empId);
            if (member == null || !member.getDeptId().equals(manager.getDeptId())) {
                req.setAttribute("errorMsg", "无权查看该员工的考勤记录！");
                teamAttend(req, resp);
                return;
            }

            List<AttendRecord> records = attendMapper.findByEmpAndMonth(empId, yearMonth);
            Map stats = attendMapper.countByStatus(empId, yearMonth);

            req.setAttribute("member", member);
            req.setAttribute("records", records);
            req.setAttribute("stats", stats);
            req.setAttribute("yearMonth", yearMonth);
            req.getRequestDispatcher("/views/manager/member_attend.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 主管修改下属考勤记录状态 */
    private void attendUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Employee manager = getCurrentUser(req);
        Integer recordId = Integer.parseInt(req.getParameter("id"));
        String newStatus = req.getParameter("status");
        String empIdStr = req.getParameter("empId");
        String yearMonth = req.getParameter("yearMonth");

        if (newStatus == null || newStatus.isEmpty()) {
            req.setAttribute("errorMsg", "请选择要修改的状态！");
            resp.sendRedirect(req.getContextPath() + "/mgr?action=memberAttend&empId=" + empIdStr + "&yearMonth=" + yearMonth);
            return;
        }

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper attendMapper = session.getMapper(AttendRecordMapper.class);
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);

            // 先查询该考勤记录对应的员工，校验权限
            // 通过recordId查询记录，然后校验员工是否属于主管部门
            AttendRecord targetRecord = null;
            java.util.List<AttendRecord> allRecords = attendMapper.findByConditions(new java.util.HashMap<>());
            for (AttendRecord r : allRecords) {
                if (r.getId().equals(recordId)) {
                    targetRecord = r;
                    break;
                }
            }

            if (targetRecord == null) {
                req.setAttribute("errorMsg", "考勤记录不存在！");
                resp.sendRedirect(req.getContextPath() + "/mgr?action=memberAttend&empId=" + empIdStr + "&yearMonth=" + yearMonth);
                return;
            }

            Employee recordEmp = empMapper.findById(targetRecord.getEmpId());
            if (recordEmp == null || !recordEmp.getDeptId().equals(manager.getDeptId())) {
                req.setAttribute("errorMsg", "无权修改该员工的考勤记录！");
                resp.sendRedirect(req.getContextPath() + "/mgr?action=memberAttend&empId=" + empIdStr + "&yearMonth=" + yearMonth);
                return;
            }

            // 更新考勤状态
            AttendRecord record = new AttendRecord();
            record.setId(recordId);
            record.setStatus(newStatus);
            attendMapper.update(record);
            session.commit();
            req.setAttribute("msg", "考勤状态已更新为：" + newStatus);
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "更新失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            MyBatisUtils.closeSession(session);
        }

        // 重定向回考勤明细页
        resp.sendRedirect(req.getContextPath() + "/mgr?action=memberAttend&empId=" + empIdStr + "&yearMonth=" + yearMonth);
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
