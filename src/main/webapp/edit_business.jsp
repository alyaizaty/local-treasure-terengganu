<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, util.DBConnection" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int businessId = 0;
    String businessName = "";
    String businessDescription = "";
    String businessAddress = "";
    String businessPhone = "";
    String businessHours = "";

    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT business_id, business_name, description, address, contact_phone, operating_hours " +
                     "FROM businesses WHERE user_id = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    businessId = rs.getInt("business_id");
                    businessName = rs.getString("business_name");
                    businessDescription = rs.getString("description");
                    businessAddress = rs.getString("address");
                    businessPhone = rs.getString("contact_phone");
                    businessHours = rs.getString("operating_hours");
                } else {
                    response.sendRedirect("business_dashboard.jsp?err=No business found");
                    return;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("business_dashboard.jsp?err=DB Error");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Business</title>
<style>
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: #f5f5f5;
        margin: 0;
        padding: 0;
        color: #1a1a1a;
    }

    .wrapper {
        max-width: 480px;
        margin: 60px auto;
        padding: 28px 24px;
        background: #ffffff;
        border-radius: 12px;
        border: 1px solid #ccc;
        box-shadow: 0 4px 18px rgba(0,0,0,0.1);
    }

    h1 {
        text-align: center;
        margin-bottom: 24px;
        font-size: 26px;
        font-weight: 700;
    }

    label {
        display: block;
        margin-bottom: 6px;
        font-weight: 600;
    }

    input[type="text"], textarea {
        width: 100%;
        padding: 10px 12px;
        margin-bottom: 16px;
        border-radius: 6px;
        border: 1px solid #aaa;
        background: #fafafa;
        font-size: 14px;
        color: #111;
    }

    textarea {
        resize: vertical;
    }

    .btn {
        padding: 12px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        font-weight: 600;
        transition: 0.2s;
    }

    .btn-submit {
        background: #111;
        color: #fff;
        width: 48%;
    }

    .btn-submit:hover {
        background: #333;
    }

    .btn-cancel {
        background: #fff;
        color: #111;
        border: 1px solid #111;
        width: 48%;
    }

    .btn-cancel:hover {
        background: #111;
        color: #fff;
    }

    .btn-group {
        display: flex;
        justify-content: space-between;
        gap: 12px;
    }

    @media (max-width: 500px) {
        .wrapper { margin: 40px 16px; padding: 20px; }
        .btn-group { flex-direction: column; }
        .btn-submit, .btn-cancel { width: 100%; }
    }
</style>
</head>
<body>

<div class="wrapper">
    <h1>Edit Business</h1>

    <form action="UpdateBusinessServlet" method="post">
        <input type="hidden" name="businessId" value="<%= businessId %>">

        <label>Business Name</label>
        <input type="text" name="name" value="<%= businessName %>" required>

        <label>Description</label>
        <textarea name="description" rows="4"><%= businessDescription %></textarea>

        <label>Address</label>
        <input type="text" name="address" value="<%= businessAddress %>" required>

        <label>Contact Phone</label>
        <input type="text" name="phone" value="<%= businessPhone %>">

        <label>Operating Hours</label>
        <input type="text" name="hours" value="<%= businessHours %>">

        <div class="btn-group">
            <button type="submit" class="btn btn-submit">Update</button>
            <a href="business_dashboard.jsp" class="btn btn-cancel">Cancel</a>
        </div>
    </form>
</div>

</body>
</html>