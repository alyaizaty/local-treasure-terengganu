package dao;

import model.LocationSubmission;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LocationSubmissionDAO {

    public int insertSubmission(Connection conn, LocationSubmission submission) throws Exception {
        String sql =
            "INSERT INTO location_submission " +
            "(user_id, name, category, description, address_line, city, state, gmaps_link, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, submission.getUserId());
            ps.setString(2, submission.getName());
            ps.setString(3, submission.getCategory());
            ps.setString(4, submission.getDescription());
            ps.setString(5, submission.getAddressLine());
            ps.setString(6, submission.getCity());
            ps.setString(7, submission.getState());
            ps.setString(8, submission.getGmapsLink());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        throw new Exception("Failed to get submission ID.");
    }

    public void insertSubmissionImage(Connection conn, int submissionId, String fileName) throws Exception {
        String sql = "INSERT INTO location_submission_images(submission_id, file_name) VALUES (?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            ps.setString(2, fileName);
            ps.executeUpdate();
        }
    }

    public String getSubmissionStatusByUser(Connection conn, int submissionId, int userId) throws Exception {
        String sql = "SELECT status FROM location_submission WHERE submission_id=? AND user_id=? LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }

        return null;
    }

    public boolean updateSubmission(Connection conn, LocationSubmission submission) throws Exception {
        String sql = "UPDATE location_submission SET " +
                     "name=?, category=?, description=?, address_line=?, city=?, state=?, gmaps_link=? " +
                     "WHERE submission_id=? AND user_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, submission.getName());
            ps.setString(2, submission.getCategory());
            ps.setString(3, submission.getDescription());
            ps.setString(4, submission.getAddressLine());
            ps.setString(5, submission.getCity());
            ps.setString(6, submission.getState());
            ps.setString(7, submission.getGmapsLink());
            ps.setInt(8, submission.getSubmissionId());
            ps.setInt(9, submission.getUserId());

            return ps.executeUpdate() == 1;
        }
    }

    public List<String> getSubmissionImageFiles(Connection conn, int submissionId) throws Exception {
        List<String> files = new ArrayList<>();

        String sql = "SELECT file_name FROM location_submission_images WHERE submission_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String fileName = rs.getString("file_name");
                    if (fileName != null && !fileName.trim().isEmpty()) {
                        files.add(fileName.trim());
                    }
                }
            }
        }

        return files;
    }

    public void deleteSubmissionImages(Connection conn, int submissionId) throws Exception {
        String sql = "DELETE FROM location_submission_images WHERE submission_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            ps.executeUpdate();
        }
    }

    public boolean deleteSubmission(Connection conn, int submissionId, int userId) throws Exception {
        String sql = "DELETE FROM location_submission WHERE submission_id=? AND user_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public LocationSubmission getSubmissionForDecision(Connection conn, int submissionId) throws Exception {
        String sql = "SELECT submission_id, user_id, name, category, description, address_line, city, state, gmaps_link, status " +
                     "FROM location_submission WHERE submission_id=? FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LocationSubmission submission = new LocationSubmission();
                    submission.setSubmissionId(rs.getInt("submission_id"));
                    submission.setUserId(rs.getInt("user_id"));
                    submission.setName(rs.getString("name"));
                    submission.setCategory(rs.getString("category"));
                    submission.setDescription(rs.getString("description"));
                    submission.setAddressLine(rs.getString("address_line"));
                    submission.setCity(rs.getString("city"));
                    submission.setState(rs.getString("state"));
                    submission.setGmapsLink(rs.getString("gmaps_link"));
                    submission.setStatus(rs.getString("status"));
                    return submission;
                }
            }
        }

        return null;
    }

    public String getFirstSubmissionImageFile(Connection conn, int submissionId) throws Exception {
        String sql = "SELECT file_name FROM location_submission_images " +
                     "WHERE submission_id=? ORDER BY created_at ASC, image_id ASC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, submissionId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("file_name");
                }
            }
        }

        return null;
    }

    public void updateSubmissionStatus(Connection conn, int submissionId, String status) throws Exception {
        String sql = "UPDATE location_submission SET status=? WHERE submission_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, submissionId);
            ps.executeUpdate();
        }
    }
}