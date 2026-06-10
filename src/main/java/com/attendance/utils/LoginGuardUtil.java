package com.attendance.utils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 登录防护工具类
 *
 * 功能:
 *   1. 防止暴力破解 - 同一IP连续失败5次后锁定15分钟
 *   2. 同一账号连续失败5次后锁定15分钟
 */
public class LoginGuardUtil {

    /** 最大失败次数 */
    private static final int MAX_ATTEMPTS = 5;
    /** 锁定时间（毫秒） */
    private static final long LOCK_DURATION_MS = 15 * 60 * 1000; // 15分钟

    /** IP级别的失败记录 */
    private static final Map<String, FailureRecord> ipFailures = new ConcurrentHashMap<>();
    /** 账号级别的失败记录 */
    private static final Map<String, FailureRecord> accountFailures = new ConcurrentHashMap<>();

    /**
     * 检查指定IP是否已被锁定
     *
     * @param clientIp 客户端IP
     * @return 锁定原因，null表示未锁定
     */
    public static String checkLocked(String clientIp) {
        FailureRecord ipRecord = ipFailures.get(clientIp);
        if (ipRecord != null && ipRecord.isLocked()) {
            long remaining = (ipRecord.lockedAt + LOCK_DURATION_MS - System.currentTimeMillis()) / 60000;
            return "登录尝试过于频繁，请等待 " + Math.max(1, remaining) + " 分钟后再试";
        }
        return null;
    }

    /**
     * 检查指定账号是否已被锁定
     *
     * @param empNo 员工工号
     * @return 锁定原因，null表示未锁定
     */
    public static String checkAccountLocked(String empNo) {
        FailureRecord accountRecord = accountFailures.get(empNo);
        if (accountRecord != null && accountRecord.isLocked()) {
            long remaining = (accountRecord.lockedAt + LOCK_DURATION_MS - System.currentTimeMillis()) / 60000;
            return "该账号登录失败次数过多，请等待 " + Math.max(1, remaining) + " 分钟后再试";
        }
        return null;
    }

    /**
     * 记录一次登录失败
     *
     * @param clientIp 客户端IP
     * @param empNo    员工工号
     */
    public static void recordFailure(String clientIp, String empNo) {
        // 记录IP失败
        FailureRecord ipRecord = ipFailures.computeIfAbsent(clientIp, k -> new FailureRecord());
        ipRecord.recordFailure();

        // 记录账号失败
        if (empNo != null && !empNo.isEmpty()) {
            FailureRecord accountRecord = accountFailures.computeIfAbsent(empNo, k -> new FailureRecord());
            accountRecord.recordFailure();
        }
    }

    /**
     * 清除失败记录（登录成功后调用）
     *
     * @param clientIp 客户端IP
     * @param empNo    员工工号
     */
    public static void clearFailures(String clientIp, String empNo) {
        ipFailures.remove(clientIp);
        if (empNo != null && !empNo.isEmpty()) {
            accountFailures.remove(empNo);
        }
    }

    /**
     * 获取客户端真实IP
     */
    public static String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 处理多级代理，取第一个IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    /**
     * 失败记录内部类
     */
    private static class FailureRecord {
        int count = 0;
        long lockedAt = 0;

        void recordFailure() {
            count++;
            if (count >= MAX_ATTEMPTS) {
                lockedAt = System.currentTimeMillis();
            }
        }

        boolean isLocked() {
            if (count < MAX_ATTEMPTS) return false;
            // 检查锁定是否过期
            if (System.currentTimeMillis() - lockedAt > LOCK_DURATION_MS) {
                count = 0;
                lockedAt = 0;
                return false;
            }
            return true;
        }
    }
}
