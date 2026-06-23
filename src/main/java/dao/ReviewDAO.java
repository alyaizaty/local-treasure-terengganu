package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public int insertReview(Connection conn, int locationId, int userId, int rating, String reviewText) throws Exception {
        String sql = "INSERT INTO reviews(location_id,user_id,rating,review_text,review_date) " +
                     "VALUES(?,?,?,?,CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, locationId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, reviewText);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new Exception("Failed to create review.");
    }

    public void insertReviewImage(Connection conn, int reviewId, String fileName) throws Exception {
        String sql = "INSERT INTO review_images(review_id, file_name) VALUES(?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setString(2, fileName);
            ps.executeUpdate();
        }
    }

    public int getReviewOwner(Connection conn, int reviewId) throws Exception {
        String sql = "SELECT user_id FROM reviews WHERE review_id=? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }

        return 0;
    }

    public List<String> getReviewImageFiles(Connection conn, int reviewId) throws Exception {
        List<String> files = new ArrayList<>();

        String sql = "SELECT file_name FROM review_images WHERE review_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String f = rs.getString("file_name");
                    if (f != null && !f.trim().isEmpty()) {
                        files.add(f.trim());
                    }
                }
            }
        }

        return files;
    }

    public void deleteReview(Connection conn, int reviewId, int userId) throws Exception {
        String sql = "DELETE FROM reviews WHERE review_id=? AND user_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}