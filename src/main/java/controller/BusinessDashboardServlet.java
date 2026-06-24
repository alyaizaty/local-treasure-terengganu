package controller;

import dao.BusinessDAO;
import model.Business;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.Map;
import util.DBConnection;

@WebServlet("/businessDashboard")
public class BusinessDashboardServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
	        throws ServletException, IOException {
	    
	    HttpSession session = request.getSession(false);
	    if (session == null || session.getAttribute("userId") == null) {
	        response.sendRedirect("login.jsp");
	        return;
	    }
	    
	    int userId = (Integer) session.getAttribute("userId");
	    
	    try (Connection conn = DBConnection.getConnection()) {
	        // 1. Get the Business ID and its associated Location ID
	        String bizSql = "SELECT b.business_id, l.location_id FROM businesses b " +
	                        "LEFT JOIN location l ON b.business_id = l.business_id " +
	                        "WHERE b.user_id = ?";
	        
	        int businessId = 0;
	        int locationId = 0;
	        
	        try (PreparedStatement ps = conn.prepareStatement(bizSql)) {
	            ps.setInt(1, userId);
	            try (ResultSet rs = ps.executeQuery()) {
	                if (rs.next()) {
	                    businessId = rs.getInt("business_id");
	                    locationId = rs.getInt("location_id");
	                }
	            }
	        }

	        // 2. Fetch Reviews for this location
	        List<Map<String, Object>> reviews = new ArrayList<>();
	        if (locationId > 0) {
	            String revSql = "SELECT r.*, u.username FROM reviews r " +
	                            "JOIN users u ON r.user_id = u.id " +
	                            "WHERE r.location_id = ? ORDER BY r.review_date DESC";
	            try (PreparedStatement ps = conn.prepareStatement(revSql)) {
	                ps.setInt(1, locationId);
	                try (ResultSet rs = ps.executeQuery()) {
	                    while (rs.next()) {
	                        Map<String, Object> review = new HashMap<>();
	                        review.put("username", rs.getString("username"));
	                        review.put("rating", rs.getInt("rating"));
	                        review.put("text", rs.getString("review_text"));
	                        review.put("date", rs.getDate("review_date"));
	                        reviews.add(review);
	                    }
	                }
	            }
	        }
	        
	        request.setAttribute("reviews", reviews);
	        request.getRequestDispatcher("business_dashboard.jsp").forward(request, response);
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	        response.sendRedirect("error.jsp");
	    }
	}
}