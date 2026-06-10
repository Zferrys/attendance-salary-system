package com.attendance.utils;

import java.security.MessageDigest;

/**
 * MD5 加密工具类
 *
 * @deprecated MD5已被破解，不安全。请使用 {@link PasswordUtil} 替代。
 *             此类仅保留用于历史数据兼容。
 */
@Deprecated
public class MD5Util {

    @Deprecated
    public static String md5(String input) {
        return PasswordUtil.md5Legacy(input);
    }

    /**
     * @deprecated 请使用 {@link PasswordUtil#verify(String, String)} 替代
     */
    @Deprecated
    public static boolean verify(String plainPassword, String hashedPassword) {
        return PasswordUtil.verify(plainPassword, hashedPassword);
    }
}
