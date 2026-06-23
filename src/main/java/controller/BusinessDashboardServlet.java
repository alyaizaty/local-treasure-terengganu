package controller;

import dao.BusinessDAO;
import model.Business;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import java.util.Map;

import util.DBConnection;

@WebServlet("/businessDashboard")
public class BusinessDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try (Connection conn = DBConnection.getConnection()) {
            BusinessDAO dao = new BusinessDAO();

            // Get business info
            Business business = dao.getBusinessByUserId(conn, userId);
            if (business == null) {
                response.sendRedirect("home.jsp");
                return;
            }

            // Get lists
            List<Map<String,Object>> locationList = dao.getLocationsForBusiness(conn, business.getBusinessId(), userId);
            List<Map<String,Object>> promotionList = dao.getPromotionsForBusiness(conn, business.getBusinessId());
            List<Map<String,Object>> reviewList = dao.getAllReviewsForBusiness(conn, business.getBusinessId(), userId);

            // Stats
            int totalLocations = locationList.size();
            int totalReviews = reviewList.size();
            int activePromotions = promotionList.size();

            request.setAttribute("business", business);
            request.setAttribute("locationList", locationList);
            request.setAttribute("promotionList", promotionList);
            request.setAttribute("reviewList", reviewList);
            request.setAttribute("totalLocations", totalLocations);
            request.setAttribute("totalReviews", totalReviews);
            request.setAttribute("activePromotions", activePromotions);

            request.getRequestDispatcher("business_dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp");
        }
    }
}