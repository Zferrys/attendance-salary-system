package com.attendance.utils;

import com.alibaba.druid.pool.DruidDataSourceFactory;
import org.apache.ibatis.builder.xml.XMLConfigBuilder;
import org.apache.ibatis.io.Resources;
import org.apache.ibatis.mapping.Environment;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.ibatis.transaction.jdbc.JdbcTransactionFactory;

import javax.sql.DataSource;
import java.io.InputStream;
import java.util.Properties;

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
            // 1. 加载 mybatis-config.xml 获取全局配置（settings、typeAliases、mappers）
            String resource = "mybatis-config.xml";
            InputStream inputStream = Resources.getResourceAsStream(resource);
            XMLConfigBuilder parser = new XMLConfigBuilder(inputStream);
            Configuration configuration = parser.parse();

            // 2. 加载 Druid 连接池配置
            Properties druidProps = new Properties();
            try (InputStream druidStream = Resources.getResourceAsStream("druid.properties")) {
                druidProps.load(druidStream);
            }

            // 3. 创建真正的 Druid 数据源（使 keepAlive、testWhileIdle 等参数真正生效）
            DataSource dataSource = DruidDataSourceFactory.createDataSource(druidProps);

            // 4. 用 Druid 数据源替换 MyBatis 默认的 POOLED 连接池
            Environment environment = new Environment("development", new JdbcTransactionFactory(), dataSource);
            configuration.setEnvironment(environment);

            // 5. 构建 SqlSessionFactory
            sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);

            System.out.println("[MyBatis] 初始化成功！Druid 连接池已启用。");
        } catch (Exception e) {
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
