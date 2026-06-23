package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class CommentDAO {

    public void insertComment(Connection conn, int reviewId, int userId, String commentText) throws Exception {
        String sql = "INSERT INTO comments(review_id,user_id,comment_text,comment_date) " +
                     "VALUES(?,?,?,CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            ps.executeUpdate();
        }
    }
}