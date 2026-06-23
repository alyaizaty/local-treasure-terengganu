<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp?from=submit_location");
        return;
    }

    String username = (String) session.getAttribute("username");
    String profilePicture = (String) session.getAttribute("profilePicture");

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
        ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
        : "image/profile.jpeg";

    // ===== Notification counts (same logic like your notifications.jsp) =====
    int notiLikes = 0;
    int notiComments = 0;
    int notiTotal = 0;

    try (Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/ltwbs", "root", "")) {

        // likes on your reviews (exclude your own likes)
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

        // comments on your reviews (exclude your own comments)
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

    } catch (Exception ignore) {}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Location | Local Treasure Terengganu</title>

    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/home.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root{
            --black:#111; --white:#fff; --gray-light:#f5f5f5; --gray-dark:#333;
            --accent:#ff4757;
        }

        /* 🔔 Notification icon in navbar (same style) */
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

        .page-wrap{ max-width: 980px; margin: 30px auto; padding: 0 18px; }
        .card{ background:#fff; border-radius:16px; box-shadow:0 10px 24px rgba(0,0,0,.12); padding:22px; }
        .card h2{ margin:0 0 6px; }
        .muted{ color:#6b7280; margin:0 0 14px; font-weight:700; }

        label{ font-weight:800; display:block; margin:12px 0 6px; }
        input, select, textarea{
            width:100%;
            border:1px solid #e5e7eb;
            border-radius:12px;
            padding:12px;
            outline:none;
            box-sizing:border-box;
        }
        textarea{ min-height:120px; resize:vertical; }

        .grid{ display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        @media (max-width:780px){ .grid{ grid-template-columns:1fr; } }

        .actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:14px; }
        .btn{
            display:inline-flex; align-items:center; justify-content:center;
            padding:12px 16px; border-radius:12px;
            border:1px solid rgba(0,0,0,.08);
            cursor:pointer; text-decoration:none; font-weight:900;
        }
        .btn-primary{ background:#0f2a45; color:#fff; border-color:#0f2a45; }
        .btn-light{ background:#fff; color:#111827; }

        .alert{
            padding:12px 14px; border-radius:12px;
            margin: 0 0 14px 0; font-weight:800;
        }
        .alert-success{ background:#ecfdf5; border:1px solid #10b98133; color:#065f46; }
        .alert-error{ background:#fef2f2; border:1px solid #ef444433; color:#991b1b; }

        #mapWrap{ display:none; margin-top:12px; }
        #mapFrame{ width:100%; height:280px; border:0; border-radius:14px; }
        #openMapsBtn{ display:none; }

        .hint{ font-size:13px; color:#6b7280; font-weight:700; margin-top:6px; }
    </style>
</head>

<body>

<!-- ✅ NAVBAR (ikut style macam contoh you bagi) -->
<nav class="navbar">
    <div class="container navbar-container">

        <div class="navbar-left">
            <a href="home.jsp" class="nav-link">Explore</a>
            <a href="bookmark.jsp" class="nav-link">Bookmark</a>
            <a href="treasures.jsp" class="nav-link">Treasures</a>
        </div>

        <a href="home.jsp" class="navbar-brand">
            <div class="brand-main">Local Treasure Terengganu</div>
            <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
        </a>

        <div class="navbar-right">
            <!-- 🔔 Notifications -->
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
        <a href="home.jsp" class="nav-link">Explore</a>
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
        <h2>Submit a Hidden Gem 🐢</h2>
        <p class="muted">Fill in details, preview map, then submit for admin approval. Images are optional.</p>

        <% if (request.getParameter("msg") != null) { %>
            <div class="alert alert-success"><%= request.getParameter("msg") %></div>
        <% } %>
        <% if (request.getParameter("err") != null) { %>
            <div class="alert alert-error"><%= request.getParameter("err") %></div>
        <% } %>

        <form method="post"
              action="<%= request.getContextPath() %>/SubmitLocationServlet"
              enctype="multipart/form-data"
              onsubmit="return beforeSubmit();">

            <label for="locationName">Location Name *</label>
            <input id="locationName" name="locationName" type="text" placeholder="e.g., Pantai Batu Buruk" required>

            <label for="category">Category *</label>
            <select id="category" name="category" required>
                <option value="" selected disabled>Select category</option>
                <option value="Food">Food</option>
                <option value="Scenic Spots">Scenic Spots</option>
                <option value="Chalets">Chalets</option>
                <option value="Shopping">Shopping</option>
                <option value="Culture">Culture</option>
                <option value="Others">Others</option>
            </select>

            <label for="description">Description *</label>
            <textarea id="description" name="description" placeholder="Describe what makes this place special..." required></textarea>

            <hr style="margin:18px 0; border:none; border-top:1px solid #eee;">

            <label for="addressLine">Address Line *</label>
            <input id="addressLine" name="addressLine" type="text" placeholder="e.g., Jalan Pantai" required onblur="previewMap()">

            <div class="grid">
                <div>
                    <label for="city">City *</label>
                    <input id="city" name="city" type="text" placeholder="Kuala Terengganu" required onblur="previewMap()">
                </div>
                <div>
                    <label for="state">State *</label>
                    <input id="state" name="state" type="text" placeholder="Terengganu" required onblur="previewMap()">
                </div>
            </div>

            <label for="images">Upload Images (optional)</label>
            <input id="images" type="file" name="images" accept="image/*" multiple>
            <div class="hint">You can select multiple images at once (Ctrl/Shift).</div>

            <input type="hidden" id="gmapsLink" name="gmapsLink">

            <div class="actions">
                <button type="button" class="btn btn-light" onclick="previewMap()">Preview Map</button>
                <a id="openMapsBtn" class="btn btn-light" href="#" target="_blank">Open in Google Maps</a>
                <button type="submit" class="btn btn-primary">Submit Location</button>
            </div>

            <div id="mapWrap">
                <iframe id="mapFrame" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
            </div>

        </form>
    </div>
</div>

<script>
function previewMap(){
    // ✅ ikut address (bukan locationName)
    const address = document.getElementById("addressLine").value || "";
    const city    = document.getElementById("city").value || "";
    const state   = document.getElementById("state").value || "";

    const full = [address, city, state].filter(Boolean).join(", ").trim();

    if(!full){
        alert("Sila isi Address, City dan State dulu.");
        return;
    }

    const q = encodeURIComponent(full);

    const mapsLink = "https://www.google.com/maps/search/?api=1&query=" + q;
    document.getElementById("gmapsLink").value = mapsLink;

    const btn = document.getElementById("openMapsBtn");
    btn.href = mapsLink;
    btn.style.display = "inline-flex";

    const embed = "https://www.google.com/maps?q=" + q + "&output=embed";
    document.getElementById("mapFrame").src = embed;
    document.getElementById("mapWrap").style.display = "block";
}

function beforeSubmit(){
    const link = document.getElementById("gmapsLink").value;
    if(!link){
        alert("Please click Preview Map first (to generate Google Maps link).");
        return false;
    }
    return true;
}

// navbar mobile toggle (same)
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
