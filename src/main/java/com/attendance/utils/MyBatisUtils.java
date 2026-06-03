package com.attendance.utils;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

import java.io.IOException;
import java.io.InputStream;

/**
 * MyBatis 工具类（单例模式）
 *
 * 用途: 统一管理 SqlSessionFactory 和 SqlSession 的创建与释放。
 *       所有Service层都通过此类获取数据库会话。
 *
 * 核心功能:
 *   1. 加载 mybatis-config.xml 配置文件
 *   2. 创建 SqlSessionFactory（全局唯一，应用启动时初始化一次）
 *   3. 提供获取 SqlSession 的静态方法
 *   4. 提供 Session 的安全关闭方法
 *
 * 使用示例:
 * <pre>
 *     // 获取SqlSession
 *     SqlSession session = MyBatisUtils.getSession();
 *     try {
 *         EmployeeMapper mapper = session.getMapper(EmployeeMapper.class);
 *         Employee emp = mapper.findById(1);
 *         session.commit();  // 提交事务
 *     } finally {
 *         MyBatisUtils.closeSession(session);  // 确保关闭
 *     }
 * </pre>
 */
public class MyBatisUtils {

    /** 全局唯一的SqlSessionFactory实例（线程安全） */
    private static SqlSessionFactory sqlSessionFactory;

    /**
     * 静态代码块 - 应用启动时执行一次
     * 负责加载MyBatis配置文件并创建SqlSessionFactory
     */
    static {
        try {
            // 从classpath读取mybatis-config.xml配置文件
            String resource = "mybatis-config.xml";
            InputStream inputStream = Resources.getResourceAsStream(resource);

            // 使用SqlSessionFactoryBuilder构建工厂
            sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

            System.out.println("[MyBatis] 初始化成功！SqlSessionFactory已创建。");
        } catch (IOException e) {
            throw new RuntimeException("MyBatis初始化失败！请检查配置文件路径和内容。", e);
        }
    }

    /**
     * 禁止外部实例化（工具类设计原则）
     */
    private MyBatisUtils() {}

    /**
     * 获取一个新的SqlSession
     *
     * @return SqlSession 数据库会话对象
     * 注意: 每次调用返回新的Session，使用后必须调用closeSession()关闭
     */
    public static SqlSession getSession() {
        return sqlSessionFactory.openSession(false); // false=手动提交事务
    }

    /**
     * 安全关闭SqlSession
     * 处理null值检查，避免NPE异常
     *
     * @param session 要关闭的SqlSession
     */
    public static void closeSession(SqlSession session) {
        if (session != null) {
            session.close();
        }
    }

    /**
     * 获取SqlSessionFactory（供特殊场景使用）
     * 例如需要自定义Session配置时
     *
     * @return SqlSessionFactory 工厂实例
     */
    public static SqlSessionFactory getSqlSessionFactory() {
        return sqlSessionFactory;
    }
}
