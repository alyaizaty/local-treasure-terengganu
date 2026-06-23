package controller;

import dao.BusinessDAO;
import dao.UserDAO;
import model.Business;
import model.User;
import util.DBConnection;
import util.PasswordUtil;
import util.BusinessImageUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;

@WebServlet("/businessSignup")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 25 * 1024 * 1024
)
public class BusinessSignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        String bName = trim(request.getParameter("businessName"));
        String desc = trim(request.getParameter("description"));
        String addr = trim(request.getParameter("address"));
        String phone = trim(request.getParameter("contactPhone"));
        String hours = trim(request.getParameter("operatingHours"));
        String catIdStr = trim(request.getParameter("categoryId"));

        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)
                || isBlank(bName) || isBlank(desc) || isBlank(addr)
                || isBlank(phone) || isBlank(hours) || isBlank(catIdStr)) {

            redirectError(response, "Please fill all required fields.");
            return;
        }

        if (!password.equals(confirmPassword)) {
            redirectError(response, "Passwords do not match.");
            return;
        }

        int categoryId;

        try {
            categoryId = Integer.parseInt(catIdStr);
        } catch (NumberFormatException e) {
            redirectError(response, "Invalid category selected.");
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            User user = new User();
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(PasswordUtil.hashPassword(password));
            user.setRole("Local Business");

            int userId = new UserDAO().insertUserAndGetId(conn, user);

            String fileName = "default_business.jpg";
            Part filePart = request.getPart("businessImage");

            if (filePart != null && filePart.getSize() > 0) {
                String contentType = filePart.getContentType();

                if (contentType != null && contentType.toLowerCase().startsWith("image/")) {
                    String realPath = getServletContext().getRealPath("");

                    BusinessImageUploadUtil.ensureUploadDirectoryExists(realPath);

                    String savedFile = BusinessImageUploadUtil.saveImage(filePart, realPath);

                    if (savedFile != null && !savedFile.trim().isEmpty()) {
                        fileName = savedFile;
                    }

                } else {
                    redirectError(response, "Only image files are allowed.");
                    return;
                }
            }

            Business b = new Business();
            b.setUserId(userId);
            b.setBusinessName(bName);
            b.setDescription(desc);
            b.setAddress(addr);
            b.setContactPhone(phone);
            b.setOperatingHours(hours);
            b.setCategoryId(categoryId);
            b.setImage(fileName);

            new BusinessDAO().insertBusinessAndGetId(conn, b);

            conn.commit();

            response.sendRedirect("business_signup.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            redirectError(response, "System error: " + e.getMessage());

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    private static void redirectError(HttpServletResponse response, String message) throws IOException {
        response.sendRedirect("business_signup.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}