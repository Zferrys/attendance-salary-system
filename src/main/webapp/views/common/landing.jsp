<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>考勤薪资管理系统 - 智能企业考勤薪资一体化平台</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</head>
<body class="landing-page">

<!-- ====== Navbar ====== -->
<nav class="landing-nav" id="landingNav">
  <a href="#" class="nav-logo">
    <div class="logo-dot">
      <img src="${pageContext.request.contextPath}/assets/images/logo.svg" alt="Logo" width="18" height="18">
    </div>
    考勤薪资
  </a>
  <div class="nav-links">
    <a href="#features">功能</a>
    <a href="#showcase">亮点</a>
    <a href="#stats">数据</a>
    <a href="#contact">联系</a>
  </div>
  <div class="nav-cta">
    <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn-nav btn-nav-outline">登录系统</a>
    <a href="${pageContext.request.contextPath}/views/miniapp/login.jsp" class="btn-nav btn-nav-primary">小程序入口</a>
  </div>
</nav>

<!-- ====== Hero Carousel ====== -->
<section class="hero-carousel" id="hero">
  <div class="carousel-slides">
    <!-- Slide 1: 考勤打卡 -->
    <div class="carousel-slide active" style="background-image: url('${pageContext.request.contextPath}/assets/images/hero-slide-1.png'); background-size: cover; background-position: center;">
      <div class="slide-overlay"></div>
      <div class="slide-content">
        <div class="slide-text">
          <div class="slide-badge">核心功能</div>
          <h1>智能考勤打卡</h1>
          <p>支持 PC 端和小程序双端打卡，自动识别迟到早退<br>考勤数据实时同步，管理更高效</p>
          <div class="slide-actions">
            <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn-slide btn-slide-light">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
              立即登录
            </a>
          </div>
        </div>
      </div>
    </div>
    <!-- Slide 2: 薪资计算 -->
    <div class="carousel-slide" style="background-image: url('${pageContext.request.contextPath}/assets/images/hero-slide-2.png'); background-size: cover; background-position: center;">
      <div class="slide-overlay"></div>
      <div class="slide-content">
        <div class="slide-text">
          <div class="slide-badge">智能核算</div>
          <h1>自动薪资计算</h1>
          <p>基于考勤与请假数据一键生成月度薪资<br>全勤奖、迟到扣款自动核算，精准无误</p>
          <div class="slide-actions">
            <a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn-slide btn-slide-light">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
              立即登录
            </a>
          </div>
        </div>
      </div>
    </div>
    <!-- Slide 3: 移动小程序 -->
    <div class="carousel-slide" style="background-image: url('${pageContext.request.contextPath}/assets/images/hero-slide-3.png'); background-size: cover; background-position: center;">
      <div class="slide-overlay"></div>
      <div class="slide-content">
        <div class="slide-text">
          <div class="slide-badge">移动办公</div>
          <h1>小程序移动打卡</h1>
          <p>手机端随时随地打卡签到、查看考勤记录<br>薪资明细一键查询，请假申请快速提交</p>
          <div class="slide-actions">
            <a href="${pageContext.request.contextPath}/views/miniapp/login.jsp" class="btn-slide btn-slide-light">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg>
              进入小程序
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- 左右箭头 -->
  <button class="carousel-arrow carousel-prev" onclick="changeSlide(-1)" aria-label="上一张">&#10094;</button>
  <button class="carousel-arrow carousel-next" onclick="changeSlide(1)" aria-label="下一张">&#10095;</button>
  <!-- 底部圆点 -->
  <div class="carousel-dots">
    <span class="dot active" onclick="goToSlide(0)"></span>
    <span class="dot" onclick="goToSlide(1)"></span>
    <span class="dot" onclick="goToSlide(2)"></span>
  </div>
</section>

<!-- ====== Feature Showcase (Carousel) ====== -->
<section class="feature-showcase" id="showcase">
  <div class="section-header">
    <div class="section-badge">Platform Highlights</div>
    <h2>核心亮点</h2>
    <p>告别传统复杂流程，用数据驱动管理决策</p>
  </div>
  <div class="showcase-track">
    <div class="showcase-nav" id="showcaseNav">
      <div class="showcase-item active" data-index="0">
        <div class="sc-num">01</div>
        <h4>智能考勤打卡</h4>
        <p>PC端小程序双端支持，自动识别迟到早退缺勤状态，打卡数据实时同步。</p>
      </div>
      <div class="showcase-item" data-index="1">
        <div class="sc-num">02</div>
        <h4>自动薪资计算</h4>
        <p>根据考勤与请假数据一键生成月度薪资，全勤奖、迟到扣款自动核算。</p>
      </div>
      <div class="showcase-item" data-index="2">
        <div class="sc-num">03</div>
        <h4>多级权限管理</h4>
        <p>管理员、主管、员工三级角色分离，数据安全隔离，操作日志完整可追溯。</p>
      </div>
      <div class="showcase-item" data-index="3">
        <div class="sc-num">04</div>
        <h4>数据分析报表</h4>
        <p>月度薪资汇总、考勤统计图表、一键导出Excel/CSV，辅助管理决策。</p>
      </div>
    </div>
    <div class="showcase-visual" id="showcaseVisual">
      <div class="showcase-card active">
        <div class="sc-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-attendance.svg" alt="考勤" width="40" height="40"></div>
        <h3>智能考勤打卡</h3>
        <p>支持上班签到与下班签退，系统根据打卡时间自动判定考勤状态（正常/迟到/早退/缺勤），并自动统计月度出勤数据。</p>
      </div>
      <div class="showcase-card">
        <div class="sc-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-salary.svg" alt="薪资" width="40" height="40"></div>
        <h3>自动薪资计算</h3>
        <p>基于考勤统计与请假记录，系统按照国家标准（21.75天/月）自动计算迟到扣款、请假扣款、全勤奖及实发工资。</p>
      </div>
      <div class="showcase-card">
        <div class="sc-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-employee.svg" alt="权限" width="40" height="40"></div>
        <h3>多级权限管理</h3>
        <p>管理员全局管理、主管查看部门数据、员工管理个人考勤薪资，各角色权限清晰、互不干扰。</p>
      </div>
      <div class="showcase-card">
        <div class="sc-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-salary.svg" alt="报表" width="40" height="40"></div>
        <h3>数据分析报表</h3>
        <p>月度薪资汇总、部门考勤统计、发放状态分布一目了然，支持多维度筛选与一键导出。</p>
      </div>
    </div>
  </div>
</section>

<!-- ====== Core Features ====== -->
<section class="core-features" id="features">
  <div class="section-header">
    <div class="section-badge">Features</div>
    <h2>全部功能</h2>
    <p>覆盖考勤、薪资、员工管理的全流程</p>
  </div>
  <div class="features-grid">
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-attendance.svg" alt="考勤" width="32" height="32"></div>
      <h4>考勤管理</h4>
      <p>每日打卡签到签退、考勤日历展示、迟到早退缺勤自动标记、部门维度统计分析。</p>
    </div>
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-leave.svg" alt="请假" width="32" height="32"></div>
      <h4>请假审批</h4>
      <p>在线提交请假申请、主管审批流程、剩余假期跟踪、请假历史查询。</p>
    </div>
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-salary.svg" alt="薪资" width="32" height="32"></div>
      <h4>薪资计算</h4>
      <p>一键生成月度薪资、全勤奖300元自动判定、迟到请假自动扣款、薪资条打印。</p>
    </div>
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-employee.svg" alt="员工" width="32" height="32"></div>
      <h4>员工管理</h4>
      <p>员工信息维护、Excel批量导入导出、部门组织架构管理、工号自动分配。</p>
    </div>
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-miniapp.svg" alt="小程序" width="32" height="32"></div>
      <h4>移动小程序</h4>
      <p>手机端打卡签到、查看个人考勤记录、薪资明细查询、请假申请提交。</p>
    </div>
    <div class="feature-block">
      <div class="fb-icon"><img src="${pageContext.request.contextPath}/assets/images/feature-notify.svg" alt="通知" width="32" height="32"></div>
      <h4>消息通知</h4>
      <p>薪资发放邮件通知、请假审批状态推送、关键操作实时提醒。</p>
    </div>
  </div>
</section>

<!-- ====== Stats ====== -->
<section class="stats-section" id="stats">
  <div class="section-header">
    <div class="section-badge">Statistics</div>
    <h2>平台数据</h2>
    <p>用数字彰显实力</p>
  </div>
  <div class="stats-grid">
    <div class="stat-block">
      <div class="stat-num" data-target="3">0</div>
      <div class="stat-label">角色权限体系</div>
    </div>
    <div class="stat-block">
      <div class="stat-num" data-target="6">0</div>
      <div class="stat-label">核心功能模块</div>
    </div>
    <div class="stat-block">
      <div class="stat-num" data-target="100">0</div>
      <div class="stat-label">% 数据准确率</div>
    </div>
    <div class="stat-block">
      <div class="stat-num" data-target="7">0</div>
      <div class="stat-label">x24 全天可用</div>
    </div>
  </div>
</section>

<!-- ====== Contact / Footer ====== -->
<footer class="landing-footer" id="contact">
  <div class="footer-inner">
    <div class="footer-brand">
      <h3>考勤薪资管理系统</h3>
      <p>智能企业考勤薪资一体化平台，致力于为企业提供高效、精准、安全的人事管理解决方案。</p>
    </div>
    <div class="footer-col">
      <h4>快速入口</h4>
      <a href="${pageContext.request.contextPath}/views/common/login.jsp">PC 管理端登录</a>
      <a href="${pageContext.request.contextPath}/views/miniapp/login.jsp">小程序入口</a>
      <a href="#features">功能概览</a>
      <a href="#showcase">核心亮点</a>
    </div>
    <div class="footer-col">
      <h4>功能模块</h4>
      <a href="#">考勤打卡</a>
      <a href="#">薪资计算</a>
      <a href="#">请假审批</a>
      <a href="#">数据分析</a>
    </div>
    <div class="footer-col">
      <h4>联系我们</h4>
      <a href="mailto:1978738217@qq.com">📧 1978738217@qq.com</a>
    </div>
  </div>
  <div class="footer-bottom">
    &copy; 2026 考勤薪资管理系统. All Rights Reserved. | 数据加密传输，保障信息安全
  </div>
</footer>

<script>
(function() {
  'use strict';

  // ====== Navbar Scroll Effect ======
  var nav = document.getElementById('landingNav');
  window.addEventListener('scroll', function() {
    if (window.scrollY > 50) nav.classList.add('scrolled');
    else nav.classList.remove('scrolled');
  });

  // ====== Showcase Carousel ======
  var navItems = document.querySelectorAll('#showcaseNav .showcase-item');
  var visualCards = document.querySelectorAll('#showcaseVisual .showcase-card');
  var currentIndex = 0;
  var autoTimer;

  function switchShowcase(idx) {
    navItems.forEach(function(el) { el.classList.remove('active'); });
    visualCards.forEach(function(el) { el.classList.remove('active'); });
    navItems[idx].classList.add('active');
    visualCards[idx].classList.add('active');
    currentIndex = idx;
  }

  navItems.forEach(function(item) {
    item.addEventListener('click', function() {
      var idx = parseInt(this.getAttribute('data-index'));
      switchShowcase(idx);
      resetAutoSwitch();
    });
  });

  function autoSwitch() {
    var next = (currentIndex + 1) % navItems.length;
    switchShowcase(next);
  }

  function resetAutoSwitch() {
    clearInterval(autoTimer);
    autoTimer = setInterval(autoSwitch, 4000);
  }
  autoTimer = setInterval(autoSwitch, 4000);

  // ====== Hero Carousel ======
  var slides = document.querySelectorAll('.carousel-slide');
  var dots = document.querySelectorAll('.carousel-dots .dot');
  var heroIdx = 0;
  var heroTimer;

  function showSlide(n) {
    slides[heroIdx].classList.remove('active');
    dots[heroIdx].classList.remove('active');
    heroIdx = (n + slides.length) % slides.length;
    slides[heroIdx].classList.add('active');
    dots[heroIdx].classList.add('active');
  }

  window.changeSlide = function(dir) {
    showSlide(heroIdx + dir);
    resetHeroTimer();
  };
  window.goToSlide = function(n) {
    showSlide(n);
    resetHeroTimer();
  };

  function resetHeroTimer() {
    clearInterval(heroTimer);
    heroTimer = setInterval(function() { showSlide(heroIdx + 1); }, 5000);
  }
  heroTimer = setInterval(function() { showSlide(heroIdx + 1); }, 5000);

  // ====== Number Counter Animation ======
  var statsSection = document.getElementById('stats');
  var animated = false;

  function animateNumbers() {
    if (animated) return;
    var nums = document.querySelectorAll('.stat-num[data-target]');
    nums.forEach(function(el) {
      var target = parseInt(el.getAttribute('data-target'));
      var current = 0;
      var increment = Math.ceil(target / 40);
      var timer = setInterval(function() {
        current += increment;
        if (current >= target) { current = target; clearInterval(timer); }
        el.textContent = target === 100 ? current + '%' : current + '+';
      }, 40);
    });
    animated = true;
  }

  function checkScroll() {
    if (!statsSection) return;
    var rect = statsSection.getBoundingClientRect();
    if (rect.top < window.innerHeight * 0.75 && rect.bottom > 0) {
      animateNumbers();
    }
  }

  window.addEventListener('scroll', checkScroll);
  checkScroll();

  // ====== Smooth Scroll for Nav Links ======
  document.querySelectorAll('.landing-nav .nav-links a[href^="#"]').forEach(function(link) {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      var target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

})();
</script>

</body>
</html>
