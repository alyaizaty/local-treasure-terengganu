package dao;

import model.Business;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import util.DBConnection;

public class BusinessDAO {

    public int insertBusinessAndGetId(Connection conn, Business b) throws Exception {
        String sql = "INSERT INTO businesses "
                + "(user_id, business_name, description, address, contact_phone, operating_hours, category_id, image, gmaps_link) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, b.getUserId());
            ps.setString(2, b.getBusinessName());
            ps.setString(3, b.getDescription());
            ps.setString(4, b.getAddress());
            ps.setString(5, b.getContactPhone());
            ps.setString(6, b.getOperatingHours());
            ps.setInt(7, b.getCategoryId());
            ps.setString(8, b.getImage());
            ps.setString(9, b.getGmapsLink());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Gagal mendaftar entiti perniagaan. ID tidak diperoleh.");
    }

    public void insertBusinessImage(Connection conn, int businessId, String fileName) throws Exception {
        String sql = "INSERT INTO business_images (business_id, file_name) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            ps.setString(2, fileName);
            ps.executeUpdate();
        }
    }
public List<Map<String,Object>> getAllReviewsForBusiness(Connection conn, int businessId, int userId) throws Exception {
    List<Map<String,Object>> list = new ArrayList<>();
    
    String sql = 
        "SELECT u.username, l.name AS location_name, r.rating, r.review_text, r.review_date " +
        "FROM reviews r " +
        "JOIN users u ON u.id = r.user_id " +
        "JOIN locations l ON l.location_id = r.location_id " +
        "WHERE l.business_id = ? " +
        "UNION " +
        "SELECT u.username, s.name AS location_name, r.rating, r.review_text, r.review_date " +
        "FROM reviews r " +
        "JOIN users u ON u.id = r.user_id " +
        "JOIN location_submission s ON s.submission_id = r.location_id " +
        "WHERE s.user_id = ? " +
        "ORDER BY review_date DESC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, businessId);
        ps.setInt(2, userId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> map = new HashMap<>();
                map.put("username", rs.getString("username"));
                map.put("locationName", rs.getString("location_name"));
                map.put("rating", rs.getInt("rating"));
                map.put("text", rs.getString("review_text"));
                map.put("date", rs.getDate("review_date"));
                list.add(map);
            }
        }
    }

    return list;
}public List<Map<String,Object>> getLocationsForBusiness(Connection conn, int businessId, int userId) throws Exception {
    List<Map<String,Object>> list = new ArrayList<>();
    // Fetch official locations
    String sql = "SELECT location_id, name, description FROM locations WHERE business_id=? ORDER BY location_id DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, businessId);
        try (ResultSet rs = ps.executeQuery()) {
            while(rs.next()) {
                Map<String,Object> loc = new HashMap<>();
                loc.put("id", rs.getInt("location_id"));
                loc.put("name", rs.getString("name"));
                loc.put("desc", rs.getString("description"));
                list.add(loc);
            }
        }
    }
    // Fetch submitted locations (optional)
    sql = "SELECT submission_id, name, description, status FROM location_submission WHERE user_id=? ORDER BY submission_id DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
            while(rs.next()) {
                Map<String,Object> loc = new HashMap<>();
                loc.put("id", rs.getInt("submission_id"));
                loc.put("name", rs.getString("name"));
                loc.put("desc", rs.getString("description"));
                loc.put("status", rs.getString("status"));
                list.add(loc);
            }
        }
    }
    return list;
}

public List<Map<String,Object>> getPromotionsForBusiness(Connection conn, int businessId) throws Exception {
    List<Map<String,Object>> list = new ArrayList<>();
    String sql = "SELECT promotion_id, title, description, start_date, end_date, is_active, approval_status " +
                 "FROM promotions WHERE business_id=? ORDER BY promotion_id DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, businessId);
        try (ResultSet rs = ps.executeQuery()) {
            while(rs.next()) {
                Map<String,Object> promo = new HashMap<>();
                promo.put("id", rs.getInt("promotion_id"));
                promo.put("title", rs.getString("title"));
                promo.put("desc", rs.getString("description"));
                promo.put("start", rs.getString("start_date"));
                promo.put("end", rs.getString("end_date"));
                promo.put("active", rs.getString("is_active"));
                promo.put("status", rs.getString("approval_status"));
                list.add(promo);
            }
        }
    }
    return list;
}


    

    public void deleteBusinessImages(Connection conn, int businessId) throws Exception {
        String sql = "DELETE FROM business_images WHERE business_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            ps.executeUpdate();
        }
    }

    public List<String> getBusinessImages(Connection conn, int businessId) throws Exception {
        List<String> list = new ArrayList<>();
        String sql = "SELECT file_name FROM business_images WHERE business_id = ? ORDER BY business_image_id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(rs.getString("file_name"));
            }
        }
        return list;
    }

    public Business getBusinessById(Connection conn, int businessId) throws Exception {
        String sql = "SELECT b.*, c.name AS category_name, u.username AS owner_username FROM businesses b "
                   + "LEFT JOIN categories c ON b.category_id = c.category_id "
                   + "LEFT JOIN users u ON b.user_id = u.id "
                   + "WHERE b.business_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Business b = new Business();
                    b.setBusinessId(rs.getInt("business_id"));
                    b.setUserId(rs.getInt("user_id"));
                    b.setBusinessName(rs.getString("business_name"));
                    b.setDescription(rs.getString("description"));
                    b.setAddress(rs.getString("address"));
                    b.setContactPhone(rs.getString("contact_phone"));
                    b.setOperatingHours(rs.getString("operating_hours"));
                    b.setGmapsLink(rs.getString("gmaps_link"));
                    b.setCategoryId(rs.getInt("category_id"));
                    b.setImage(rs.getString("image"));
                    b.setCategoryName(rs.getString("category_name"));
                    b.setOwnerUsername(rs.getString("owner_username"));
                    return b;
                }
            }
        }
        return null;
    }

    public List<Business> getAllRegisteredBusinesses() throws Exception {
        List<Business> list = new ArrayList<>();
        String sql = "SELECT b.*, c.name AS category_name, u.username AS owner_username, "
                   + "IFNULL(r.avg_rating, 0) AS avg_rating, IFNULL(r.total_reviews, 0) AS total_reviews "
                   + "FROM businesses b "
                   + "LEFT JOIN categories c ON b.category_id = c.category_id "
                   + "LEFT JOIN users u ON b.user_id = u.id "
                   + "LEFT JOIN (SELECT business_id, AVG(rating) AS avg_rating, COUNT(review_id) AS total_reviews "
                   + "FROM business_reviews GROUP BY business_id) r ON b.business_id = r.business_id "
                   + "ORDER BY b.business_id DESC";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Business b = new Business();
                b.setBusinessId(rs.getInt("business_id"));
                b.setUserId(rs.getInt("user_id"));
                b.setBusinessName(rs.getString("business_name"));
                b.setDescription(rs.getString("description"));
                b.setAddress(rs.getString("address"));
                b.setContactPhone(rs.getString("contact_phone"));
                b.setOperatingHours(rs.getString("operating_hours"));
                b.setGmapsLink(rs.getString("gmaps_link"));
                b.setCategoryId(rs.getInt("category_id"));
                b.setImage(rs.getString("image"));
                b.setCategoryName(rs.getString("category_name"));
                b.setOwnerUsername(rs.getString("owner_username"));
                b.setAvgRating(rs.getDouble("avg_rating"));
                b.setTotalReviews(rs.getInt("total_reviews"));
                list.add(b);
            }
        }
        return list;
    }

    public void insertReview(Connection conn, int businessId, int userId, int rating, String text) throws Exception {
        String sql = "INSERT INTO business_reviews (business_id, user_id, rating, review_text) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, text);
            ps.executeUpdate();
        }
    }
    public boolean updateBusiness(Business b) {
    String sql = "UPDATE businesses SET business_name=?, description=?, address=?, contact_phone=?, operating_hours=?, gmaps_link=?, category_id=?, image=? WHERE business_id=? AND user_id=?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, b.getBusinessName());
        ps.setString(2, b.getDescription());
        ps.setString(3, b.getAddress());
        ps.setString(4, b.getContactPhone());
        ps.setString(5, b.getOperatingHours());
        ps.setString(6, b.getGmapsLink());
        ps.setInt(7, b.getCategoryId());
        ps.setString(8, b.getImage());
        ps.setInt(9, b.getBusinessId());
        ps.setInt(10, b.getUserId());

        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

    public List<Map<String, Object>> getReviewsForBusiness(Connection conn, int businessId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username FROM business_reviews r JOIN users u ON r.user_id = u.id WHERE r.business_id = ? ORDER BY r.review_id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("username", rs.getString("username"));
                    map.put("rating", rs.getInt("rating"));
                    map.put("text", rs.getString("review_text"));
                    map.put("date", rs.getDate("review_date"));
                    list.add(map);
                }
            }
        }
        return list;
    }
    // ================= REVIEW IMAGE METHODS =================

public int insertReviewAndGetId(Connection conn, int locationId, int userId, int rating, String reviewText) throws Exception {
    String sql = "INSERT INTO reviews (location_id, user_id, rating, review_text) VALUES (?, ?, ?, ?)";

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

    throw new SQLException("Failed to insert review. Review ID not generated.");
}

public void insertReviewImage(Connection conn, int reviewId, String fileName) throws Exception {
    String sql = "INSERT INTO review_images (review_id, file_name) VALUES (?, ?)";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, reviewId);
        ps.setString(2, fileName);
        ps.executeUpdate();
    }
}

public List<String> getReviewImages(Connection conn, int reviewId) throws Exception {
    List<String> images = new ArrayList<>();

    String sql = "SELECT file_name FROM review_images WHERE review_id = ? ORDER BY image_id ASC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, reviewId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                images.add(rs.getString("file_name"));
            }
        }
    }

    return images;
}

public List<String> getReviewImagesByReviewId(Connection conn, int reviewId) throws Exception {
    return getReviewImages(conn, reviewId);
}

public void deleteReviewImages(Connection conn, int reviewId) throws Exception {
    String sql = "DELETE FROM review_images WHERE review_id = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, reviewId);
        ps.executeUpdate();
    }
}

    public Business getBusinessByUserId(Connection conn, int userId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}