package com.attendance.service;

import com.attendance.entity.AttendRecord;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 考勤记录服务接口
 *
 * 封装考勤相关的所有业务逻辑，包括打卡判断、考勤查询与统计。
 */
public interface AttendRecordService {

    /** 根据员工ID和日期查询考勤记录（用于防重复打卡） */
    AttendRecord findByEmpAndDate(Integer empId, Date workDate);

    /** 多条件组合查询（支持分页） */
    List<AttendRecord> findByConditions(Map<String, Object> params);

    /** 统计符合条件的记录数 */
    int countByConditions(Map<String, Object> params);

    /** 根据ID查询 */
    AttendRecord findById(Integer id);

    /** 查询员工指定月份的考勤记录 */
    List<AttendRecord> findByEmpAndMonth(Integer empId, String yearMonth);

    /** 统计员工某月的各状态天数 */
    Map<String, Object> countByStatus(Integer empId, String yearMonth);

    /** 新增考勤记录（首次打卡） */
    int insert(AttendRecord record);

    /** 更新考勤记录（二次打卡或修改） */
    int update(AttendRecord record);

    /** 删除考勤记录 */
    boolean deleteById(Integer id);
}
