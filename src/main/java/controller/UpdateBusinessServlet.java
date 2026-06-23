package controller;

import dao.BusinessDAO;
import util.DBConnection;
import model.Business;

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
        int businessId = Integer.parseInt(request.getParameter("businessId"));
        String name = request.getParameter("name").trim();
        String description = request.getParameter("description").trim();
        String address = request.getParameter("address").trim();
        String phone = request.getParameter("phone").trim();
        String hours = request.getParameter("hours").trim();

        Business business = new Business();
        business.setBusinessId(businessId);
        business.setUserId(userId);
        business.setBusinessName(name);
        business.setDescription(description);
        business.setAddress(address);
        business.setContactPhone(phone);
        business.setOperatingHours(hours);

        BusinessDAO dao = new BusinessDAO();
        boolean success = dao.updateBusiness(business);

        // Sync linked locations name & description
        if (success) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "UPDATE locations SET name=?, description=? WHERE business_id=?")) {
                ps.setString(1, name);
                ps.setString(2, description);
                ps.setInt(3, businessId);
                ps.executeUpdate();
            } catch (Exception e) { e.printStackTrace(); }
        }

        if (success)
            response.sendRedirect("business_dashboard.jsp?msg=Business updated successfully");
        else
            response.sendRedirect("business_dashboard.jsp?err=Failed to update business");
    }
}