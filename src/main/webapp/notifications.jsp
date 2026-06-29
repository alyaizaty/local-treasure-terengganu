<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String profilePicture = (String) session.getAttribute("profilePicture");

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
        ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
        : "image/profile.jpeg";

    String type = request.getParameter("type");
    if (type == null || type.trim().isEmpty()) type = "ALL";
    type = type.toUpperCase();

    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;

    String notiHtml = "";

try (Connection conn = util.DBConnection.getConnection()) {

        // Count likes on your reviews (exclude your own likes)
        try (PreparedStatement ps = conn.prepareStatement(
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

        // Count comments on your reviews (exclude your own comments)
        try (PreparedStatement ps = conn.prepareStatement(
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

        // Build notification list (ALL / LIKE / COMMENT)
        String wherePart = "";
        if ("LIKE".equals(type)) {
            wherePart = " WHERE x.ntype='LIKE' ";
        } else if ("COMMENT".equals(type)) {
            wherePart = " WHERE x.ntype='COMMENT' ";
        }

        String sql =
            "SELECT * FROM ( " +
            "  SELECT 'LIKE' AS ntype, lk.like_date AS ndate, u.username AS actor_name, " +
            "         r.review_id, r.location_id, l.name AS location_name, r.review_text AS review_text, " +
            "         NULL AS comment_text " +
            "  FROM likes lk " +
            "  JOIN reviews r ON r.review_id = lk.review_id " +
            "  JOIN location l ON l.location_id = r.location_id " +
            "  JOIN users u ON u.id = lk.user_id " +
            "  WHERE r.user_id=? AND lk.user_id <> ? " +
            "  UNION ALL " +
            "  SELECT 'COMMENT' AS ntype, c.comment_date AS ndate, u2.username AS actor_name, " +
            "         r2.review_id, r2.location_id, l2.name AS location_name, r2.review_text AS review_text, " +
            "         c.comment_text AS comment_text " +
            "  FROM comments c " +
            "  JOIN reviews r2 ON r2.review_id = c.review_id " +
            "  JOIN location l2 ON l2.location_id = r2.location_id " +
            "  JOIN users u2 ON u2.id = c.user_id " +
            "  WHERE r2.user_id=? AND c.user_id <> ? " +
            ") x " +
            wherePart +
            "ORDER BY x.ndate DESC " +
            "LIMIT 50";

        StringBuilder sb = new StringBuilder();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String ntype = rs.getString("ntype");
                    String ndate = rs.getString("ndate");
                    String actor = rs.getString("actor_name");
                    int locId = rs.getInt("location_id");
                    int revId = rs.getInt("review_id");
                    String locName = rs.getString("location_name");

                    String reviewText = rs.getString("review_text");
                    String commentText = rs.getString("comment_text");

                    String link = "location_details.jsp?id=" + locId + "#review-" + revId;

                    sb.append("<div class='notiItem'>");

                    if ("LIKE".equals(ntype)) {
                        sb.append("<div class='tag tagLike'><i class='fas fa-thumbs-up'></i> Like</div>");
                        sb.append("<div class='notiText'><b>").append(actor).append("</b> liked your review at ");
                    } else {
                        sb.append("<div class='tag tagComment'><i class='fas fa-comment'></i> Comment</div>");
                        sb.append("<div class='notiText'><b>").append(actor).append("</b> commented on your review at ");
                    }

                    sb.append("<a href='").append(link).append("'>").append(locName).append("</a></div>");

                    // mini preview
                    if (reviewText != null && !reviewText.trim().isEmpty()) {
                        String preview = reviewText;
                        if (preview.length() > 120) preview = preview.substring(0, 120) + "...";
                        sb.append("<div class='preview'><span class='muted'>Your review:</span> “").append(preview).append("”</div>");
                    }

                    if ("COMMENT".equals(ntype) && commentText != null && !commentText.trim().isEmpty()) {
                        String cprev = commentText;
                        if (cprev.length() > 120) cprev = cprev.substring(0, 120) + "...";
                        sb.append("<div class='preview'><span class='muted'>Comment:</span> “").append(cprev).append("”</div>");
                    }

                    sb.append("<div class='notiDate'>").append(ndate).append("</div>");
                    sb.append("</div>");
                }
            }
        }

        notiHtml = sb.toString();

    } catch (Exception ignore) {
        // silent fail, page still loads
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Notifications - Local Treasure Terengganu</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root{
            --black:#111; --white:#fff; --gray-light:#f5f5f5; --gray-dark:#333;
            --accent:#ff4757;
            --shadow:0 10px 24px rgba(0,0,0,.14);
        }
        body{ background: linear-gradient(135deg, var(--gray-light) 0%, #e8e8e8 100%); min-height:100vh; padding-bottom:30px; }

        .page-wrap{ max-width: 860px; margin: 22px auto; padding: 0 14px; }
        .card{
            background:#fff;
            border:2px solid var(--black);
            border-radius:18px;
            box-shadow:var(--shadow);
            overflow:hidden;
        }
        .header{
            background: linear-gradient(90deg, var(--black) 0%, var(--gray-dark) 100%);
            color:#fff;
            padding:18px 18px;
            border-bottom:3px solid var(--black);
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
        }
        .title{
            font-weight:1000;
            letter-spacing:1px;
            text-transform:uppercase;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .counts{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
            font-weight:900;
        }
        .pill{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:7px 12px;
            border-radius:999px;
            border:2px solid var(--black);
            background:#fff;
            color:#111;
            font-weight:1000;
            font-size:12px;
        }
        .pill b{ font-weight:1000; }

        /* sub-navbar filter */
        .subnav{
            background:#fff;
            border-bottom:2px solid var(--black);
            display:flex;
            gap:10px;
            padding:12px 12px;
            flex-wrap:wrap;
        }
        .tab{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:10px 12px;
            border-radius:14px;
            border:2px solid var(--black);
            background:#fff;
            color:#111;
            text-decoration:none;
            font-weight:1000;
            box-shadow: 0 6px 0 var(--black);
        }
        .tab:hover{ background:#111; color:#fff; }
        .tab.active{ background:#111; color:#fff; }

        .list{ padding: 14px 16px 18px; background:#f7f7f7; }
        .empty{
            background:#fff;
            border:2px dashed #111;
            border-radius:14px;
            padding:16px;
            font-weight:900;
            color:#6b7280;
        }

        .notiItem{
            background:#fff;
            border:2px solid var(--black);
            border-radius:14px;
            padding:14px;
            box-shadow: 0 6px 0 var(--black);
            margin-bottom:12px;
        }
        .tag{
            display:inline-flex; align-items:center; gap:8px;
            padding:6px 10px; border-radius:999px;
            border:2px solid #111; font-weight:1000; font-size:12px;
            margin-bottom:8px;
        }
        .tagLike{ background:#ecfeff; }
        .tagComment{ background:#fff7ed; }
        .notiText{ font-weight:1000; color:#111; }
        .notiText a{ color:#111; text-decoration: underline; }
        .preview{
            margin-top:8px;
            font-weight:900;
            color:#111;
            background:#f3f4f6;
            border:2px solid #111;
            border-radius:12px;
            padding:10px;
        }
        .muted{ color:#6b7280; font-weight:1000; }
        .notiDate{ margin-top:10px; font-size:12px; color:#6b7280; font-weight:900; }

        /* Notification icon in navbar */
        .nav-noti{
            position: relative;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            width:40px; height:40px;
            border:2px solid var(--black);
            border-radius:999px;
            background:#fff;
            color:#111;
            text-decoration:none;
            box-shadow: 0 6px 0 var(--black);
        }
        .nav-noti:hover{ background:#111; color:#fff; }
        .nav-noti .noti-badge{
            position:absolute;
            top:-8px; right:-8px;
            min-width:22px; height:22px;
            padding:0 6px;
            border-radius:999px;
            border:2px solid var(--black);
            background:var(--accent);
            color:#fff;
            font-weight:1000;
            font-size:12px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            line-height:1;
        }
    </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar">
    <div class="container navbar-container">

        <div class="navbar-left">
            <a href="index.jsp" class="nav-link">Explore</a>
            <a href="bookmark.jsp" class="nav-link">Bookmark</a>
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
                <img src="<%= profileImgUrl %>" alt="Profile" class="nav-profile-img">
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
        <a href="bookmark.jsp" class="nav-link">Bookmark</a>
        <a href="treasures.jsp" class="nav-link">Treasures</a>
        <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>

        <a href="notifications.jsp?type=ALL" class="nav-link">
            Notifications <% if (notiTotal > 0) { %>(<%= notiTotal %>)<% } %>
        </a>

        <a href="user_profile.jsp" class="nav-profile">
            <img src="<%= profileImgUrl %>" alt="Profile" class="nav-profile-img">
            <span><%= username %></span>
        </a>

        <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
    </div>
</nav>

<div class="page-wrap">
    <div class="card">

        <div class="header">
            <div class="title">
                <i class="fas fa-bell"></i>
                Notifications
            </div>
            <div class="counts">
                <span class="pill"><i class="fas fa-circle-dot"></i> Total: <b><%= notiTotal %></b></span>
                <span class="pill"><i class="fas fa-thumbs-up"></i> Likes: <b><%= notiLikes %></b></span>
                <span class="pill"><i class="fas fa-comment"></i> Comments: <b><%= notiComments %></b></span>
            </div>
        </div>

        <div class="subnav">
            <a class="tab <%= "ALL".equals(type) ? "active" : "" %>" href="notifications.jsp?type=ALL">
                <i class="fas fa-layer-group"></i> All
            </a>
            <a class="tab <%= "LIKE".equals(type) ? "active" : "" %>" href="notifications.jsp?type=LIKE">
                <i class="fas fa-thumbs-up"></i> Likes
            </a>
            <a class="tab <%= "COMMENT".equals(type) ? "active" : "" %>" href="notifications.jsp?type=COMMENT">
                <i class="fas fa-comment"></i> Comments
            </a>
        </div>

        <div class="list">
            <%
                if (notiHtml == null || notiHtml.trim().isEmpty()) {
            %>
                <div class="empty">
                    No notifications found for <b><%= type %></b>.
                </div>
            <%
                } else {
                    out.print(notiHtml);
                }
            %>
        </div>

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

</body>
</html>
