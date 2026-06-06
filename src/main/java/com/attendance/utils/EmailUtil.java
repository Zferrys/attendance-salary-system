package com.attendance.utils;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.InputStream;
import java.util.Properties;

/**
 * 邮件发送工具类
 * 用于工资发放后发送邮件通知员工
 * <p>
 * 配置方式：在 src/main/resources/email.properties 中配置邮箱信息（该文件已在 .gitignore 中排除）
 * 格式：
 *   mail.smtp.host=smtp.qq.com
 *   mail.smtp.port=587
 *   mail.from.email=your_email@qq.com
 *   mail.from.password=your_smtp_auth_code
 */
public class EmailUtil {

    // 配置缓存
    private static Properties emailConfig;

    static {
        emailConfig = new Properties();
        try (InputStream is = EmailUtil.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                emailConfig.load(is);
            }
        } catch (Exception e) {
            System.err.println("[邮件] 未找到 email.properties，邮件功能将使用模拟模式");
        }
    }

    private static String getConfig(String key) {
        return emailConfig != null ? emailConfig.getProperty(key) : null;
    }

    /**
     * 发送薪资通知邮件
     *
     * @param toEmail  收件人邮箱
     * @param empName  员工姓名
     * @param yearMonth 薪资月份
     * @param actualSalary 实发工资
     * @return true=发送成功
     */
    public static boolean sendSalaryNotification(String toEmail, String empName,
                                                  String yearMonth, String actualSalary) {
        String smtpHost = getConfig("mail.smtp.host");
        String smtpPort = getConfig("mail.smtp.port");
        String fromEmail = getConfig("mail.from.email");
        String fromPassword = getConfig("mail.from.password");

        // 如果未配置邮箱，使用模拟模式
        if (fromEmail == null || fromPassword == null ||
                "your_email@qq.com".equals(fromEmail) || "your_smtp_auth_code".equals(fromPassword)) {
            System.out.println("[邮件] 薪资通知（模拟）：" + empName + " " + yearMonth + " 实发 " + actualSalary);
            return true;
        }

        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", smtpHost);
            props.put("mail.smtp.port", smtpPort);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(fromEmail, fromPassword);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("【薪资通知】" + yearMonth + " 工资已发放");
            message.setText("尊敬的 " + empName + "：\n\n"
                    + "您的 " + yearMonth + " 薪资已发放，实发金额：" + actualSalary + " 元。\n\n"
                    + "请登录系统查看详细薪资明细。\n\n"
                    + "如有疑问，请联系人力资源部。\n\n"
                    + "—— 考勤薪资管理系统");

            Transport.send(message);
            System.out.println("[邮件] 发送成功：发件=" + fromEmail + "，收件=" + toEmail + "，主题=薪资通知-" + yearMonth);
            return true;
        } catch (Exception e) {
            System.err.println("[邮件] 发送失败：" + e.getMessage());
            System.err.println("[邮件] 可能原因：1) SMTP授权码过期  2) 网络不通  3) 收件地址不存在");
            e.printStackTrace();
            return false;
        }
    }
}
