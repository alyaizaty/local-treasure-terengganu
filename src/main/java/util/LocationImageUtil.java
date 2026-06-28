package util;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

public class LocationImageUtil {
    private static final Path UPLOAD_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "locations");

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
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".gif")) return "image/gif";
        if (lower.endsWith(".webp")) return "image/webp";
        return "application/octet-stream";
    }
}