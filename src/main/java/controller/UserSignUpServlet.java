package controller;

import dao.UserDAO;
import model.User;
import util.FileUploadUtil;
import util.PasswordUtil;
import util.ActivityLogger;

import java.io.IOException;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import util.DBConnection;

@WebServlet("/UserSignUpServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class UserSignUpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = trim(request.getParameter("role"));

        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)) {
            request.setAttribute("errorMessage", "Please fill all required fields.");
            request.getRequestDispatcher("sign_up.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.getRequestDispatcher("sign_up.jsp").forward(request, response);
            return;
        }

        if (!role.equals("Tourist") && !role.equals("Local Business") && !role.equals("Content Manager")) {
            request.setAttribute("errorMessage", "Invalid role selected.");
            request.getRequestDispatcher("sign_up.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();

        if (userDAO.existsByUsernameOrEmail(username, email)) {
            request.setAttribute("errorMessage", "Username or Email already exists.");
            request.getRequestDispatcher("sign_up.jsp").forward(request, response);
            return;
        }

        Part filePart = null;
        try {
            filePart = request.getPart("profilePicture");
        } catch (Exception e) {
            // Ignored so that profile picture is optional
        }

        String savedFileName = null; // Defaults to null for the "kosong" picture

        try {
            // ONLY process the image if the user actually uploaded one
            if (filePart != null && filePart.getSize() > 0) {
                String submitted = FileUploadUtil.getSubmittedFileName(filePart);
                String ext = FileUploadUtil.getExtension(submitted).toLowerCase();

                if (!FileUploadUtil.isAllowedImageExtension(ext)) {
                    request.setAttribute("errorMessage", "Only JPG/PNG/WEBP/GIF allowed.");
                    request.getRequestDispatcher("sign_up.jsp").forward(request, response);
                    return;
                }

                if (!FileUploadUtil.isImageContentType(filePart.getContentType())) {
                    request.setAttribute("errorMessage", "Invalid image file.");
                    request.getRequestDispatcher("sign_up.jsp").forward(request, response);
                    return;
                }

                FileUploadUtil.createUploadDirectory();
                savedFileName = FileUploadUtil.saveProfileImage(filePart);
            }

            // Create the User object
            User user = new User();
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(PasswordUtil.hashPassword(password));
            user.setProfilePicture(savedFileName); // Will be null if no image was uploaded
            user.setRole(role);

            boolean success = userDAO.insertUser(user);

            if (success) {
                try (Connection conn = DBConnection.getConnection()) {
                    int newUserId = userDAO.getUserIdByUsernameOrEmail(username, email);
                    ActivityLogger.log(conn, newUserId, "SIGNUP");
                } catch (Exception logEx) {
                    logEx.printStackTrace();
                }

                response.sendRedirect("login.jsp?msg=Account created. Please login.");

            } else {
                // Cleanup file if DB insert fails
                if (savedFileName != null) {
                    FileUploadUtil.deleteProfileImage(savedFileName);
                }

                request.setAttribute("errorMessage", "Sign up failed. Please try again.");
                request.getRequestDispatcher("sign_up.jsp").forward(request, response);
            }

        } catch (Exception e) {
            // Cleanup file if error occurs
            if (savedFileName != null) {
                FileUploadUtil.deleteProfileImage(savedFileName);
            }

            e.printStackTrace();
            request.setAttribute("errorMessage", "System error: " + e.getMessage());
            request.getRequestDispatcher("sign_up.jsp").forward(request, response);
        }
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}