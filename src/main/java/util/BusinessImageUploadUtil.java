package util;

import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

public class BusinessImageUploadUtil {

    private static final String UPLOAD_DIR = "uploads";

    public static void ensureUploadDirectoryExists(String realPath) {
        File uploadDir = new File(realPath + File.separator + UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
    }

    public static String saveImage(Part part, String realPath) throws IOException {
        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (fileName == null || fileName.trim().isEmpty()) {
            return null;
        }

        String ext = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex >= 0) {
            ext = fileName.substring(dotIndex);
        }

        String uniqueFileName = "business_" + UUID.randomUUID().toString() + ext;
        String savePath = realPath + File.separator + UPLOAD_DIR + File.separator + uniqueFileName;
        part.write(savePath);

        return uniqueFileName;
    }
}