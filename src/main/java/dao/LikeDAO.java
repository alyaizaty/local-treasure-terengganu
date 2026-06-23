package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LikeDAO {

    public boolean exists(Connection conn, int reviewId, int userId) throws Exception {
        String sql = "SELECT like_id FROM likes WHERE review_id=? AND user_id=? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void insert(Connection conn, int reviewId, int userId) throws Exception {
        String sql = "INSERT INTO likes(review_id,user_id,like_date) VALUES(?,?,CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void delete(Connection conn, int reviewId, int userId) throws Exception {
        String sql = "DELETE FROM likes WHERE review_id=? AND user_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void toggle(Connection conn, int reviewId, int userId) throws Exception {
        if (exists(conn, reviewId, userId)) {
            delete(conn, reviewId, userId);
        } else {
            insert(conn, reviewId, userId);
        }
    }
}