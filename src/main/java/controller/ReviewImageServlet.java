package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ReviewImageServlet")
public class ReviewImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String file = request.getParameter("file");
        if (file == null || file.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/image/background.jpg");
            return;
        }
        if (file.startsWith("http://") || file.startsWith("https://")) {
            response.sendRedirect(file);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/image/background.jpg");
    }
}