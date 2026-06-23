<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Locale" %>

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

    // 1. Strict Validation of Input Parameters
    int locationId = 0;
    try { 
        String idParam = request.getParameter("id");
        if (idParam != null && idParam.matches("\\d+")) {
            locationId = Integer.parseInt(idParam); 
        }
    } catch(Exception e){ 
        locationId = 0; 
    }

    if (locationId <= 0) {
        out.println("<h3 style='color:red; text-align:center; margin-top:50px;'>Invalid location id.</h3>");
        return;
    }

    String msg = request.getParameter("msg");

    // Initialize display metadata
    String locName="", locDesc="", locImg="";
    String imgUrl="image/placeholder.jpg";
    String gmapsLink=null;
    String addressText=null;

    // Aggregations and Counters
    double avgRating = 0.0;
    int totalReviews = 0;
    int totalViews = 0;
    int[] dist = new int[6];

    String dbUrl = "jdbc:mysql://localhost:3306/ltwbs";
    String dbUser = "root";
    String dbPass = "";

    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
        // Enable transactional encapsulation for safety
        conn.setAutoCommit(false);

        // REQUIREMENT 1: Increment View Count Atomically on Page Load
        String updateViewsSql = "UPDATE location SET views = views + 1 WHERE location_id = ?";
        try (PreparedStatement psViews = conn.prepareStatement(updateViewsSql)) {
            psViews.setInt(1, locationId);
            psViews.executeUpdate();
        }

        // REQUIREMENT 2 & 3: Performance Aggregation via Combined SQL Fetch Loop
        String mainLocSql = "SELECT l.name, l.description, l.image, l.views, "
                          + "COALESCE(AVG(r.rating), 0) AS avg_rating, "
                          + "COUNT(r.review_id) AS total_reviews "
                          + "FROM location l "
                          + "LEFT JOIN reviews r ON l.location_id = r.location_id "
                          + "WHERE l.location_id = ? "
                          + "GROUP BY l.location_id, l.name, l.description, l.image, l.views";

        try (PreparedStatement psMain = conn.prepareStatement(mainLocSql)) {
            psMain.setInt(1, locationId);
            try (ResultSet rs = psMain.executeQuery()) {
                if (rs.next()) {
                    locName = rs.getString("name");
                    locDesc = rs.getString("description");
                    locImg = rs.getString("image");
                    totalViews = rs.getInt("views"); // Fetches the newly incremented value
                    avgRating = rs.getDouble("avg_rating");
                    totalReviews = rs.getInt("total_reviews");

                    if (locImg != null && !locImg.trim().isEmpty()) {
                        imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + URLEncoder.encode(locImg.trim(), "UTF-8");
                    }
                } else {
                    conn.rollback();
                    out.println("<h3 style='color:red; text-align:center; margin-top:50px;'>Location not found.</h3>");
                    return;
                }
            }
        }
        
        // Finalize state commit safely
        conn.commit();

        // Load Location Address Data
        String addrSql = "SELECT address_line, city, state, gmaps_link FROM location_address WHERE location_id=? ORDER BY created_at DESC LIMIT 1";
        try (PreparedStatement psAddr = conn.prepareStatement(addrSql)) {
            psAddr.setInt(1, locationId);
            try (ResultSet rs = psAddr.executeQuery()) {
                if (rs.next()) {
                    String al = rs.getString("address_line");
                    String c  = rs.getString("city");
                    String s  = rs.getString("state");
                    String direct = rs.getString("gmaps_link");

                    addressText = (al != null ? al : "")
                                + ((c != null && !c.trim().isEmpty()) ? (", " + c) : "")
                                + ((s != null && !s.trim().isEmpty()) ? (", " + s) : "");

                    if (direct != null && !direct.trim().isEmpty()) {
                        gmapsLink = direct;
                    } else if (addressText != null && !addressText.trim().isEmpty()) {
                        gmapsLink = "https://gs.jurieo.com/gemini/official/maps/search/?api=1&query=" + URLEncoder.encode(addressText, "UTF-8");
                    }
                }
            }
        }

        // Fallback for empty/missing map references
        if (gmapsLink == null || gmapsLink.trim().isEmpty()) {
            String fallbackQuery = locName + ", Terengganu";
            gmapsLink = "https://gs.jurieo.com/gemini/official/maps/search/?api=1&query=" + URLEncoder.encode(fallbackQuery, "UTF-8");
        }

        // Fetch Rating Bar Distribution Metrics
        String distSql = "SELECT rating, COUNT(*) c FROM reviews WHERE location_id=? GROUP BY rating";
        try (PreparedStatement psDist = conn.prepareStatement(distSql)) {
            psDist.setInt(1, locationId);
            try (ResultSet rs = psDist.executeQuery()) {
                while (rs.next()) {
                    int r = rs.getInt("rating");
                    int c = rs.getInt("c");
                    if (r >= 1 && r <= 5) dist[r] = c;
                }
            }
        }

    } catch(Exception e) {
        out.println("<p style='color:red; text-align:center;'>Database Core Configuration Error: " + e.getMessage() + "</p>");
        return;
    }

    int maxCount = 0;
    for(int r = 1; r <= 5; r++) {
        if(dist[r] > maxCount) maxCount = dist[r];
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= locName %> | Details</title>

    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/home.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .nav-guest{ display:inline-flex; align-items:center; gap:8px; color:#fff; font-weight:700; }
        .guest-badge{ width:32px; height:32px; border-radius:50%; display:grid; place-items:center; background:rgba(255,255,255,0.18); border:2px solid #f8c471; font-weight:800; }
        .guest-text{ opacity:.9; }

        .wrap{ max-width: 1050px; margin: 20px auto; padding: 0 16px; }
        .back{ display:inline-flex; gap:8px; align-items:center; color:#111; text-decoration:none; margin:10px 0; font-weight:800; }
        .hero{ background:#fff; border-radius:18px; overflow:hidden; box-shadow:0 10px 24px rgba(0,0,0,.10); }
        .hero img{ width:100%; height:320px; object-fit:cover; display:block; }
        .hero-body{ padding:16px 18px; }
        .row{ display:flex; justify-content:space-between; gap:14px; flex-wrap:wrap; align-items:flex-end; }
        .title{ margin:0; font-size:26px; font-weight:900; }
        
        /* Summary Metric Styling Rules */
        .meta-metrics { display: inline-flex; align-items: center; gap: 12px; margin-top: 10px; font-size: 14px; font-weight: 700; color: #4b5563; background: #f3f4f6; padding: 8px 16px; border-radius: 999px; }
        .meta-metrics span.sep { color: #d1d5db; }

        .btn{ display:inline-flex; gap:8px; align-items:center; padding:10px 14px; border-radius:12px; border:1px solid rgba(0,0,0,.12); background:#111; color:#fff; text-decoration:none; font-weight:900; }
        .desc{ margin:14px 0 0; color:#374151; line-height:1.6; }

        .grid2{ display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-top:18px; }
        @media(max-width: 900px){ .grid2{ grid-template-columns:1fr; } }

        .card{ background:#fff; border-radius:18px; padding:16px; box-shadow:0 10px 24px rgba(0,0,0,.08); }
        .card h3{ margin:0 0 10px; font-size:18px; font-weight:900; }

        .ratingBox{ display:flex; gap:16px; align-items:flex-start; }
        .big{ font-size:36px; font-weight:1000; line-height:1; }
        .stars{ color:#111; letter-spacing:2px; }
        .barRow{ display:flex; align-items:center; gap:10px; margin:8px 0; }
        .bar{ flex:1; height:8px; background:#e5e7eb; border-radius:999px; overflow:hidden; }
        .bar > div{ height:100%; background:#111; width:0%; }
        .muted{ color:#6b7280; font-weight:700; }

        .btnLight{ background:#fff; color:#111; border:1px solid rgba(0,0,0,.12); border-radius:12px; padding:10px 14px; font-weight:900; cursor:pointer; }
        .reviewForm textarea{ width:100%; min-height:90px; border-radius:12px; border:1px solid #e5e7eb; padding:10px; box-sizing: border-width; }
        .reviewForm input[type="file"]{ width:100%; padding:10px; border:1px solid #e5e7eb; border-radius:12px; background:#fff; display:block; }

        .reviewItem{ border-top:1px solid #eee; padding-top:14px; margin-top:14px; }
        .reviewHead{ display:flex; justify-content:space-between; gap:10px; align-items:center; flex-wrap:wrap; }
        .reviewName{ font-weight:900; }
        .likeBtn{ background:#fff; border:1px solid rgba(0,0,0,.12); border-radius:999px; padding:6px 10px; cursor:pointer; font-weight:900; display:inline-flex; gap:8px; align-items:center; }
        .likeBtn.liked{ background:#111; color:#fff; }
        .danger{ border-color:#ef4444; color:#ef4444; }
        .commentBox{ margin-top:10px; padding-left:14px; border-left:3px solid #eee; }
        .commentItem{ margin:8px 0; }
        .commentForm{ display:flex; gap:8px; margin-top:10px; flex-wrap:wrap; }
        .commentForm input{ flex:1; min-width:220px; border-radius:12px; border:1px solid #e5e7eb; padding:10px; }

        .gallery{ margin-top:10px; display:flex; gap:10px; flex-wrap:wrap; }
        .gallery img{ width:160px; height:120px; object-fit:cover; border-radius:12px; border:1px solid #eee; }
        .msg{ margin:10px 0; padding:10px 12px; border-radius:12px; background:#ecfdf5; border:1px solid #10b98133; color:#065f46; font-weight:800; }
    </style>
</head>

<body>

<nav class="navbar">
    <div class="container navbar-container">
        <div class="navbar-left">
            <a href="home.jsp" class="nav-link">Explore</a>
            <a href="bookmark.jsp" class="nav-link">Bookmark</a>
            <a href="treasures.jsp" class="nav-link active">Treasures</a>
        </div>

        <a href="home.jsp" class="navbar-brand">
            <div class="brand-main">Local Treasure Terengganu</div>
            <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
        </a>

        <div class="navbar-right">
            <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>
            <a href="about.jsp" class="nav-link">About</a>

            <% if (loggedIn) { %>
                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl %>" alt="Profile" class="nav-profile-img">
                    <span><%= (username == null ? "Profile" : username) %></span>
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
            <% } else { %>
                <div class="nav-guest">
                    <div class="guest-badge">G</div>
                    <span class="guest-text">Guest</span>
                </div>
                <a href="login.jsp" class="nav-link">Login</a>
                <a href="sign_up.jsp?from=location_details&id=<%= locationId %>" class="nav-link">Sign Up</a>
            <% } %>
        </div>

        <button class="navbar-toggle" id="navbarToggle" type="button">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="navbar-mobile-menu" id="navbarMobileMenu">
        <a href="home.jsp" class="nav-link">Explore</a>
        <a href="bookmark.jsp" class="nav-link">Bookmark</a>
        <a href="treasures.jsp" class="nav-link active">Treasures</a>
        <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>
        <a href="about.jsp" class="nav-link">About</a>

        <% if (loggedIn) { %>
            <a href="user_profile.jsp" class="nav-profile">
                <img src="<%= profileImgUrl %>" alt="Profile" class="nav-profile-img">
                <span><%= (username == null ? "Profile" : username) %></span>
            </a>
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link">Logout</a>
        <% } else { %>
            <div class="nav-guest" style="padding:10px 0;">
                <div class="guest-badge">G</div>
                <span class="guest-text">Guest</span>
            </div>
            <a href="login.jsp" class="nav-link">Login</a>
            <a href="sign_up.jsp?from=location_details&id=<%= locationId %>" class="nav-link">Sign Up</a>
        <% } %>
    </div>
</nav>

<div class="wrap">
    <a class="back" href="treasures.jsp"><i class="fas fa-arrow-left"></i> Back to Locations</a>

    <% if (msg != null) { %>
        <div class="msg"><%= msg %></div>
    <% } %>

    <div class="hero">
        <img src="<%= imgUrl %>" alt="<%= locName %>">
        <div class="hero-body">
            <div class="row">
                <div>
                    <h1 class="title"><%= locName %></h1>
                    
                    <div class="meta-metrics">
                        <span><i class="fas fa-star" style="color: #f59e0b;"></i> <%= String.format(Locale.US, "%.1f", avgRating) %></span>
                        <span class="sep">|</span>
                        <span><i class="fas fa-eye"></i> <%= totalViews %> views</span>
                        <span class="sep">|</span>
                        <span><i class="fas fa-comment"></i> <%= totalReviews %> reviews</span>
                    </div>
                </div>

                <a class="btn" href="<%= gmapsLink %>" target="_blank" rel="noopener">
                    <i class="fas fa-map-marker-alt"></i> Show in Google Maps
                </a>
            </div>

            <p class="desc"><%= locDesc %></p>

            <% if (addressText != null && !addressText.trim().isEmpty()) { %>
                <p class="muted" style="margin-top:14px;"><i class="fas fa-location-dot" style="color:#667eea;"></i> <%= addressText %></p>
            <% } %>
        </div>
    </div>

    <div class="grid2">
        <div class="card">
            <h3>Ratings Breakdown</h3>
            <div class="ratingBox">
                <div>
                    <div class="big"><%= String.format(Locale.US, "%.1f", avgRating) %></div>
                    <div class="stars">
                        <%
                            int full = (int) Math.round(avgRating);
                            for(int i = 1; i <= 5; i++) { 
                                out.print(i <= full ? "★" : "☆"); 
                            }
                        %>
                    </div>
                    <div class="muted" style="margin-top: 4px;"><%= totalReviews %> reviews</div>
                </div>

                <div style="flex:1;">
                    <%
                        for(int r = 5; r >= 1; r--) {
                            int c = dist[r];
                            int pct = (maxCount == 0) ? 0 : (int) Math.round((c * 100.0) / maxCount);
                    %>
                        <div class="barRow">
                            <div class="muted" style="width:28px;"><%= r %>★</div>
                            <div class="bar"><div style="width: <%= pct %>%"></div></div>
                            <div class="muted" style="width:20px; text-align:right;"><%= c %></div>
                        </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>Write a Review</h3>

            <% if (!loggedIn) { %>
                <div class="muted">
                    Please <a href="login.jsp?from=location_details&id=<%= locationId %>">login</a> to write a review.
                </div>
            <% } else { %>
                <form class="reviewForm"
                      method="post"
                      action="<%= request.getContextPath() %>/ReviewActionServlet"
                      enctype="multipart/form-data">

                    <input type="hidden" name="action" value="addOrUpdateReview">
                    <input type="hidden" name="locationId" value="<%= locationId %>">

                    <div class="muted" style="margin-bottom:8px;">Your Rating</div>
                    <select name="rating" style="width:100%; border-radius:12px; padding:10px; border:1px solid #e5e7eb; background:#fff;">
                        <option value="5">5 - Excellent</option>
                        <option value="4">4 - Good</option>
                        <option value="3">3 - Okay</option>
                        <option value="2">2 - Bad</option>
                        <option value="1">1 - Terrible</option>
                    </select>

                    <div class="muted" style="margin:10px 0 6px;">Review Description</div>
                    <textarea name="reviewText" placeholder="Share details of your experience..."></textarea>

                    <div class="muted" style="margin:10px 0 6px;">Upload Images (optional)</div>
                    <input type="file" name="reviewImages" accept="image/*" multiple>

                    <div style="margin-top:12px;">
                        <button class="btnLight" type="submit">Post Review</button>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <div class="card" style="margin-top:16px;">
        <h3>All User Reviews</h3>

        <%
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
                String reviewSql =
                    "SELECT r.review_id, r.user_id, r.rating, r.review_text, r.review_date, " +
                    "COALESCE(u.username, CONCAT('User #', r.user_id)) AS display_name, " +
                    "(SELECT COUNT(*) FROM likes lk WHERE lk.review_id=r.review_id) AS like_count, " +
                    (loggedIn
                        ? "(SELECT COUNT(*) FROM likes lk2 WHERE lk2.review_id=r.review_id AND lk2.user_id=?) AS user_liked "
                        : "0 AS user_liked ") +
                    "FROM reviews r " +
                    "LEFT JOIN users u ON u.id = r.user_id " +
                    "WHERE r.location_id=? " +
                    "ORDER BY r.review_id DESC";

                try (PreparedStatement psReview = conn.prepareStatement(reviewSql)) {
                    int idx = 1;
                    if (loggedIn) psReview.setInt(idx++, userId);
                    psReview.setInt(idx, locationId);

                    try (ResultSet rs = psReview.executeQuery()) {
                        boolean hasReviews = false;

                        while (rs.next()) {
                            hasReviews = true;
                            int reviewId = rs.getInt("review_id");
                            int reviewOwnerId = rs.getInt("user_id");
                            int rating = rs.getInt("rating");
                            String rText = rs.getString("review_text");
                            String rDate = rs.getString("review_date");
                            String rUser = rs.getString("display_name");
                            int likeCount = rs.getInt("like_count");
                            boolean userLiked = rs.getInt("user_liked") > 0;
        %>
                            <div class="reviewItem" id="review-<%= reviewId %>">
                                <div class="reviewHead">
                                    <div>
                                        <div class="reviewName"><%= rUser %></div>
                                        <div class="muted">
                                            <% for(int i = 1; i <= 5; i++) out.print(i <= rating ? "★" : "☆"); %>
                                            • <%= rDate %>
                                        </div>
                                    </div>

                                    <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                                        <% if (!loggedIn) { %>
                                            <a class="likeBtn" href="login.jsp?from=location_details&id=<%= locationId %>">
                                                <i class="fas fa-thumbs-up"></i> <%= likeCount %>
                                            </a>
                                        <% } else { %>
                                            <form method="post" action="<%= request.getContextPath() %>/ReviewActionServlet" style="display:inline;">
                                                <input type="hidden" name="action" value="toggleLike">
                                                <input type="hidden" name="locationId" value="<%= locationId %>">
                                                <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                                <button type="submit" class="likeBtn <%= userLiked ? "liked" : "" %>">
                                                    <i class="fas fa-thumbs-up"></i> <%= likeCount %>
                                                </button>
                                            </form>
                                        <% } %>

                                        <% if (loggedIn && userId.intValue() == reviewOwnerId) { %>
                                            <form method="post" action="<%= request.getContextPath() %>/ReviewActionServlet" style="display:inline;">
                                                <input type="hidden" name="action" value="deleteReview">
                                                <input type="hidden" name="locationId" value="<%= locationId %>">
                                                <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                                <button type="submit" class="likeBtn danger" onclick="return confirm('Delete this review?');">
                                                    🗑 Delete
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>

                                <p style="margin:10px 0 0; color:#374151; line-height:1.6;"><%= (rText == null ? "" : rText) %></p>

                                <div class="gallery">
                                    <%
                                        String imgQuery = "SELECT file_name FROM review_images WHERE review_id=? ORDER BY image_id ASC";
                                        try (PreparedStatement ips = conn.prepareStatement(imgQuery)) {
                                            ips.setInt(1, reviewId);
                                            try (ResultSet irs = ips.executeQuery()) {
                                                while (irs.next()) {
                                                    String fn = irs.getString("file_name");
                                    %>
                                                    <img src="<%= request.getContextPath() %>/ReviewImageServlet?file=<%= URLEncoder.encode(fn, "UTF-8") %>" alt="review image">
                                    <%
                                                }
                                            }
                                        }
                                    %>
                                </div>

                                <div class="commentBox">
                                    <div class="muted" style="font-weight:900;">Comments</div>
                                    <%
                                        String commentSql = "SELECT c.comment_text, c.comment_date, " +
                                                            "COALESCE(u2.username, CONCAT('User #', c.user_id)) AS c_name " +
                                                            "FROM comments c " +
                                                            "LEFT JOIN users u2 ON u2.id = c.user_id " +
                                                            "WHERE c.review_id=? ORDER BY c.comment_id ASC";
                                        try (PreparedStatement cps = conn.prepareStatement(commentSql)) {
                                            cps.setInt(1, reviewId);
                                            try (ResultSet crs = cps.executeQuery()) {
                                                boolean hasComments = false;
                                                while (crs.next()) {
                                                    hasComments = true;
                                    %>
                                                    <div class="commentItem">
                                                        <span style="font-weight:900;"><%= crs.getString("c_name") %>:</span>
                                                        <span><%= crs.getString("comment_text") %></span>
                                                        <span class="muted"> • <%= crs.getString("comment_date") %></span>
                                                    </div>
                                    <%
                                                }
                                                if (!hasComments) {
                                                    out.println("<div class='muted' style='margin-top:6px;'>No comments yet.</div>");
                                                }
                                            }
                                        }
                                    %>

                                    <% if (loggedIn) { %>
                                        <form class="commentForm" method="post" action="<%= request.getContextPath() %>/ReviewActionServlet">
                                            <input type="hidden" name="action" value="addComment">
                                            <input type="hidden" name="locationId" value="<%= locationId %>">
                                            <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                            <input type="text" name="commentText" placeholder="Write a comment..." required>
                                            <button class="btnLight" type="submit">Post</button>
                                        </form>
                                    <% } else { %>
                                        <div class="muted" style="margin-top:10px;">
                                            Please <a href="login.jsp?from=location_details&id=<%= locationId %>">login</a> to comment.
                                        </div>
                                    <% } %>
                                </div>
                            </div>
        <%
                        }

                        if (!hasReviews) {
                            out.println("<div class='muted'>No reviews yet. Be the first to review this place!</div>");
                        }
                    }
                }
            } catch(Exception e) {
                out.println("<p style='color:red;'>DB Error loading reviews: " + e.getMessage() + "</p>");
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

</body>
</html>