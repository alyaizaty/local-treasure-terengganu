package controller;

import java.io.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ReviewImageServlet")
public class ReviewImageServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "C:/uploads/reviews";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        String file = request.getParameter("file");
        if (file == null || file.contains("..") || file.contains("/") || file.contains("\\"))
            return;

        File img = new File(UPLOAD_DIR, file);
        if (!img.exists()) return;

        String lower = file.toLowerCase();
        if (lower.endsWith(".png")) response.setContentType("image/png");
        else if (lower.endsWith(".webp")) response.setContentType("image/webp");
        else response.setContentType("image/jpeg");

        response.setContentLengthLong(img.length());

        try (InputStream in = new FileInputStream(img);
             OutputStream out = response.getOutputStream()) {

            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
