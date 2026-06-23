package util;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ProfileImageUtil {

    private static final Path UPLOAD_DIR = Paths.get("C:/uploads/profile");

    public static File getImageFile(String fileParam) {
        if (fileParam == null || fileParam.trim().isEmpty()) {
            return null;
        }

        String fileName = new File(fileParam).getName();

        if (fileName.contains("..")) {
            return null;
        }

        String lower = fileName.toLowerCase();
        boolean allowed = lower.endsWith(".png") || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg") || lower.endsWith(".gif")
                || lower.endsWith(".webp");

        if (!allowed) {
            return null;
        }

        File imageFile = UPLOAD_DIR.resolve(fileName).toFile();

        if (!imageFile.exists() || !imageFile.isFile()) {
            return null;
        }

        return imageFile;
    }

    public static String getContentType(String fileName) {
        String lower = fileName.toLowerCase();

        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".gif")) return "image/gif";
        if (lower.endsWith(".webp")) return "image/webp";

        return "application/octet-stream";
    }
}