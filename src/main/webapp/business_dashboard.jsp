<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, util.DBConnection" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String email = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    String profilePicture = (String) session.getAttribute("profilePicture");

    if (role == null || !role.equals("Local Business")) {
        response.sendRedirect("home.jsp");
        return;
    }

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
            : "image/profile.jpeg";

    int businessId = 0;
    String businessName = "";
    String businessDescription = "";
    String businessAddress = "";
    String businessPhone = "";
    String businessHours = "";

    int totalLocations = 0;
    int totalReviews = 0;
    int activePromotions = 0;

    List<Map<String, Object>> locationList = new ArrayList<>();
    List<Map<String, Object>> promotionList = new ArrayList<>();
    List<Map<String, Object>> reviewList = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {

        // ===== 1) Get business info =====
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT business_id, business_name, description, address, contact_phone, operating_hours " +
                "FROM businesses WHERE user_id = ? LIMIT 1")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    businessId = rs.getInt("business_id");
                    businessName = rs.getString("business_name");
                    businessDescription = rs.getString("description");
                    businessAddress = rs.getString("address");
                    businessPhone = rs.getString("contact_phone");
                    businessHours = rs.getString("operating_hours");
                }
            }
        } catch (Exception ignore) {}

        // ===== 2) Total locations =====
        // Try option A: locations owned directly by business
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) c FROM locations WHERE business_id = ?")) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalLocations = rs.getInt("c");
            }
        } catch (Exception e) {
            // Try option B: location submissions by this business user
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) c FROM location_submission WHERE user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalLocations = rs.getInt("c");
                }
            } catch (Exception ignore) {}
        }

        // ===== 3) Total reviews =====
        // Try option A: reviews on business-owned locations
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) c " +
                "FROM reviews r " +
                "JOIN locations l ON l.location_id = r.location_id " +
                "WHERE l.business_id = ?")) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalReviews = rs.getInt("c");
            }
        } catch (Exception e) {
            // Try option B: reviews on locations created by this user
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) c " +
                    "FROM reviews r " +
                    "JOIN locations l ON l.location_id = r.location_id " +
                    "WHERE l.user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalReviews = rs.getInt("c");
                }
            } catch (Exception ignore) {}
        }

        // ===== 4) Active promotions =====
        if (businessId > 0) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) c FROM promotions " +
                    "WHERE business_id = ? AND (is_active = 1 OR is_active = '1' OR is_active = 'Yes' OR is_active = 'YES')")) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) activePromotions = rs.getInt("c");
                }
            } catch (Exception e) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) c FROM promotions WHERE business_id = ?")) {
                    ps.setInt(1, businessId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) activePromotions = rs.getInt("c");
                    }
                } catch (Exception ignore) {}
            }
        }

        // ===== 5) Location list =====
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT location_id, name, description " +
                "FROM locations WHERE business_id = ? ORDER BY location_id DESC")) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("location_id"));
                    row.put("name", rs.getString("name"));
                    row.put("desc", rs.getString("description"));
                    locationList.add(row);
                }
            }
        } catch (Exception e) {
            // fallback: location submission list
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT submission_id, name, description, status " +
                    "FROM location_submission WHERE user_id = ? ORDER BY submission_id DESC")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", rs.getInt("submission_id"));
                        row.put("name", rs.getString("name"));
                        row.put("desc", rs.getString("description"));
                        row.put("status", rs.getString("status"));
                        locationList.add(row);
                    }
                }
            } catch (Exception ignore) {}
        }

        // ===== 6) Promotion list =====
        if (businessId > 0) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT promotion_id, title, description, start_date, end_date, is_active, approval_status " +
                    "FROM promotions WHERE business_id = ? ORDER BY promotion_id DESC")) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", rs.getInt("promotion_id"));
                        row.put("title", rs.getString("title"));
                        row.put("desc", rs.getString("description"));
                        row.put("start", rs.getString("start_date"));
                        row.put("end", rs.getString("end_date"));
                        row.put("active", rs.getString("is_active"));
                        row.put("status", rs.getString("approval_status"));
                        promotionList.add(row);
                    }
                }
            } catch (Exception ignore) {}
        }

        // ===== 7) Review list =====
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT u.username, l.name AS location_name, r.rating, r.review_text, r.review_date " +
                "FROM reviews r " +
                "JOIN users u ON u.id = r.user_id " +
                "JOIN locations l ON l.location_id = r.location_id " +
                "WHERE l.business_id = ? " +
                "ORDER BY r.review_date DESC LIMIT 10")) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("username", rs.getString("username"));
                    row.put("location", rs.getString("location_name"));
                    row.put("rating", rs.getInt("rating"));
                    row.put("text", rs.getString("review_text"));
                    row.put("date", rs.getString("review_date"));
                    reviewList.add(row);
                }
            }
        } catch (Exception e) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT u.username, l.name AS location_name, r.rating, r.review_text, r.review_date " +
                    "FROM reviews r " +
                    "JOIN users u ON u.id = r.user_id " +
                    "JOIN locations l ON l.location_id = r.location_id " +
                    "WHERE l.user_id = ? " +
                    "ORDER BY r.review_date DESC LIMIT 10")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("username", rs.getString("username"));
                        row.put("location", rs.getString("location_name"));
                        row.put("rating", rs.getInt("rating"));
                        row.put("text", rs.getString("review_text"));
                        row.put("date", rs.getString("review_date"));
                        reviewList.add(row);
                    }
                }
            } catch (Exception ignore) {}
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Business Dashboard - Local Treasure</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root{
            --bg:#f6f7fb;
            --card:#ffffff;
            --text:#1f2937;
            --muted:#6b7280;
            --line:#e5e7eb;
            --blue:#3b82f6;
            --green:#22c55e;
            --orange:#f97316;
            --yellow:#fbbf24;
            --shadow:0 10px 25px rgba(0,0,0,.06);
            --radius:18px;
        }

        *{ box-sizing:border-box; }

        body{
            margin:0;
            font-family: 'Poppins', Arial, sans-serif;
            background:var(--bg);
            color:var(--text);
        }

        .wrapper{
            max-width:1180px;
            margin:0 auto;
            padding:32px 20px 50px;
        }

        .topbar{
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:20px;
            flex-wrap:wrap;
            margin-bottom:22px;
        }

        .topbar-left h1{
            margin:0;
            font-size:42px;
            font-weight:800;
            letter-spacing:-1px;
        }

        .topbar-left p{
            margin:8px 0 0;
            color:var(--muted);
            font-size:15px;
        }

        .topbar-right{
            display:flex;
            align-items:center;
            gap:12px;
            flex-wrap:wrap;
        }

        .mini-profile{
            display:flex;
            align-items:center;
            gap:12px;
            background:var(--card);
            padding:10px 14px;
            border-radius:14px;
            box-shadow:var(--shadow);
        }

        .mini-profile img{
            width:42px;
            height:42px;
            border-radius:50%;
            object-fit:cover;
        }

        .mini-profile .name{
            font-weight:700;
            font-size:14px;
        }

        .mini-profile .role{
            font-size:12px;
            color:var(--muted);
        }

        .btn{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            gap:8px;
            padding:11px 15px;
            border-radius:12px;
            border:none;
            background:#111827;
            color:#fff;
            text-decoration:none;
            font-weight:600;
            cursor:pointer;
        }

        .btn-outline{
            background:#fff;
            color:#111827;
            border:1px solid var(--line);
        }

        .stats{
            display:grid;
            grid-template-columns:repeat(3, 1fr);
            gap:18px;
            margin-bottom:22px;
        }

        .stat-card{
            background:var(--card);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            padding:22px 24px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            min-height:120px;
        }

        .stat-label{
            color:var(--muted);
            font-size:14px;
            margin-bottom:10px;
        }

        .stat-value{
            font-size:40px;
            font-weight:800;
            line-height:1;
        }

        .stat-icon{
            font-size:30px;
        }

        .stat-icon.blue{ color:var(--blue); }
        .stat-icon.green{ color:var(--green); }
        .stat-icon.orange{ color:var(--orange); }

        .tabs{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
            margin-bottom:18px;
        }

        .tab-btn{
            background:#fff;
            border:1px solid var(--line);
            border-radius:999px;
            padding:10px 16px;
            font-weight:600;
            cursor:pointer;
            color:#374151;
        }

        .tab-btn.active{
            background:#111827;
            color:#fff;
            border-color:#111827;
        }

        .panel{
            display:none;
            background:var(--card);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            padding:24px;
        }

        .panel.active{
            display:block;
        }

        .panel-title{
            font-size:24px;
            font-weight:700;
            margin:0 0 4px;
        }

        .panel-subtitle{
            color:var(--muted);
            margin:0 0 22px;
            font-size:14px;
        }

        .grid-2{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:18px;
        }

        .info-card, .item-card, .review-card{
            border:1px solid var(--line);
            border-radius:16px;
            padding:18px;
            background:#fff;
        }

        .info-label{
            font-size:12px;
            text-transform:uppercase;
            color:var(--muted);
            font-weight:700;
            margin-bottom:6px;
        }

        .info-value{
            font-size:15px;
            font-weight:600;
            word-break:break-word;
        }

        .item-title{
            font-size:18px;
            font-weight:700;
            margin:0 0 8px;
        }

        .item-desc{
            color:var(--muted);
            font-size:14px;
            margin-bottom:12px;
            line-height:1.6;
        }

        .meta-row{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
        }

        .badge{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:7px 12px;
            border-radius:999px;
            font-size:12px;
            font-weight:700;
            border:1px solid var(--line);
            background:#f9fafb;
        }

        .badge.green{
            background:#ecfdf5;
            color:#166534;
            border-color:#bbf7d0;
        }

        .badge.yellow{
            background:#fffbeb;
            color:#92400e;
            border-color:#fde68a;
        }

        .badge.red{
            background:#fef2f2;
            color:#991b1b;
            border-color:#fecaca;
        }

        .review-head{
            display:flex;
            justify-content:space-between;
            gap:15px;
            align-items:flex-start;
            margin-bottom:8px;
        }

        .reviewer{
            font-weight:700;
            margin-bottom:4px;
        }

        .review-location{
            color:var(--muted);
            font-size:13px;
        }

        .stars{
            color:var(--yellow);
            font-size:14px;
            white-space:nowrap;
        }

        .review-text{
            color:#374151;
            line-height:1.7;
            margin:12px 0;
        }

        .review-date{
            color:#9ca3af;
            font-size:13px;
        }

        .empty{
            text-align:center;
            padding:40px 20px;
            color:var(--muted);
            border:1px dashed var(--line);
            border-radius:16px;
            background:#fafafa;
        }

        .actions{
            display:flex;
            gap:12px;
            flex-wrap:wrap;
            margin-top:18px;
        }

        @media (max-width: 900px){
            .stats{ grid-template-columns:1fr; }
            .grid-2{ grid-template-columns:1fr; }
            .topbar-left h1{ font-size:32px; }
        }
    </style>
</head>
<body>

<div class="wrapper">

    <div class="topbar">
        <div class="topbar-left">
            <h1>Business Dashboard</h1>
            <p>Manage your locations and promotions</p>
        </div>

        <div class="topbar-right">
            <div class="mini-profile">
                <img src="<%= profileImgUrl %>" alt="Profile">
                <div>
                    <div class="name"><%= username %></div>
                    <div class="role"><%= role %></div>
                </div>
            </div>

            <a href="home.jsp" class="btn btn-outline">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="user_profile.jsp" class="btn btn-outline">
                <i class="fas fa-user"></i> Profile
            </a>
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </div>

    <div class="stats">
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Locations</div>
                <div class="stat-value"><%= totalLocations %></div>
            </div>
            <div class="stat-icon blue"><i class="fas fa-location-dot"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-label">Total Reviews</div>
                <div class="stat-value"><%= totalReviews %></div>
            </div>
            <div class="stat-icon green"><i class="fas fa-pen-to-square"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-label">Active Promotions</div>
                <div class="stat-value"><%= activePromotions %></div>
            </div>
            <div class="stat-icon orange"><i class="fas fa-tags"></i></div>
        </div>
    </div>

    <div class="tabs">
        <button class="tab-btn active" onclick="showTab('locations', this)">Locations</button>
        <button class="tab-btn" onclick="showTab('promotions', this)">Promotions</button>
        <button class="tab-btn" onclick="showTab('reviews', this)">Reviews</button>
    </div>

    <!-- LOCATIONS -->
    <div id="locations" class="panel active">
        <h2 class="panel-title">Business Profile & Locations</h2>
        <p class="panel-subtitle">View your business information and submitted locations</p>

        <div class="grid-2">
            <div class="info-card">
                <div class="info-label">Business Name</div>
                <div class="info-value"><%= (businessName == null || businessName.trim().isEmpty()) ? "-" : businessName %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Contact Phone</div>
                <div class="info-value"><%= (businessPhone == null || businessPhone.trim().isEmpty()) ? "-" : businessPhone %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Operating Hours</div>
                <div class="info-value"><%= (businessHours == null || businessHours.trim().isEmpty()) ? "-" : businessHours %></div>
            </div>

            <div class="info-card">
                <div class="info-label">Address</div>
                <div class="info-value"><%= (businessAddress == null || businessAddress.trim().isEmpty()) ? "-" : businessAddress %></div>
            </div>
        </div>

        <div class="info-card" style="margin-top:18px;">
            <div class="info-label">Description</div>
            <div class="info-value"><%= (businessDescription == null || businessDescription.trim().isEmpty()) ? "-" : businessDescription %></div>
        </div>

        <div class="actions">
            <a href="edit_business.jsp" class="btn">
                <i class="fas fa-plus"></i> Edit Business
            </a>
            <a href="user_profile.jsp" class="btn btn-outline">
                <i class="fas fa-edit"></i> Edit Profile
            </a>
        </div>

        <div style="margin-top:24px;">
            <% if (locationList.isEmpty()) { %>
                <div class="empty">No locations found yet.</div>
            <% } else { %>
                <% for (Map<String, Object> loc : locationList) { %>
                    <div class="item-card" style="margin-bottom:14px;">
                        <div class="item-title"><%= loc.get("name") %></div>
                        <div class="item-desc"><%= loc.get("desc") == null ? "-" : loc.get("desc") %></div>

                        <div class="meta-row">
                            <span class="badge">
                                <i class="fas fa-hashtag"></i>
                                ID: <%= loc.get("id") %>
                            </span>

                            <% if (loc.get("status") != null) { %>
                                <span class="badge yellow">
                                    <i class="fas fa-clock"></i>
                                    <%= loc.get("status") %>
                                </span>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <!-- PROMOTIONS -->
    <div id="promotions" class="panel">
        <h2 class="panel-title">Promotions</h2>
        <p class="panel-subtitle">Manage your promotional offers</p>

        <div class="actions">
            <a href="add_promotion.jsp" class="btn">
                <i class="fas fa-plus"></i> Add Promotion
            </a>
        </div>

        <div style="margin-top:24px;">
            <% if (promotionList.isEmpty()) { %>
                <div class="empty">No promotions found yet.</div>
            <% } else { %>
                <% for (Map<String, Object> promo : promotionList) { %>
                    <div class="item-card" style="margin-bottom:14px;">
                        <div class="item-title"><%= promo.get("title") %></div>
                        <div class="item-desc"><%= promo.get("desc") == null ? "-" : promo.get("desc") %></div>

                        <div class="meta-row">
                            <span class="badge">
                                <i class="fas fa-calendar"></i>
                                <%= promo.get("start") == null ? "-" : promo.get("start") %> - <%= promo.get("end") == null ? "-" : promo.get("end") %>
                            </span>

                            <span class="badge green">
                                <i class="fas fa-bullhorn"></i>
                                Active: <%= promo.get("active") == null ? "-" : promo.get("active") %>
                            </span>

                            <span class="badge yellow">
                                <i class="fas fa-shield-check"></i>
                                Status: <%= promo.get("status") == null ? "-" : promo.get("status") %>
                            </span>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <!-- REVIEWS -->
    <div id="reviews" class="panel">
        <h2 class="panel-title">Customer Reviews</h2>
        <p class="panel-subtitle">See what customers are saying about your locations</p>

        <% if (reviewList.isEmpty()) { %>
            <div class="empty">No reviews found yet.</div>
        <% } else { %>
            <% for (Map<String, Object> rev : reviewList) { %>
                <div class="review-card" style="margin-bottom:14px;">
                    <div class="review-head">
                        <div>
                            <div class="reviewer"><%= rev.get("username") %></div>
                            <div class="review-location"><%= rev.get("location") %></div>
                        </div>

                        <div class="stars">
                            <%
                                int stars = 0;
                                try { stars = Integer.parseInt(String.valueOf(rev.get("rating"))); } catch (Exception ex) {}
                                for (int i = 1; i <= stars; i++) {
                            %>
                                <i class="fas fa-star"></i>
                            <% } %>
                        </div>
                    </div>

                    <div class="review-text">
                        <%= rev.get("text") == null ? "-" : rev.get("text") %>
                    </div>

                    <div class="review-date">
                        <%= rev.get("date") == null ? "-" : rev.get("date") %>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
</div>

<script>
    function showTab(tabId, btn){
        document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

        document.getElementById(tabId).classList.add('active');
        btn.classList.add('active');
    }
</script>

</body>
</html>