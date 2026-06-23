package controller;

import dao.LocationSubmissionDAO;
import model.LocationSubmission;
import util.DBConnection;
import util.LocationImageUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/SubmitLocationServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 25 * 1024 * 1024
)
public class SubmitLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp?from=submit_location");
            return;
        }

        String locationName = trim(request.getParameter("locationName"));
        String category = trim(request.getParameter("category"));
        String description = trim(request.getParameter("description"));
        String addressLine = trim(request.getParameter("addressLine"));
        String city = trim(request.getParameter("city"));
        String state = trim(request.getParameter("state"));
        String gmapsLink = trim(request.getParameter("gmapsLink"));

        if (isBlank(locationName) || isBlank(category) || isBlank(description)
                || isBlank(addressLine) || isBlank(city) || isBlank(state) || isBlank(gmapsLink)) {

            response.sendRedirect("submit_location.jsp?err=" +
                    URLEncoder.encode("Please fill all fields and click Preview Map before submitting.", "UTF-8"));
            return;
        }

        LocationSubmission submission = new LocationSubmission();
        submission.setUserId(userId);
        submission.setName(locationName);
        submission.setCategory(category);
        submission.setDescription(description);
        submission.setAddressLine(addressLine);
        submission.setCity(city);
        submission.setState(state);
        submission.setGmapsLink(gmapsLink);

        LocationSubmissionDAO submissionDAO = new LocationSubmissionDAO();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int submissionId = submissionDAO.insertSubmission(conn, submission);

            LocationImageUploadUtil.ensureUploadDirectoryExists();

            for (Part p : request.getParts()) {
                if (!"images".equals(p.getName())) {
                    continue;
                }

                if (p.getSize() <= 0) {
                    continue;
                }

                String contentType = p.getContentType();
                if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                    continue;
                }

                String fileName = LocationImageUploadUtil.saveImage(p, submissionId);
                if (fileName != null) {
                    submissionDAO.insertSubmissionImage(conn, submissionId, fileName);
                }
            }

            conn.commit();

            response.sendRedirect("my_submissions.jsp?msg=" +
                    URLEncoder.encode("Location submitted successfully! (Status: PENDING)", "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ignore) {
            }

            response.sendRedirect("submit_location.jsp?err=" +
                    URLEncoder.encode("System error: " + e.getMessage(), "UTF-8"));

        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }
}