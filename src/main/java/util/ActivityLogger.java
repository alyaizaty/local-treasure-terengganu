package util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class ActivityLogger {

    public static void log(Connection conn, int userId, String type) {
        if (conn == null || type == null) return;

        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO user_activity (user_id, activity_type) VALUES (?, ?)"
        )) {
            ps.setInt(1, userId);
            ps.setString(2, type.toUpperCase());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}