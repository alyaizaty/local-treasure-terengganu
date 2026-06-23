package controller;

import dao.LocationSubmissionDAO;
import model.LocationSubmission;
import util.DBConnection;
import util.LocationImageUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/LocationSubmissionActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5L * 1024 * 1024,
        maxRequestSize = 10L * 1024 * 1024
)
public class LocationSubmissionActionServlet extends HttpServlet {

    private static final boolean ALLOW_APPROVED_EDIT = true;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int submissionId = parseInt(request.getParameter("submissionId"));

        if (submissionId <= 0) {
            redirectMsg(response, request, "/my_submissions.jsp", "Invalid submission");
            return;
        }

        if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, response, userId, submissionId);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response, userId, submissionId);
        } else {
            redirectMsg(response, request, "/my_submissions.jsp", "Invalid action");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response,
                              int userId, int submissionId) throws IOException, ServletException {

        String name = trim(request.getParameter("name"));
        String category = trim(request.getParameter("category"));
        String description = trim(request.getParameter("description"));
        String addressLine = trim(request.getParameter("addressLine"));
        String city = trim(request.getParameter("city"));
        String state = trim(request.getParameter("state"));
        String gmapsLink = trim(request.getParameter("gmapsLink"));

        if (isBlank(name) || isBlank(category) || isBlank(description) ||
                isBlank(addressLine) || isBlank(city) || isBlank(state) || isBlank(gmapsLink)) {

            String url = request.getContextPath() + "/edit_submissions.jsp?id=" + submissionId +
                    "&msg=" + enc("Please fill all fields");
            response.sendRedirect(url);
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            LocationSubmissionDAO dao = new LocationSubmissionDAO();
            String status = dao.getSubmissionStatusByUser(conn, submissionId, userId);

            if (status == null) {
                redirectMsg(response, request, "/my_submissions.jsp", "Submission not found");
                return;
            }

            boolean canEdit =
                    "PENDING".equalsIgnoreCase(status) ||
                    "REJECTED".equalsIgnoreCase(status) ||
                    (ALLOW_APPROVED_EDIT && "APPROVED".equalsIgnoreCase(status));

            if (!canEdit) {
                redirectMsg(response, request, "/my_submissions.jsp", "Submission locked");
                return;
            }

            LocationSubmission submission = new LocationSubmission();
            submission.setSubmissionId(submissionId);
            submission.setUserId(userId);
            submission.setName(name);
            submission.setCategory(category);
            submission.setDescription(description);
            submission.setAddressLine(addressLine);
            submission.setCity(city);
            submission.setState(state);
            submission.setGmapsLink(gmapsLink);

            boolean updated = dao.updateSubmission(conn, submission);

            if (!updated) {
                redirectMsg(response, request, "/edit_submissions.jsp?id=" + submissionId, "Update failed");
                return;
            }

            Part imagePart = null;
            try {
                imagePart = request.getPart("image");
            } catch (Exception ignore) {
            }

            if (imagePart != null && imagePart.getSize() > 0) {
                String contentType = imagePart.getContentType();

                if (contentType != null && contentType.toLowerCase().startsWith("image/")) {
                    LocationImageUploadUtil.ensureUploadDirectoryExists();
                    String fileName = LocationImageUploadUtil.saveImage(imagePart, submissionId);

                    if (fileName == null) {
                        String url = request.getContextPath() + "/edit_submissions.jsp?id=" + submissionId +
                                "&msg=" + enc("Image must be JPG/PNG/WEBP/GIF");
                        response.sendRedirect(url);
                        return;
                    }

                    dao.insertSubmissionImage(conn, submissionId, fileName);
                } else {
                    String url = request.getContextPath() + "/edit_submissions.jsp?id=" + submissionId +
                            "&msg=" + enc("Invalid image file");
                    response.sendRedirect(url);
                    return;
                }
            }

            redirectMsg(response, request, "/my_submissions.jsp", "Updated successfully");

        } catch (Exception e) {
            e.printStackTrace();
            redirectMsg(response, request, "/my_submissions.jsp", "DB Error: " + e.getMessage());
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ignore) {
            }
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response,
                              int userId, int submissionId) throws IOException {

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            LocationSubmissionDAO dao = new LocationSubmissionDAO();
            String status = dao.getSubmissionStatusByUser(conn, submissionId, userId);

            if (status == null) {
                redirectMsg(response, request, "/my_submissions.jsp", "Submission not found");
                return;
            }

            boolean canEdit =
                    "PENDING".equalsIgnoreCase(status) ||
                    "REJECTED".equalsIgnoreCase(status) ||
                    (ALLOW_APPROVED_EDIT && "APPROVED".equalsIgnoreCase(status));

            if (!canEdit) {
                redirectMsg(response, request, "/my_submissions.jsp", "Submission locked");
                return;
            }

            List<String> files = dao.getSubmissionImageFiles(conn, submissionId);
            dao.deleteSubmissionImages(conn, submissionId);

            boolean deleted = dao.deleteSubmission(conn, submissionId, userId);

            if (!deleted) {
                conn.rollback();
                redirectMsg(response, request, "/my_submissions.jsp", "Delete failed");
                return;
            }

            conn.commit();
            LocationImageUploadUtil.deleteImages(files);

            redirectMsg(response, request, "/my_submissions.jsp", "Deleted successfully");

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignore) {
            }

            redirectMsg(response, request, "/my_submissions.jsp", "DB Error: " + e.getMessage());

        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ignore) {
            }
        }
    }

    private static void redirectMsg(HttpServletResponse response, HttpServletRequest request,
                                    String path, String msg) throws IOException {
        String url = request.getContextPath() + (path.startsWith("/") ? path : ("/" + path));
        url += (url.contains("?") ? "&" : "?") + "msg=" + enc(msg);
        response.sendRedirect(url);
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private static int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }
}