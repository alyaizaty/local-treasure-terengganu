package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/BusinessReviewImageServlet")
public class BusinessReviewImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fileParam = request.getParameter("file");
        if (fileParam == null || fileParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/image/background.jpg");
            return;
        }
        // Cloudinary URL — redirect terus
        if (fileParam.startsWith("http://") || fileParam.startsWith("https://")) {
            response.sendRedirect(fileParam);
            return;
        }
        // File lama — redirect ke default
        response.sendRedirect(request.getContextPath() + "/image/background.jpg");
    }
}