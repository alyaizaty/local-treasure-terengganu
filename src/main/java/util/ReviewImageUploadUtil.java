package util;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import javax.servlet.http.Part;

public class ReviewImageUploadUtil {

    private static final Path UPLOAD_DIR = Paths.get("C:/uploads/reviews");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(UPLOAD_DIR);
    }

    public static String saveImage(Part part, int reviewId) throws Exception {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.trim().isEmpty()) {
            return null;
        }

        String safeName = Paths.get(submitted).getFileName().toString();
        String lower = safeName.toLowerCase();

        String ext;
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            ext = ".jpg";
        } else if (lower.endsWith(".png")) {
            ext = ".png";
        } else if (lower.endsWith(".webp")) {
            ext = ".webp";
        } else if (lower.endsWith(".gif")) {
            ext = ".gif";
        } else {
            return null;
        }

        String fileName = "review_" + reviewId + "_" +
                UUID.randomUUID().toString().replace("-", "") + ext;

        File saved = new File(UPLOAD_DIR.toString(), fileName);
        part.write(saved.getAbsolutePath());

        return fileName;
    }

    public static void deleteImages(List<String> files) {
        if (files == null) return;

        for (String fileName : files) {
            if (fileName == null || fileName.trim().isEmpty()) continue;
            try {
                Files.deleteIfExists(UPLOAD_DIR.resolve(fileName.trim()));
            } catch (Exception ignore) {
            }
        }
    }
}