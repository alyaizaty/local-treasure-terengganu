package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/ContentDashboardServlet")
public class ContentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = session == null ? null : String.valueOf(session.getAttribute("role"));

        if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) tab = "pending";
        tab = tab.toLowerCase();

        switch (tab) {
            case "pending":
            case "locations":
            case "business":
            case "reviews":
            case "featured":
            case "analytics":
                break;
            default:
                tab = "pending";
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");

        StringBuilder pendingRows = new StringBuilder();
        StringBuilder locationRows = new StringBuilder();
        StringBuilder featuredRows = new StringBuilder();
        StringBuilder businessRows = new StringBuilder();
        StringBuilder reviewRows = new StringBuilder();
        StringBuilder commentRows = new StringBuilder();

        int pendingCount = 0;
        int totalLocations = 0;
        int featuredCount = 0;
        int totalReviews = 0;
        int totalBusinesses = 0;
        int totalComments = 0;

        List<String> chartLabels = new ArrayList<>();
        List<Integer> loginData = new ArrayList<>();
        List<Integer> signupData = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            pendingCount = count(conn, "SELECT COUNT(*) FROM location_submission WHERE status='PENDING'");
            totalLocations = count(conn, "SELECT COUNT(*) FROM location");
            featuredCount = count(conn, "SELECT COUNT(*) FROM location WHERE is_featured = 1");
            totalReviews = count(conn, "SELECT COUNT(*) FROM reviews");
            totalBusinesses = count(conn, "SELECT COUNT(*) FROM businesses");
            totalComments = count(conn, "SELECT COUNT(*) FROM comments");

            String sqlPending =
                "SELECT s.submission_id, s.user_id, s.name, s.category, s.city, s.state, s.gmaps_link, " +
                "(SELECT i.file_name FROM location_submission_images i " +
                " WHERE i.submission_id = s.submission_id " +
                " ORDER BY i.created_at ASC, i.image_id ASC LIMIT 1) AS first_image " +
                "FROM location_submission s " +
                "WHERE s.status='PENDING' " +
                "ORDER BY s.submission_id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlPending);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    int id = rs.getInt("submission_id");
                    String firstImg = rs.getString("first_image");

                    String imgUrl = request.getContextPath() + "/image/no-image.png";
                    if (firstImg != null && !firstImg.trim().isEmpty()) {
                        imgUrl = request.getContextPath() + "/LocationImageServlet?file=" +
                                URLEncoder.encode(firstImg.trim(), "UTF-8");
                    }

                    pendingRows.append("<tr>");
                    pendingRows.append("<td>#").append(id).append("</td>");
                    pendingRows.append("<td><img class='thumb' src='").append(imgUrl).append("'></td>");
                    pendingRows.append("<td>").append(rs.getInt("user_id")).append("</td>");
                    pendingRows.append("<td><b>").append(h(rs.getString("name"))).append("</b></td>");
                    pendingRows.append("<td>").append(h(rs.getString("category"))).append("</td>");
                    pendingRows.append("<td>").append(h(rs.getString("city"))).append(", ").append(h(rs.getString("state"))).append("</td>");
                    pendingRows.append("<td>");

                    String gmaps = rs.getString("gmaps_link");
                    if (gmaps != null && !gmaps.trim().isEmpty()) {
                        pendingRows.append("<a href='").append(h(gmaps)).append("' target='_blank'>Open Map</a>");
                    } else {
                        pendingRows.append("-");
                    }

                    pendingRows.append("</td>");
                    pendingRows.append("<td class='action-cell'>");

                    pendingRows.append("<form method='post' action='").append(request.getContextPath()).append("/SubmissionDecisionServlet'>");
                    pendingRows.append("<input type='hidden' name='submissionId' value='").append(id).append("'>");
                    pendingRows.append("<input type='hidden' name='action' value='APPROVE'>");
                    pendingRows.append("<button class='btn btn-approve' type='submit' onclick=\"return confirm('Approve this submission?')\">Approve</button>");
                    pendingRows.append("</form>");

                    pendingRows.append("<form method='post' action='").append(request.getContextPath()).append("/SubmissionDecisionServlet'>");
                    pendingRows.append("<input type='hidden' name='submissionId' value='").append(id).append("'>");
                    pendingRows.append("<input type='hidden' name='action' value='REJECT'>");
                    pendingRows.append("<button class='btn btn-reject' type='submit' onclick=\"return confirm('Reject this submission?')\">Reject</button>");
                    pendingRows.append("</form>");

                    pendingRows.append("</td>");
                    pendingRows.append("</tr>");
                }
            }

            String sqlLoc =
                "SELECT location_id, category_id, name, description, image, is_featured " +
                "FROM location ORDER BY location_id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlLoc);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    int lid = rs.getInt("location_id");
                    int isFeatured = rs.getInt("is_featured");
                    String img = rs.getString("image");

                    String imgUrl = request.getContextPath() + "/image/no-image.png";
                    if (img != null && !img.trim().isEmpty()) {
                        String clean = img.trim();
                        String encoded = URLEncoder.encode(clean, "UTF-8");

                        if (clean.toLowerCase().startsWith("sub_")) {
                            imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + encoded;
                        } else if (clean.toLowerCase().startsWith("business_") || clean.equalsIgnoreCase("default_business.jpg")) {
                            imgUrl = request.getContextPath() + "/uploads/" + encoded;
                        } else {
                            imgUrl = request.getContextPath() + "/image/" + encoded;
                        }
                    }

                    String desc = rs.getString("description");
                    String preview = desc == null ? "" : desc.trim();
                    if (preview.length() > 90) preview = preview.substring(0, 90) + "...";

                    StringBuilder row = new StringBuilder();
                    row.append("<tr>");
                    row.append("<td>#").append(lid).append("</td>");
                    row.append("<td><img class='thumb' src='").append(imgUrl).append("'></td>");
                    row.append("<td>").append(rs.getInt("category_id")).append("</td>");
                    row.append("<td><b>").append(h(rs.getString("name"))).append("</b></td>");
                    row.append("<td>").append(h(preview)).append("</td>");
                    row.append("<td>").append(isFeatured == 1 ? "<span class='badge-featured'>Featured</span>" : "<span class='badge-normal'>Normal</span>").append("</td>");

                    row.append("<td class='action-cell'>");
                    row.append("<a class='btn btn-view' href='").append(request.getContextPath()).append("/locationDetails?id=").append(lid).append("'>View</a>");

                    row.append("<form method='post' action='").append(request.getContextPath()).append("/FeatureLocationServlet'>");
                    row.append("<input type='hidden' name='locationId' value='").append(lid).append("'>");
                    row.append("<input type='hidden' name='currentStatus' value='").append(isFeatured).append("'>");

                    if (isFeatured == 1) {
                        row.append("<button class='btn btn-unfeature' type='submit'>Unfeature</button>");
                    } else {
                        row.append("<button class='btn btn-feature' type='submit'>Feature</button>");
                    }

                    row.append("</form>");

                    row.append("<form method='post' action='").append(request.getContextPath()).append("/DeleteLocationServlet'>");
                    row.append("<input type='hidden' name='locationId' value='").append(lid).append("'>");
                    row.append("<button class='btn btn-delete' type='submit' onclick=\"return confirm('Delete this location?')\">Delete</button>");
                    row.append("</form>");

                    row.append("</td>");
                    row.append("</tr>");

                    locationRows.append(row);

                    if (isFeatured == 1) {
                        featuredRows.append(row);
                    }
                }
            }

            String sqlBusiness =
                "SELECT b.business_id, b.business_name, b.description, b.address, b.contact_phone, " +
                "b.operating_hours, b.image, c.name AS category_name, u.username AS owner_username, " +
                "IFNULL(rev.avg_rating, 0) AS avg_rating, IFNULL(rev.total_reviews, 0) AS total_reviews " +
                "FROM businesses b " +
                "LEFT JOIN users u ON b.user_id = u.id " +
                "LEFT JOIN categories c ON b.category_id = c.category_id " +
                "LEFT JOIN ( " +
                "   SELECT l.business_id, AVG(r.rating) AS avg_rating, COUNT(r.review_id) AS total_reviews " +
                "   FROM location l LEFT JOIN reviews r ON l.location_id = r.location_id " +
                "   GROUP BY l.business_id " +
                ") rev ON b.business_id = rev.business_id " +
                "ORDER BY b.business_id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlBusiness);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    int bid = rs.getInt("business_id");
                    String img = rs.getString("image");

                    String imgUrl = request.getContextPath() + "/uploads/default_business.jpg";
                    if (img != null && !img.trim().isEmpty()) {
                        imgUrl = request.getContextPath() + "/uploads/" + URLEncoder.encode(img.trim(), "UTF-8");
                    }

                    String desc = rs.getString("description");
                    String preview = desc == null ? "" : desc.trim();
                    if (preview.length() > 90) preview = preview.substring(0, 90) + "...";

                    businessRows.append("<tr>");
                    businessRows.append("<td>#").append(bid).append("</td>");
                    businessRows.append("<td><img class='thumb' src='").append(imgUrl).append("'></td>");
                    businessRows.append("<td><b>").append(h(rs.getString("business_name"))).append("</b><br><small>").append(h(rs.getString("category_name"))).append("</small></td>");
                    businessRows.append("<td>").append(h(preview)).append("</td>");
                    businessRows.append("<td>").append(h(rs.getString("address"))).append("</td>");
                    businessRows.append("<td>").append(h(rs.getString("contact_phone"))).append("</td>");
                    businessRows.append("<td>@").append(h(rs.getString("owner_username"))).append("</td>");
                    businessRows.append("<td>").append(String.format(Locale.US, "%.1f", rs.getDouble("avg_rating"))).append(" / ").append(rs.getInt("total_reviews")).append(" reviews</td>");
                    businessRows.append("<td class='action-cell'>");
                    businessRows.append("<a class='btn btn-view' href='").append(request.getContextPath()).append("/businessDetails?id=").append(bid).append("'>Details</a>");
                    businessRows.append("<a class='btn btn-feature' href='").append(request.getContextPath()).append("/businessReviews?id=").append(bid).append("'>Reviews</a>");
                    businessRows.append("</td>");
                    businessRows.append("</tr>");
                }
            }

            String sqlReviews =
                "SELECT r.review_id, r.rating, r.review_text, r.review_date, " +
                "COALESCE(u.username, CONCAT('User #', r.user_id)) AS username, " +
                "l.name AS location_name, b.business_name, " +
                "(SELECT COUNT(*) FROM comments c WHERE c.review_id = r.review_id) AS total_comments " +
                "FROM reviews r " +
                "LEFT JOIN users u ON r.user_id = u.id " +
                "LEFT JOIN location l ON r.location_id = l.location_id " +
                "LEFT JOIN businesses b ON l.business_id = b.business_id " +
                "ORDER BY r.review_id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlReviews);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String target = rs.getString("business_name");
                    if (target == null || target.trim().isEmpty()) target = rs.getString("location_name");

                    reviewRows.append("<tr>");
                    reviewRows.append("<td>#").append(rs.getInt("review_id")).append("</td>");
                    reviewRows.append("<td>@").append(h(rs.getString("username"))).append("</td>");
                    reviewRows.append("<td>").append(h(target)).append("</td>");
                    reviewRows.append("<td>").append(rs.getInt("rating")).append(" ★</td>");
                    reviewRows.append("<td>").append(h(shorten(rs.getString("review_text"), 120))).append("</td>");
                    reviewRows.append("<td>").append(rs.getString("review_date")).append("</td>");
                    reviewRows.append("<td>").append(rs.getInt("total_comments")).append("</td>");
                    reviewRows.append("</tr>");
                }
            }

            String sqlComments =
                "SELECT c.comment_id, c.comment_text, c.comment_date, " +
                "COALESCE(u.username, CONCAT('User #', c.user_id)) AS username, " +
                "r.review_id, l.name AS location_name, b.business_name " +
                "FROM comments c " +
                "LEFT JOIN users u ON c.user_id = u.id " +
                "LEFT JOIN reviews r ON c.review_id = r.review_id " +
                "LEFT JOIN location l ON r.location_id = l.location_id " +
                "LEFT JOIN businesses b ON l.business_id = b.business_id " +
                "ORDER BY c.comment_id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlComments);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String target = rs.getString("business_name");
                    if (target == null || target.trim().isEmpty()) target = rs.getString("location_name");

                    commentRows.append("<tr>");
                    commentRows.append("<td>#").append(rs.getInt("comment_id")).append("</td>");
                    commentRows.append("<td>@").append(h(rs.getString("username"))).append("</td>");
                    commentRows.append("<td>").append(h(target)).append("</td>");
                    commentRows.append("<td>#").append(rs.getInt("review_id")).append("</td>");
                    commentRows.append("<td>").append(h(shorten(rs.getString("comment_text"), 120))).append("</td>");
                    commentRows.append("<td>").append(rs.getString("comment_date")).append("</td>");
                    commentRows.append("</tr>");
                }
            }

            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_MONTH, -6);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            Map<String, Integer> loginMap = new LinkedHashMap<>();
            Map<String, Integer> signupMap = new LinkedHashMap<>();

            for (int i = 0; i < 7; i++) {
                String d = sdf.format(cal.getTime());
                loginMap.put(d, 0);
                signupMap.put(d, 0);
                cal.add(Calendar.DAY_OF_MONTH, 1);
            }

            String sqlActivity =
                "SELECT DATE(activity_date) AS d, activity_type, COUNT(*) AS total " +
                "FROM user_activity " +
                "WHERE activity_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                "GROUP BY DATE(activity_date), activity_type " +
                "ORDER BY d ASC";

            try (PreparedStatement ps = conn.prepareStatement(sqlActivity);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String d = rs.getString("d");
                    String type = rs.getString("activity_type");
                    int total = rs.getInt("total");

                    if ("LOGIN".equalsIgnoreCase(type) && loginMap.containsKey(d)) {
                        loginMap.put(d, total);
                    } else if ("SIGNUP".equalsIgnoreCase(type) && signupMap.containsKey(d)) {
                        signupMap.put(d, total);
                    }
                }
            } catch (Exception ignore) {
            }

            for (String d : loginMap.keySet()) {
                chartLabels.add(d);
                loginData.add(loginMap.get(d));
                signupData.add(signupMap.get(d));
            }

        } catch (Exception e) {
            err = "DB Error: " + e.getMessage();
            e.printStackTrace();
        }

        request.setAttribute("tab", tab);
        request.setAttribute("msg", msg);
        request.setAttribute("err", err);

        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("totalLocations", totalLocations);
        request.setAttribute("featuredCount", featuredCount);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("totalBusinesses", totalBusinesses);
        request.setAttribute("totalComments", totalComments);

        request.setAttribute("pendingRows", pendingRows.toString());
        request.setAttribute("locationRows", locationRows.toString());
        request.setAttribute("featuredRows", featuredRows.toString());
        request.setAttribute("businessRows", businessRows.toString());
        request.setAttribute("reviewRows", reviewRows.toString());
        request.setAttribute("commentRows", commentRows.toString());

        request.setAttribute("chartLabels", toJsonStringArray(chartLabels));
        request.setAttribute("loginData", loginData.toString());
        request.setAttribute("signupData", signupData.toString());

        request.getRequestDispatcher("/content_dashboard.jsp").forward(request, response);
    }

    private int count(Connection conn, String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception ignored) {
        }
        return 0;
    }

    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private static String shorten(String s, int max) {
        if (s == null) return "";
        s = s.trim();
        if (s.length() <= max) return s;
        return s.substring(0, max - 3) + "...";
    }

    private static String toJsonStringArray(List<String> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(list.get(i).replace("\"", "\\\"")).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }
}