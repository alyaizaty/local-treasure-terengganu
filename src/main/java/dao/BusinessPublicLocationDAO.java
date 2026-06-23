package dao;

import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class BusinessPublicLocationDAO {

    public int insertBusinessAsLocation(Connection conn,
                                        int businessId,
                                        String businessName,
                                        String description,
                                        int categoryId,
                                        String address,
                                        String imageFileName) throws Exception {

        int locationId = insertLocation(
                conn,
                businessId,
                businessName,
                description,
                categoryId,
                imageFileName
        );

        if (locationId <= 0) {
            return -1;
        }

        insertLocationAddress(conn, locationId, address, businessName);
        return locationId;
    }

    private int insertLocation(Connection conn,
                               int businessId,
                               String businessName,
                               String description,
                               int categoryId,
                               String imageFileName) throws Exception {

        String sql = "INSERT INTO location (business_id, name, description, image, category_id) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, businessId);
            ps.setString(2, businessName);
            ps.setString(3, description);

            if (imageFileName == null || imageFileName.trim().isEmpty()) {
                ps.setString(4, "default_business.jpg");
            } else {
                ps.setString(4, imageFileName);
            }

            if (categoryId > 0) {
                ps.setInt(5, categoryId);
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }

            int affected = ps.executeUpdate();

            if (affected == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }

        return -1;
    }

    private void insertLocationAddress(Connection conn,
                                       int locationId,
                                       String address,
                                       String businessName) throws Exception {

        String gmapsLink = "";

        try {
            String q = ((address == null ? "" : address) + " "
                    + (businessName == null ? "" : businessName)
                    + " Terengganu").trim();

            gmapsLink = "https://www.google.com/maps/search/?api=1&query="
                    + URLEncoder.encode(q, "UTF-8");

        } catch (Exception e) {
            gmapsLink = "";
        }

        String sql = "INSERT INTO location_address " +
                     "(location_id, address_line, city, state, gmaps_link, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, locationId);
            ps.setString(2, address);
            ps.setString(3, "");
            ps.setString(4, "Terengganu");
            ps.setString(5, gmapsLink);
            ps.executeUpdate();
        }
    }

    public int findLocationIdByBusinessId(Connection conn, int businessId) throws Exception {
        String sql = "SELECT location_id FROM location WHERE business_id = ? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, businessId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("location_id");
                }
            }
        }

        return 0;
    }
}