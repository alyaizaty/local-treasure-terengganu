package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import javax.servlet.http.Part;

public class FileUploadUtil {

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "doo3ui8xn",
        "api_key", "458121741898811",
        "api_secret", "r5GecXAEy3gS0PetUO9Rn0PblUA"
    ));

    private static final Path TEMP_DIR = Paths.get(System.getProperty("java.io.tmpdir"), "uploads", "profile");

    public static Path getUploadDir() { return TEMP_DIR; }

    public static void createUploadDirectory() throws Exception {
        Files.createDirectories(TEMP_DIR);
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

    public static String getExtension(String filename) {
        if (filename == null) return "";
        int i = filename.lastIndexOf('.');
        return (i >= 0) ? filename.substring(i) : "";
    }

    public static boolean isAllowedImageExtension(String ext) {
        ext = ext.toLowerCase();
        return ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg")
                || ext.equals(".webp") || ext.equals(".gif");
    }

    public static boolean isImageContentType(String contentType) {
        return contentType != null && contentType.toLowerCase().startsWith("image/");
    }

    public static String saveProfileImage(Part filePart) throws Exception {
        String submitted = getSubmittedFileName(filePart);
        String ext = getExtension(submitted).toLowerCase();

        Files.createDirectories(TEMP_DIR);
        String tempName = "signup_" + System.currentTimeMillis() + ext;
        Path tempPath = TEMP_DIR.resolve(tempName);
        filePart.write(tempPath.toString());

        File tempFile = tempPath.toFile();
        Map result = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
            "folder", "profile",
            "public_id", "signup_" + System.currentTimeMillis(),
            "overwrite", false
        ));
        tempFile.delete();

        return (String) result.get("secure_url");
    }

    public static void deleteProfileImage(String url) {
        // Cloudinary manages deletion
    }
}