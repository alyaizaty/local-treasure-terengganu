<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder" %>
<%@ page import="util.DBConnection" %>
<%
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }
    int locId = Integer.parseInt(idStr);

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean loggedIn = (userId != null);

    String profilePicture = (String) session.getAttribute("profilePicture");
    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + URLEncoder.encode(profilePicture, "UTF-8"))
            : "image/profile.jpeg";

    String locName = "Location Details";
    String locDesc = "";
    String mainImage = "";
    String categoryName = "General";
    int views = 0;
    String gmapsLink = "";

    double avgRating = 0.0;
    int totalReviews = 0;
    int[] dist = new int[6];

    try (Connection conn = DBConnection.getConnection()) {
        // 1. Update views count
        try (PreparedStatement ps = conn.prepareStatement("UPDATE location SET views = views + 1 WHERE location_id = ?")) {
            ps.setInt(1, locId);
            ps.executeUpdate();
        }

        // 2. Fetch Location Details
        String locSql = "SELECT l.*, c.name AS category_name, a.gmaps_link " +
                        "FROM location l " +
                        "LEFT JOIN categories c ON l.category_id = c.category_id " +
                        "LEFT JOIN location_address a ON l.location_id = a.location_id " +
                        "WHERE l.location_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(locSql)) {
            ps.setInt(1, locId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    locName = rs.getString("name");
                    locDesc = rs.getString("description");
                    mainImage = rs.getString("image");
                    if (rs.getString("category_name") != null) categoryName = rs.getString("category_name");
                    views = rs.getInt("views");
                    gmapsLink = rs.getString("gmaps_link");
                } else {
                    response.sendRedirect("index.jsp");
                    return;
                }
            }
        }

        // 3. Fetch Aggregate Ratings
        String aggSql = "SELECT IFNULL(AVG(rating), 0) AS avg_rating, COUNT(review_id) AS total_reviews FROM reviews WHERE location_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(aggSql)) {
            ps.setInt(1, locId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    avgRating = rs.getDouble("avg_rating");
                    totalReviews = rs.getInt("total_reviews");
                }
            }
        }

        // 4. Fetch Rating Distribution
        String distSql = "SELECT rating, COUNT(*) c FROM reviews WHERE location_id=? GROUP BY rating";
        try (PreparedStatement ps = conn.prepareStatement(distSql)) {
            ps.setInt(1, locId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int r = rs.getInt("rating");
                    if (r >= 1 && r <= 5) {
                        dist[r] = rs.getInt("c");
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    int maxCount = 0;
    for (int r = 1; r <= 5; r++) {
        if (dist[r] > maxCount) maxCount = dist[r];
    }

    // ==========================================
    // SMART IMAGE LOGIC (FIX FOR BROKEN IMAGES)
    // ==========================================
    String imgUrl = request.getContextPath() + "/image/background.jpg";
    if (mainImage != null && !mainImage.trim().isEmpty()) {
        if (mainImage.startsWith("sub_")) {
            imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + URLEncoder.encode(mainImage.trim(), "UTF-8");
        } else if (mainImage.startsWith("business_")) {
            imgUrl = request.getContextPath() + "/uploads/" + URLEncoder.encode(mainImage.trim(), "UTF-8");
        } else {
            imgUrl = request.getContextPath() + "/image/" + mainImage.trim();
        }
    }
    
    // Gmaps fallback link
    if (gmapsLink == null || gmapsLink.trim().isEmpty()) {
        gmapsLink = "https://www.google.com/maps/search/?api=1&query=" + URLEncoder.encode(locName + ", Terengganu", "UTF-8");
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= locName %> | Details</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .wrap{ max-width:1050px; margin:20px auto; padding:0 16px; }
        .back{ display:inline-flex; gap:8px; align-items:center; color:#111; text-decoration:none; margin:10px 0; font-weight:800; }
        .hero{ background:#fff; border-radius:18px; overflow:hidden; box-shadow:0 10px 24px rgba(0,0,0,.10); border:1px solid #eee; }
        .hero img{ width:100%; height:380px; object-fit:cover; display:block; }
        .hero-body{ padding:20px 24px; }
        .row{ display:flex; justify-content:space-between; gap:14px; flex-wrap:wrap; align-items:flex-end; }
        .title{ margin:0; font-size:32px; font-weight:900; }
        .meta-metrics{ display:inline-flex; align-items:center; gap:12px; margin-top:10px; font-size:14px; font-weight:700; color:#4b5563; background:#f3f4f6; padding:8px 16px; border-radius:999px; }
        .meta-metrics span.sep{ color:#d1d5db; }
        .btn{ display:inline-flex; gap:8px; align-items:center; padding:10px 14px; border-radius:12px; border:1px solid rgba(0,0,0,.12); background:#111; color:#fff; text-decoration:none; font-weight:900; }
        
        .grid2{ display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-top:18px; }
        @media(max-width:900px){ .grid2{ grid-template-columns:1fr; } }
        
        .card{ background:#fff; border-radius:18px; padding:20px; box-shadow:0 10px 24px rgba(0,0,0,.08); border:1px solid #eee; }
        .card h3{ margin:0 0 15px; font-size:20px; font-weight:900; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        
        .ratingBox{ display:flex; gap:16px; align-items:flex-start; }
        .big{ font-size:36px; font-weight:1000; line-height:1; }
        .stars{ color:#111; letter-spacing:2px; }
        .barRow{ display:flex; align-items:center; gap:10px; margin:8px 0; }
        .bar{ flex:1; height:8px; background:#e5e7eb; border-radius:999px; overflow:hidden; }
        .bar > div{ height:100%; background:#111; width:0%; }
        .muted{ color:#6b7280; font-weight:700; }
        
        .btnLight{ background:#fff; color:#111; border:1px solid rgba(0,0,0,.12); border-radius:12px; padding:10px 14px; font-weight:900; cursor:pointer; }
        .reviewForm textarea{ width:100%; min-height:90px; border-radius:12px; border:1px solid #e5e7eb; padding:10px; box-sizing:border-box; resize:vertical; font-family:inherit;}
        .reviewForm input[type="file"]{ width:100%; padding:10px; border:1px solid #e5e7eb; border-radius:12px; background:#fff; display:block; }
        
        .reviewItem{ border-top:1px solid #eee; padding-top:16px; margin-top:16px; }
        .reviewHead{ display:flex; justify-content:space-between; gap:10px; align-items:center; flex-wrap:wrap; }
        .reviewName{ font-weight:900; font-size:15px; }
        .likeBtn{ background:#fff; border:1px solid rgba(0,0,0,.12); border-radius:999px; padding:6px 12px; cursor:pointer; font-weight:900; display:inline-flex; gap:8px; align-items:center; font-size:13px; }
        .likeBtn.liked{ background:#111; color:#fff; }
        .danger{ border-color:#ef4444; color:#ef4444; }
        
        .commentBox{ margin-top:12px; padding-left:16px; border-left:3px solid #eee; }
        .commentItem{ margin:8px 0; font-size:14px; }
        .commentForm{ display:flex; gap:8px; margin-top:10px; flex-wrap:wrap; }
        .commentForm input{ flex:1; min-width:220px; border-radius:12px; border:1px solid #e5e7eb; padding:10px; font-family:inherit; }
        
        .gallery{ margin-top:12px; display:flex; gap:10px; flex-wrap:wrap; }
        .gallery img{ width:160px; height:120px; object-fit:cover; border-radius:12px; border:1px solid #eee; }
        .msg{ margin:10px 0; padding:12px; border-radius:12px; background:#ecfdf5; border:1px solid #10b98133; color:#065f46; font-weight:800; }
        
        /* Navbar tweaks to match */
        .navbar{ background:#000; padding:15px 0; }
        .navbar a{ color:#fff; text-decoration:none; font-weight:bold; margin-right:15px; }
    </style>
</head>
<body style="background-color: #f4f7f6; margin: 0; font-family: Arial, sans-serif;">

<!-- Simple Header to match design -->

   
    


<div class="wrap">
    <a class="back" href="index.jsp">
        <i class="fas fa-arrow-left"></i> Back to Locations
    </a>

    <% if (msg != null) { %>
        <div class="msg"><%= msg %></div>
    <% } %>

    <div class="hero">
        <!-- FIXED IMAGE LOGIC + FALLBACK ONERROR -->
        <img src="<%= imgUrl %>" onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/image/background.jpg';" alt="<%= locName %>">
        
        <div class="hero-body">
            <div class="row">
                <div>
                    <h1 class="title"><%= locName %></h1>
                    <div class="meta-metrics">
                        <span><i class="fas fa-star" style="color:#f59e0b;"></i> <%= String.format(Locale.US, "%.1f", avgRating) %></span>
                        <span class="sep">|</span>
                        <span><i class="fas fa-eye"></i> <%= views %> views</span>
                        <span class="sep">|</span>
                        <span><i class="fas fa-comment"></i> <%= totalReviews %> reviews</span>
                    </div>
                </div>
                <a class="btn" href="<%= gmapsLink %>" target="_blank">
                    <i class="fas fa-map-marker-alt"></i> Show in Google Maps
                </a>
            </div>
            <p style="margin-top:20px; color:#4b5563; line-height:1.6; font-size:16px;">
                <%= locDesc %>
            </p>
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
                            for (int i = 1; i <= 5; i++) {
                                out.print(i <= full ? "★" : "☆");
                            }
                        %>
                    </div>
                    <div class="muted" style="margin-top:4px;"><%= totalReviews %> reviews</div>
                </div>
                <div style="flex:1;">
                    <%
                        for (int r = 5; r >= 1; r--) {
                            int c = dist[r];
                            int pct = maxCount == 0 ? 0 : (int) Math.round((c * 100.0) / maxCount);
                    %>
                        <div class="barRow">
                            <div class="muted" style="width:28px;"><%= r %>★</div>
                            <div class="bar"><div style="width:<%= pct %>%"></div></div>
                            <div class="muted" style="width:20px; text-align:right;"><%= c %></div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>Write a Review</h3>
            <% if (!loggedIn) { %>
                <div class="muted">
                    Please <a href="login.jsp?redirect=location_details.jsp?id=<%= locId %>" style="color:#111; text-decoration:underline;">login</a> to write a review.
                </div>
            <% } else { %>
                <form class="reviewForm" method="post" action="<%= request.getContextPath() %>/ReviewActionServlet" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="addOrUpdateReview">
                    <input type="hidden" name="locationId" value="<%= locId %>">
                    <input type="hidden" name="customRedirect" value="location_details.jsp?id=<%= locId %>">
                    
                    <div class="muted" style="margin-bottom:8px;">Your Rating</div>
                    <select name="rating" style="width:100%; border-radius:12px; padding:10px; border:1px solid #e5e7eb; background:#fff; font-weight:bold; font-family:inherit;">
                        <option value="5">5 - Excellent</option>
                        <option value="4">4 - Good</option>
                        <option value="3">3 - Okay</option>
                        <option value="2">2 - Bad</option>
                        <option value="1">1 - Terrible</option>
                    </select>
                    
                    <div class="muted" style="margin:10px 0 6px;">Review Description</div>
                    <textarea name="reviewText" placeholder="Share details of your experience..." required></textarea>
                    
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
            try (Connection conn = DBConnection.getConnection()) {
                String reviewSql =
                    "SELECT r.review_id, r.user_id, r.rating, r.review_text, r.review_date, r.image AS main_review_image, " +
                    "COALESCE(u.username, CONCAT('User #', r.user_id)) AS display_name, " +
                    "(SELECT COUNT(*) FROM likes lk WHERE lk.review_id = r.review_id) AS like_count, " +
                    (loggedIn
                        ? "(SELECT COUNT(*) FROM likes lk2 WHERE lk2.review_id = r.review_id AND lk2.user_id = ?) AS user_liked "
                        : "0 AS user_liked ") +
                    "FROM reviews r " +
                    "LEFT JOIN users u ON u.id = r.user_id " +
                    "WHERE r.location_id = ? " +
                    "ORDER BY r.review_id DESC";
                    
                try (PreparedStatement psReview = conn.prepareStatement(reviewSql)) {
                    int idx = 1;
                    if (loggedIn) {
                        psReview.setInt(idx++, userId);
                    }
                    psReview.setInt(idx, locId);
                    
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
                            String mainReviewImage = rs.getString("main_review_image");
                            int likeCount = rs.getInt("like_count");
                            boolean userLiked = rs.getInt("user_liked") > 0;
        %>
                            <div class="reviewItem" id="review-<%= reviewId %>">
                                <div class="reviewHead">
                                    <div>
                                        <div class="reviewName"><%= rUser %></div>
                                        <div class="muted">
                                            <% for (int i = 1; i <= 5; i++) out.print(i <= rating ? "★" : "☆"); %>
                                            • <%= rDate %>
                                        </div>
                                    </div>
                                    <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                                        <% if (!loggedIn) { %>
                                            <a class="likeBtn" href="login.jsp">
                                                <i class="fas fa-thumbs-up"></i> <%= likeCount %>
                                            </a>
                                        <% } else { %>
                                            <form method="post" action="<%= request.getContextPath() %>/ReviewActionServlet" style="display:inline;">
                                                <input type="hidden" name="action" value="toggleLike">
                                                <input type="hidden" name="locationId" value="<%= locId %>">
                                                <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                                <input type="hidden" name="customRedirect" value="location_details.jsp?id=<%= locId %>#review-<%= reviewId %>">
                                                <button type="submit" class="likeBtn <%= userLiked ? "liked" : "" %>">
                                                    <i class="fas fa-thumbs-up"></i> <%= likeCount %>
                                                </button>
                                            </form>
                                        <% } %>
                                        
                                        <% if (loggedIn && userId.intValue() == reviewOwnerId) { %>
                                            <form method="post" action="<%= request.getContextPath() %>/ReviewActionServlet" style="display:inline;">
                                                <input type="hidden" name="action" value="deleteReview">
                                                <input type="hidden" name="locationId" value="<%= locId %>">
                                                <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                                <input type="hidden" name="customRedirect" value="location_details.jsp?id=<%= locId %>">
                                                <button type="submit" class="likeBtn danger" onclick="return confirm('Delete this review?');">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                                
                                <p style="margin:12px 0; color:#374151; line-height:1.6;">
                                    <%= rText == null ? "" : rText %>
                                </p>
                                
                                <% if(mainReviewImage != null && !mainReviewImage.trim().isEmpty()) { %>
                                    <div style="margin-top:10px; margin-bottom: 10px;">
                                        <img src="<%= request.getContextPath() %>/ReviewImageServlet?file=<%= URLEncoder.encode(mainReviewImage, "UTF-8") %>" style="max-width: 100%; max-height: 250px; border-radius: 8px; border: 1px solid #eee; object-fit: cover;" alt="Review Image">
                                    </div>
                                <% } %>
                                
                                <div class="gallery">
                                <%
                                    String imgQuery = "SELECT file_name FROM review_images WHERE review_id=? ORDER BY image_id ASC";
                                    try (PreparedStatement ips = conn.prepareStatement(imgQuery)) {
                                        ips.setInt(1, reviewId);
                                        try (ResultSet irs = ips.executeQuery()) {
                                            while (irs.next()) {
                                                String fn = irs.getString("file_name");
                                %>
                                                <img src="<%= request.getContextPath() %>/ReviewImageServlet?file=<%= URLEncoder.encode(fn, "UTF-8") %>" alt="Gallery Image">
                                <%
                                            }
                                        }
                                    }
                                %>
                                </div>
                                
                                <div class="commentBox">
                                    <div class="muted" style="font-weight:900;">Comments</div>
                                    <%
                                        String commentSql =
                                            "SELECT c.comment_text, c.comment_date, " +
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
                                            <input type="hidden" name="locationId" value="<%= locId %>">
                                            <input type="hidden" name="reviewId" value="<%= reviewId %>">
                                            <input type="hidden" name="customRedirect" value="location_details.jsp?id=<%= locId %>#review-<%= reviewId %>">
                                            <input type="text" name="commentText" placeholder="Write a comment..." required>
                                            <button class="btnLight" type="submit">Post</button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
        <%
                        }
                        if (!hasReviews) {
                            out.println("<div class='muted'>No reviews yet. Be the first to review this!</div>");
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>DB Error loading reviews: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

</body>
</html>