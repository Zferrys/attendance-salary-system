package com.attendance.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * MD5 加密工具类
 *
 * 用途：对用户密码进行MD5哈希处理，确保数据库中不存储明文密码。
 * 注意：已存在的旧数据（明文密码）不会被修改，仅对新添加/修改的密码进行加密。
 */
public class MD5Util {

    /**
     * 对字符串进行MD5加密，返回32位小写十六进制字符串
     *
     * @param input 原始字符串
     * @return MD5哈希值（32位小写十六进制）
     */
    public static String md5(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5算法不可用", e);
        } catch (Exception e) {
            throw new RuntimeException("MD5加密失败", e);
        }
    }

    /**
     * 验证明文密码是否与MD5哈希值匹配
     *
     * @param plainPassword  用户输入的明文密码
     * @param hashedPassword 数据库中存储的密码（可能是MD5或明文）
     * @return true表示匹配
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        // 先尝试MD5比对（新数据）
        String md5Hash = md5(plainPassword);
        if (md5Hash.equals(hashedPassword)) {
            return true;
        }
        // 兼容旧数据：直接明文比对（历史遗留的明文密码）
        return plainPassword.equals(hashedPassword);
    }
}
