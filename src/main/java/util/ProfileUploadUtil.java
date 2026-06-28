package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import javax.servlet.http.Part;

public class ProfileUploadUtil {

    private static final String CLOUD_NAME = "doo3ui8xn";
    private static final String API_KEY = "458121741898811";
    private static final String API_SECRET = "r5GecXAEy3gS0PetUO9Rn0PblUA";

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", CLOUD_NAME,
        "api_key", API_KEY,
        "api_secret", API_SECRET
    ));

    private static final Path TEMP_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "profile");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(TEMP_DIR);
    }

    public static String saveProfileImage(Part filePart, int userId) throws Exception {
        String submitted = getSubmittedFileName(filePart);
        String ext = getExt(submitted).toLowerCase();
        if (!(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp"))) {
            return null;
        }

        // Save temp file
        Files.createDirectories(TEMP_DIR);
        String tempName = "u" + userId + "_" + System.currentTimeMillis() + ext;
        Path tempPath = TEMP_DIR.resolve(tempName);
        filePart.write(tempPath.toString());

        // Upload to Cloudinary
        File tempFile = tempPath.toFile();
        Map result = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
            "folder", "profile",
            "public_id", "u" + userId,
            "overwrite", true
        ));

        // Delete temp file
        tempFile.delete();

        return (String) result.get("secure_url");
    }

    public static void deleteProfileImage(String url) {
        // Cloudinary manages deletion separately, skip for now
    }

    public static String getExt(String filename) {
        if (filename == null) return "";
        int i = filename.lastIndexOf('.');
        return (i >= 0) ? filename.substring(i) : "";
    }

    public static String getSubmittedFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return "upload";
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename=")) {
                String fn = token.substring("filename=".length()).trim().replace("\"", "");
                fn = fn.replace("\\", "/");
                int slash = fn.lastIndexOf('/');
                return (slash >= 0) ? fn.substring(slash + 1) : fn;
            }
        }
        return "upload";
    }
}