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
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (Connection conn = DBConnection.getConnection()) {

            // GET DATA
            String sessionId = request.getSession().getId();

            Integer userId =
                    (Integer) request.getSession().getAttribute("userId");

            String userMessage = request.getParameter("message");

            // VALIDATION
            if (userMessage == null || userMessage.trim().isEmpty()) {
                userMessage = "hello";
            }

            // SAVE USER MESSAGE
            ChatMessage userChat = new ChatMessage();

            userChat.setSessionId(sessionId);
            userChat.setUserId(userId);
            userChat.setSender("USER");
            userChat.setMessage(userMessage);

            chatDAO.insertMessage(conn, userChat);

            // GET BOT REPLY
            String botReply =
                    chatDAO.getAnswerFromDB(conn, userMessage);

            // SAVE BOT MESSAGE
            ChatMessage botChat = new ChatMessage();

            botChat.setSessionId(sessionId);
            botChat.setUserId(userId);
            botChat.setSender("BOT");
            botChat.setMessage(botReply);

            chatDAO.insertMessage(conn, botChat);

            // ESCAPE JSON
            botReply = botReply
                    .replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "");

            // SEND JSON RESPONSE
            PrintWriter out = response.getWriter();

            out.write("{\"reply\":\"" + botReply + "\"}");

            out.flush();

        } catch (Exception e) {

            e.printStackTrace();

            response.getWriter().write(
                    "{\"reply\":\"Server error occurred.\"}"
            );
        }
    }
}