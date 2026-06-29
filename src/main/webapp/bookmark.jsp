<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<link rel="stylesheet" href="css/styles.css">
<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("sign_up.jsp?from=bookmark");
        return;
    }

    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String profilePicture = (String) session.getAttribute("profilePicture");
    boolean loggedIn = true;

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
        ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
        : "image/profile.jpeg";

    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;

    try (Connection connN = util.DBConnection.getConnection()) {

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bookmark Location</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
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
        .nav-noti:hover{
            background:#111;
            color:#fff;
        }
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
        .love-btn{
            width:44px;
            height:44px;
            border-radius:999px;
            border:2px solid #111;
            background:#ff4757;
            color:#fff;
            cursor:pointer;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            box-shadow: 0 6px 0 #111;
            transition: 0.2s;
        }
        .love-btn i{ font-size:18px; }
        .love-btn:hover{
            transform: translateY(-2px);
            box-shadow: 0 10px 0 #111;
        }
    </style>
</head>

<body>

<nav class="navbar">
    <div class="container navbar-container">
        <div class="navbar-left">
            <a href="index.jsp" class="nav-link">Explore</a>
            <a href="bookmark.jsp" class="nav-link active">Bookmark</a>
            <a href="treasures.jsp" class="nav-link">Treasures</a>
        </div>

        <a href="index.jsp" class="navbar-brand">
            <div class="brand-main">Local Treasure Terengganu</div>
            <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
        </a>

        <div class="navbar-right">
            <a href="notifications.jsp?type=ALL" class="nav-noti" title="Notifications">
                <i class="fas fa-bell"></i>
                <% if (notiTotal > 0) { %>
                    <span class="noti-badge"><%= notiTotal %></span>
                <% } %>
            </a>

            <a href="user_profile.jsp" class="nav-profile">
                <img src="<%= profileImgUrl %>" class="nav-profile-img">
                <span><%= username %></span>
            </a>

            <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
        </div>

        <button class="navbar-toggle" id="navbarToggle" type="button">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="navbar-mobile-menu" id="navbarMobileMenu">
        <a href="index.jsp" class="nav-link">Explore</a>
        <a href="bookmark.jsp" class="nav-link active">Bookmark</a>
        <a href="treasures.jsp" class="nav-link">Treasures</a>
        <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>

        <a href="notifications.jsp?type=ALL" class="nav-link">
            Notifications <% if (notiTotal > 0) { %>(<%= notiTotal %>)<% } %>
        </a>

        <a href="user_profile.jsp" class="nav-profile">
            <img src="<%= profileImgUrl %>" class="nav-profile-img">
            <span><%= username %></span>
        </a>

        <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
    </div>
</nav>

<header class="header">
    <div class="container header-content">
        <h1>Local Treasure Terengganu</h1>
        <p>Discover Terengganu's Hidden Treasures</p>
    </div>
</header>

<div class="container" style="padding:30px 20px;">
    <h2 class="section-title">My Bookmarked Locations</h2>

    <div class="treasures-grid">
        <%
            try (Connection conn = util.DBConnection.getConnection()) {

                String sql =
                    "SELECT l.location_id, l.name, l.description, l.image " +
                    "FROM bookmarks b " +
                    "JOIN location l ON l.location_id = b.location_id " +
                    "WHERE b.user_id=? " +
                    "ORDER BY b.created_at DESC";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        boolean any = false;

                        while (rs.next()) {
                            any = true;

                            int locId = rs.getInt("location_id");
                            String img = rs.getString("image");
                         String imgUrl = request.getContextPath() + "/image/background.jpg";
if (img != null && !img.trim().isEmpty()) {
    if (img.startsWith("http://") || img.startsWith("https://")) {
        imgUrl = img; // Cloudinary URL terus
    } else if (img.startsWith("sub_")) {
        imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + img;
    } else {
        imgUrl = request.getContextPath() + "/image/" + img;
    }
}
                            <div class="treasure-card" id="loc-<%= locId %>">
                                <img src="<%= imgUrl %>" class="card-image">

                                <div class="card-content">
                                    <h3 class="card-title"><%= rs.getString("name") %></h3>
                                    <p class="card-description"><%= rs.getString("description") %></p>

                                    <form action="ToggleBookmarkServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="locationId" value="<%= locId %>">
                                        <input type="hidden" name="redirect" value="bookmark.jsp#loc-<%= locId %>">

                                        <button class="love-btn" type="submit" title="Remove Bookmark">
                                            <i class="fas fa-heart-broken"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
        <%
                        }

                        if (!any) {
        %>
                            <p style="text-align:center; color:#666;">
                                You have no bookmarks yet.
                            </p>
        <%
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>DB Error: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

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
<%@ include file="footer.jsp" %>
</body>
</html>