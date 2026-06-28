<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

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
    boolean loggedIn = (userId != null);

    // fallback if profilePicture null/empty
    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
            : "image/profile.jpeg";

    // ========= STATS (DB) =========
    int bookmarkCount = 0;

    int subTotal = 0;
    int subPending = 0;
    int subApproved = 0;
    int subRejected = 0;

    // notifications counts for navbar bell badge
    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;

   
         try (Connection conn = util.DBConnection.getConnection()) {

        // Bookmarks count
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) c FROM bookmarks WHERE user_id=?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    bookmarkCount = rs.getInt("c");
                }
            }
        } catch (Exception ignore) {
        }

        // Location submissions count + status breakdown
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT "
                + "  COUNT(*) total, "
                + "  SUM(CASE WHEN status='PENDING' THEN 1 ELSE 0 END) pending, "
                + "  SUM(CASE WHEN status='APPROVED' THEN 1 ELSE 0 END) approved, "
                + "  SUM(CASE WHEN status='REJECTED' THEN 1 ELSE 0 END) rejected "
                + "FROM location_submission WHERE user_id=?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    subTotal = rs.getInt("total");
                    subPending = rs.getInt("pending");
                    subApproved = rs.getInt("approved");
                    subRejected = rs.getInt("rejected");
                }
            }
        } catch (Exception ignore) {
        }

        // Notifications counts:
        // Likes on your reviews (exclude your own likes)
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) c "
                + "FROM likes lk "
                + "JOIN reviews r ON r.review_id = lk.review_id "
                + "WHERE r.user_id=? AND lk.user_id <> ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    notiLikes = rs.getInt("c");
                }
            }
        } catch (Exception ignore) {
        }

        // Comments on your reviews (exclude your own comments)
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) c "
                + "FROM comments c "
                + "JOIN reviews r ON r.review_id = c.review_id "
                + "WHERE r.user_id=? AND c.user_id <> ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    notiComments = rs.getInt("c");
                }
            }
        } catch (Exception ignore) {
        }

        notiTotal = notiLikes + notiComments;

    } catch (Exception ignore) {
        // kalau DB error, page still jalan with 0 counts
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>My Profile - Local Treasure Terengganu</title>
        <link rel="stylesheet" href="css/styles.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>
            :root{
                --black:#111;
                --white:#fff;
                --gray-light:#f5f5f5;
                --gray-medium:#888;
                --gray-dark:#333;
                --accent:#ff4757;
                --accent-light:#ff6b81;
                --shadow:0 10px 24px rgba(0,0,0,.14);
                --transition: all .25s ease;
            }
            body{
                background: linear-gradient(135deg, var(--gray-light) 0%, #e8e8e8 100%);
                min-height:100vh;
                padding-bottom:30px;
            }

            /* ✅ Fixed size smaller */
            .profile-container{
                max-width: 760px;
                margin: 22px auto;
                padding: 0 14px;
            }
            .profile-card{
                background:var(--white);
                border-radius:18px;
                overflow:hidden;
                box-shadow:var(--shadow);
                border:2px solid var(--black);
            }

            .profile-header{
                background: linear-gradient(90deg, var(--black) 0%, var(--gray-dark) 100%);
                padding: 26px 22px 18px;
                color: var(--white);
                position: relative;
                text-align: center;
                border-bottom: 3px solid var(--black);
            }

            .edit-profile-btn{
                position:absolute;
                top:14px;
                right:14px;
                background:var(--white);
                color:var(--black);
                border:2px solid var(--black);
                padding:8px 12px;
                border-radius:999px;
                font-weight:900;
                cursor:pointer;
                display:flex;
                align-items:center;
                gap:8px;
                font-size:12px;
            }
            .edit-profile-btn:hover{
                background:var(--black);
                color:var(--white);
            }

            .profile-avatar{
                width: 110px;
                height: 110px;
                border-radius:50%;
                object-fit:cover;
                border:5px solid var(--white);
                box-shadow: 0 10px 22px rgba(0,0,0,.25);
            }
            .profile-name{
                font-size: 24px;
                font-weight: 1000;
                margin: 10px 0 4px;
                text-transform:uppercase;
                letter-spacing:1px;
            }
            .profile-email{
                font-size: 14px;
                opacity:.9;
                margin: 0 0 12px;
                color:#f1f5f9;
            }

            .role-badge{
                display:inline-flex;
                align-items:center;
                gap:8px;
                background:var(--white);
                color:var(--black);
                padding:7px 14px;
                border-radius:999px;
                font-weight:1000;
                font-size:12px;
                text-transform:uppercase;
                border:2px solid var(--black);
            }

            .profile-body{
                padding: 18px 18px 24px;
                background: var(--gray-light);
            }

            .section-title{
                font-size: 14px;
                font-weight: 1000;
                letter-spacing:1px;
                display:flex;
                gap:10px;
                align-items:center;
                border-bottom: 3px solid var(--black);
                padding-bottom: 10px;
                margin: 18px 0 14px;
                text-transform: uppercase;
            }

            .info-grid{
                display:grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
            }
            @media(max-width: 720px){
                .info-grid{
                    grid-template-columns:1fr;
                }
            }

            .info-item{
                background:var(--white);
                border:2px solid var(--black);
                border-radius:14px;
                padding: 14px 14px;
                box-shadow: 0 6px 0 var(--black);
                position: relative;
            }
            .info-label{
                font-size: 11px;
                color: var(--gray-medium);
                font-weight: 900;
                text-transform:uppercase;
                letter-spacing:1px;
            }
            .info-value{
                font-size: 16px;
                font-weight: 1000;
                color: var(--black);
                margin-top:6px;
            }

            .stats-container{
                display:flex;
                gap:12px;
                flex-wrap:wrap;
                background: transparent;
                margin-top: 10px;
            }
            .statBox{
                flex:1;
                min-width: 210px;
                background: var(--white);
                border:2px solid var(--black);
                border-radius:14px;
                padding: 14px 14px;
                box-shadow: 0 6px 0 var(--black);
            }
            .statNum{
                font-size: 28px;
                font-weight: 1000;
                color: var(--black);
                line-height:1;
            }
            .statLabel{
                margin-top:6px;
                font-size:12px;
                font-weight:900;
                color:var(--gray-dark);
                text-transform:uppercase;
                letter-spacing:1px;
            }
            .subStatus{
                margin-top:10px;
                display:flex;
                gap:8px;
                flex-wrap:wrap;
            }
            .chip{
                display:inline-flex;
                align-items:center;
                gap:8px;
                padding:6px 10px;
                border-radius:999px;
                border:2px solid var(--black);
                font-weight:1000;
                font-size:12px;
                background:#fff;
            }
            .chipPending{
                background:#fff7ed;
            }
            .chipApproved{
                background:#ecfdf5;
            }
            .chipRejected{
                background:#fef2f2;
            }

            .action-buttons{
                display:flex;
                gap:12px;
                flex-wrap:wrap;
                margin-top: 16px;
            }
            .btn{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                gap:10px;
                padding: 12px 16px;
                border-radius:14px;
                font-weight:1000;
                text-decoration:none;
                border:2px solid var(--black);
                cursor:pointer;
                background:#fff;
                color:#111;
                box-shadow: 0 6px 0 var(--black);
            }
            .btn:hover{
                transform: translateY(-2px);
                box-shadow: 0 10px 0 var(--black);
            }
            .btnPrimary{
                background:#111;
                color:#fff;
            }
            .btnDanger{
                background: var(--accent);
                color:#fff;
                border-color:#d63031;
            }

            /* 🔔 Notification icon in navbar (ganti About) */
            .nav-noti{
                position: relative;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                width:40px;
                height:40px;
                border:2px solid var(--black);
                border-radius:999px;
                background:#fff;
                color:#111;
                text-decoration:none;
                box-shadow: 0 6px 0 var(--black);
            }
            .nav-noti:hover{
                background:#111;
                color:#fff;
            }
            .nav-noti .noti-badge{
                position:absolute;
                top:-8px;
                right:-8px;
                min-width:22px;
                height:22px;
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

        <!-- ✅ NAVBAR (About dibuang, diganti icon 🔔) -->
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
                    <% if (loggedIn) { %>

                    <!-- 🔔 Notification icon (replace About) -->
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
                <a href="index.jsp" class="nav-link active">Explore</a>
                <a href="bookmark.jsp" class="nav-link">Bookmark</a>
                <a href="treasures.jsp" class="nav-link">Treasures</a>
                <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>

                <% if (loggedIn) { %>
                <a href="notifications.jsp?type=ALL" class="nav-link">
                    Notifications <% if (notiTotal > 0) {%>(<%= notiTotal%>)<% }%>
                </a>

                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                    <span><%= username%></span>
                </a>
                <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
                <% }%>
            </div>
        </nav>

        <div class="profile-container">
            <div class="profile-card">

                <div class="profile-header">
                    <a class="edit-profile-btn" href="edit_profile.jsp">
                        <i class="fas fa-edit"></i> Edit
                    </a>


                    <img class="profile-avatar" src="<%= profileImgUrl%>" alt="Profile">

                    <div class="profile-name"><%= username%></div>
                    <div class="profile-email"><%= email%></div>

                    <div class="role-badge">
                        <i class="fas fa-user-tag"></i> <%= role%>
                    </div>
                </div>

                <div class="profile-body">

                    <div class="section-title"><i class="fas fa-user-circle"></i> Account Information</div>

                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-label">Username</div>
                            <div class="info-value"><%= username%></div>
                        </div>

                        <div class="info-item">
                            <div class="info-label">Email</div>
                            <div class="info-value"><%= email%></div>
                        </div>

                        <div class="info-item">
                            <div class="info-label">Role</div>
                            <div class="info-value"><%= role%></div>
                        </div>

                        <div class="info-item">
                            <div class="info-label">Status</div>
                            <div class="info-value">ACTIVE <i class="fas fa-check-circle" style="color:#00b894;"></i></div>
                        </div>
                    </div>

                    <div class="section-title"><i class="fas fa-chart-line"></i> Your Activity</div>

                    <div class="stats-container">

                        <div class="statBox">
                            <div class="statNum"><%= bookmarkCount%></div>
                            <div class="statLabel">Bookmarks</div>
                        </div>

                        <div class="statBox">
                            <div class="statNum"><%= subTotal%></div>
                            <div class="statLabel">Location Submitted</div>
                            <a class="btn" href="my_submissions.jsp"><i class="fas fa-location-dot"></i> My Submissions</a>

                            <div class="subStatus">
                                <span class="chip chipPending"><i class="fas fa-hourglass-half"></i> Pending: <%= subPending%></span>
                                <span class="chip chipApproved"><i class="fas fa-check"></i> Approved: <%= subApproved%></span>
                                <span class="chip chipRejected"><i class="fas fa-xmark"></i> Rejected: <%= subRejected%></span>
                            </div>
                        </div>

                    </div>

                    <!-- ✅ Notifications box dalam profile DIKELUARKAN (semua noti ada di notifications.jsp) -->

                    <div class="action-buttons">
                        <a class="btn" href="index.jsp"><i class="fas fa-home"></i> Home</a>
                        <a class="btn btnPrimary" href="bookmark.jsp"><i class="fas fa-bookmark"></i> Bookmarks</a>

                        <!-- ✅ button notifications dibuang sebab dah ada icon 🔔 kat navbar -->

                        <a class="btn btnPrimary" href="<%= request.getContextPath()%>/LogoutServlet">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>

                      <form method="post" action="<%= request.getContextPath() %>/DeleteAccountServlet" onsubmit="return confirm('Are you sure you want to delete your account? This action is irreversible.');">
    <button type="submit" class="btn btnDanger">
        <i class="fas fa-trash"></i> Delete
    </button>

                    </div>

                </div>
            </div>
        </div>

        <script>
            // navbar mobile toggle
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
