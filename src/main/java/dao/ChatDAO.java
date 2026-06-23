package dao;

import model.ChatMessage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;

public class ChatDAO {

    /**
     * Get answer from FAQ database based on user message.
     * Splits user message into keywords and matches any keyword in the FAQ questions.
     */
    public String getAnswerFromDB(Connection conn, String userMessage) {

        if (userMessage == null || userMessage.trim().isEmpty()) {
            return "Maaf, saya tidak jumpa jawapan untuk soalan itu.";
        }

        // Split user message into individual keywords
        String[] keywords = userMessage.toLowerCase().split("\\s+");

        // Build SQL query with multiple LIKE conditions
        StringBuilder sql = new StringBuilder("SELECT answer FROM faqs WHERE ");
        for (int i = 0; i < keywords.length; i++) {
            sql.append("LOWER(question) LIKE ?");
            if (i < keywords.length - 1) sql.append(" OR ");
        }
        sql.append(" LIMIT 1");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            // Set parameters for each keyword
            for (int i = 0; i < keywords.length; i++) {
                ps.setString(i + 1, "%" + keywords[i] + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("answer");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Default fallback if no match found
        return "Maaf, saya tidak jumpa jawapan untuk soalan itu.";
    }

    /**
     * Insert a chat message into chat_history table.
     */
    public boolean insertMessage(Connection conn, ChatMessage chat) {

        String sql =
                "INSERT INTO chat_history " +
                        "(session_id, user_id, sender, message) " +
                        "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, chat.getSessionId());

            if (chat.getUserId() != null) {
                ps.setInt(2, chat.getUserId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, chat.getSender());
            ps.setString(4, chat.getMessage());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}