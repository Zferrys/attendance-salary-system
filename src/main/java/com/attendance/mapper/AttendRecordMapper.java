package com.attendance.mapper;

import com.attendance.entity.AttendRecord;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 考勤记录Mapper接口
 * 对应XML映射文件: mapper/AttendRecordMapper.xml
 *
 * 核心功能:
 *   - 打卡操作（判断重复打卡，INSERT或UPDATE）
 *   - 【动态SQL】考勤查询（@SelectProvider + 多条件组合）
 *   - 月度考勤统计
 *
 * 技术约束:
 *   - 每人每天只能有1条考勤记录（联合唯一键 emp_id+work_date）
 *   - 每天最多打卡2次（上班1次+下班1次）
 */
public interface AttendRecordMapper {

    /**
     * 根据员工ID和日期查询当日考勤记录
     * 用于判断当天是否已打卡（避免重复打卡）
     *
     * @param empId 员工ID
     * @param workDate 工作日期
     * @return 考勤记录，不存在返回null
     */
    AttendRecord findByEmpAndDate(@Param("empId") Integer empId, @Param("workDate") Date workDate);

    /**
     * 【动态SQL】多条件组合查询考勤记录（支持分页）
     *
     * 支持的查询条件:
     *   - empId (Integer): 指定员工
     *   - startDate (Date): 日期范围-开始
     *   - endDate (Date): 日期范围-结束
     *   - status (String): 考勤状态筛选（正常/迟到/早退/缺勤）
     *   - deptId (Integer): 按部门筛选
     *   - offset (Integer): 分页偏移量
     *   - limit (Integer): 每页记录数
     *
     * @param params 条件Map
     * @return 符合条件的考勤记录列表
     */
    List<AttendRecord> findByConditions(Map<String, Object> params);

    /**
     * 统计符合条件的考勤记录总数
     * @param params 条件Map（与findByConditions使用相同的条件）
     * @return 记录总数
     */
    int countByConditions(Map<String, Object> params);

    /**
     * 新增考勤记录（首次打卡时使用）
     * 当天无任何记录时执行INSERT
     *
     * @param record 考勤记录实体
     * @return 影响行数
     */
    int insert(AttendRecord record);

    /**
     * 更新考勤记录（第二次打卡时使用）
     * 已有上班记录时更新下班时间和状态
     *
     * @param record 考勤记录实体
     * @return 影响行数
     */
    int update(AttendRecord record);

    /**
     * 查询员工在指定月份的所有考勤记录（用于月度考勤日历展示）
     *
     * @param empId 员工ID
     * @param yearMonth 年月字符串（如 "2026-06"）
     * @return 该月的所有考勤记录列表
     */
    List<AttendRecord> findByEmpAndMonth(@Param("empId") Integer empId, @Param("yearMonth") String yearMonth);

    /**
     * 统计指定月份某员工的各状态天数
     *
     * @param empId 员工ID
     * @param yearMonth 年月
     * @return 统计结果Map: {正常: x天, 迟到: y天, 早退: z天, 缺勤: n天}
     */
    Map<String, Object> countByStatus(@Param("empId") Integer empId, @Param("yearMonth") String yearMonth);

    /**
     * 根据ID删除考勤记录
     *
     * @param id 记录ID
     * @return 影响行数
     */
    int deleteById(Integer id);

    /**
     * 根据ID查询考勤记录
     *
     * @param id 记录ID
     * @return 考勤记录
     */
    AttendRecord findById(Integer id);
}
