package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/LocationImageServlet")
public class LocationImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fileParam = request.getParameter("file");
        if (fileParam == null || fileParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing file parameter");
            return;
        }

        // Kalau Cloudinary URL, redirect terus
        if (fileParam.startsWith("http://") || fileParam.startsWith("https://")) {
            response.sendRedirect(fileParam);
            return;
        }

        // Kalau file lama
        java.io.File imageFile = util.LocationImageUtil.getImageFile(fileParam);
        if (imageFile == null) {
            response.sendRedirect(request.getContextPath() + "/image/background.jpg");
            return;
        }

        response.setContentType(util.LocationImageUtil.getContentType(imageFile.getName()));
        response.setContentLengthLong(imageFile.length());

        try (java.io.FileInputStream fis = new java.io.FileInputStream(imageFile);
             java.io.OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}