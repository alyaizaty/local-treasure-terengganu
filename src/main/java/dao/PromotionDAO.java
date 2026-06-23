package dao;

import model.Promotion;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAO {

    public boolean insertPromotion(Promotion p) {
        String sql = "INSERT INTO promotions (business_id, title, description, start_date, end_date, is_active, approval_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, p.getBusinessId());
            ps.setString(2, p.getTitle());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getStartDate());
            ps.setString(5, p.getEndDate());
            ps.setBoolean(6, p.getIsActive());
            ps.setString(7, p.getApprovalStatus());
            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public int getBusinessIdByUserId(int userId) {
        int businessId = -1;
        String sql = "SELECT business_id FROM businesses WHERE user_id=? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) businessId = rs.getInt("business_id");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return businessId;
    }

    public List<Promotion> getPromotionsByBusiness(int businessId) {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE business_id=? ORDER BY start_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Promotion p = new Promotion();
                    p.setPromotionId(rs.getInt("promotion_id"));
                    p.setBusinessId(businessId);
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("description"));
                    p.setStartDate(rs.getString("start_date"));
                    p.setEndDate(rs.getString("end_date"));
                    p.setIsActive(rs.getBoolean("is_active"));
                    p.setApprovalStatus(rs.getString("approval_status"));
                    list.add(p);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}