package controller;

import dao.LocationDAO;
import dao.LocationSubmissionDAO;
import model.LocationSubmission;
import util.DBConnection;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubmissionDecisionServlet")
public class SubmissionDecisionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String role = (session == null) ? null : String.valueOf(session.getAttribute("role"));

        if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int submissionId = parseInt(request.getParameter("submissionId"));
        String action = request.getParameter("action");

        if (submissionId <= 0 || action == null) {
            redirectDash(request, response, "pending", "err", "Invalid request");
            return;
        }

        action = action.trim().toUpperCase();

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            LocationSubmissionDAO submissionDAO = new LocationSubmissionDAO();
            LocationDAO locationDAO = new LocationDAO();

            LocationSubmission submission = submissionDAO.getSubmissionForDecision(conn, submissionId);

            if (submission == null) {
                conn.rollback();
                redirectDash(request, response, "pending", "err", "Submission not found");
                return;
            }

            if (submission.getStatus() == null || !submission.getStatus().equalsIgnoreCase("PENDING")) {
                conn.rollback();
                redirectDash(request, response, "pending", "err", "Only PENDING submissions can be processed");
                return;
            }

            if ("REJECT".equals(action)) {
                submissionDAO.updateSubmissionStatus(conn, submissionId, "REJECTED");
                conn.commit();
                redirectDash(request, response, "pending", "msg", "Rejected.");
                return;
            }

            if ("APPROVE".equals(action)) {
                int categoryId = mapCategoryToId(submission.getCategory());

                String imageFileName = submissionDAO.getFirstSubmissionImageFile(conn, submissionId);

                if (imageFileName == null || imageFileName.trim().isEmpty()) {
                    imageFileName = "no-image.png";
                } else {
                    imageFileName = imageFileName.trim();
                }

                String finalDesc = (submission.getDescription() == null) ? "" : submission.getDescription().trim();

                int newLocationId = locationDAO.insertApprovedLocation(
                        conn,
                        categoryId,
                        submission.getName(),
                        finalDesc,
                        imageFileName
                );

                submissionDAO.updateSubmissionStatus(conn, submissionId, "APPROVED");

                conn.commit();
                redirectDash(request, response, "pending", "msg", "Approved. Location ID: " + newLocationId);
                return;
            }

            conn.rollback();
            redirectDash(request, response, "pending", "err", "Invalid action");

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ignore) {
            }

            redirectDash(request, response, "pending", "err", "DB Error: " + e.getMessage());

        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }

    private static void redirectDash(HttpServletRequest request, HttpServletResponse response,
                                     String tab, String key, String value) throws IOException {

        String url = request.getContextPath() + "/ContentDashboardServlet?tab=" + tab
                + "&" + key + "=" + URLEncoder.encode(value, StandardCharsets.UTF_8);

        response.sendRedirect(url);
    }

    private static int mapCategoryToId(String cat) {
        if (cat == null) return 2;

        String c = cat.trim().toLowerCase();

        if (c.equals("food")) return 1;
        if (c.equals("scenic spots") || c.equals("scenic") || c.equals("spot")) return 2;
        if (c.equals("chalets") || c.equals("chalet")) return 3;
        if (c.equals("shopping")) return 4;
        if (c.equals("culture")) return 4;

        return 2;
    }

    private static int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }
}