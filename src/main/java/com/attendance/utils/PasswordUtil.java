package com.attendance.utils;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.util.Base64;

/**
 * 安全密码工具类 (PBKDF2WithHmacSHA256)
 *
 * 替代已废弃的MD5加密，使用NIST推荐的PBKDF2算法。
 * 
 * 输出格式: {iterations}:{salt}:{hash}
 *   - iterations: 迭代次数 (默认 100000)
 *   - salt: 16字节随机盐 (Base64编码)
 *   - hash: 256位哈希值 (Base64编码)
 */
public class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 100000;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * 对明文密码进行哈希加密
     *
     * @param password 明文密码
     * @return 加密后的密文，格式为 {iterations}:{salt}:{hash}
     */
    public static String hash(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("密码不能为空");
        }
        byte[] salt = generateSalt();
        byte[] hash = pbkdf2(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
        return ITERATIONS + ":" + base64Encode(salt) + ":" + base64Encode(hash);
    }

    /**
     * 验证明文密码是否与密文匹配
     *
     * @param plainPassword  用户输入的明文密码
     * @param storedPassword 数据库中存储的密文 (可能是PBKDF2密文、MD5密文或明文)
     * @return true表示密码正确
     */
    public static boolean verify(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }

        // 1. 检测PBKDF2格式: {iterations}:{salt}:{hash}
        if (storedPassword.contains(":") && storedPassword.split(":").length == 3) {
            try {
                String[] parts = storedPassword.split(":");
                int iterations = Integer.parseInt(parts[0]);
                byte[] salt = base64Decode(parts[1]);
                byte[] expectedHash = base64Decode(parts[2]);
                byte[] actualHash = pbkdf2(plainPassword.toCharArray(), salt, iterations, KEY_LENGTH);
                return slowEquals(expectedHash, actualHash);
            } catch (Exception e) {
                return false;
            }
        }

        // 2. 兼容旧的MD5密码
        String md5Hash = md5Legacy(plainPassword);
        if (md5Hash != null && md5Hash.equals(storedPassword)) {
            return true;
        }

        // 3. 兼容历史遗留的明文密码
        return plainPassword.equals(storedPassword);
    }

    /**
     * 判断密码是否已经是PBKDF2加密格式
     */
    public static boolean isPBKDF2(String password) {
        return password != null && password.contains(":") && password.split(":").length == 3;
    }

    /**
     * 判断数据库中的密码是否需要升级为PBKDF2格式
     *
     * @param storedPassword 数据库中存储的密码
     * @return true 表示需要升级（是MD5或明文格式）
     */
    public static boolean needsUpgrade(String storedPassword) {
        if (storedPassword == null) {
            return false;
        }
        return !(storedPassword.contains(":") && storedPassword.split(":").length == 3);
    }

    // ==================== 内部实现 ====================

    private static byte[] generateSalt() {
        byte[] salt = new byte[SALT_LENGTH];
        RANDOM.nextBytes(salt);
        return salt;
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
        try {
            KeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            return factory.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("密码加密失败", e);
        }
    }

    /**
     * 恒定时间比较，防止时序攻击
     */
    private static boolean slowEquals(byte[] a, byte[] b) {
        int diff = a.length ^ b.length;
        for (int i = 0; i < a.length && i < b.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }

    private static String base64Encode(byte[] data) {
        return Base64.getEncoder().encodeToString(data);
    }

    private static byte[] base64Decode(String data) {
        return Base64.getDecoder().decode(data);
    }

    // ==================== 遗留MD5兼容 ====================

    /**
     * 旧版MD5哈希，仅用于兼容历史数据验证
     * @deprecated MD5已不安全，请使用 {@link #hash(String)}
     */
    @Deprecated
    public static String md5Legacy(String input) {
        if (input == null || input.isEmpty()) return null;
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
}
