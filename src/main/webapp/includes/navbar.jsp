<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String profilePicture = (String) session.getAttribute("profilePicture");

    boolean loggedIn = (userId != null);

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());

    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
            : "image/profile.jpeg";

    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;

    if (loggedIn) {
        try (Connection connN = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ltwbs",
                "root",
                "")) {

            try (PreparedStatement ps = connN.prepareStatement(
                    "SELECT COUNT(*) c FROM likes lk " +
                    "JOIN reviews r ON r.review_id = lk.review_id " +
                    "WHERE r.user_id=? AND lk.user_id <> ?")) {

                ps.setInt(1, userId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        notiLikes = rs.getInt("c");
                    }
                }

            } catch (Exception ignore) {}

            try (PreparedStatement ps = connN.prepareStatement(
                    "SELECT COUNT(*) c FROM comments c " +
                    "JOIN reviews r ON r.review_id = c.review_id " +
                    "WHERE r.user_id=? AND c.user_id <> ?")) {

                ps.setInt(1, userId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        notiComments = rs.getInt("c");
                    }
                }

            } catch (Exception ignore) {}

            notiTotal = notiLikes + notiComments;

        } catch (Exception ignore) {}
    }
%>

<nav class="navbar">

    <div class="container navbar-container">

        <div class="navbar-left">
            <a href="home.jsp" class="nav-link active">Explore</a>
            <a href="bookmark.jsp" class="nav-link">Bookmark</a>
            <a href="treasures.jsp" class="nav-link">Treasures</a>
        </div>

        <a href="home.jsp" class="navbar-brand">
            <div class="brand-main">Local Treasure Terengganu</div>
            <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
        </a>

        <div class="navbar-right">

            <% if (loggedIn) { %>

                <a href="notifications.jsp?type=ALL"
                   class="nav-noti"
                   title="Notifications">

                    <i class="fas fa-bell"></i>

                    <% if (notiTotal > 0) { %>
                        <span class="noti-badge">
                            <%= notiTotal %>
                        </span>
                    <% } %>

                </a>

                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl %>"
                         alt="Profile"
                         class="nav-profile-img">

                    <span><%= username %></span>
                </a>

                <% if ("Local Business".equalsIgnoreCase(role)) { %>
                    <a href="business_dashboard.jsp" class="nav-link">
                        Dashboard
                    </a>
                <% } %>

                <a href="<%= request.getContextPath() %>/LogoutServlet"
                   class="nav-link">
                    Logout
                </a>

            <% } else { %>

                <div class="nav-guest">
                    <div class="guest-badge">G</div>
                    <span class="guest-text">Guest</span>
                </div>

                <a href="login.jsp" class="nav-link">Login</a>
                <a href="sign_up.jsp?from=home" class="nav-link">
                    Sign Up
                </a>

            <% } %>

        </div>

        <button class="navbar-toggle"
                id="navbarToggle"
                type="button">

            <i class="fas fa-bars"></i>

        </button>

    </div>

    <div class="navbar-mobile-menu" id="navbarMobileMenu">

        <a href="home.jsp" class="nav-link active">Explore</a>
        <a href="bookmark.jsp" class="nav-link">Bookmark</a>
        <a href="treasures.jsp" class="nav-link">Treasures</a>
        <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>

        <% if (loggedIn) { %>

            <a href="notifications.jsp?type=ALL" class="nav-link">
                Notifications
                <% if (notiTotal > 0) { %>
                    (<%= notiTotal %>)
                <% } %>
            </a>

            <% if ("Local Business".equalsIgnoreCase(role)) { %>

                <a href="business_dashboard.jsp" class="nav-link">
                    Business Dashboard
                </a>

            <% } %>

            <a href="user_profile.jsp" class="nav-profile">

                <img src="<%= profileImgUrl %>"
                     alt="Profile"
                     class="nav-profile-img">

                <span><%= username %></span>

            </a>

            <a href="<%= request.getContextPath() %>/LogoutServlet"
               class="nav-link">
                Logout
            </a>

        <% } else { %>

            <div class="nav-guest" style="padding:10px 0;">
                <div class="guest-badge">G</div>
                <span class="guest-text">Guest</span>
            </div>

            <a href="login.jsp" class="nav-link">Login</a>

            <a href="sign_up.jsp?from=home"
               class="nav-link">
                Sign Up
            </a>

        <% } %>

    </div>

</nav>

<script>
document.addEventListener('DOMContentLoaded', function () {

    const navbarToggle =
        document.getElementById('navbarToggle');

    const navbarMobileMenu =
        document.getElementById('navbarMobileMenu');

    if (navbarToggle && navbarMobileMenu) {

        navbarToggle.addEventListener('click', function (e) {

            e.stopPropagation();

            navbarMobileMenu.classList.toggle('active');

        });
    }

    document.addEventListener('click', function (event) {

        if (
            navbarMobileMenu &&
            !event.target.closest('.navbar-container') &&
            !event.target.closest('.navbar-mobile-menu')
        ) {
            navbarMobileMenu.classList.remove('active');
        }

    });

});
</script>