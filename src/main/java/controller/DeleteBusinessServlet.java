package controller;

import util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteBusinessServlet")
public class DeleteBusinessServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = session == null ? null : String.valueOf(session.getAttribute("role"));

        if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int businessId;
        try {
            businessId = Integer.parseInt(request.getParameter("businessId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/ContentDashboardServlet?tab=business&err=Invalid+business+ID");
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Delete location linked to this business first
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM location WHERE business_id=?")) {
                ps.setInt(1, businessId);
                ps.executeUpdate();
            }

            // Delete the business itself
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM businesses WHERE business_id=?")) {
                ps.setInt(1, businessId);
                ps.executeUpdate();
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/ContentDashboardServlet?tab=business&msg=Business+deleted+successfully");

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            response.sendRedirect(request.getContextPath() + "/ContentDashboardServlet?tab=business&err=" + e.getMessage());
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ignore) {}
        }
    }
}