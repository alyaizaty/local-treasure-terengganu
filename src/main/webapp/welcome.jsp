<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <link rel="stylesheet" href="css/styles.css"> <!-- optional -->
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: #f7f7f7; }
        .welcome-box { background: white; padding: 30px; border-radius: 10px; display: inline-block; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        p { color: #555; }
        a { text-decoration: none; color: #007BFF; }
    </style>
</head>
<body>

<div class="welcome-box">
    <h1>Welcome to Local Treasure Terengganu!</h1>
    <p>Your account has been successfully created.</p>
    <p><a href="login.jsp">Click here to sign in</a></p>
</div>

</body>
</html>
