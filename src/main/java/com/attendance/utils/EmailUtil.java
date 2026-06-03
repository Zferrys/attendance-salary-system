package com.attendance.utils;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * 邮件发送工具类
 * 用于工资发放后发送邮件通知员工
 */
public class EmailUtil {

    // 邮件服务器配置（演示用，实际应配置在properties文件中）
    private static final String SMTP_HOST = "smtp.qq.com";
    private static final String SMTP_PORT = "587";
    private static final String FROM_EMAIL = "1978738217@qq.com";
    private static final String FROM_PASSWORD = "obhteejihdkeccia";

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
        // 如果未配置邮箱，返回false（避免报错）
        if (FROM_EMAIL.contains("your_email")) {
            System.out.println("[邮件] 薪资通知（模拟）：" + empName + " " + yearMonth + " 实发 " + actualSalary);
            return true;
        }

        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("【薪资通知】" + yearMonth + " 工资已发放");
            message.setText("尊敬的 " + empName + "：\n\n"
                    + "您的 " + yearMonth + " 薪资已发放，实发金额：" + actualSalary + " 元。\n\n"
                    + "请登录系统查看详细薪资明细。\n\n"
                    + "如有疑问，请联系人力资源部。\n\n"
                    + "—— 考勤薪资管理系统");

            Transport.send(message);
            System.out.println("[邮件] 发送成功：发件=" + FROM_EMAIL + "，收件=" + toEmail + "，主题=薪资通知-" + yearMonth);
            return true;
        } catch (Exception e) {
            System.err.println("[邮件] 发送失败：" + e.getMessage());
            System.err.println("[邮件] 可能原因：1) SMTP授权码过期  2) 网络不通  3) 收件地址不存在");
            e.printStackTrace();
            return false;
        }
    }
}
