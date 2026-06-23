package util;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.servlet.http.Part;

public class ProfileUploadUtil {

    private static final Path UPLOAD_DIR = Paths.get("C:/uploads/profile");

    public static void ensureUploadDirectoryExists() throws Exception {
        Files.createDirectories(UPLOAD_DIR);
    }

    public static String saveProfileImage(Part filePart, int userId) throws Exception {
        String submitted = getSubmittedFileName(filePart);
        String ext = getExt(submitted).toLowerCase();

        if (!(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp"))) {
            return null;
        }

        String savedFileName = "u" + userId + "_" + System.currentTimeMillis() + ext;
        Path target = UPLOAD_DIR.resolve(savedFileName);

        filePart.write(target.toString());

        return savedFileName;
    }

    public static void deleteProfileImage(String fileName) {
        try {
            if (fileName != null && !fileName.trim().isEmpty()) {
                Files.deleteIfExists(UPLOAD_DIR.resolve(fileName.trim()));
            }
        } catch (Exception ignore) {
        }
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