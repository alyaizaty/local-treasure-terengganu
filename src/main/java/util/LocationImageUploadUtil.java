package util;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import javax.servlet.http.Part;

public class LocationImageUploadUtil {
    private static final Path UPLOAD_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "locations");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(UPLOAD_DIR);
    }

    public static String saveImage(Part part, int submissionId) throws Exception {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.trim().isEmpty()) {
            return null;
        }
        String safe = Paths.get(submitted).getFileName().toString();
        String lower = safe.toLowerCase();
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
        String fileName = "sub_" + submissionId + "_" +
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
                Files.deleteIfExists(UPLOAD_DIR.resolve(fileName));
            } catch (Exception ignore) {}
        }
    }

    public static void deleteLocationImage(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) return;
        String lower = fileName.trim().toLowerCase();
        if (!(lower.startsWith("sub_") || lower.startsWith("loc_"))) return;
        try {
            Files.deleteIfExists(UPLOAD_DIR.resolve(fileName.trim()));
        } catch (Exception ignore) {}
    }
}