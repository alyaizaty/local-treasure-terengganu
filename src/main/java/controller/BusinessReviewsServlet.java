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

            String sqlBusiness =
                    "SELECT b.business_id, b.business_name, b.description, b.category_id, c.name AS category_name " +
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
                        business.put("category_name", rs.getString("category_name") != null ? rs.getString("category_name") : "Business");
                        business.put("image", "default_business.jpg");
                    } else {
                        response.sendRedirect("home.jsp");
                        return;
                    }
                }
            }

            String checkLocationSql = "SELECT location_id FROM location WHERE business_id = ? LIMIT 1";

            try (PreparedStatement ps = conn.prepareStatement(checkLocationSql)) {
                ps.setInt(1, businessId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        targetLocationId = rs.getInt("location_id");
                    }
                }
            }

            if (targetLocationId == 0) {
                String insertLocationSql =
                        "INSERT INTO location (category_id, name, description, image, business_id, views, is_featured) " +
                        "VALUES (?, ?, ?, ?, ?, 0, 0)";

                try (PreparedStatement ps = conn.prepareStatement(insertLocationSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, (Integer) business.get("category_id"));
                    ps.setString(2, String.valueOf(business.get("name")));
                    ps.setString(3, String.valueOf(business.get("desc")));
                    ps.setString(4, "default_business.jpg");
                    ps.setInt(5, businessId);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            targetLocationId = rs.getInt(1);
                        }
                    }
                }
            }

            double avgRating = 0.0;
            int totalReviews = 0;

            String aggSql =
                    "SELECT IFNULL(AVG(rating), 0) AS avg_rating, COUNT(review_id) AS total_reviews " +
                    "FROM reviews WHERE location_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(aggSql)) {
                ps.setInt(1, targetLocationId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        avgRating = rs.getDouble("avg_rating");
                        totalReviews = rs.getInt("total_reviews");
                    }
                }
            }

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

            business.put("avg_rating", avgRating);
            business.put("total_reviews", totalReviews);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3 style='color:red;'>Business Reviews Error</h3>");
            response.getWriter().println("<pre>" + e.getMessage() + "</pre>");
            return;
        }

        request.setAttribute("business", business);
        request.setAttribute("targetLocationId", targetLocationId);
        request.setAttribute("dist", dist);

        request.getRequestDispatcher("/business_reviews.jsp").forward(request, response);
    }
}