package controller;

import dao.LocationDAO;
import util.DBConnection;
import util.LocationImageUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteLocationServlet")
public class DeleteLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : String.valueOf(session.getAttribute("role"));

        if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int locationId = parseInt(request.getParameter("locationId"));
        if (locationId <= 0) {
            redirectDash(request, response, "locations", "err", "Invalid location id");
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            LocationDAO locationDAO = new LocationDAO();

            String imageName = locationDAO.getLocationImageById(conn, locationId);

            locationDAO.deleteBookmarksByLocationId(conn, locationId);

            boolean deleted = locationDAO.deleteLocationById(conn, locationId);
            if (!deleted) {
                conn.rollback();
                redirectDash(request, response, "locations", "err", "Delete failed");
                return;
            }

            conn.commit();

            if (imageName != null && !imageName.trim().isEmpty()) {
                LocationImageUploadUtil.deleteLocationImage(imageName);
            }

            redirectDash(request, response, "locations", "msg", "Deleted.");

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ignore) {
            }

            redirectDash(request, response, "locations", "err", "DB Error: " + e.getMessage());

        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }

    private static void redirectDash(HttpServletRequest request, HttpServletResponse response,
                                     String tab, String key, String value) throws IOException {

        String url = request.getContextPath() + "/ContentDashboardServlet?tab=" + tab
                + "&" + key + "=" + URLEncoder.encode(value, StandardCharsets.UTF_8);

        response.sendRedirect(url);
    }

    private static int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }
}