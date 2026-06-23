package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class LocationDAO {

    public String getLocationImageById(Connection conn, int locationId) throws Exception {
        String sql = "SELECT image FROM location WHERE location_id=? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, locationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("image");
                }
            }
        }

        return null;
    }

    public void deleteBookmarksByLocationId(Connection conn, int locationId) throws Exception {
        String sql = "DELETE FROM bookmarks WHERE location_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, locationId);
            ps.executeUpdate();
        }
    }

    public boolean deleteLocationById(Connection conn, int locationId) throws Exception {
        String sql = "DELETE FROM location WHERE location_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, locationId);
            return ps.executeUpdate() == 1;
        }
    }

    public int insertApprovedLocation(Connection conn, int categoryId, String name, String description, String image) throws Exception {
        String sql = "INSERT INTO location (category_id, name, description, image) VALUES (?,?,?,?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, categoryId);
            ps.setString(2, name);
            ps.setString(3, description);
            ps.setString(4, image);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new Exception("Failed to insert approved location.");
    }
}