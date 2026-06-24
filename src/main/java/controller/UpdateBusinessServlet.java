package controller;

import util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/UpdateBusinessServlet")
public class UpdateBusinessServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        
        try {
            int businessId = Integer.parseInt(request.getParameter("businessId"));
            String name = request.getParameter("name").trim();
            String description = request.getParameter("description").trim();
            String address = request.getParameter("address").trim();
            String phone = request.getParameter("phone").trim();
            String hours = request.getParameter("hours").trim();

            try (Connection conn = DBConnection.getConnection()) {
                // 1. Update the 'businesses' table
                String bizSql = "UPDATE businesses SET business_name=?, description=?, address=?, contact_phone=?, operating_hours=? WHERE business_id=? AND user_id=?";
                try (PreparedStatement ps = conn.prepareStatement(bizSql)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setString(3, address);
                    ps.setString(4, phone);
                    ps.setString(5, hours);
                    ps.setInt(6, businessId);
                    ps.setInt(7, userId);
                    ps.executeUpdate();
                }

                // 2. Sync linked 'location' table (FIXED: changed 'locations' to 'location')
                String locSql = "UPDATE location SET name=?, description=? WHERE business_id=?";
                try (PreparedStatement ps = conn.prepareStatement(locSql)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setInt(3, businessId);
                    ps.executeUpdate();
                }
            }
            
            // Redirect with success message
            response.sendRedirect("business_dashboard.jsp?msg=Business updated successfully");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit_business.jsp?err=Failed to update: " + e.getMessage());
        }
    }
}