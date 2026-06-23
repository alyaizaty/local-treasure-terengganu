package controller;

import dao.UserDAO;
import util.DBConnection;
import util.ProfileUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String newUsername = trim(request.getParameter("username"));
        String newEmail = trim(request.getParameter("email"));

        if (isBlank(newUsername) || isBlank(newEmail)) {
            response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("Please fill all fields"));
            return;
        }

        Part filePart = null;
        try {
            filePart = request.getPart("profilePicture");
        } catch (Exception ignore) {
        }

        String savedFileName = null;
        Connection conn = null;

        try {
            UserDAO userDAO = new UserDAO();
            conn = DBConnection.getConnection();

            String oldPic = userDAO.getProfilePictureById(conn, userId);

            if (filePart != null && filePart.getSize() > 0) {
                String ctype = filePart.getContentType();
                if (ctype == null || !ctype.toLowerCase().startsWith("image/")) {
                    response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("Invalid image file"));
                    return;
                }

                ProfileUploadUtil.ensureUploadDirectoryExists();
                savedFileName = ProfileUploadUtil.saveProfileImage(filePart, userId);

                if (savedFileName == null) {
                    response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("Only JPG/PNG/WEBP allowed"));
                    return;
                }

                boolean updated = userDAO.updateProfileWithImage(conn, userId, newUsername, newEmail, savedFileName);

                if (!updated) {
                    response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("Update failed"));
                    return;
                }

                if (oldPic != null && !oldPic.trim().isEmpty() && !oldPic.trim().equals(savedFileName)) {
                    ProfileUploadUtil.deleteProfileImage(oldPic);
                }

                session.setAttribute("profilePicture", savedFileName);

            } else {
                boolean updated = userDAO.updateProfileWithoutImage(conn, userId, newUsername, newEmail);

                if (!updated) {
                    response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("Update failed"));
                    return;
                }
            }

            session.setAttribute("username", newUsername);
            session.setAttribute("email", newEmail);

            response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?msg=" + enc("Updated ✅"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/edit_profile.jsp?err=" + enc("DB Error: " + e.getMessage()));
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ignore) {
            }
        }
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String enc(String s) {
        try {
            return URLEncoder.encode(s, "UTF-8");
        } catch (Exception e) {
            return s;
        }
    }
}