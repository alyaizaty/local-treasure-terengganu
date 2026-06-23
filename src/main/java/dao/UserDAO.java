package dao;

import model.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class UserDAO {

    public User findByEmail(String email) {
        User user = null;

        String sql = "SELECT id, username, email, password, profile_picture, role " +
                     "FROM users WHERE email = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setProfilePicture(rs.getString("profile_picture"));
                    user.setRole(rs.getString("role"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }
public int getUserIdByUsernameOrEmail(String username, String email) {
    String sql = "SELECT id FROM users WHERE username = ? OR email = ? LIMIT 1";

    try (java.sql.Connection conn = util.DBConnection.getConnection();
         java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, username);
        ps.setString(2, email);

        try (java.sql.ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("id");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return 0;
}
    public boolean existsByUsernameOrEmail(String username, String email) {
        String sql = "SELECT id FROM users WHERE username = ? OR email = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean insertUser(User user) {
        try (Connection conn = DBConnection.getConnection()) {
            return insertUserAndGetId(conn, user) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int insertUserAndGetId(Connection conn, User user) throws Exception {
        String sql = "INSERT INTO users (username, email, password, profile_picture, role) VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getProfilePicture());
            ps.setString(5, user.getRole());

            int affectedRows = ps.executeUpdate();

            if (affectedRows == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }

        return -1;
    }

    public String getProfilePictureById(Connection conn, int userId) throws Exception {
        String sql = "SELECT profile_picture FROM users WHERE id = ? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("profile_picture");
                }
            }
        }

        return null;
    }

    public boolean updateProfileWithoutImage(Connection conn, int userId, String username, String email) throws Exception {
        String sql = "UPDATE users SET username = ?, email = ? WHERE id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setInt(3, userId);

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateProfileWithImage(Connection conn, int userId, String username, String email, String profilePicture) throws Exception {
        String sql = "UPDATE users SET username = ?, email = ?, profile_picture = ? WHERE id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, profilePicture);
            ps.setInt(4, userId);

            return ps.executeUpdate() == 1;
        }
    }

    public boolean deleteUserById(Connection conn, int userId) throws Exception {
        String sql = "DELETE FROM users WHERE id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() == 1;
        }
    }
}