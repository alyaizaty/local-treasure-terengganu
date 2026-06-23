package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import util.ActivityLogger;
import util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMessage", "Please enter email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        email = email.trim();

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByEmail(email);

        if (user == null) {
            request.setAttribute("errorMessage", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        boolean passwordMatched = false;
        String storedPassword = user.getPassword();

        if (storedPassword != null) {
            if (storedPassword.equals(password)) {
                passwordMatched = true;
            } else {
                try {
                    String hashedInput = PasswordUtil.hashPassword(password);
                    if (storedPassword.equals(hashedInput)) {
                        passwordMatched = true;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        if (!passwordMatched) {
            request.setAttribute("errorMessage", "Invalid email or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            ActivityLogger.log(conn, user.getId(), "LOGIN");
        } catch (Exception e) {
            e.printStackTrace();
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("profilePicture", user.getProfilePicture());
        session.setAttribute("role", user.getRole());

        String role = user.getRole();

        if ("Tourist".equalsIgnoreCase(role)) {
            response.sendRedirect("home.jsp");
        } else if ("Local Business".equalsIgnoreCase(role)) {
            response.sendRedirect("home.jsp");
        } else if ("Content Manager".equalsIgnoreCase(role)) {
           response.sendRedirect("ContentDashboardServlet");
        } else {
            response.sendRedirect("user_profile.jsp");
        }
    }
}