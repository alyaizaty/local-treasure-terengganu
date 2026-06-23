package util;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import javax.servlet.http.Part;

public class BusinessReviewImageUtil {

    private static final Path UPLOAD_DIR = Paths.get("C:/uploads/business_reviews");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(UPLOAD_DIR);
    }

    public static String saveImage(Part part, int reviewId) throws Exception {
        if (part == null || part.getSize() <= 0) {
            return null;
        }

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

        String fileName = "business_review_" + reviewId + "_" +
                UUID.randomUUID().toString().replace("-", "") + ext;

        File saved = UPLOAD_DIR.resolve(fileName).toFile();

        part.write(saved.getAbsolutePath());

        return fileName;
    }

    public static File getImageFile(String fileParam) {
        if (fileParam == null || fileParam.trim().isEmpty()) {
            return null;
        }

        String file = fileParam.replace("\\", "/");

        if (file.contains("..") || file.contains("/")) {
            return null;
        }

        File imageFile = UPLOAD_DIR.resolve(file).toFile();

        if (!imageFile.exists() || !imageFile.isFile()) {
            return null;
        }

        return imageFile;
    }

    public static String getContentType(String fileName) {
        if (fileName == null) {
            return "application/octet-stream";
        }

        String lower = fileName.toLowerCase();

        if (lower.endsWith(".png")) {
            return "image/png";
        }

        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            return "image/jpeg";
        }

        if (lower.endsWith(".gif")) {
            return "image/gif";
        }

        if (lower.endsWith(".webp")) {
            return "image/webp";
        }

        return "application/octet-stream";
    }

    public static void deleteImages(List<String> files) {
        if (files == null) {
            return;
        }

        for (String fileName : files) {
            if (fileName == null || fileName.trim().isEmpty()) {
                continue;
            }

            try {
                String safeName = Paths.get(fileName.trim()).getFileName().toString();

                if (safeName.contains("..") || safeName.contains("/") || safeName.contains("\\")) {
                    continue;
                }

                Files.deleteIfExists(UPLOAD_DIR.resolve(safeName));
            } catch (Exception ignore) {
            }
        }
    }
}