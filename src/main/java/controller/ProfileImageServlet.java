package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProfileImageServlet")
public class ProfileImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fileParam = request.getParameter("file");
        if (fileParam == null || fileParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing file parameter");
            return;
        }

        // Kalau URL Cloudinary, redirect terus
        if (fileParam.startsWith("http://") || fileParam.startsWith("https://")) {
            response.sendRedirect(fileParam);
            return;
        }

        // Kalau file lama, guna ProfileImageUtil
        java.io.File imageFile = util.ProfileImageUtil.getImageFile(fileParam);
        if (imageFile == null) {
            response.sendRedirect(request.getContextPath() + "/image/profile.jpeg");
            return;
        }

        response.setContentType(util.ProfileImageUtil.getContentType(imageFile.getName()));
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setContentLengthLong(imageFile.length());

        try (java.io.FileInputStream fis = new java.io.FileInputStream(imageFile);
             java.io.OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}