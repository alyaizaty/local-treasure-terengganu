<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String email = (String) session.getAttribute("email");
    String profilePicture = (String) session.getAttribute("profilePicture");

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
            ? (request.getContextPath() + "/ProfileImageServlet?file=" + java.net.URLEncoder.encode(profilePicture, "UTF-8"))
            : "image/profile.jpeg";

    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Edit Profile</title>
        <link rel="stylesheet" href="css/styles.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root{
                --bg:#f3f4f6;
                --black:#111;
                --muted:#6b7280;
                --shadow:0 10px 24px rgba(0,0,0,.14);
            }
            body{
                background:var(--bg);
                min-height:100vh;
            }
            .wrap{
                max-width:760px;
                margin:24px auto;
                padding:0 14px;
            }
            .card{
                background:#fff;
                border:2px solid var(--black);
                border-radius:18px;
                box-shadow:var(--shadow);
                overflow:hidden;
            }
            .head{
                padding:18px;
                border-bottom:2px solid var(--black);
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:12px;
            }
            .head h2{
                margin:0;
                font-weight:1000;
                display:flex;
                gap:10px;
                align-items:center;
            }
            .content{
                padding:18px;
            }

            .row{
                display:grid;
                grid-template-columns: 170px 1fr;
                gap:16px;
                align-items:start;
            }
            @media(max-width:720px){
                .row{
                    grid-template-columns:1fr;
                }
            }

            .avatar{
                width:150px;
                height:150px;
                border-radius:999px;
                border:4px solid var(--black);
                object-fit:cover;
                background:#fff;
            }

            .field{
                margin-bottom:12px;
            }
            .label{
                font-weight:900;
                margin-bottom:6px;
            }
            .input{
                width:100%;
                padding:12px;
                border-radius:12px;
                border:2px solid var(--black);
                font-weight:800;
            }
            .hint{
                color:var(--muted);
                font-weight:800;
                font-size:13px;
                margin-top:6px;
            }

            .btns{
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                margin-top:12px;
            }

            .btn{
                display:inline-flex;
                gap:10px;
                align-items:center;
                justify-content:center;
                padding:12px 16px;
                border-radius:14px;
                border:2px solid var(--black);
                font-weight:1000;
                cursor:pointer;
                text-decoration:none;
                background:#fff;
                color:#111;
                box-shadow:0 6px 0 var(--black);
            }
            .btn:hover{
                transform:translateY(-2px);
                box-shadow:0 10px 0 var(--black);
            }
            .btnPrimary{
                background:#111;
                color:#fff;
            }
            .btnDanger{
                border-color:#b91c1c;
                color:#b91c1c;
                box-shadow:0 6px 0 #b91c1c;
            }
            .btnDanger:hover{
                background:#b91c1c;
                color:#fff;
            }

            .alert{
                padding:12px 14px;
                border-radius:12px;
                margin-bottom:12px;
                font-weight:900;
            }
            .ok{
                background:#ecfdf5;
                border:1px solid #10b98133;
                color:#065f46;
            }
            .bad{
                background:#fef2f2;
                border:1px solid #ef444433;
                color:#991b1b;
            }

            .divider{
                margin:18px 0;
                border:none;
                border-top:1px solid #eee;
            }
        </style>
    </head>
    <body>

        <div class="wrap">
            <div class="card">
                <div class="head">
                    <h2><i class="fas fa-user-pen"></i> Edit Profile</h2>
                    <a class="btn" href="user_profile.jsp"><i class="fas fa-arrow-left"></i> Back</a>
                </div>

                <div class="content">
                    <% if (msg != null) {%><div class="alert ok"><%= msg%></div><% } %>
                    <% if (err != null) {%><div class="alert bad"><%= err%></div><% }%>

                    <!-- ✅ UPDATE PROFILE FORM -->
                    <form action="<%= request.getContextPath()%>/UpdateProfileServlet"
                          method="post" enctype="multipart/form-data">

                        <div class="row">
                            <div>
                                <img class="avatar" src="<%= profileImgUrl%>" alt="Profile">
                                <div class="hint">Upload gambar baru (optional).</div>
                            </div>

                            <div>
                                <div class="field">
                                    <div class="label">Username</div>
                                    <input class="input" type="text" name="username"
                                           value="<%= username == null ? "" : username%>" required>
                                </div>

                                <div class="field">
                                    <div class="label">Email</div>
                                    <input class="input" type="email" name="email"
                                           value="<%= email == null ? "" : email%>" required>
                                </div>

                                <div class="field">
                                    <div class="label">Profile Picture</div>
                                    <input class="input" type="file" name="profilePicture" accept="image/*">
                                </div>

                                <div class="btns">
                                    <button class="btn btnPrimary" type="submit">
                                        <i class="fas fa-floppy-disk"></i> Save Changes
                                    </button>
                                    <a class="btn" href="user_profile.jsp">
                                        <i class="fas fa-xmark"></i> Cancel
                                    </a>
                                </div>
                            </div>
                        </div>
                    </form>

                    <hr class="divider">

                    <!-- ✅ DELETE ACCOUNT FORM (SEPARATE FORM) -->
                    <form action="<%= request.getContextPath()%>/DeleteAccountServlet"
                          method="post"
                          onsubmit="return confirm('Are you sure? Account akan dipadam terus!')">

                        <button class="btn btnDanger" type="submit">
                            <i class="fas fa-trash"></i> Delete My Account
                        </button>
                    </form>

                </div>
            </div>
        </div>

    </body>
</html>
