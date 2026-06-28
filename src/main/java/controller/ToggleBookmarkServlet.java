package controller;

import dao.BookmarkDAO;
import util.DBConnection;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ToggleBookmarkServlet")
public class ToggleBookmarkServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String locIdStr = request.getParameter("locationId");
        if (locIdStr == null || locIdStr.trim().isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        int locationId;
        try {
            locationId = Integer.parseInt(locIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            BookmarkDAO bookmarkDAO = new BookmarkDAO();
            bookmarkDAO.toggle(conn, userId, locationId);

            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()) {
                response.sendRedirect(redirect);
                return;
            }

            String back = request.getHeader("Referer");
            response.sendRedirect(back != null ? back : "index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}