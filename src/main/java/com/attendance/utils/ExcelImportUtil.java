package com.attendance.utils;

import com.attendance.entity.Employee;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

/**
 * Excel导入工具类
 * 支持从Excel文件批量导入员工信息
 */
public class ExcelImportUtil {

    /**
     * 从Excel输入流解析员工列表（工号由系统自动生成，不再从Excel读取）
     * 模板格式：角色(E/M/A) | 姓名 | 密码 | 部门ID | 职位 | 基本工资 | 入职日期 | 邮箱
     *
     * @param is Excel文件输入流
     * @return 员工列表（empNo 字段为空，由调用方自动分配）
     */
    public static List<Employee> parseEmployees(InputStream is) throws Exception {
        List<Employee> list = new ArrayList<>();
        Workbook workbook = new XSSFWorkbook(is);
        Sheet sheet = workbook.getSheetAt(0);

        // 从第2行开始读取（跳过表头）
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            // 列0: 角色标识（E=员工, M=主管, A=管理员），为空则跳过该行
            String role = getCellString(row.getCell(0));
            if (role == null || role.isEmpty()) continue;
            // 统一转大写并取首字母
            role = role.toUpperCase().trim();
            if (role.startsWith("A") || role.startsWith("管")) role = "A";
            else if (role.startsWith("M") || role.startsWith("主")) role = "M";
            else role = "E";

            Employee emp = new Employee();
            // 工号暂不设置，由调用方根据角色前缀自动分配
            // 设置角色
            if ("A".equals(role)) {
                emp.setRole("ADMIN");
            } else if ("M".equals(role)) {
                emp.setRole("MANAGER");
            } else {
                emp.setRole("EMPLOYEE");
            }
            emp.setName(getCellString(row.getCell(1)));
            emp.setPassword(MD5Util.md5(getCellString(row.getCell(2))));

            // 部门ID：兼容数字和文本格式
            Cell deptCell = row.getCell(3);
            int deptId = parseIntCell(deptCell);
            emp.setDeptId(deptId);

            emp.setPosition(getCellString(row.getCell(4)));

            // 基本工资：兼容数字和文本格式
            Cell salaryCell = row.getCell(5);
            double baseSalary = parseDoubleCell(salaryCell);
            emp.setBaseSalary(BigDecimal.valueOf(baseSalary));

            // 日期处理：兼容日期格式、标准日期字符串、中文日期格式
            Cell dateCell = row.getCell(6);
            Date parsedDate = parseDateCell(dateCell);
            if (parsedDate != null) {
                emp.setEntryDate(parsedDate);
            } else {
                // 日期为空或无法解析，使用当天日期作为默认值
                emp.setEntryDate(new Date(System.currentTimeMillis()));
            }

            // 邮箱（可选字段）
            Cell emailCell = row.getCell(7);
            if (emailCell != null) {
                String email = getCellString(emailCell);
                if (email != null && !email.isEmpty()) {
                    emp.setEmail(email);
                }
            }

            // 校验通过后暂存角色前缀（用 empNo 字段临时存储，调用方取出后覆盖）
            emp.setEmpNo(role);

            // 简单校验
            if (emp.getName() != null && !emp.getName().isEmpty()
                    && emp.getDeptId() != null && emp.getDeptId() > 0) {
                list.add(emp);
            }
        }

        workbook.close();
        return list;
    }

    private static String getCellString(Cell cell) {
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
            case NUMERIC:
                return String.valueOf((long) cell.getNumericCellValue());
            case FORMULA:
                try {
                    return String.valueOf((long) cell.getNumericCellValue());
                } catch (Exception e) {
                    return cell.getStringCellValue().trim();
                }
            default:
                return "";
        }
    }

    /** 解析整数单元格，兼容数字和文本格式 */
    private static int parseIntCell(Cell cell) {
        if (cell == null) return 0;
        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return (int) cell.getNumericCellValue();
            } else {
                String val = cell.getStringCellValue().trim();
                return Integer.parseInt(val);
            }
        } catch (Exception e) {
            return 0;
        }
    }

    /** 解析小数单元格，兼容数字和文本格式 */
    private static double parseDoubleCell(Cell cell) {
        if (cell == null) return 0.0;
        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            } else {
                String val = cell.getStringCellValue().trim().replace(",", "");
                return Double.parseDouble(val);
            }
        } catch (Exception e) {
            return 0.0;
        }
    }

    /** 解析日期单元格，兼容日期格式、yyyy-MM-dd、中文日期格式 */
    private static Date parseDateCell(Cell cell) {
        if (cell == null) return null;
        try {
            if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
                return new Date(cell.getDateCellValue().getTime());
            }
            String dateStr = cell.getStringCellValue().trim();
            if (dateStr.isEmpty()) return null;

            // 尝试 yyyy-MM-dd
            try {
                return Date.valueOf(dateStr);
            } catch (IllegalArgumentException ignored) {}

            // 尝试中文格式：2024年1月15日
            java.util.regex.Pattern cnPattern = java.util.regex.Pattern.compile("(\\d{4})年(\\d{1,2})月(\\d{1,2})日");
            java.util.regex.Matcher cnMatcher = cnPattern.matcher(dateStr);
            if (cnMatcher.matches()) {
                int year = Integer.parseInt(cnMatcher.group(1));
                int month = Integer.parseInt(cnMatcher.group(2));
                int day = Integer.parseInt(cnMatcher.group(3));
                return Date.valueOf(String.format("%04d-%02d-%02d", year, month, day));
            }

            // 尝试 yyyy/MM/dd
            java.util.regex.Pattern slashPattern = java.util.regex.Pattern.compile("(\\d{4})/(\\d{1,2})/(\\d{1,2})");
            java.util.regex.Matcher slashMatcher = slashPattern.matcher(dateStr);
            if (slashMatcher.matches()) {
                int year = Integer.parseInt(slashMatcher.group(1));
                int month = Integer.parseInt(slashMatcher.group(2));
                int day = Integer.parseInt(slashMatcher.group(3));
                return Date.valueOf(String.format("%04d-%02d-%02d", year, month, day));
            }

            // 尝试 yyyy年M月
            java.util.regex.Pattern monthPattern = java.util.regex.Pattern.compile("(\\d{4})年(\\d{1,2})月");
            java.util.regex.Matcher monthMatcher = monthPattern.matcher(dateStr);
            if (monthMatcher.matches()) {
                int year = Integer.parseInt(monthMatcher.group(1));
                int month = Integer.parseInt(monthMatcher.group(2));
                return Date.valueOf(String.format("%04d-%02d-01", year, month));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
