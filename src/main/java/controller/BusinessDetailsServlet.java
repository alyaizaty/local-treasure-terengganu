package controller;

import util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/businessDetails")
public class BusinessDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("home.jsp");
            return;
        }

        int businessId;
        try {
            businessId = Integer.parseInt(idStr);
        } catch (Exception e) {
            response.sendRedirect("home.jsp");
            return;
        }

        Map<String, Object> business = new HashMap<>();
        List<Map<String, Object>> promotions = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. Fetch the exact Business details
            String sqlBiz = "SELECT b.*, c.name AS category_name FROM businesses b LEFT JOIN categories c ON b.category_id = c.category_id WHERE b.business_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlBiz)) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        business.put("id", rs.getInt("business_id"));
                        business.put("name", rs.getString("business_name"));
                        business.put("desc", rs.getString("description"));
                        business.put("address", rs.getString("address"));
                        business.put("phone", rs.getString("contact_phone"));
                        business.put("hours", rs.getString("operating_hours"));
                        business.put("image", rs.getString("image"));
                        business.put("category", rs.getString("category_name") != null ? rs.getString("category_name") : "General");
                    } else {
                        response.sendRedirect("home.jsp");
                        return;
                    }
                }
            }

            // 2. Fetch Active Promotions
            String sqlPromo = "SELECT * FROM promotions WHERE business_id = ? AND (is_active = 1 OR is_active = '1' OR is_active = 'Yes')";
            try (PreparedStatement ps = conn.prepareStatement(sqlPromo)) {
                ps.setInt(1, businessId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("title", rs.getString("title"));
                        p.put("desc", rs.getString("description"));
                        p.put("start", rs.getString("start_date"));
                        p.put("end", rs.getString("end_date"));
                        promotions.add(p);
                    }
                }
            }

            // Send to JSP
            request.setAttribute("business", business);
            request.setAttribute("promotionsList", promotions);
            request.getRequestDispatcher("business_details.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            response.getWriter().println("<h3>Database Error: " + e.getMessage() + "</h3>");
        }
    }
}