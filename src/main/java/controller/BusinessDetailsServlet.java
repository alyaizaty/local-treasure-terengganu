package controller;

import dao.BusinessDAO;
import model.Business;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;
import java.util.Map;

@WebServlet("/businessDetails")
public class BusinessDetailsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");

        // 1. Check if the ID parameter is completely missing or empty
        if (idStr == null || idStr.trim().isEmpty()) {
            System.err.println("BusinessDetailsServlet: ID parameter is missing.");
            response.sendRedirect("home.jsp?msg=Missing+Business+ID");
            return;
        }

        try {
            // Attempt to parse the ID into an integer
            int businessId = Integer.parseInt(idStr.trim());

            try (Connection conn = DBConnection.getConnection()) {
                BusinessDAO dao = new BusinessDAO();
                Business business = dao.getBusinessById(conn, businessId);

                // 2. Check if the database query returned null (business doesn't exist)
                if (business == null) {
                    System.err.println("BusinessDetailsServlet: No business found for ID " + businessId);
                    response.sendRedirect("home.jsp?msg=Business+Not+Found");
                    return;
                }

                // Retrieve optional gallery images and reviews
                List<String> galleryImages = dao.getBusinessImages(conn, businessId);
                List<Map<String, Object>> reviewsList = dao.getReviewsForBusiness(conn, businessId);

                // 3. Set attributes to be passed to the JSP
                request.setAttribute("business", business);
                request.setAttribute("galleryImages", galleryImages);
                request.setAttribute("reviewsList", reviewsList);

                // 4. Forward to the JSP page
                // Note: If businessDetails.jsp does not exist, this line throws a ServletException
                request.getRequestDispatcher("businessDetails.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            // Triggered if the user passed something like ?id=abc instead of a number
            System.err.println("BusinessDetailsServlet: Invalid ID format -> " + idStr);
            response.sendRedirect("home.jsp?msg=Invalid+Business+ID");
            
        } catch (ServletException e) {
            // Triggered if businessDetails.jsp is MISSING or has Java/HTML syntax errors inside it.
            // By throwing it, Tomcat will show you the exact JSP error on the screen instead of silently refreshing.
            System.err.println("BusinessDetailsServlet: JSP Forwarding Error. Check if businessDetails.jsp exists and compiles.");
            throw e; 
            
        } catch (Exception e) {
            // Triggered by Database/SQL issues (e.g., missing tables, bad DB connection)
            System.err.println("BusinessDetailsServlet: Database or Server Exception occurred.");
            e.printStackTrace(); // Read your Tomcat/Glassfish console to see this error
            response.sendRedirect("home.jsp?msg=Internal+Server+Error");
        }
    }
}