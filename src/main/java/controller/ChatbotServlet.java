package controller;

import dao.ChatDAO;
import model.ChatMessage;
import util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/chatbot")
public class ChatbotServlet extends HttpServlet {
    private ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBConnection.getConnection()) {
            String sessionId = request.getSession().getId();
            Integer userId = (Integer) request.getSession().getAttribute("userId");
            String userMessage = request.getParameter("message");

            if (userMessage == null || userMessage.trim().isEmpty()) {
                userMessage = "hello";
            }

            // Save User Message
            ChatMessage userChat = new ChatMessage();
            userChat.setSessionId(sessionId);
            userChat.setUserId(userId);
            userChat.setSender("USER");
            userChat.setMessage(userMessage);
            chatDAO.insertMessage(conn, userChat);

            // Get Bot Reply
            String botReply = chatDAO.getAnswerFromDB(conn, userMessage);

            // Save Bot Message
            ChatMessage botChat = new ChatMessage();
            botChat.setSessionId(sessionId);
            botChat.setUserId(userId);
            botChat.setSender("BOT");
            botChat.setMessage(botReply);
            chatDAO.insertMessage(conn, botChat);

            // Robust JSON escaping
            String jsonReply = botReply.replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
            out.write("{\"reply\": \"" + jsonReply + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"reply\": \"Sorry, server error occurred.\"}");
        } finally {
            out.flush();
        }
    }
}