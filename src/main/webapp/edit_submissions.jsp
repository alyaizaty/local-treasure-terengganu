<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String msg = request.getParameter("msg");

    int sid = 0;
    try { sid = Integer.parseInt(request.getParameter("id")); } catch(Exception e){ sid = 0; }
    if (sid <= 0) { response.sendRedirect("my_submissions.jsp?msg=Invalid+submission"); return; }

    String name="", category="", description="", addressLine="", city="", state="", gmapsLink="", status="";

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ltwbs","root","")) {

        // 1) get submission main data
        String sql = "SELECT * FROM location_submission WHERE submission_id=? AND user_id=? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sid);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("my_submissions.jsp?msg=Submission+not+found");
                    return;
                }
                name = rs.getString("name");
                category = rs.getString("category");
                description = rs.getString("description");
                addressLine = rs.getString("address_line");
                city = rs.getString("city");
                state = rs.getString("state");
                gmapsLink = rs.getString("gmaps_link");
                status = rs.getString("status");
            }
        }

    } catch (Exception e) {
        response.sendRedirect("my_submissions.jsp?msg=DB+Error");
        return;
    }

    // ✅ kalau nak approved boleh edit
    boolean ALLOW_APPROVED_EDIT = true;

    boolean canEdit =
        "PENDING".equalsIgnoreCase(status) ||
        "REJECTED".equalsIgnoreCase(status) ||
        (ALLOW_APPROVED_EDIT && "APPROVED".equalsIgnoreCase(status));

    String disabledAttr = canEdit ? "" : "disabled";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Submission</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body{ background:#f3f4f6; }
        .wrap{max-width:860px;margin:22px auto;padding:0 14px;}
        .card{background:#fff;border:2px solid #111;border-radius:16px;box-shadow:0 10px 24px rgba(0,0,0,.12);padding:18px;}
        .titleRow{display:flex;justify-content:space-between;gap:10px;align-items:flex-start;flex-wrap:wrap;}
        .title{font-size:22px;font-weight:1000;margin:0;}
        .muted{color:#6b7280;font-weight:800;}
        .statusPill{display:inline-flex;gap:8px;align-items:center;padding:6px 10px;border:2px solid #111;border-radius:999px;font-weight:1000;background:#fff;}
        .grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
        @media(max-width:720px){.grid{grid-template-columns:1fr;}}
        label{font-weight:1000;display:block;margin:10px 0 6px;}
        input,textarea{width:100%;padding:10px;border:2px solid #111;border-radius:12px;box-sizing:border-box;}
        textarea{min-height:120px;resize:vertical;}
        .btnRow{display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;}
        .btn{
            display:inline-flex;align-items:center;gap:8px;
            padding:10px 14px;border-radius:12px;border:2px solid #111;
            background:#111;color:#fff;text-decoration:none;font-weight:1000;cursor:pointer;
        }
        .btnLight{background:#fff;color:#111;}
        .btnDanger{background:#ef4444;border-color:#991b1b;}
        .btnDisabled{opacity:.45;pointer-events:none;}
        .note{margin-top:10px;background:#fff7ed;border:2px solid #fb923c;padding:10px;border-radius:12px;font-weight:900;color:#9a3412;}
        .note2{margin-top:10px;background:#ecfdf5;border:2px solid #10b98155;padding:10px;border-radius:12px;font-weight:900;color:#065f46;}
        .msg{margin-top:10px;background:#eef2ff;border:2px solid #6366f1;padding:10px;border-radius:12px;font-weight:900;color:#3730a3;}
    </style>
</head>
<body>

<div class="wrap">
    <div class="card">
        <div class="titleRow">
            <div>
                <h2 class="title"><i class="fas fa-pen"></i> Edit Submission</h2>
                <div class="muted">Update balik location yang kau submit.</div>
            </div>
            <div class="statusPill">
                <i class="fas fa-flag"></i> Status: <%= status %>
            </div>
        </div>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="msg"><%= msg %></div>
        <% } %>

        <% if (!canEdit) { %>
            <div class="note">
                Submission ni locked.
            </div>
        <% } else { %>
            <div class="note2">
                Kau boleh edit & upload gambar baru.
            </div>
        <% } %>

        <!-- UPDATE FORM -->
        <form method="post"
              action="<%= request.getContextPath() %>/LocationSubmissionActionServlet"
              enctype="multipart/form-data"
              style="margin-top:12px;">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="submissionId" value="<%= sid %>">

            <label>Name</label>
            <input type="text" name="name" value="<%= name %>" required <%= disabledAttr %>>

            <div class="grid">
                <div>
                    <label>Category</label>
                    <input type="text" name="category" value="<%= category %>" required <%= disabledAttr %>>
                </div>
                <div>
                    <label>State</label>
                    <input type="text" name="state" value="<%= state %>" required <%= disabledAttr %>>
                </div>
            </div>

            <label>Description</label>
            <textarea name="description" required <%= disabledAttr %>><%= description %></textarea>

            <label>Address Line</label>
            <input type="text" name="addressLine" value="<%= addressLine %>" required <%= disabledAttr %>>

            <div class="grid">
                <div>
                    <label>City</label>
                    <input type="text" name="city" value="<%= city %>" required <%= disabledAttr %>>
                </div>
                <div>
                    <label>Google Maps Link</label>
                    <input type="text" name="gmapsLink" value="<%= gmapsLink %>" required <%= disabledAttr %>>
                </div>
            </div>

            <!-- ✅ IMAGE UPLOAD -->
            <label>Upload New Image (JPG/PNG/WEBP/GIF)</label>
            <input type="file" name="image" accept="image/*" <%= disabledAttr %>>

            <div class="btnRow">
                <a class="btn btnLight" href="<%= request.getContextPath() %>/my_submissions.jsp">
                    <i class="fas fa-arrow-left"></i> Back
                </a>

                <button class="btn <%= canEdit? "" : "btnDisabled" %>" type="submit">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </div>
        </form>

        <!-- DELETE FORM -->
        <form method="post"
              action="<%= request.getContextPath() %>/LocationSubmissionActionServlet"
              style="margin-top:10px;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="submissionId" value="<%= sid %>">
            <button class="btn btnDanger <%= canEdit? "" : "btnDisabled" %>" type="submit"
                    onclick="return confirm('Delete submission ni? Tindakan ni tak boleh undo.');">
                <i class="fas fa-trash"></i> Delete Submission
            </button>
        </form>

    </div>
</div>

</body>
</html>


