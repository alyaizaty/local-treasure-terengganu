package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class BookmarkDAO {

    public boolean exists(Connection conn, int userId, int locationId) throws Exception {
        String sql = "SELECT id FROM bookmarks WHERE user_id=? AND location_id=? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, locationId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void insert(Connection conn, int userId, int locationId) throws Exception {
        String sql = "INSERT INTO bookmarks(user_id, location_id) VALUES(?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, locationId);
            ps.executeUpdate();
        }
    }

    public void delete(Connection conn, int userId, int locationId) throws Exception {
        String sql = "DELETE FROM bookmarks WHERE user_id=? AND location_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, locationId);
            ps.executeUpdate();
        }
    }

    public boolean toggle(Connection conn, int userId, int locationId) throws Exception {
        boolean exists = exists(conn, userId, locationId);

        if (exists) {
            delete(conn, userId, locationId);
            return false;
        } else {
            insert(conn, userId, locationId);
            return true;
        }
    }
}