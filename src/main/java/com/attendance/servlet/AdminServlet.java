package com.attendance.servlet;

import com.attendance.entity.*;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.mapper.DepartmentMapper;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.service.SalaryService;
import com.attendance.service.impl.SalaryServiceImpl;
import com.attendance.utils.EmailUtil;
import com.attendance.utils.ExcelImportUtil;
import com.attendance.utils.MD5Util;
import com.attendance.utils.MyBatisUtils;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.ibatis.session.SqlSession;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理员端Servlet（管理员功能控制器）
 *
 * 功能模块:
 *   - dashboard:     管理后台首页（数据概览）
 *   - empList:       员工管理列表
 *   - empAdd:        添加新员工
 *   - attendanceList:考勤管理列表（管理员可查看所有员工考勤）
 *   - salaryGen:     生成月度薪资
 *   - salaryList:    薪资管理列表
 *   - salaryPay:     薪资发放
 *   - salaryReport:  月度报表导出
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private SalaryService salaryService = new SalaryServiceImpl();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            switch (action == null ? "dashboard" : action) {
                case "dashboard":      dashboard(req, resp); break;
                case "empList":        empList(req, resp); break;
                case "empAdd":         empAdd(req, resp); break;
                case "getNextEmpNo":   getNextEmpNo(req, resp); break;
                case "empImport":      empImport(req, resp); break;
                case "empEdit":        empEdit(req, resp); break;
                case "empUpdate":      empUpdate(req, resp); break;
                case "empDelete":      empDelete(req, resp); break;
                case "attendanceList": attendanceList(req, resp); break;
                case "attendanceEdit": attendanceEdit(req, resp); break;
                case "attendanceUpdate": attendanceUpdate(req, resp); break;
                case "attendanceDelete": attendanceDelete(req, resp); break;
                case "salaryGen":      salaryGen(req, resp); break;
                case "salaryList":     salaryList(req, resp); break;
                case "salaryPay":      salaryPay(req, resp); break;
                case "salaryReport":   salaryReport(req, resp); break;
                case "exportTemplate": exportTemplate(req, resp); break;
                default:               dashboard(req, resp); break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    /** 管理后台首页：数据概览 */
    private void dashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            DepartmentMapper deptMapper = session.getMapper(DepartmentMapper.class);

            req.setAttribute("totalEmps", empMapper.findAllWithDept().size());
            req.setAttribute("totalDepts", deptMapper.findAll().size());
            
            req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 员工列表：支持多条件搜索和分页 */
    private void empList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            
            Map<String, Object> params = new HashMap<>();
            String name = req.getParameter("name");
            String deptIdStr = req.getParameter("deptId");
            if (name != null && !name.isEmpty()) params.put("name", name);
            if (deptIdStr != null && !deptIdStr.isEmpty()) params.put("deptId", Integer.parseInt(deptIdStr));

            // 分页参数
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);

            List<Employee> list = mapper.findByConditions(params);
            int totalCount = mapper.countByConditions(params);
            
            req.setAttribute("empList", list);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            
            // 获取部门列表用于下拉筛选
            DepartmentMapper deptMapper = session.getMapper(DepartmentMapper.class);
            req.setAttribute("deptList", deptMapper.findAll());
            
            req.getRequestDispatcher("/views/admin/emp_list.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 添加新员工 */
    private void empAdd(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // GET请求显示表单，POST请求处理提交
        if ("GET".equalsIgnoreCase(req.getMethod())) {
            SqlSession session = MyBatisUtils.getSession();
            try {
                DepartmentMapper mapper = session.getMapper(DepartmentMapper.class);
                req.setAttribute("deptList", mapper.findAll());
                req.getRequestDispatcher("/views/admin/emp_add.jsp").forward(req, resp);
            } finally { MyBatisUtils.closeSession(session); }
            return;
        }

        // 处理添加请求
        String empNo = req.getParameter("empNo");
        String name = req.getParameter("name");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        Integer deptId = Integer.parseInt(req.getParameter("deptId"));
        String position = req.getParameter("position");
        Double baseSalaryDbl = Double.parseDouble(req.getParameter("baseSalary"));
        String entryDateStr = req.getParameter("entryDate");

        Employee emp = new Employee();
        emp.setEmpNo(empNo.trim());
        emp.setName(name.trim());
        emp.setPassword(MD5Util.md5(password.trim()));
        if (email != null && !email.trim().isEmpty()) {
            emp.setEmail(email.trim());
        }
        emp.setDeptId(deptId);
        emp.setPosition(position.trim());
        // 根据工号前缀自动设置角色
        if (empNo.trim().startsWith("A")) {
            emp.setRole("ADMIN");
        } else if (empNo.trim().startsWith("M")) {
            emp.setRole("MANAGER");
        } else {
            emp.setRole("EMPLOYEE");
        }
        emp.setBaseSalary(java.math.BigDecimal.valueOf(baseSalaryDbl));
        emp.setEntryDate(java.sql.Date.valueOf(entryDateStr));

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            mapper.insert(emp);
            session.commit();
            req.setAttribute("msg", "员工 " + name + " 添加成功！");
            empList(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /**
     * 自动生成下一个可用工号
     * 前端通过 AJAX 调用，根据角色前缀返回下一个编号
     * 如 prefix=E → 返回 E006（假设已有 E001~E005）
     */
    private void getNextEmpNo(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String prefix = req.getParameter("prefix");
        if (prefix == null || prefix.isEmpty()) {
            prefix = "E";
        }
        
        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            // 查询该前缀下的最大工号
            String maxEmpNo = mapper.findMaxEmpNoByPrefix(prefix + "%");
            
            int nextNum = 1;
            if (maxEmpNo != null && maxEmpNo.length() > 1) {
                try {
                    nextNum = Integer.parseInt(maxEmpNo.substring(1)) + 1;
                } catch (NumberFormatException e) {
                    nextNum = 1;
                }
            }
            
            String newEmpNo = prefix + String.format("%03d", nextNum);
            
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"empNo\":\"" + newEmpNo + "\"}");
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    /** 编辑员工：显示编辑表单（GET请求） */
    private void empEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer empId = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            if (emp == null) {
                req.setAttribute("errorMsg", "员工不存在！");
                empList(req, resp);
                return;
            }

            // 获取部门列表用于下拉选择
            DepartmentMapper deptMapper = session.getMapper(DepartmentMapper.class);
            req.setAttribute("deptList", deptMapper.findAll());
            req.setAttribute("editEmp", emp);
            req.getRequestDispatcher("/views/admin/emp_edit.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 更新员工信息（POST请求） */
    private void empUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer empId = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        Integer deptId = null;
        String deptIdStr = req.getParameter("deptId");
        if (deptIdStr != null && !deptIdStr.isEmpty()) {
            deptId = Integer.parseInt(deptIdStr);
        }
        String position = req.getParameter("position");
        String baseSalaryStr = req.getParameter("baseSalary");

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            if (emp == null) {
                req.setAttribute("errorMsg", "员工不存在！");
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
            if (deptId != null) {
                emp.setDeptId(deptId);
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
        Integer empId = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            Employee emp = empMapper.findById(empId);

            if (emp == null) {
                req.setAttribute("errorMsg", "员工不存在！");
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

    /**
     * 考勤管理列表（管理员查看所有员工考勤）
     * 支持按部门、日期范围、考勤状态筛选和分页
     */
    private void attendanceList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper recordMapper = session.getMapper(AttendRecordMapper.class);
            DepartmentMapper deptMapper = session.getMapper(DepartmentMapper.class);
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);

            // 获取筛选参数
            String deptIdStr = req.getParameter("deptId");
            String startDate = req.getParameter("startDate");
            String endDate = req.getParameter("endDate");
            String status = req.getParameter("status");

            java.util.Map<String, Object> params = new java.util.HashMap<>();
            if (deptIdStr != null && !deptIdStr.isEmpty()) {
                params.put("deptId", Integer.parseInt(deptIdStr));
            }
            if (startDate != null && !startDate.isEmpty()) {
                params.put("startDate", java.sql.Date.valueOf(startDate));
            }
            if (endDate != null && !endDate.isEmpty()) {
                params.put("endDate", java.sql.Date.valueOf(endDate));
            }
            if (status != null && !status.isEmpty()) {
                params.put("status", status);
            }

            // 分页参数
            int[] pageInfo = parsePageParams(req);
            params.put("offset", pageInfo[1]);
            params.put("limit", pageInfo[2]);

            java.util.List<AttendRecord> recordList = recordMapper.findByConditions(params);
            int totalCount = recordMapper.countByConditions(params);
            
            req.setAttribute("recordList", recordList);
            setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
            req.setAttribute("deptList", deptMapper.findAll());
            req.setAttribute("empList", empMapper.findAllWithDept());

            // 回显筛选条件
            req.setAttribute("deptId", deptIdStr);
            req.setAttribute("startDate", startDate);
            req.setAttribute("endDate", endDate);
            req.setAttribute("status", status);

            req.getRequestDispatcher("/views/admin/attendance_list.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 编辑考勤记录：显示编辑表单 */
    private void attendanceEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper recordMapper = session.getMapper(AttendRecordMapper.class);
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);

            // 查询该记录
            java.util.Map<String, Object> params = new java.util.HashMap<>();
            params.put("id", id);
            java.util.List<AttendRecord> list = recordMapper.findByConditions(params);
            AttendRecord record = list.isEmpty() ? null : list.get(0);

            if (record == null) {
                req.setAttribute("errorMsg", "考勤记录不存在！");
                attendanceList(req, resp);
                return;
            }

            req.setAttribute("record", record);
            req.setAttribute("empList", empMapper.findAllWithDept());
            req.getRequestDispatcher("/views/admin/attendance_edit.jsp").forward(req, resp);
        } finally { MyBatisUtils.closeSession(session); }
    }

    /** 更新考勤记录 */
    private void attendanceUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));
        String checkInTimeStr = req.getParameter("checkInTime");
        String checkOutTimeStr = req.getParameter("checkOutTime");
        String status = req.getParameter("status");
        String workHoursStr = req.getParameter("workHours");

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper recordMapper = session.getMapper(AttendRecordMapper.class);

            AttendRecord record = new AttendRecord();
            record.setId(id);

            if (checkInTimeStr != null && !checkInTimeStr.isEmpty()) {
                record.setCheckInTime(java.sql.Timestamp.valueOf(checkInTimeStr.replace("T", " ") + ":00"));
            }
            if (checkOutTimeStr != null && !checkOutTimeStr.isEmpty()) {
                record.setCheckOutTime(java.sql.Timestamp.valueOf(checkOutTimeStr.replace("T", " ") + ":00"));
            }
            record.setStatus(status);
            if (workHoursStr != null && !workHoursStr.isEmpty()) {
                record.setWorkHours(java.math.BigDecimal.valueOf(Double.parseDouble(workHoursStr)));
            }

            recordMapper.update(record);
            session.commit();
            req.setAttribute("msg", "考勤记录更新成功！");
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "更新失败：" + e.getMessage());
        } finally {
            MyBatisUtils.closeSession(session);
        }
        attendanceList(req, resp);
    }

    /** 删除考勤记录 */
    private void attendanceDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));

        SqlSession session = MyBatisUtils.getSession();
        try {
            AttendRecordMapper recordMapper = session.getMapper(AttendRecordMapper.class);
            recordMapper.deleteById(id);
            session.commit();
            req.setAttribute("msg", "考勤记录删除成功！");
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "删除失败：" + e.getMessage());
        } finally {
            MyBatisUtils.closeSession(session);
        }
        attendanceList(req, resp);
    }

    /**
     * 生成月度薪资
     * 参数: yearMonth (如 2026-06)
     * 调用 SalaryService.generateMonthlySalaries() 执行完整计算
     */
    private void salaryGen(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        int count = salaryService.generateMonthlySalaries(yearMonth);
        req.setAttribute("msg", "薪资生成完成！共为 " + count + " 名员工生成了 " + yearMonth + " 的薪资记录。");
        // 设置 yearMonth 属性，确保 salaryList 能正确获取
        req.setAttribute("yearMonth", yearMonth);
        
        salaryList(req, resp);
    }

    /** 薪资管理列表：查看所有员工的薪资记录（支持分页） */
    private void salaryList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 优先从 request 属性获取（可能由 salaryGen 设置），其次从参数获取
        String yearMonth = (String) req.getAttribute("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = req.getParameter("yearMonth");
        }
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        // 分页参数
        int[] pageInfo = parsePageParams(req);
        List<Salary> list = salaryService.findByMonthPaged(yearMonth, pageInfo[1], pageInfo[2]);
        int totalCount = salaryService.countByMonth(yearMonth);
        
        req.setAttribute("salaryList", list);
        setPageAttributes(req, pageInfo[0], pageInfo[2], totalCount);
        req.setAttribute("yearMonth", yearMonth);
        req.getRequestDispatcher("/views/admin/salary_list.jsp").forward(req, resp);
    }

    /** 发放薪资：将状态从"未发放"更新为"已发放" */
    private void salaryPay(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = Integer.parseInt(req.getParameter("id"));
        String yearMonth = req.getParameter("yearMonth");
        
        // 先获取薪资信息用于邮件通知
        Salary salary = salaryService.findById(id);
        boolean success = salaryService.paySalary(id);
        
        if (success) {
            StringBuilder msgBuilder = new StringBuilder("薪资发放成功！");
            // 发送邮件通知
            if (salary != null) {
                // 从 Employee 表获取真实邮箱
                String email = null;
                SqlSession session = MyBatisUtils.getSession();
                try {
                    EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
                    Employee emp = empMapper.findById(salary.getEmpId());
                    if (emp != null && emp.getEmail() != null && !emp.getEmail().isEmpty()) {
                        email = emp.getEmail();
                    }
                } finally { MyBatisUtils.closeSession(session); }

                if (email != null) {
                    boolean mailSent = EmailUtil.sendSalaryNotification(
                        email,
                        salary.getEmpName(),
                        salary.getYearMonth(),
                        salary.getActualSalary().toString()
                    );
                    if (mailSent) {
                        msgBuilder.append(" 邮件已发送至 ").append(maskEmail(email)).append("。");
                        System.out.println("[邮件] 成功发送薪资通知到 " + email + "（" + salary.getEmpName() + "，" + salary.getYearMonth() + "）");
                    } else {
                        msgBuilder.append(" 但邮件发送失败，请检查邮件配置。");
                        System.out.println("[邮件] 发送失败：" + email + "（" + salary.getEmpName() + "）");
                    }
                } else {
                    msgBuilder.append("（员工未配置邮箱，跳过邮件通知）");
                    System.out.println("[邮件] 员工 " + salary.getEmpName() + " 未配置邮箱，跳过邮件发送");
                }
            }
            req.setAttribute("msg", msgBuilder.toString());
        } else {
            req.setAttribute("errorMsg", "发放失败，可能该记录已被处理。");
        }
        if (yearMonth != null) {
            req.setAttribute("yearMonth", yearMonth);
        }
        salaryList(req, resp);
    }

    /** 邮箱脱敏：3186649022@qq.com → 318****022@qq.com */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        String[] parts = email.split("@");
        String name = parts[0];
        if (name.length() <= 3) return name + "***@" + parts[1];
        return name.substring(0, 3) + "****" + name.substring(name.length() - 3) + "@" + parts[1];
    }

    /**
     * 月度薪资报表：展示薪资汇总统计和图表数据
     * 与 salaryList 的区别：侧重统计分析，不做 CRUD 操作
     */
    private void salaryReport(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            yearMonth = new SimpleDateFormat("yyyy-MM").format(new java.util.Date());
        }

        List<Salary> list = salaryService.findByMonth(yearMonth);
        req.setAttribute("salaryList", list);
        req.setAttribute("yearMonth", yearMonth);

        // 汇总统计
        int totalCount = list.size();
        int paidCount = 0, unpaidCount = 0;
        double totalActual = 0, totalBase = 0, totalBonus = 0, totalLate = 0, totalLeave = 0;
        for (Salary s : list) {
            if ("已发放".equals(s.getStatus())) paidCount++;
            else unpaidCount++;
            if (s.getActualSalary() != null) totalActual += s.getActualSalary().doubleValue();
            if (s.getBaseSalary() != null) totalBase += s.getBaseSalary().doubleValue();
            if (s.getAttendanceBonus() != null) totalBonus += s.getAttendanceBonus().doubleValue();
            if (s.getDeductionLate() != null) totalLate += s.getDeductionLate().doubleValue();
            if (s.getDeductionLeave() != null) totalLeave += s.getDeductionLeave().doubleValue();
        }

        req.setAttribute("totalCount", totalCount);
        req.setAttribute("paidCount", paidCount);
        req.setAttribute("unpaidCount", unpaidCount);
        req.setAttribute("totalActual", totalActual);
        req.setAttribute("totalBase", totalBase);
        req.setAttribute("totalBonus", totalBonus);
        req.setAttribute("totalLate", totalLate);
        req.setAttribute("totalLeave", totalLeave);

        req.getRequestDispatcher("/views/admin/salary_report.jsp").forward(req, resp);
    }

    /**
     * 批量导入员工（Excel文件上传）
     * 工号由系统根据角色前缀自动生成，无需在Excel中填写
     */
    private void empImport(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!ServletFileUpload.isMultipartContent(req)) {
            req.setAttribute("errorMsg", "请上传Excel文件！");
            empList(req, resp);
            return;
        }

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setHeaderEncoding("UTF-8");

        SqlSession session = MyBatisUtils.getSession();
        int successCount = 0;
        int skipCount = 0;
        StringBuilder errDetail = new StringBuilder();
        try {
            EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
            
            // 预查各角色前缀的当前最大工号，用于自动分配
            Map<String, Integer> prefixCounters = new HashMap<>();
            
            List<FileItem> items = upload.parseRequest(req);
            for (FileItem item : items) {
                if (!item.isFormField()) {
                    InputStream is = item.getInputStream();
                    List<Employee> emps = ExcelImportUtil.parseEmployees(is);
                    if (emps.isEmpty()) {
                        errDetail.append("Excel中未解析到有效员工数据，请检查：\n");
                        errDetail.append("1. 表头是否在首行\n");
                        errDetail.append("2. 数据是否从第2行开始\n");
                        errDetail.append("3. 角色、姓名、部门ID是否填写正确\n");
                    }
                    for (Employee emp : emps) {
                        try {
                            // 从 empNo 临时字段取出角色前缀（ExcelImportUtil 存入的）
                            String rolePrefix = emp.getEmpNo();
                            
                            // 为该前缀分配下一个可用工号
                            String newEmpNo = allocateNextEmpNo(mapper, rolePrefix, prefixCounters);
                            emp.setEmpNo(newEmpNo);
                            
                            mapper.insert(emp);
                            successCount++;
                        } catch (Exception insertEx) {
                            skipCount++;
                            errDetail.append("员工 ").append(emp.getName()).append(" 插入失败：").append(insertEx.getMessage()).append("\n");
                        }
                    }
                    is.close();
                }
            }
            session.commit();
            if (successCount > 0) {
                req.setAttribute("msg", "成功导入 " + successCount + " 名员工！" + (skipCount > 0 ? "（跳过 " + skipCount + " 条）" : ""));
            } else {
                req.setAttribute("errorMsg", "未成功导入任何员工。" + (errDetail.length() > 0 ? "\n" + errDetail.toString() : ""));
            }
        } catch (Exception e) {
            session.rollback();
            req.setAttribute("errorMsg", "导入失败：" + e.getMessage() + (errDetail.length() > 0 ? "\n详情：" + errDetail.toString() : ""));
            e.printStackTrace();
        } finally {
            MyBatisUtils.closeSession(session);
        }
        empList(req, resp);
    }

    /**
     * 为导入的员工分配下一个可用工号
     * @param mapper EmployeeMapper
     * @param prefix 角色前缀（E/M/A）
     * @param prefixCounters 内存计数器缓存，避免批量导入时重复查询数据库
     * @return 新工号，如 E006
     */
    private String allocateNextEmpNo(EmployeeMapper mapper, String prefix, Map<String, Integer> prefixCounters) {
        Integer counter = prefixCounters.get(prefix);
        if (counter == null) {
            // 首次遇到该前缀，从数据库查询当前最大值
            String maxEmpNo = mapper.findMaxEmpNoByPrefix(prefix + "%");
            int startNum = 1;
            if (maxEmpNo != null && maxEmpNo.length() > 1) {
                try {
                    startNum = Integer.parseInt(maxEmpNo.substring(1)) + 1;
                } catch (NumberFormatException e) {
                    startNum = 1;
                }
            }
            counter = startNum;
        }
        String newEmpNo = prefix + String.format("%03d", counter);
        prefixCounters.put(prefix, counter + 1);
        return newEmpNo;
    }

    /**
     * 导出批量导入员工的 Excel 模板
     * 生成一个包含表头和示例数据的 .xlsx 文件供用户下载参考
     */
    private void exportTemplate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        // 使用 Apache POI 生成 Excel
        org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.xssf.usermodel.XSSFSheet sheet = workbook.createSheet("员工导入模板");

        // ---- 样式定义 ----
        org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(new org.apache.poi.xssf.usermodel.XSSFColor(new byte[]{(byte)68, (byte)114, (byte)196}, null));
        headerStyle.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(org.apache.poi.ss.usermodel.HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(org.apache.poi.ss.usermodel.VerticalAlignment.CENTER);
        org.apache.poi.xssf.usermodel.XSSFFont headerFont = workbook.createFont();
        headerFont.setColor(new org.apache.poi.xssf.usermodel.XSSFColor(new byte[]{(byte)255, (byte)255, (byte)255}, null));
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);

        org.apache.poi.xssf.usermodel.XSSFCellStyle exampleStyle = workbook.createCellStyle();
        exampleStyle.setFillForegroundColor(new org.apache.poi.xssf.usermodel.XSSFColor(new byte[]{(byte)226, (byte)239, (byte)218}, null));
        exampleStyle.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
        exampleStyle.setAlignment(org.apache.poi.ss.usermodel.HorizontalAlignment.CENTER);
        exampleStyle.setVerticalAlignment(org.apache.poi.ss.usermodel.VerticalAlignment.CENTER);
        org.apache.poi.xssf.usermodel.XSSFFont exampleFont = workbook.createFont();
        exampleFont.setColor(new org.apache.poi.xssf.usermodel.XSSFColor(new byte[]{(byte)55, (byte)86, (byte)35}, null));
        exampleFont.setFontHeightInPoints((short) 10);
        exampleStyle.setFont(exampleFont);

        org.apache.poi.xssf.usermodel.XSSFCellStyle tipStyle = workbook.createCellStyle();
        org.apache.poi.xssf.usermodel.XSSFFont tipFont = workbook.createFont();
        tipFont.setColor(new org.apache.poi.xssf.usermodel.XSSFColor(new byte[]{(byte)156, (byte)163, (byte)175}, null));
        tipFont.setItalic(true);
        tipFont.setFontHeightInPoints((short) 9);
        tipStyle.setFont(tipFont);
        tipStyle.setVerticalAlignment(org.apache.poi.ss.usermodel.VerticalAlignment.CENTER);

        // ---- 说明行（第1行）----
        org.apache.poi.xssf.usermodel.XSSFRow tipRow = sheet.createRow(0);
        org.apache.poi.xssf.usermodel.XSSFCell tipCell = tipRow.createCell(0);
        tipCell.setCellValue("说明：表头为第2行，数据从第3行开始填写。角色：E=员工 M=主管 A=管理员。部门ID：1=技术部 2=市场部 3=财务部 4=人事部 5=运营部。工号由系统自动生成，无需填写。");
        tipCell.setCellStyle(tipStyle);
        sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

        // ---- 表头行（第2行）----
        org.apache.poi.xssf.usermodel.XSSFRow headerRow = sheet.createRow(1);
        String[] headers = {"角色", "姓名", "密码", "部门ID", "职位", "基本工资", "入职日期", "邮箱(选填)"};
        for (int i = 0; i < headers.length; i++) {
            org.apache.poi.xssf.usermodel.XSSFCell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        // ---- 示例数据（第3行起）----
        Object[][] examples = {
            {"E", "张三", "123456", 1, "Java开发工程师", 8000.00, "2025-03-01", "zhangsan@example.com"},
            {"M", "李四", "123456", 1, "技术主管", 15000.00, "2024-06-15", "lisi@example.com"},
            {"A", "管理员", "123456", 1, "系统管理员", 12000.00, "2024-01-01", ""},
            {"E", "王五", "123456", 2, "市场专员", 6000.00, "2025-01-10", ""},
            {"E", "赵六", "123456", 3, "会计", 7000.00, "2024-09-01", "zhaoliu@example.com"},
        };
        for (int i = 0; i < examples.length; i++) {
            org.apache.poi.xssf.usermodel.XSSFRow row = sheet.createRow(i + 2);
            for (int j = 0; j < examples[i].length; j++) {
                org.apache.poi.xssf.usermodel.XSSFCell cell = row.createCell(j);
                if (examples[i][j] instanceof Number) {
                    cell.setCellValue(((Number) examples[i][j]).doubleValue());
                } else {
                    cell.setCellValue(String.valueOf(examples[i][j]));
                }
                cell.setCellStyle(exampleStyle);
            }
        }

        // ---- 列宽调整 ----
        int[] widths = {8, 10, 10, 10, 16, 12, 14, 24};
        for (int i = 0; i < widths.length; i++) {
            sheet.setColumnWidth(i, widths[i] * 256);
        }

        // ---- 输出 ----
        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=employee_import_template.xlsx");
        workbook.write(resp.getOutputStream());
        workbook.close();
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
