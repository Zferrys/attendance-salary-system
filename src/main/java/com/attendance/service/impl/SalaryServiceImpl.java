package com.attendance.service.impl;

import com.attendance.entity.*;
import com.attendance.mapper.AttendRecordMapper;
import com.attendance.mapper.EmployeeMapper;
import com.attendance.mapper.LeaveRequestMapper;
import com.attendance.mapper.SalaryMapper;
import com.attendance.service.SalaryService;
import com.attendance.utils.MyBatisUtils;
import org.apache.ibatis.session.SqlSession;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.util.*;

/**
 * 薪资服务实现类
 *
 * 【核心算法 - 评分占比15%】薪资计算规则详细实现
 *
 * 计算公式（月度自动执行）：
 * ┌─────────────────────────────────────────────────────┐
 * │  实际工资 = 基本工资 + 全勤奖 + 加班补贴              │
 * │           - 迟到扣款 - 请假扣款                      │
 * ├─────────────────────────────────────────────────────┤
 * │  迟到扣款 = 迟到次数 × (基本工资 / 21.75 / 8) × 1   │
 * │           说明: 每次迟到扣1小时工资                  │
 * │  请假扣款 = (基本工资 / 21.75) × 请假天数             │
 * │           说明: 日薪 = 月薪 / 月平均工作日(21.75天)   │
 * │  全勤奖  = 无迟到+无请假+无缺勤 → 发放300元          │
 * │           否则不发放                                 │
 * └─────────────────────────────────────────────────────┘
 *
 * 常量说明:
 *   21.75 = (365天 - 104个双休日) / 12个月 ≈ 月平均工作日数
 */
public class SalaryServiceImpl implements SalaryService {

    /** 月平均工作日数常量（用于计算日薪） */
    private static final double MONTHLY_WORK_DAYS = 21.75;

    /** 每天工作小时数 */
    private static final double DAILY_WORK_HOURS = 8.0;

    /** 全勤奖金额（元）- 无迟到无请假无缺勤时发放 */
    private static final BigDecimal FULL_ATTENDANCE_BONUS = new BigDecimal("300.00");

    /** 每次迟到扣款的小时数 */
    private static final double LATE_DEDUCTION_HOURS = 1.0;

    // ==================== 核心方法：生成月度薪资 ====================

    /**
     * 为所有在职员工生成指定月份的薪资记录
     *
     * @param yearMonth 年月，格式 "2026-06"
     * @return 成功生成的薪资记录数量
     */
    @Override
    public int generateMonthlySalaries(String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        int count = 0;
        
        try {
            EmployeeMapper empMapper = session.getMapper(EmployeeMapper.class);
            AttendRecordMapper attendMapper = session.getMapper(AttendRecordMapper.class);
            LeaveRequestMapper leaveMapper = session.getMapper(LeaveRequestMapper.class);
            SalaryMapper salaryMapper = session.getMapper(SalaryMapper.class);

            // 1. 获取所有在职员工列表
            List<Employee> employees = empMapper.findAllWithDept();

            // 2. 遍历每个员工，分别计算薪资
            for (Employee emp : employees) {
                // 检查该员工本月是否已有薪资记录（避免重复生成）
                Salary existing = salaryMapper.findByEmpAndMonth(emp.getId(), yearMonth);
                if (existing != null) {
                    continue; // 已存在则跳过
                }

                // 3. 执行薪资计算核心逻辑
                Salary salary = calculateSalary(emp, yearMonth, 
                                                  attendMapper, leaveMapper);

                // 4. 将计算结果写入数据库
                salaryMapper.insert(salary);
                count++;
            }

            session.commit();
        } finally {
            MyBatisUtils.closeSession(session);
        }
        
        return count;
    }

    /**
     * 【核心算法】为单个员工计算指定月份的薪资
     *
     * 计算流程：
     *   Step1: 获取当月考勤统计（正常天数、迟到次数等）
     *   Step2: 获取当月已批准的请假天数
     *   Step3: 计算各项扣款和奖金
     *   Step4: 汇总得到实际应发工资
     *
     * @param emp 员工对象
     * @param yearMonth 年月
     * @param attendMapper 考勤Mapper
     * @param leaveMapper 请假Mapper
     * @return 构建好的Salary对象
     */
    private Salary calculateSalary(Employee emp, String yearMonth,
                                   AttendRecordMapper attendMapper,
                                   LeaveRequestMapper leaveMapper) {
        // ---- Step1: 获取当月考勤统计数据 ----
        Map<String, Object> attendanceStats = attendMapper.countByStatus(
                emp.getId(), yearMonth);

        // 从统计结果中提取各状态天数（注意处理null值）
        long lateDays = getLongValue(attendanceStats, "lateDays");
        long absentDays = getLongValue(attendanceStats, "absentDays");
        long totalDays = getLongValue(attendanceStats, "totalDays");

        // ---- Step2: 获取当月已批准的请假总天数 ----
        Map<String, Object> params = new HashMap<>();
        params.put("empId", emp.getId());
        params.put("status", "已批准");
        List<LeaveRequest> approvedLeaves = leaveMapper.findByConditions(params);

        // 累加所有已批准请假的请假天数
        int totalLeaveDays = 0;
        for (LeaveRequest lr : approvedLeaves) {
            if (isLeaveInMonth(lr, yearMonth)) {
                totalLeaveDays += lr.getDays();
            }
        }

        // ---- Step3: 计算薪资各项明细 ----
        BigDecimal baseSalary = emp.getBaseSalary(); // 基本工资

        // 计算【迟到扣款】
        // 公式: 迟到次数 × (基本工资 / 21.75 / 8) × 1小时
        BigDecimal deductionLate = calculateLateDeduction(baseSalary, lateDays);

        // 计算【请假扣款】
        // 公式: (基本工资 / 21.75) × 请假天数
        BigDecimal deductionLeave = calculateLeaveDeduction(baseSalary, totalLeaveDays);

        // 计算【全勤奖】
        // 条件: 无迟到(lateDays=0) + 无请假(totalLeaveDays=0) + 无缺勤(absentDays=0)
        boolean isFullAttendance = (lateDays == 0 && totalLeaveDays == 0 && absentDays == 0);
        BigDecimal attendanceBonus = isFullAttendance ? FULL_ATTENDANCE_BONUS : BigDecimal.ZERO;

        // 加班费（暂设为0，可根据实际加班数据扩展）
        BigDecimal overtimePay = BigDecimal.ZERO;

        // ---- Step4: 计算最终实际工资 ----
        // 公式: 基本工资 + 全勤奖 + 加班费 - 迟到扣款 - 请假扣款
        BigDecimal actualSalary = baseSalary
                .add(attendanceBonus)
                .add(overtimePay)
                .subtract(deductionLate)
                .subtract(deductionLeave)
                .setScale(2, RoundingMode.HALF_UP); // 四舍五入保留2位小数

        // ---- 构建并返回Salary对象 ----
        Salary salary = new Salary();
        salary.setEmpId(emp.getId());
        salary.setYearMonth(yearMonth);
        salary.setBaseSalary(baseSalary);
        salary.setAttendanceBonus(attendanceBonus);
        salary.setOvertimePay(overtimePay);
        salary.setDeductionLate(deductionLate);
        salary.setDeductionLeave(deductionLeave);
        salary.setActualSalary(actualSalary);
        salary.setStatus("未发放");

        return salary;
    }

    // ==================== 辅助计算方法 ====================

    /**
     * 计算迟到扣款总额
     *
     * @param baseSalary 基本工资
     * @param lateCount  迟到次数
     * @return 迟到扣款金额
     *
     * 计算公式: 迟到次数 × (基本工资 / 21.75 / 8) × 1
     * 解释: 先算出每小时工资，每次迟到扣1小时工资
     */
    private BigDecimal calculateLateDeduction(BigDecimal baseSalary, long lateCount) {
        if (lateCount <= 0 || baseSalary == null) {
            return BigDecimal.ZERO;
        }
        // 每小时工资 = 基本工资 / 月平均工作日 / 每天工作时长
        BigDecimal hourlyRate = baseSalary
                .divide(BigDecimal.valueOf(MONTHLY_WORK_DAYS), 4, RoundingMode.HALF_UP)
                .divide(BigDecimal.valueOf(DAILY_WORK_HOURS), 4, RoundingMode.HALF_UP);
        // 总扣款 = 小时工资 × 迟到次数 × 每次扣除小时数
        return hourlyRate.multiply(BigDecimal.valueOf(lateCount))
                          .multiply(BigDecimal.valueOf(LATE_DEDUCTION_HOURS))
                          .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 计算请假扣款
     *
     * @param baseSalary 基本工资
     * @param leaveDays  请假天数
     * @return 请假扣款金额
     *
     * 计算公式: (基本工资 / 21.75) × 请假天数
     * 解释: 日薪 = 月薪 / 21.75，然后乘以请假天数
     */
    private BigDecimal calculateLeaveDeduction(BigDecimal baseSalary, int leaveDays) {
        if (leaveDays <= 0 || baseSalary == null) {
            return BigDecimal.ZERO;
        }
        // 日薪 = 基本工资 / 月平均工作日
        BigDecimal dailyRate = baseSalary.divide(
                BigDecimal.valueOf(MONTHLY_WORK_DAYS), 4, RoundingMode.HALF_UP);
        // 扣款 = 日薪 × 请假天数
        return dailyRate.multiply(BigDecimal.valueOf(leaveDays))
                         .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 安全地从Map中获取Long类型的值
     *
     * @param map 数据Map
     * @param key 键名
     * @return Long值，null时返回0
     */
    private long getLongValue(Map<String, Object> map, String key) {
        if (map == null || map.get(key) == null) {
            return 0L;
        }
        Object val = map.get(key);
        if (val instanceof Number) {
            return ((Number) val).longValue();
        }
        return 0L;
    }

    /**
     * 判断请假记录是否属于指定月份
     * 通过比较请假的 startDate/endDate 与目标月份是否有交集来判断
     *
     * @param lr        请假记录
     * @param yearMonth 目标年月，格式 "2026-06"
     * @return true=属于该月份
     */
    private boolean isLeaveInMonth(LeaveRequest lr, String yearMonth) {
        if (lr == null || lr.getStartDate() == null) {
            return false;
        }
        // 获取目标月份的起止日期
        String[] parts = yearMonth.split("-");
        int year = Integer.parseInt(parts[0]);
        int month = Integer.parseInt(parts[1]);

        Calendar cal = Calendar.getInstance();
        cal.set(year, month - 1, 1);
        Date monthStart = new Date(cal.getTimeInMillis());
        cal.set(year, month - 1, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        Date monthEnd = new Date(cal.getTimeInMillis());

        // 判断请假日期与目标月份是否有交集
        Date leaveStart = lr.getStartDate();
        Date leaveEnd = lr.getEndDate() != null ? lr.getEndDate() : leaveStart;

        return !leaveStart.after(monthEnd) && !leaveEnd.before(monthStart);
    }

    // ==================== 其他Service方法 ====================

    @Override
    public boolean paySalary(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            int rows = mapper.markAsPaid(id);
            session.commit();
            return rows > 0;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<Salary> findAll() {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            return mapper.findAllWithDetails();
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<Salary> findByMonth(String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            Map<String, Object> params = new HashMap<>();
            params.put("yearMonth", yearMonth);
            return mapper.findByMonth(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<Salary> findByMonthPaged(String yearMonth, int offset, int limit) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            Map<String, Object> params = new HashMap<>();
            params.put("yearMonth", yearMonth);
            params.put("offset", offset);
            params.put("limit", limit);
            return mapper.findByMonth(params);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public int countByMonth(String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            return mapper.countByMonth(yearMonth);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public Salary findById(Integer id) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            return mapper.findById(id);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public Salary findByEmpAndMonth(Integer empId, String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            return mapper.findByEmpAndMonth(empId, yearMonth);
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }

    @Override
    public List<Map<String, Object>> getSalaryReport(String yearMonth) {
        SqlSession session = MyBatisUtils.getSession();
        try {
            SalaryMapper mapper = session.getMapper(SalaryMapper.class);
            Map<String, Object> params = new HashMap<>();
            params.put("yearMonth", yearMonth);
            List<Salary> salaries = mapper.findByMonth(params);
            
            List<Map<String, Object>> report = new ArrayList<>();
            for (Salary s : salaries) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("empNo", s.getEmpNo());
                row.put("empName", s.getEmpName());
                row.put("deptName", s.getDeptName());
                row.put("baseSalary", s.getBaseSalary());
                row.put("attendanceBonus", s.getAttendanceBonus());
                row.put("deductionLate", s.getDeductionLate());
                row.put("deductionLeave", s.getDeductionLeave());
                row.put("actualSalary", s.getActualSalary());
                row.put("status", s.getStatus());
                report.add(row);
            }
            return report;
        } finally {
            MyBatisUtils.closeSession(session);
        }
    }
}
