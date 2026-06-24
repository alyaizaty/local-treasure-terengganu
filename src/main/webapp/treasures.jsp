<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // ===== SESSION USER INFO =====
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String profilePicture = (String) session.getAttribute("profilePicture");
    boolean loggedIn = (userId != null);
    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + URLEncoder.encode(profilePicture, "UTF-8"))
            : "image/profile.jpeg";

    // ===== NOTIFICATION COUNT (badge 🔔) =====
    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;
    if (loggedIn) {
        try (Connection connN = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ltwbs", "root", "")) {
            try (PreparedStatement ps = connN.prepareStatement(
                    "SELECT COUNT(*) c " +
                            "FROM likes lk " +
                            "JOIN reviews r ON r.review_id = lk.review_id " +
                            "WHERE r.user_id=? AND lk.user_id <> ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) notiLikes = rs.getInt("c");
                }
            } catch (Exception ignore) {}
            try (PreparedStatement ps = connN.prepareStatement(
                    "SELECT COUNT(*) c " +
                            "FROM comments c " +
                            "JOIN reviews r ON r.review_id = c.review_id " +
                            "WHERE r.user_id=? AND c.user_id <> ?")) {
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treasures | Local Treasure Terengganu</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/home.css">
    <style>
        /* ===== Guest badge ===== */
        .nav-guest{
            display:inline-flex;
            align-items:center;
            gap:8px;
            color:#fff;
            font-weight:700;
        }
        .guest-badge{
            width:32px;
            height:32px;
            border-radius:50%;
            display:grid;
            place-items:center;
            background:rgba(255,255,255,0.18);
            border:2px solid #f8c471;
            font-weight:800;
        }
        .guest-text{ opacity:.9; }
        /* 🔔 Notification icon in navbar */
        .nav-noti{
            position: relative;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            width:40px; height:40px;
            border:2px solid #111;
            border-radius:999px;
            background:#fff;
            color:#111;
            text-decoration:none;
            box-shadow: 0 6px 0 #111;
        }
        .nav-noti:hover{ background:#111; color:#fff; }
        .nav-noti .noti-badge{
            position:absolute;
            top:-8px; right:-8px;
            min-width:22px; height:22px;
            padding:0 6px;
            border-radius:999px;
            border:2px solid #111;
            background:#ff4757;
            color:#fff;
            font-weight:1000;
            font-size:12px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            line-height:1;
        }
        /* ❤️ Love button (same design) */
        .love-btn{
            width:44px;
            height:44px;
            border-radius:999px;
            border:2px solid #111;
            background:#fff;
            cursor:pointer;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            box-shadow: 0 6px 0 #111;
            transition: 0.2s;
            text-decoration:none;
            color:#111;
            padding:0;
        }
        .love-btn i{ font-size:18px; }
        .love-btn:hover{
            transform: translateY(-2px);
            box-shadow: 0 10px 0 #111;
        }
        .love-btn.active{
            background:#ff4757;
            color:#fff;
            border-color:#111;
        }
        /* Page head */
        .page-head{
            max-width: 1100px;
            margin: 26px auto 8px;
            padding: 0 20px;
            color:#fff;
        }
        .page-head h1{ margin:0 0 6px 0; }
        .page-head p{ margin:0; opacity:.9; }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="container navbar-container">
        <div class="navbar-left">
            <a href="index.jsp" class="nav-link">Explore</a>
            <a href="bookmark.jsp" class="nav-link">Bookmark</a>
            <a href="treasures.jsp" class="nav-link active">Treasures</a>
        </div>
        <a href="index.jsp" class="navbar-brand">
            <div class="brand-main">Local Treasure Terengganu</div>
            <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
        </a>
        <div class="navbar-right">
            <% if (loggedIn) { %>
                <a href="notifications.jsp?type=ALL" class="nav-noti" title="Notifications">
                    <i class="fas fa-bell"></i>
                    <% if (notiTotal > 0) { %>
                        <span class="noti-badge"><%= notiTotal %></span>
                    <% } %>
                </a>
                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                    <span><%= username%></span>
                </a>
                <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
            <% } else { %>
                <div class="nav-guest">
                    <div class="guest-badge">G</div>
                    <span class="guest-text">Guest</span>
                </div>
                <a href="login.jsp" class="nav-link">Login</a>
                <a href="sign_up.jsp?from=home" class="nav-link">Sign Up</a>
            <% } %>
        </div>
        <button class="navbar-toggle" id="navbarToggle" type="button">
            <i class="fas fa-bars"></i>
        </button>
    </div>
    <div class="navbar-mobile-menu" id="navbarMobileMenu">
        <a href="index.jsp" class="nav-link">Explore</a>
        <a href="bookmark.jsp" class="nav-link">Bookmark</a>
        <a href="treasures.jsp" class="nav-link active">Treasures</a>
        <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>
        <% if (loggedIn) { %>
            <a href="notifications.jsp?type=ALL" class="nav-link">
                Notifications <% if (notiTotal > 0) { %>(<%= notiTotal %>)<% } %>
            </a>
            <a href="user_profile.jsp" class="nav-profile">
                <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                <span><%= username%></span>
            </a>
            <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
        <% } else { %>
            <div class="nav-guest" style="padding:10px 0;">
                <div class="guest-badge">G</div>
                <span class="guest-text">Guest</span>
            </div>
            <a href="login.jsp" class="nav-link">Login</a>
            <a href="sign_up.jsp?from=home" class="nav-link">Sign Up</a>
        <% } %>
    </div>
</nav>

<section class="page-head">
    <h1>Treasures</h1>
    <p>Browse all locations in Terengganu.</p>
</section>

<section class="treasures-section container">
    <h2 class="section-title">All Locations</h2>
    <div class="treasures-grid">
        <%
            try (Connection conn = util.DBConnection.getConnection()) {
                // FIXED: Added WHERE l.business_id IS NULL so businesses are hidden from the Treasures page
                String sql =
                        "SELECT l.location_id, l.name, l.description, l.image, " +
                                (loggedIn
                                        ? "EXISTS(SELECT 1 FROM bookmarks b WHERE b.user_id=? AND b.location_id=l.location_id) AS bookmarked "
                                        : "0 AS bookmarked ") +
                                "FROM location l " +
                                "WHERE l.business_id IS NULL " +
                                "ORDER BY l.location_id DESC";
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    if (loggedIn) ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                            int locId = rs.getInt("location_id");
                            String name = rs.getString("name");
                            String desc = rs.getString("description");
                            String imgName = rs.getString("image");
                            boolean bookmarked = rs.getInt("bookmarked") == 1;

                            // FIXED: Smart Image Logic with Universal Fallback
                            String imgUrl = request.getContextPath() + "/image/background.jpg";
                            if (imgName != null && !imgName.trim().isEmpty()) {
                                if (imgName.startsWith("sub_")) {
                                    imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + URLEncoder.encode(imgName, "UTF-8");
                                } else if (imgName.startsWith("business_")) {
                                    imgUrl = request.getContextPath() + "/uploads/" + URLEncoder.encode(imgName, "UTF-8");
                                } else {
                                    imgUrl = request.getContextPath() + "/image/" + imgName;
                                }
                            }
        %>
        <div class="treasure-card" id="loc-<%= locId %>">
            <img src="<%= imgUrl %>" onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/image/background.jpg';" alt="<%= name %>" class="card-image">
            <div class="card-content">
                <h3 class="card-title"><%= name %></h3>
                <p class="card-description"><%= desc %></p>
                <a class="card-btn" href="location_details.jsp?id=<%= locId %>" style="display:inline-block;">
                    View Details & Reviews
                </a>
                
                <div style="margin-top:10px; display:flex; gap:10px; align-items:center;">
                    <% if (!loggedIn) { %>
                        <a class="love-btn" href="login.jsp" title="Login to bookmark">
                            <i class="far fa-heart"></i>
                        </a>
                    <% } else { %>
                        <form action="ToggleBookmarkServlet" method="post" style="display:inline;">
                            <input type="hidden" name="locationId" value="<%= locId %>">
                            <input type="hidden" name="redirect" value="treasures.jsp#loc-<%= locId %>">
                            <button class="love-btn <%= bookmarked ? "active" : "" %>" type="submit"
                                    title="<%= bookmarked ? "Remove bookmark" : "Add bookmark" %>">
                                <i class="<%= bookmarked ? "fas fa-heart" : "far fa-heart" %>"></i>
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
        <%
                        }
                        if (!any) {
                            out.println("<p style='width:100%;text-align:center;color:#fff;opacity:.9;'>No locations found in database.</p>");
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>DB Error: " + e.getMessage() + "</p>");
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
                <a href="about.jsp">About Us</a>
                <a href="plan-visit.jsp">Plan Your Visit</a>
                <a href="bookmark.jsp">Bookmarks</a>
                <a href="contact.jsp">Contact Us</a>
            </div>
            <div class="footer-contact">
                <strong>Contact Information</strong>
                <address>Kompleks Yayasan Islam Terengganu, 20200 Kuala Terengganu, Terengganu, Malaysia</address>
                <p><i class="fas fa-phone"></i> +60 9-622 1433</p>
                <p><i class="fas fa-envelope"></i> info@terengganu-treasure.my</p>
            </div>
        </div>
        <div class="footer-bottom">
            <span>© <%= java.time.Year.now() %> Local Treasure Terengganu. All rights reserved.</span>
        </div>
    </div>
</footer>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const navbarToggle = document.getElementById('navbarToggle');
        const navbarMobileMenu = document.getElementById('navbarMobileMenu');
        if (navbarToggle && navbarMobileMenu) {
            navbarToggle.addEventListener('click', function (e) {
                e.stopPropagation();
                navbarMobileMenu.classList.toggle('active');
            });
        }
        document.addEventListener('click', function (event) {
            if (!event.target.closest('.navbar-container') && !event.target.closest('.navbar-mobile-menu')) {
                navbarMobileMenu.classList.remove('active');
            }
        });
    });
</script>
</body>
</html>