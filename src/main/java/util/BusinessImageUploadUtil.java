package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;
import javax.servlet.http.Part;

public class BusinessImageUploadUtil {

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "doo3ui8xn",
        "api_key", "458121741898811",
        "api_secret", "r5GecXAEy3gS0PetUO9Rn0PblUA"
    ));

    private static final Path TEMP_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "business");

    public static void ensureUploadDirectoryExists(String realPath) throws Exception {
        Files.createDirectories(TEMP_DIR);
    }

    public static String saveImage(Part part, String realPath) throws Exception {
        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (fileName == null || fileName.trim().isEmpty()) return null;

        String ext = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex >= 0) ext = fileName.substring(dotIndex).toLowerCase();

        // Save temp file
        Files.createDirectories(TEMP_DIR);
        String tempName = "business_" + UUID.randomUUID().toString() + ext;
        Path tempPath = TEMP_DIR.resolve(tempName);
        part.write(tempPath.toString());

        // Upload to Cloudinary
        File tempFile = tempPath.toFile();
        Map result = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
            "folder", "businesses",
            "public_id", "business_" + UUID.randomUUID().toString().replace("-", ""),
            "overwrite", false
        ));

        // Delete temp file
        tempFile.delete();

        return (String) result.get("secure_url");
    }
}