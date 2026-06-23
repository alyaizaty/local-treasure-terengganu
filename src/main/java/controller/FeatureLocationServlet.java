package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet(name = "FeatureLocationServlet", urlPatterns = {"/FeatureLocationServlet"})
public class FeatureLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = session == null ? null : String.valueOf(session.getAttribute("role"));

        if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int locationId = Integer.parseInt(request.getParameter("locationId"));
            int currentStatus = Integer.parseInt(request.getParameter("currentStatus"));
            int newStatus = currentStatus == 1 ? 0 : 1;

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "UPDATE location SET is_featured = ? WHERE location_id = ?")) {

                ps.setInt(1, newStatus);
                ps.setInt(2, locationId);
                ps.executeUpdate();
            }

            response.sendRedirect(request.getContextPath()
                    + "/ContentDashboardServlet?tab=locations&msg=Featured status updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/ContentDashboardServlet?tab=locations&err=Failed to update featured status");
        }
    }
}