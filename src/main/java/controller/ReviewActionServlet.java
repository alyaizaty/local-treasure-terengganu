package controller;

import dao.CommentDAO;
import dao.LikeDAO;
import dao.ReviewDAO;
import util.DBConnection;
import util.ReviewImageUploadUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ReviewActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB threshold
        maxFileSize = 1024 * 1024 * 10,       // Max 10MB per file
        maxRequestSize = 1024 * 1024 * 50     // Max 50MB total request size
)
public class ReviewActionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

        String action = request.getParameter("action");
        int locationId = parseInt(request.getParameter("locationId"));

        String customRedirect = request.getParameter("customRedirect");
        String successRedirect = request.getParameter("successRedirect");

        if (locationId <= 0) {
            response.sendRedirect("treasures.jsp");
            return;
        }

        if (userId == null) {
            response.sendRedirect("login.jsp?from=location_details&id=" + locationId);
            return;
        }

        String msg = null;
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            ReviewDAO reviewDAO = new ReviewDAO();
            LikeDAO likeDAO = new LikeDAO();
            CommentDAO commentDAO = new CommentDAO();

            // ================= ADD OR UPDATE REVIEW =================
            if ("addOrUpdateReview".equals(action)) {

                int rating = parseInt(request.getParameter("rating"));
                String reviewText = request.getParameter("reviewText");

                if (rating < 1 || rating > 5) {
                    msg = "Please choose rating 1–5.";
                } else {
                    // Insert review first
                    int reviewId = reviewDAO.insertReview(
                            conn,
                            locationId,
                            userId,
                            rating,
                            reviewText != null ? reviewText.trim() : ""
                    );

                    if (reviewId <= 0) {
                        throw new Exception("Failed to create review entry.");
                    }

                    // ================= UPLOAD IMAGES =================
                    ReviewImageUploadUtil.ensureUploadDirectoryExists();

                    for (Part part : request.getParts()) {
                        if (!"reviewImages".equals(part.getName())) {
                            continue;
                        }

                        if (part.getSize() <= 0) {
                            continue;
                        }

                        String contentType = part.getContentType();

                        if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                            continue;
                        }

                        String fileName = ReviewImageUploadUtil.saveImage(part, reviewId);

                        if (fileName != null && !fileName.trim().isEmpty()) {
                            reviewDAO.insertReviewImage(conn, reviewId, fileName);
                        }
                    }

                    msg = "Review posted successfully.";
                }
            }

            // ================= TOGGLE LIKE =================
            else if ("toggleLike".equals(action)) {

                int reviewId = parseInt(request.getParameter("reviewId"));

                if (reviewId > 0) {
                    likeDAO.toggle(conn, reviewId, userId);
                }
            }

            // ================= ADD COMMENT =================
            else if ("addComment".equals(action)) {

                int reviewId = parseInt(request.getParameter("reviewId"));
                String commentText = request.getParameter("commentText");

                if (commentText == null || commentText.trim().isEmpty()) {
                    msg = "Comment cannot be empty.";
                } else if (reviewId > 0) {
                    commentDAO.insertComment(conn, reviewId, userId, commentText.trim());
                    msg = "Comment added successfully.";
                }
            }

            // ================= DELETE REVIEW =================
            else if ("deleteReview".equals(action)) {

                int reviewId = parseInt(request.getParameter("reviewId"));

                if (reviewId > 0) {
                    int owner = reviewDAO.getReviewOwner(conn, reviewId);

                    if (owner != userId) {
                        msg = "Not allowed. You are not the owner of this review.";
                    } else {
                        // Get all image filenames for deletion
                        List<String> files = reviewDAO.getReviewImageFiles(conn, reviewId);

                        // Delete review + images in DB
                        reviewDAO.deleteReview(conn, reviewId, userId);

                        // Delete files from server
                        ReviewImageUploadUtil.deleteImages(files);

                        msg = "Review deleted successfully.";
                    }
                }
            }

            conn.commit();

        } catch (Exception e) {
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            msg = "System Error: " + e.getMessage();

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeError) {
                    closeError.printStackTrace();
                }
            }
        }

        // ================= REDIRECT =================
        String redirect;

        if (customRedirect != null && !customRedirect.trim().isEmpty()) {
            redirect = customRedirect.trim();
        } else if (successRedirect != null && !successRedirect.trim().isEmpty()) {
            redirect = successRedirect.trim();
        } else {
            redirect = "location_details.jsp?id=" + locationId;
        }

        if (msg != null && !msg.trim().isEmpty()) {
            String encodedMsg = URLEncoder.encode(msg, "UTF-8");

            if (redirect.contains("#")) {
                String[] parts = redirect.split("#", 2);
                String base = parts[0];
                String anchor = parts[1];

                if (base.contains("?")) {
                    redirect = base + "&msg=" + encodedMsg + "#" + anchor;
                } else {
                    redirect = base + "?msg=" + encodedMsg + "#" + anchor;
                }
            } else {
                if (redirect.contains("?")) {
                    redirect += "&msg=" + encodedMsg;
                } else {
                    redirect += "?msg=" + encodedMsg;
                }
            }
        }

        response.sendRedirect(redirect);
    }

    // Helper parseInt
    private int parseInt(String s) {
        if (s == null) {
            return 0;
        }

        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return 0;
        }
    }
}