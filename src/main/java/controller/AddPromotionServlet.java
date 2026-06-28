package controller;

import dao.PromotionDAO;
import model.Promotion;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate; // Import for date validation

@WebServlet("/addPromotion")
public class AddPromotionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // Session Validation
        if (userId == null || !"Local Business".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        PromotionDAO promotionDAO = new PromotionDAO();
        int businessId = promotionDAO.getBusinessIdByUserId(userId);

        if (businessId == -1) {
            request.setAttribute("error", "Business profile not found.");
            request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
            return;
        }

        // Fetch data from form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        // --- DATE LOGIC FIX ---
        try {
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);
            LocalDate today = LocalDate.now();

            // 1. Start date cannot be in the past
            if (startDate.isBefore(today)) {
                request.setAttribute("error", "Start date cannot be in the past.");
                request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
                return;
            }

            // 2. End date cannot be before the start date
            if (endDate.isBefore(startDate)) {
                request.setAttribute("error", "End date cannot be before the start date.");
                request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
                return;
            }
        } catch (Exception e) {
            request.setAttribute("error", "Invalid date format.");
            request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
            return;
        }
        // ----------------------

        // Save to Model
        Promotion promotion = new Promotion();
        promotion.setBusinessId(businessId);
        promotion.setTitle(title);
        promotion.setDescription(description);
        promotion.setStartDate(startDateStr);
        promotion.setEndDate(endDateStr);
        promotion.setIsActive(true);
        promotion.setApprovalStatus("Approved");

        // Process Save
        boolean inserted = promotionDAO.insertPromotion(promotion);

        if (inserted) {
            response.sendRedirect("add_promotion.jsp?success=1");
        } else {
            request.setAttribute("error", "Failed to save promotion to the system.");
            request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
        }
    }
}