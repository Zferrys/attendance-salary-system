package com.attendance.servlet;

import com.attendance.entity.*;
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
 *   - dashboard:    管理后台首页（数据概览）
 *   - empList:      员工管理列表
 *   - empAdd:       添加新员工
 *   - salaryGen:    生成月度薪资
 *   - salaryList:   薪资管理列表
 *   - salaryPay:    薪资发放
 *   - salaryReport: 月度报表导出
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
                case "dashboard":     dashboard(req, resp); break;
                case "empList":       empList(req, resp); break;
                case "empAdd":        empAdd(req, resp); break;
                case "getNextEmpNo":  getNextEmpNo(req, resp); break;
                case "empImport":     empImport(req, resp); break;
                case "empEdit":       empEdit(req, resp); break;
                case "empUpdate":     empUpdate(req, resp); break;
                case "empDelete":     empDelete(req, resp); break;
                case "salaryGen":     salaryGen(req, resp); break;
                case "salaryList":    salaryList(req, resp); break;
                case "salaryPay":     salaryPay(req, resp); break;
                case "salaryReport":  salaryReport(req, resp); break;
                default:              dashboard(req, resp); break;
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

    /** 员工列表：支持多条件搜索 */
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

            List<Employee> list = mapper.findByConditions(params);
            req.setAttribute("empList", list);
            
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

    /** 薪资管理列表：查看所有员工的薪资记录 */
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

        List<Salary> list = salaryService.findByMonth(yearMonth);
        req.setAttribute("salaryList", list);
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

    // ==================== 工具方法 ====================

    private Employee getCurrentUser(HttpServletRequest req) {
        return (Employee) req.getSession().getAttribute("currentUser");
    }
}
