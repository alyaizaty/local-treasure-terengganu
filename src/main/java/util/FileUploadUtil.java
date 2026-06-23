package util;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.servlet.http.Part;

public class FileUploadUtil {

    private static final Path UPLOAD_DIR = Paths.get("C:/uploads/profile");

    public static Path getUploadDir() {
        return UPLOAD_DIR;
    }

    public static void createUploadDirectory() throws Exception {
        Files.createDirectories(UPLOAD_DIR);
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

        String savedFileName = "u_signup_" + System.currentTimeMillis() + ext;
        Path target = UPLOAD_DIR.resolve(savedFileName);

        filePart.write(target.toString());
        return savedFileName;
    }

    public static void deleteProfileImage(String fileName) {
        try {
            Files.deleteIfExists(UPLOAD_DIR.resolve(fileName));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}