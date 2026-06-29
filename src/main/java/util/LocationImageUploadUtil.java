package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.servlet.http.Part;

public class LocationImageUploadUtil {

    private static final String CLOUD_NAME = "doo3ui8xn";
    private static final String API_KEY = "458121741898811";
    private static final String API_SECRET = "r5GecXAEy3gS0PetUO9Rn0PblUA";

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", CLOUD_NAME,
        "api_key", API_KEY,
        "api_secret", API_SECRET
    ));

    private static final Path TEMP_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "locations");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(TEMP_DIR);
    }

    public static String saveImage(Part part, int submissionId) throws Exception {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.trim().isEmpty()) return null;

        String safe = Paths.get(submitted).getFileName().toString();
        String lower = safe.toLowerCase();
        String ext;
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) ext = ".jpg";
        else if (lower.endsWith(".png")) ext = ".png";
        else if (lower.endsWith(".webp")) ext = ".webp";
        else if (lower.endsWith(".gif")) ext = ".gif";
        else return null;

        // Save temp file
        Files.createDirectories(TEMP_DIR);
        String tempName = "sub_" + submissionId + "_" + UUID.randomUUID().toString().replace("-", "") + ext;
        Path tempPath = TEMP_DIR.resolve(tempName);
        part.write(tempPath.toString());

        // Upload to Cloudinary
        File tempFile = tempPath.toFile();
        Map result = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
            "folder", "locations",
            "public_id", "sub_" + submissionId + "_" + UUID.randomUUID().toString().replace("-", ""),
            "overwrite", false
        ));

        // Delete temp file
        tempFile.delete();

        return (String) result.get("secure_url");
    }

    public static void deleteImages(List<String> files) {
        // Cloudinary manages deletion separately
    }

    public static void deleteLocationImage(String fileName) {
        // Cloudinary manages deletion separately
    }
}