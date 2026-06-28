package util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.util.Map;

public class CloudinaryUtil {

    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "doo3ui8xn",
        "api_key", "458121741898811",
        "api_secret", "r5GecXAEy3gS0PetUO9Rn0PblUA"
    ));

    public static String uploadImage(File file, String folder) throws Exception {
        Map result = cloudinary.uploader().upload(file, ObjectUtils.asMap(
            "folder", folder,
            "resource_type", "image"
        ));
        return (String) result.get("secure_url");
    }

    public static void deleteImage(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.asMap("resource_type", "image"));
        } catch (Exception ignore) {}
    }
}