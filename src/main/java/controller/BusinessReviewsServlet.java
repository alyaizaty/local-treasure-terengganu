package controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/businessReviews")
public class BusinessReviewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("home.jsp");
            return;
        }

        int businessId;

        try {
            businessId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("home.jsp");
            return;
        }

        Map<String, Object> business = new HashMap<>();
        int targetLocationId = 0;
        int[] dist = new int[6];

        try (Connection conn = DBConnection.getConnection()) {

            // 1. Fetch Business Details
            String sqlBusiness =
                    "SELECT b.business_id, b.business_name, b.description, b.category_id, b.image, c.name AS category_name " +
                    "FROM businesses b " +
                    "LEFT JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.business_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlBusiness)) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        business.put("id", rs.getInt("business_id"));
                        business.put("name", rs.getString("business_name"));
                        business.put("desc", rs.getString("description"));
                        business.put("category_id", rs.getInt("category_id"));
                        business.put("category_name", rs.getString("category_name") != null ? rs.getString("category_name") : "General");
                        
                        String img = rs.getString("image");
                        business.put("image", (img != null && !img.trim().isEmpty()) ? img : "default_business.jpg");
                    } else {
                        response.sendRedirect("home.jsp");
                        return;
                    }
                }
            }

            // 2. Find the linked location_id for this business
            String checkLocationSql = "SELECT location_id FROM location WHERE business_id = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(checkLocationSql)) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        targetLocationId = rs.getInt("location_id");
                    }
                }
            }

            // If no location exists for this business yet, create a dummy one so reviews work
            if (targetLocationId == 0) {
                String insertLocationSql =
                        "INSERT INTO location (category_id, name, description, image, business_id, views, is_featured) " +
                        "VALUES (?, ?, ?, ?, ?, 0, 0)";

                try (PreparedStatement ps = conn.prepareStatement(insertLocationSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, (Integer) business.get("category_id"));
                    ps.setString(2, String.valueOf(business.get("name")));
                    ps.setString(3, String.valueOf(business.get("desc")));
                    ps.setString(4, String.valueOf(business.get("image"))); 
                    ps.setInt(5, businessId);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            targetLocationId = rs.getInt(1);
                        }
                    }
                }
            }

            // 3. Aggregate Rating Calculations
            double avgRating = 0.0;
            int totalReviews = 0;

            String aggSql = "SELECT IFNULL(AVG(rating), 0) AS avg_rating, COUNT(review_id) AS total_reviews FROM reviews WHERE location_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(aggSql)) {
                ps.setInt(1, targetLocationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        avgRating = rs.getDouble("avg_rating");
                        totalReviews = rs.getInt("total_reviews");
                    }
                }
            }

            // 4. Rating Distribution
            String distSql = "SELECT rating, COUNT(*) c FROM reviews WHERE location_id=? GROUP BY rating";
            try (PreparedStatement ps = conn.prepareStatement(distSql)) {
                ps.setInt(1, targetLocationId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int r = rs.getInt("rating");
                        int c = rs.getInt("c");
                        if (r >= 1 && r <= 5) {
                            dist[r] = c;
                        }
                    }
                }
            }

            // Safely put the primitive values into the map
            business.put("avg_rating", Double.valueOf(avgRating));
            business.put("total_reviews", Integer.valueOf(totalReviews));

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Business Reviews Error</h3><pre>" + e.getMessage() + "</pre>");
            return;
        }

        // 5. Send data to JSP
        request.setAttribute("business", business);
        request.setAttribute("targetLocationId", targetLocationId);
        request.setAttribute("dist", dist);
        request.getRequestDispatcher("/business_reviews.jsp").forward(request, response);
    }
}