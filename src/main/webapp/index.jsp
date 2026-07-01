<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%@ page import="util.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String profilePicture = (String) session.getAttribute("profilePicture");
    boolean loggedIn = (userId != null);
    
    String filter = request.getParameter("filter");
    if (filter == null || filter.trim().isEmpty()) {
        filter = "all";
    }
    
    String searchText = request.getParameter("search");
    if (searchText == null) {
        searchText = "";
    }
    
    int selectedCategoryId = 0;
    try {
        String catParam = request.getParameter("categoryId");
        if (catParam != null && !catParam.trim().isEmpty()) {
            selectedCategoryId = Integer.parseInt(catParam.trim());
        }
    } catch (Exception e) {
        selectedCategoryId = 0;
    }
    
    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
            : "image/profile.jpeg";
            
    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;
    if (loggedIn) {
        try (Connection conn = util.DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) c FROM likes lk JOIN reviews r ON r.review_id = lk.review_id WHERE r.user_id=? AND lk.user_id <> ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) notiLikes = rs.getInt("c");
                }
            } catch (Exception ignore) {}
            
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) c FROM comments c JOIN reviews r ON r.review_id = c.review_id WHERE r.user_id=? AND c.user_id <> ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) notiComments = rs.getInt("c");
                }
            } catch (Exception ignore) {}
            notiTotal = notiLikes + notiComments;
        } catch (Exception ignore) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Local Treasure Terengganu</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="css/styles.css">
        <link rel="stylesheet" href="css/home.css">
        <style>
            .nav-guest{ display:inline-flex; align-items:center; gap:8px; color:#fff; font-weight:700; }
            .guest-badge{ width:32px; height:32px; border-radius:50%; display:grid; place-items:center; background:rgba(255,255,255,0.18); border:2px solid #f8c471; font-weight:800; }
            .guest-text{ opacity:.9; }
            .cta-wrap{ max-width:980px; margin:-40px auto 30px; padding:0 20px; position:relative; z-index:200; }
            .cta-card{ background:rgba(255,255,255,0.12); border:1px solid rgba(255,255,255,0.18); backdrop-filter:blur(12px); border-radius:16px; padding:26px 22px; color:#fff; text-align:center; box-shadow:0 10px 25px rgba(0,0,0,0.18); }
            .cta-card h3{ margin:0 0 10px 0; font-size:22px; font-weight:800; }
            .cta-card p{ margin:0 auto 18px; max-width:820px; opacity:0.92; line-height:1.6; }
            .cta-btn{ display:inline-flex; align-items:center; gap:10px; background:#fff; color:#111827; text-decoration:none; padding:12px 18px; border-radius:12px; font-weight:800; border:1px solid rgba(0,0,0,0.08); margin:5px; }
            .nav-noti{ position:relative; display:inline-flex; align-items:center; justify-content:center; width:40px; height:40px; border:2px solid #111; border-radius:999px; background:#fff; color:#111; text-decoration:none; box-shadow:0 6px 0 #111; }
            .nav-noti:hover{ background:#111; color:#fff; }
            .nav-noti .noti-badge{ position:absolute; top:-8px; right:-8px; min-width:22px; height:22px; padding:0 6px; border-radius:999px; border:2px solid #111; background:#ff4757; color:#fff; font-weight:1000; font-size:12px; display:inline-flex; align-items:center; justify-content:center; }
            .love-btn{ width:44px; height:44px; border-radius:999px; border:2px solid #111; background:#fff; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; box-shadow:0 6px 0 #111; transition:0.2s; }
            .love-btn i{ font-size:18px; }
            .love-btn:hover{ transform:translateY(-2px); box-shadow:0 10px 0 #111; }
            .love-btn.active{ background:#ff4757; color:#fff; border-color:#111; }
            .business-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:20px; margin-top:20px; }
            .business-card{ background:#fff; border-radius:18px; overflow:hidden; box-shadow:0 10px 24px rgba(0,0,0,.12); border:1px solid #eee; display:flex; flex-direction:column; }
            .business-card-top{ background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; text-align:center; position:relative; padding-bottom:18px; }
            .business-icon{ font-size:42px; margin:10px 0; }
            .business-name{ font-size:22px; font-weight:800; margin:0; }
            .business-owner{ font-size:14px; opacity:.92; margin-top:6px; }
            .business-card-body{ padding:18px; }
            .business-info{ margin:8px 0; color:#444; font-size:14px; line-height:1.6; }
            .business-info i{ width:18px; margin-right:8px; color:#667eea; }
            .business-desc{ color:#666; font-size:14px; margin:12px 0 16px; line-height:1.7; }
            .business-badge{ display:inline-block; background:#eef2ff; color:#4f46e5; padding:6px 12px; border-radius:999px; font-size:12px; font-weight:700; }
            .featured-badge{ display:inline-block; background:#f59e0b; color:white; padding:6px 12px; border-radius:999px; font-size:12px; font-weight:800; margin-bottom:10px; }
            
            /* Chatbox CSS */
            #chatbox-container { position: fixed; left: 20px; top: 50%; transform: translateY(-50%); width: 260px; max-height: 360px; background: #ffffff; border: 2px solid #111; border-radius: 12px; box-shadow: 0 6px 0 #111; display: flex; flex-direction: column; font-family: Arial, sans-serif; z-index: 9999; overflow: hidden; transition: all 0.3s ease; }
            #chatbox-header { background: #111827; color: #fff; padding: 8px 10px; font-weight: bold; cursor: pointer; display: flex; align-items: center; gap: 8px; font-size: 13px; }
            #chatbox-header img { width: 24px; height: 24px; border-radius: 50%; }
            #chatbox-messages { flex: 1; padding: 10px; overflow-y: auto; background: #f9f9f9; font-size: 12px; height: 200px; }
            .chat-message { margin-bottom: 8px; display: flex; gap: 6px; }
            .chat-message.user { justify-content: flex-end; }
            .chat-message .bubble { padding: 6px 10px; border-radius: 10px; max-width: 75%; word-wrap: break-word; }
            .chat-message.user .bubble { background: #111827; color: #fff; border-bottom-right-radius: 0; }
            .chat-message.bot .bubble { background: #e5e7eb; color: #111827; border-bottom-left-radius: 0; }
            #chatbox-input { display: flex; border-top: 1px solid #ccc; }
            #chatbox-input input { flex: 1; padding: 8px; border: none; outline: none; font-size: 12px; }
            #chatbox-input button { padding: 8px 12px; background: #111827; color: #fff; border: none; cursor: pointer; font-size: 12px; }
            #chatbox-container.minimized { width: 170px; max-height: 38px; box-shadow: 0 4px 0 #111; }
            @media (max-width: 768px) { #chatbox-container { left: 10px; width: 220px; } #chatbox-container.minimized { width: 140px; } }
        </style>
    </head>
    <body>
        <nav class="navbar">
            <div class="container navbar-container">
                <div class="navbar-left">
                    <a href="index.jsp" class="nav-link active">Explore</a>
                    <a href="bookmark.jsp" class="nav-link">Bookmark</a>
                    <a href="treasures.jsp" class="nav-link">Treasures</a>
                </div>
                <a href="index.jsp" class="navbar-brand">
                    <div class="brand-main">Local Treasure Terengganu</div>
                    <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
                </a>
                <div class="navbar-right">
                    <% if (loggedIn) { %>
                    <a href="notifications.jsp?type=ALL" class="nav-noti" title="Notifications">
                        <i class="fas fa-bell"></i>
                        <% if (notiTotal > 0) {%>
                        <span class="noti-badge"><%= notiTotal%></span>
                        <% }%>
                    </a>
                    <a href="user_profile.jsp" class="nav-profile">
                        <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                        <span><%= username%></span>
                    </a>
                    <% if ("Local Business".equalsIgnoreCase(role)) { %>
                    <a href="business_dashboard.jsp" class="nav-link">Dashboard</a>
                    <% }%>
                    <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
                    <% } else { %>
                    <div class="nav-guest"><div class="guest-badge">G</div><span class="guest-text">Guest</span></div>
                    <a href="login.jsp" class="nav-link">Login</a>
                    <a href="sign_up.jsp?from=home" class="nav-link">Sign Up</a>
                    <% } %>
                </div>
                    <div class="navbar-mobile-menu" id="navbarMobileMenu">
                <a href="index.jsp" class="nav-link active">Explore</a>
                <a href="bookmark.jsp" class="nav-link">Bookmark</a>
                <a href="treasures.jsp" class="nav-link">Treasures</a>
                <% if (loggedIn) { %>
                <a href="notifications.jsp?type=ALL" class="nav-link">Notifications <% if (notiTotal > 0) { %>(<%= notiTotal %>)<% } %></a>
                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl %>" class="nav-profile-img">
                    <span><%= username %></span>
                </a>
                <% if ("Local Business".equalsIgnoreCase(role)) { %>
                <a href="business_dashboard.jsp" class="nav-link">Dashboard</a>
                <% } %>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
                <% } else { %>
                <a href="login.jsp" class="nav-link">Login</a>
                <a href="sign_up.jsp?from=home" class="nav-link">Sign Up</a>
                <% } %>
            </div>
                <button class="navbar-toggle" id="navbarToggle" type="button"><i class="fas fa-bars"></i></button>
            </div>
        </nav>
        <header class="header">
            <div class="container header-content">
                <h1>Local Treasure Terengganu</h1>
                <p>Discover Terengganu's Hidden Treasures</p>
                <% if (!loggedIn) { %>
                <div class="header-actions">
                    <a href="sign_up.jsp?from=home" class="btn-signup">Sign Up to Get Started</a>
                    <button class="explore-btn" type="button">Explore</button>
                </div>
                <% }%>
            </div>
        </header>
        <section class="cta-wrap">
            <div class="cta-card">
                <h3>Know a Hidden Gem?</h3>
                 <div style="margin-top:15px; display:flex; gap:10px; justify-content:center; flex-wrap:wrap;">
                    <a class="cta-btn" href="<%= loggedIn ? "submit_location.jsp" : "login.jsp?redirect=submit_location.jsp" %>">
                        <i class="fas fa-plus"></i>
                        <span>Add Location</span>
                    </a>
                </div>
                <p>Share your favorite local spots with fellow explorers and help others discover the best of Terengganu.</p>
            </div>
        </section>
        <section class="search-section">
            <div class="container search-container">
                <div class="filter-dropdown">
                    <select id="filter-options" onchange="searchLocations()">
                        <option value="all" <%= "all".equals(filter) ? "selected" : ""%>>All Locations</option>
                        <option value="rated" <%= "rated".equals(filter) ? "selected" : ""%>>Top Rated</option>
                        <option value="views" <%= "views".equals(filter) ? "selected" : ""%>>Top View</option>
                        <option value="popular" <%= "popular".equals(filter) ? "selected" : ""%>>Top Location</option>
                        <option value="featured" <%= "featured".equals(filter) ? "selected" : ""%>>Featured Location</option>
                    </select>
                </div>
                <input type="text" id="search" class="search-input" placeholder="Search locations..." value="<%= searchText%>">
                <button class="search-btn" onclick="searchLocations()" type="button">Search</button>
            </div>
        </section>
        <section class="categories-section container">
            <h2>Explore By Category</h2>
            <div class="categories">
                <button class="category-btn <%= (selectedCategoryId == 0) ? "active" : ""%>" onclick="applyCategory(0)" type="button">All Treasures</button>
                <%
                	try (Connection conn = util.DBConnection.getConnection()) {
                        String catSql = "SELECT category_id, name FROM categories ORDER BY name ASC";
                        try (PreparedStatement psC = conn.prepareStatement(catSql); ResultSet rsC = psC.executeQuery()) {
                            while (rsC.next()) {
                                int cId = rsC.getInt("category_id");
                                String cName = rsC.getString("name");
                %>
                <button class="category-btn <%= (selectedCategoryId == cId) ? "active" : ""%>" onclick="applyCategory(<%= cId%>)" type="button"><%= cName%></button>
                <%
                            }
                        }
                    } catch (Exception e) {}
                %>
            </div>
        </section>
        <section class="treasures-section container">
            <h2 class="section-title">
                <% if ("all".equals(filter)) { %> All Locations 
                <% } else if ("rated".equals(filter)) { %> Top Rated Locations 
                <% } else if ("views".equals(filter)) { %> Top View Locations 
                <% } else if ("popular".equals(filter)) { %> Top Locations 
                <% } else if ("featured".equals(filter)) { %> Featured Locations 
                <% } %>
            </h2>
            <div class="treasures-grid">
                <%
                    try (Connection conn = util.DBConnection.getConnection()) {
                        StringBuilder sql = new StringBuilder();
                        sql.append("SELECT l.location_id, l.name, l.description, l.image, l.views, l.is_featured, ");
                        sql.append(loggedIn ? "EXISTS(SELECT 1 FROM bookmarks b WHERE b.user_id=? AND b.location_id=l.location_id) AS bookmarked, " : "0 AS bookmarked, ");
                        sql.append("COALESCE(AVG(r.rating), 0) AS avg_rating, COUNT(r.review_id) AS total_reviews FROM location l ");
                        sql.append("LEFT JOIN reviews r ON l.location_id = r.location_id ");
                        
                        ArrayList<String> whereList = new ArrayList<>();
                        // Ensure businesses are hidden from this section
                        whereList.add("l.business_id IS NULL");
                        
                        if (selectedCategoryId > 0) { whereList.add("l.category_id = ?"); }
                        if ("featured".equals(filter)) { whereList.add("l.is_featured = 1"); }
                        if (searchText != null && !searchText.trim().isEmpty()) {
                            whereList.add("(l.name LIKE ? OR l.description LIKE ?)");
                        }
                        
                        if (!whereList.isEmpty()) {
                            sql.append("WHERE ");
                            for (int i = 0; i < whereList.size(); i++) {
                                if (i > 0) sql.append(" AND ");
                                sql.append(whereList.get(i));
                            }
                        }
                        
                        sql.append(" GROUP BY l.location_id, l.name, l.description, l.image, l.views, l.is_featured ");
                        
                        if ("rated".equals(filter)) { sql.append("ORDER BY avg_rating DESC, l.location_id DESC "); } 
                        else if ("views".equals(filter)) { sql.append("ORDER BY l.views DESC, l.location_id DESC "); } 
                        else if ("popular".equals(filter)) { sql.append("ORDER BY total_reviews DESC, l.views DESC, l.location_id DESC "); } 
                        else { sql.append("ORDER BY l.location_id DESC "); }
                        
                        sql.append("LIMIT 6");
                        
                        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                            int idx = 1;
                            if (loggedIn) ps.setInt(idx++, userId);
                            if (selectedCategoryId > 0) ps.setInt(idx++, selectedCategoryId);
                            if (searchText != null && !searchText.trim().isEmpty()) {
                                String kw = "%" + searchText.trim() + "%";
                                ps.setString(idx++, kw);
                                ps.setString(idx++, kw);
                            }
                            
                            try (ResultSet rs = ps.executeQuery()) {
                                boolean any = false;
                                while (rs.next()) {
                                    any = true;
                                    int locId = rs.getInt("location_id");
                                    String name = rs.getString("name");
                                    String desc = rs.getString("description");
                                    String img = rs.getString("image");
                                    int views = rs.getInt("views");
                                    int isFeatured = rs.getInt("is_featured");
                                    double avgR = rs.getDouble("avg_rating");
                                    int totalRev = rs.getInt("total_reviews");
                                    boolean bkmk = rs.getInt("bookmarked") == 1;
                                    
                                   String imgUrl = request.getContextPath() + "/image/background.jpg";
if (img != null && !img.trim().isEmpty()) {
    if (img.startsWith("http://") || img.startsWith("https://")) {
        imgUrl = img;
    } else if (img.startsWith("sub_")) {
        imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + URLEncoder.encode(img.trim(), "UTF-8");
    } else if (img.startsWith("business_")) {
        imgUrl = request.getContextPath() + "/uploads/" + URLEncoder.encode(img.trim(), "UTF-8");
    } else {
        imgUrl = request.getContextPath() + "/image/" + img.trim();
    }
}
                %>
                <div class="treasure-card" id="loc-<%= locId%>">
                    <img src="<%= imgUrl%>" onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/image/background.jpg';" alt="<%= name%>" class="card-image">
                    <div class="card-content">
                        <% if (isFeatured == 1) { %><span class="featured-badge">⭐ Featured</span><% }%>
                        <h3 class="card-title"><%= name%></h3>
                        <p class="card-description"><%= desc%></p>
                        <p style="font-size:13px;color:#555;margin:8px 0;">⭐ <%= String.format(java.util.Locale.US, "%.1f", avgR)%> &nbsp;|&nbsp; 👁 <%= views%> views &nbsp;|&nbsp; 💬 <%= totalRev%> reviews</p>
                        <a class="card-btn" href="location_details.jsp?id=<%= locId%>" style="display:inline-block;">View Details & Reviews</a>
                        <div style="margin-top:10px;display:flex;gap:10px;align-items:center;">
                            <% if (!loggedIn) { %>
                            <a class="card-btn" href="login.jsp"><i class="far fa-heart"></i> Bookmark</a>
                            <% } else {%>
                            <form action="ToggleBookmarkServlet" method="post" style="display:inline;">
                                <input type="hidden" name="locationId" value="<%= locId%>">
                                <input type="hidden" name="redirect" value="index.jsp?categoryId=<%= selectedCategoryId%>&filter=<%= filter%>&search=<%= URLEncoder.encode(searchText, "UTF-8")%>#loc-<%= locId%>">
                                <button class="love-btn <%= bkmk ? "active" : ""%>" type="submit"><i class="<%= bkmk ? "fas fa-heart" : "far fa-heart"%>"></i></button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                </div>
                <%
                                }
                               if (!any) {
                                    out.println("<p style='width:100%;text-align:center;color:#666;'>No locations found.</p>");
                                }
                            }
                        }
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                    }
                %>
            </div>
            <div style="text-align:center; margin-top:24px;">
                <a href="treasures.jsp" class="card-btn" style="display:inline-block; padding:14px 32px; font-size:15px;">
                    <i class="fas fa-arrow-right"></i> Load More / View All Locations
                </a>
            </div>
        </section>
   
        <section class="treasures-section container">
            <h2 class="section-title">Registered Businesses</h2>
            <div class="treasures-grid">
                <%
                    Connection homeBizConn = null;
                    PreparedStatement homeBizPs = null;
                    ResultSet homeBizRs = null;
                    try {
                        homeBizConn = util.DBConnection.getConnection();
                        
                        StringBuilder bizSql = new StringBuilder(
                            "SELECT b.business_id, b.user_id, b.business_name, b.description, b.address, " +
                            "b.contact_phone, b.operating_hours, b.image, " +
                            "c.name AS category_name, u.username AS owner_username, " +
                            "IFNULL(rev_agg.avg_rating, 0) AS avg_rating, IFNULL(rev_agg.total_reviews, 0) AS total_reviews " +
                            "FROM businesses b " +
                            "LEFT JOIN categories c ON b.category_id = c.category_id " +
                            "LEFT JOIN users u ON b.user_id = u.id " +
                            "LEFT JOIN location l ON b.business_id = l.business_id " +
                            "LEFT JOIN (SELECT location_id, AVG(rating) AS avg_rating, COUNT(review_id) AS total_reviews " +
                            "FROM reviews GROUP BY location_id) rev_agg ON l.location_id = rev_agg.location_id "
                        );
                        // Apply dynamic filters to businesses
                        ArrayList<String> bizWhere = new ArrayList<>();
                        if (selectedCategoryId > 0) {
                            bizWhere.add("b.category_id = ?");
                        }
                        if (searchText != null && !searchText.trim().isEmpty()) {
                            bizWhere.add("(b.business_name LIKE ? OR b.description LIKE ?)");
                        }
                        if (!bizWhere.isEmpty()) {
                            bizSql.append(" WHERE ");
                            for (int i = 0; i < bizWhere.size(); i++) {
                                if (i > 0) bizSql.append(" AND ");
                                bizSql.append(bizWhere.get(i));
                            }
                        }
                        if ("rated".equals(filter)) {
                            bizSql.append(" ORDER BY avg_rating DESC, b.business_id DESC");
                        } else if ("views".equals(filter) || "popular".equals(filter)) {
                            bizSql.append(" ORDER BY total_reviews DESC, b.business_id DESC");
                        } else {
                            bizSql.append(" ORDER BY b.business_id DESC");
                        }
                        homeBizPs = homeBizConn.prepareStatement(bizSql.toString());
                        
                        int bIdx = 1;
                        if (selectedCategoryId > 0) {
                            homeBizPs.setInt(bIdx++, selectedCategoryId);
                        }
                        if (searchText != null && !searchText.trim().isEmpty()) {
                            String kw = "%" + searchText.trim() + "%";
                            homeBizPs.setString(bIdx++, kw);
                            homeBizPs.setString(bIdx++, kw);
                        }
                        homeBizRs = homeBizPs.executeQuery();
                        boolean hasBiz = false;
                        
                     while (homeBizRs.next()) {
    hasBiz = true;
    int bId = homeBizRs.getInt("business_id");
    String bName = homeBizRs.getString("business_name");
    String bDesc = homeBizRs.getString("description");
    String bAddr = homeBizRs.getString("address");
    String bPhone = homeBizRs.getString("contact_phone");
    String bHours = homeBizRs.getString("operating_hours");
    String bImg = homeBizRs.getString("image");
    String catName = homeBizRs.getString("category_name");
    String ownerUser = homeBizRs.getString("owner_username");
    double avgRating = homeBizRs.getDouble("avg_rating");
    int totalReviews = homeBizRs.getInt("total_reviews");

    // IMAGE LOGIC
    String bImgUrl = request.getContextPath() + "/image/background.jpg";
    if (bImg != null && !bImg.trim().isEmpty()) {
        if (bImg.startsWith("http://") || bImg.startsWith("https://")) {
            bImgUrl = bImg; // Cloudinary URL
        } else if (bImg.startsWith("sub_")) {
            bImgUrl = request.getContextPath() + "/LocationImageServlet?file=" + java.net.URLEncoder.encode(bImg.trim(), "UTF-8");
        } else if (!bImg.equals("default_business.jpg")) {
            bImgUrl = request.getContextPath() + "/image/" + bImg.trim();
        }
    }

    if (bDesc != null && bDesc.length() > 100) {
        bDesc = bDesc.substring(0, 95) + "...";
    }
                %>
                        <div class="treasure-card">
                            <img src="<%= bImgUrl %>" onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/image/background.jpg';" alt="<%= bName %>" class="card-image" style="height:180px; object-fit:cover;">
                            <div class="card-content">
                                <span class="featured-badge" style="background:#667eea; color:white;"><i class="fas fa-store"></i> <%= (catName != null) ? catName : "General" %></span>
                                <h3 class="card-title"><%= bName %></h3>
                                <div style="color: #f1c40f; font-size: 13px; margin: 4px 0;">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <i class="<%= (i <= Math.round(avgRating)) ? "fas" : "far" %> fa-star"></i>
                                    <% } %>
                                    <span style="color:#555; font-size:12px;"> (<%= String.format(java.util.Locale.US, "%.1f", avgRating) %> / <%= totalReviews %> reviews)</span>
                                </div>
                                <p class="card-description"><%= (bDesc != null) ? bDesc : "" %></p>
                                <p style="font-size:13px; color:#444; margin:4px 0;"><i class="fas fa-location-dot" style="color:#667eea;"></i> <%= (bAddr != null) ? bAddr : "-" %></p>
                                <p style="font-size:13px; color:#444; margin:4px 0;"><i class="fas fa-clock" style="color:#667eea;"></i> <%= (bHours != null) ? bHours : "-" %></p>
                                <p style="font-size:13px; color:#444; margin:4px 0;"><i class="fas fa-phone" style="color:#667eea;"></i> <%= (bPhone != null) ? bPhone : "-" %></p>
                                <p style="font-size:12px; color:#777; margin-top:6px;">Owner: <strong>@<%= (ownerUser != null) ? ownerUser : "-" %></strong></p>
                               <div style="margin-top:14px; display:flex; gap:10px;">
                                    <a class="card-btn" href="businessDetails?id=<%= bId %>" style="display:inline-block; text-align:center; flex:1; text-decoration:none;">
                                        <i class="fas fa-info-circle"></i> View Details
                                    </a>
                                    <a class="card-btn" href="<%= request.getContextPath() %>/businessReviews?id=<%= bId %>" style="display:inline-block; text-align:center; flex:1; background:#111; color:#fff; text-decoration:none;">
                                        <i class="fas fa-comments"></i> Reviews
                                    </a>
                                </div>
                            </div>
                        </div>
                <%
                        }
                        if (!hasBiz) {
                            out.println("<p style='width:100%; text-align:center; color:#666; padding: 20px;'>No registered businesses found.</p>");
                        }
                    } catch (Exception ex) {
                        out.println("<p style='color:red; padding: 20px;'>Error loading businesses: " + ex.getMessage() + "</p>");
                        ex.printStackTrace();
                    } finally {
                        if (homeBizRs != null) { try { homeBizRs.close(); } catch (Exception e) {} }
                        if (homeBizPs != null) { try { homeBizPs.close(); } catch (Exception e) {} }
                        if (homeBizConn != null) { try { homeBizConn.close(); } catch (Exception e) {} }
                    }
                %>
            </div>
        </section>
   
        <footer class="footer">
            <div class="container">
                <div class="footer-inner">
                    <div class="footer-logo">
                        <h1>Local Treasure Terengganu</h1>
                        <p>Your guide to discovering the best local treasures in Terengganu. Explore hidden gems, cultural sites, and natural wonders.</p>
                    </div>
                    <div class="footer-links">
                        <a href="index.jsp">Home</a>
                        <a href="treasures.jsp">Treasures</a>
                        <a href="bookmark.jsp">Bookmarks</a>
         
                    </div>
                    <div class="footer-contact">
                        <strong>Contact Information</strong>
                        <address>Kompleks Yayasan Islam Terengganu, 20200 Kuala Terengganu, Terengganu, Malaysia</address>
                        <p><i class="fas fa-phone"></i> +60 9-622 1433</p>
                        <p><i class="fas fa-envelope"></i> localtreasureterengganu@gmail.com</p>
                    </div>
                </div>
                <div class="footer-bottom">
                    <span>© <%= java.time.Year.now() %> Local Treasure Terengganu. All rights reserved.</span>
                </div>
            </div>
        </footer>
        
        <script>
            let currentCategoryId = <%= selectedCategoryId%>;
            function searchLocations() {
                const searchText = document.getElementById("search").value;
                const filter = document.getElementById("filter-options").value;
                let url = "index.jsp?filter=" + encodeURIComponent(filter) + "&categoryId=" + currentCategoryId;
                if (searchText.trim() !== "") {
                    url += "&search=" + encodeURIComponent(searchText.trim());
                }
                window.location.href = url;
            }
            function applyCategory(catId) {
                currentCategoryId = catId;
                searchLocations();
            }
        </script>
        
        <div id="chatbox-container" class="minimized">
            <div id="chatbox-header"><img src="image/turtle.png" alt="Turtle Icon"> Chat with Turtle </div>
            <div id="chatbox-messages"></div>
            <div id="chatbox-input">
                <input type="text" id="chat-message" placeholder="Type a message...">
                <button id="send-btn">Send</button>
            </div>
        </div>
        
        <script>
            const chatbox = document.getElementById('chatbox-container');
            const header = document.getElementById('chatbox-header');
            const messages = document.getElementById('chatbox-messages');
            const input = document.getElementById('chat-message');
            const sendBtn = document.getElementById('send-btn');
            
            // Initial Welcome Message
            window.onload = function() {
                const botMsg = document.createElement('div');
                botMsg.className = 'chat-message bot';
                botMsg.innerHTML = '<div class="bubble">🐢 Hai! Saya Turtle. Ada apa-apa soalan tentang LocalTreasure Terengganu? Contoh: "waktu operasi" atau "cara daftar".</div>';
                messages.appendChild(botMsg);
            };
            
            // Toggle Chatbox
            header.addEventListener('click', function() {
                chatbox.classList.toggle('minimized');
            });
            
            // Send on Click or Enter
            sendBtn.addEventListener('click', sendMessage);
            input.addEventListener('keypress', function (e) {
                if (e.key === 'Enter') sendMessage();
            });
            
            function sendMessage() {
                const messageText = input.value.trim();
                if (messageText === "") return; 
                
                // Add USER message to the chatbox visually
                const userMsgDiv = document.createElement('div');
                userMsgDiv.className = 'chat-message user';
                userMsgDiv.innerHTML = '<div class="bubble">' + messageText + '</div>';
                messages.appendChild(userMsgDiv);
                
                // Clear input and scroll down
                input.value = "";
                messages.scrollTop = messages.scrollHeight;
                // Send to Server
                fetch('chatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'message=' + encodeURIComponent(messageText)
                })
                .then(function(response) {
                    if (!response.ok) throw new Error("Server error");
                    return response.json();
                })
                .then(function(data) {
                    // Add BOT reply to the chatbox visually
                    const botMsgDiv = document.createElement('div');
                    botMsgDiv.className = 'chat-message bot';
                    botMsgDiv.innerHTML = '<div class="bubble">' + data.reply + '</div>';
                    messages.appendChild(botMsgDiv);
                    
                    // Scroll down
                    messages.scrollTop = messages.scrollHeight;
                })
                .catch(function(error) {
                    console.error("Chat Error:", error);
                    const errorMsgDiv = document.createElement('div');
                    errorMsgDiv.className = 'chat-message bot';
                    errorMsgDiv.innerHTML = '<div class="bubble" style="color:red;">Error connecting to server.</div>';
                    messages.appendChild(errorMsgDiv);
                });
            }
        </script>
        <script>
    document.addEventListener('DOMContentLoaded', function() {
        const navbarToggle = document.getElementById('navbarToggle');
        const navbarMobileMenu = document.getElementById('navbarMobileMenu');
        if (navbarToggle && navbarMobileMenu) {
            navbarToggle.addEventListener('click', function(e) {
                e.stopPropagation();
                navbarMobileMenu.classList.toggle('active');
            });
        }
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.navbar-container') && !event.target.closest('.navbar-mobile-menu')) {
                navbarMobileMenu.classList.remove('active');
            }
        });
    });
</script>
    </body>
</html