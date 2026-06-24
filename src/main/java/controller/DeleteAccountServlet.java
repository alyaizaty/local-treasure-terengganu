package controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ltwbs", "root", "")) {

            conn.setAutoCommit(false);

            // 1️⃣ Delete user comments
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM comments WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            // 2️⃣ Delete user reviews
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM reviews WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            // 3️⃣ Delete user bookmarks
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM bookmarks WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            // 4️⃣ Delete user locations submissions
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM location_submission WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            // 5️⃣ Delete user account
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM users WHERE id=?")) {
                ps.setInt(1, userId);
                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    response.sendRedirect("user_profile.jsp?err=Failed to delete account");
                    return;
                }
            }

            conn.commit();

            // 6️⃣ Invalidate session
            session.invalidate();

            // Redirect to homepage after deletion
            response.sendRedirect("index.jsp?msg=Account+deleted+successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("user_profile.jsp?err=Server+error+while+deleting");
        }
    }
}