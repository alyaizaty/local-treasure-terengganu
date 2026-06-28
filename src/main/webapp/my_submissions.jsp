<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Location Submissions</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .wrap{max-width:900px;margin:22px auto;padding:0 14px;}
        .card{background:#fff;border:2px solid #111;border-radius:16px;box-shadow:0 10px 24px rgba(0,0,0,.12);padding:16px;}
        .title{font-size:22px;font-weight:1000;margin:0 0 10px;}
        .muted{color:#6b7280;font-weight:800;}
        .msg{margin:10px 0;padding:10px 12px;border-radius:12px;background:#ecfdf5;border:1px solid #10b98133;color:#065f46;font-weight:900;}
        .table{width:100%;border-collapse:collapse;margin-top:12px;}
        .table th,.table td{border-top:1px solid #e5e7eb;padding:10px;vertical-align:top;}
        .table th{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:#111;text-align:left;}
        .badge{display:inline-flex;align-items:center;gap:8px;padding:6px 10px;border-radius:999px;border:2px solid #111;font-weight:1000;font-size:12px;}
        .bPending{background:#fff7ed;}
        .bApproved{background:#ecfdf5;}
        .bRejected{background:#fef2f2;}
        .actions{display:flex;gap:8px;flex-wrap:wrap;}
        .btn{display:inline-flex;align-items:center;gap:8px;padding:8px 12px;border-radius:12px;border:2px solid #111;background:#fff;color:#111;text-decoration:none;font-weight:1000;cursor:pointer;}
        .btn:hover{background:#111;color:#fff;}
        .btnDanger{background:#ff4757;color:#fff;border-color:#d63031;}
        .btnDanger:hover{background:#ff6b81;}
        .btnDisabled{opacity:.45;pointer-events:none;}
        .topbar{display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap;}
        .back{display:inline-flex;align-items:center;gap:8px;text-decoration:none;font-weight:1000;color:#111;}
    </style>
</head>
<body>

<div class="wrap">
    <a class="back" href="user_profile.jsp"><i class="fas fa-arrow-left"></i> Back to Profile</a>

    <div class="card" style="margin-top:12px;">
        <div class="topbar">
            <h1 class="title">My Location Submissions</h1>
            <a class="btn" href="submit_location.jsp"><i class="fas fa-plus"></i> Submit New</a>
        </div>
        <div class="muted">You can edit/delete your submission while it is pending.</div>

        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="msg"><%= msg %></div>
        <% } %>

        <table class="table">
            <thead>
            <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Status</th>
                <th>Submitted</th>
                <th style="width:240px;">Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
               try (Connection conn = util.DBConnection.getConnection()) {
                   String sql =
                        "SELECT submission_id, name, category, status, created_at " +
                        "FROM location_submission WHERE user_id=? " +
                        "ORDER BY submission_id DESC";

                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            boolean any = false;
                            while (rs.next()) {
                                any = true;
                                int sid = rs.getInt("submission_id");
                                String name = rs.getString("name");
                                String cat = rs.getString("category");
                                String status = rs.getString("status");
                                String created = rs.getString("created_at");

                                boolean canEdit = "PENDING".equalsIgnoreCase(status) || "REJECTED".equalsIgnoreCase(status);
                                boolean canDelete = canEdit; // ✅ pending/rejected boleh delete
            %>
                <tr>
                    <td><b><%= name %></b></td>
                    <td><%= cat %></td>
                    <td>
                        <%
                            String cls = "badge bPending";
                            if ("APPROVED".equalsIgnoreCase(status)) cls = "badge bApproved";
                            else if ("REJECTED".equalsIgnoreCase(status)) cls = "badge bRejected";
                        %>
                        <span class="<%= cls %>">
                            <i class="fas fa-flag"></i> <%= status %>
                        </span>
                    </td>
                    <td class="muted"><%= created %></td>
                    <td>
                        <div class="actions">
                            <a class="btn <%= canEdit? "" : "btnDisabled" %>"
                               href="edit_submissions.jsp?id=<%= sid %>">
                                <i class="fas fa-pen"></i> Edit
                            </a>

                            <form method="post" action="<%= request.getContextPath() %>/LocationSubmissionActionServlet"
                                  onsubmit="return confirm('Delete this submission?');" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="submissionId" value="<%= sid %>">
                                <button class="btn btnDanger <%= canDelete? "" : "btnDisabled" %>" type="submit">
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </form>
                        </div>
                        <div class="muted" style="margin-top:6px;font-size:12px;">
                            <% if (!canEdit) { %>
                                Approved submission is locked.
                            <% } else { %>
                                You can edit/delete while pending/rejected.
                            <% } %>
                        </div>
                    </td>
                </tr>
            <%
                            }
                            if (!any) {
            %>
                <tr>
                    <td colspan="5" class="muted">No submissions yet. Click “Submit New”.</td>
                </tr>
            <%
                            }
                        }
                    }
                } catch (Exception e) {
            %>
                <tr>
                    <td colspan="5" style="color:red;font-weight:900;">DB Error: <%= e.getMessage() %></td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>

    </div>
</div>

</body>
</html>
