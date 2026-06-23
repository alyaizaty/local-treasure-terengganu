package controller;

import dao.PromotionDAO;
import model.Promotion;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/addPromotion")
public class AddPromotionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // Validasi Sesi
        if (userId == null || !"Local Business".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        PromotionDAO promotionDAO = new PromotionDAO();
        int businessId = promotionDAO.getBusinessIdByUserId(userId);

        if (businessId == -1) {
            request.setAttribute("error", "Profil perniagaan tidak dijumpai.");
            request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
            return;
        }

        // Ambil data dari form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        // Simpan ke Model
        Promotion promotion = new Promotion();
        promotion.setBusinessId(businessId);
        promotion.setTitle(title);
        promotion.setDescription(description);
        promotion.setStartDate(startDate);
        promotion.setEndDate(endDate);
        promotion.setIsActive(true);
        promotion.setApprovalStatus("Approved");

        // Proses Simpan
        boolean inserted = promotionDAO.insertPromotion(promotion);

        if (inserted) {
            response.sendRedirect("add_promotion.jsp?success=1");
        } else {
            request.setAttribute("error", "Gagal menyimpan promosi ke sistem.");
            request.getRequestDispatcher("/add_promotion.jsp").forward(request, response);
        }
    }
}