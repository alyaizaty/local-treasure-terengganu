package controller;

import util.LocationImageUtil;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LocationImageServlet")
public class LocationImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fileParam = request.getParameter("file");

        if (fileParam == null || fileParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing file parameter");
            return;
        }

        File imageFile = LocationImageUtil.getImageFile(fileParam);

        if (imageFile == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found or invalid");
            return;
        }

        response.setContentType(LocationImageUtil.getContentType(imageFile.getName()));
        response.setContentLengthLong(imageFile.length());

        try (FileInputStream fis = new FileInputStream(imageFile);
             OutputStream os = response.getOutputStream()) {

            byte[] buffer = new byte[4096];
            int bytesRead;

            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}