package util;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL = "jdbc:mysql://b9xplc76zaukrdnkkz9d-mysql.services.clever-cloud.com:3306/b9xplc76zaukrdnkkz9d?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER = "umuittnslrtgekow";
    private static final String PASSWORD = "JKh89OMRtWOHverymFKz";

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}