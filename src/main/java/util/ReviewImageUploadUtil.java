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

public class ReviewImageUploadUtil {

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "doo3ui8xn",
        "api_key", "458121741898811",
        "api_secret", "r5GecXAEy3gS0PetUO9Rn0PblUA"
    ));

    private static final Path TEMP_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "reviews");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(TEMP_DIR);
    }

    public static String saveImage(Part part, int reviewId) throws Exception {
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.trim().isEmpty()) return null;

        String safeName = Paths.get(submitted).getFileName().toString();
        String lower = safeName.toLowerCase();
        String ext;
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) ext = ".jpg";
        else if (lower.endsWith(".png")) ext = ".png";
        else if (lower.endsWith(".webp")) ext = ".webp";
        else if (lower.endsWith(".gif")) ext = ".gif";
        else return null;

        Files.createDirectories(TEMP_DIR);
        String tempName = "review_" + reviewId + "_" + UUID.randomUUID().toString().replace("-", "") + ext;
        Path tempPath = TEMP_DIR.resolve(tempName);
        part.write(tempPath.toString());

        File tempFile = tempPath.toFile();
        Map result = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
            "folder", "reviews",
            "public_id", "review_" + reviewId + "_" + UUID.randomUUID().toString().replace("-", ""),
            "overwrite", false
        ));
        tempFile.delete();

        return (String) result.get("secure_url");
    }

    public static void deleteImages(List<String> files) {
        // Cloudinary manages deletion
    }
}