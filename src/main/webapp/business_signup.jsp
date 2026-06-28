<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String profilePicture = (String) session.getAttribute("profilePicture");
    boolean loggedIn = (userId != null);

    boolean hasPic = (profilePicture != null && !profilePicture.trim().isEmpty());
    String profileImgUrl = hasPic
        ? (request.getContextPath() + "/ProfileImageServlet?file=" + profilePicture)
        : "image/profile.jpeg";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Business Sign Up | Local Treasure Terengganu</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="css/styles.css">
<link rel="stylesheet" href="css/home.css">

<style>
.auth-hero{
    min-height: calc(100vh - 90px);
    padding: 40px 0 30px;
    position: relative;
}
.auth-hero::before{
    content:"";
    position:absolute;
    inset:0;
    background:
        radial-gradient(900px 500px at 20% 10%, rgba(248,196,113,0.35), transparent 60%),
        radial-gradient(900px 500px at 80% 20%, rgba(255,255,255,0.18), transparent 65%),
        linear-gradient(180deg, rgba(15,42,69,0.45), rgba(15,42,69,0.15));
    pointer-events:none;
}

.auth-container{
    position:relative;
    z-index:2;
    max-width:980px;
    margin:0 auto;
    padding:0 16px;
}

.auth-grid{
    display:grid;
    grid-template-columns:1.2fr 1fr;
    gap:18px;
    align-items:start;
}
@media(max-width:900px){
    .auth-grid{ grid-template-columns:1fr; }
}

.intro-card{
    color:#fff;
    padding:22px;
    border-radius:18px;
    border:1px solid rgba(255,255,255,0.18);
    background:rgba(255,255,255,0.10);
    backdrop-filter:blur(12px);
    box-shadow:0 10px 24px rgba(0,0,0,0.18);
}
.intro-card h1{
    margin:0 0 10px;
    font-size:30px;
    font-weight:900;
}
.intro-card p{
    margin:0;
    opacity:.92;
    line-height:1.6;
}
.intro-points{
    margin-top:14px;
    display:grid;
    gap:10px;
}
.point{
    display:flex;
    gap:10px;
    align-items:flex-start;
    background:rgba(255,255,255,0.10);
    border:1px solid rgba(255,255,255,0.14);
    padding:12px;
    border-radius:14px;
}

.form-card{
    background:#fff;
    border-radius:18px;
    padding:18px;
    box-shadow:0 10px 24px rgba(0,0,0,0.12);
}
.form-card h2{
    margin:0 0 6px;
    font-size:22px;
    font-weight:900;
    color:#111827;
}
.form-card .sub{
    margin:0 0 14px;
    color:#6b7280;
    font-weight:700;
}

.form-row{
    display:grid;
    gap:10px;
    margin-bottom:12px;
}
.form-row label{
    font-weight:900;
    color:#111827;
    font-size:13px;
}
.form-row input,
.form-row select,
.form-row textarea{
    width:100%;
    padding:11px 12px;
    border-radius:12px;
    border:1px solid #e5e7eb;
    outline:none;
    font-weight:700;
    background:#fff;
}
.form-row input:focus,
.form-row select:focus,
.form-row textarea:focus{
    border-color:rgba(15,42,69,0.45);
    box-shadow:0 0 0 3px rgba(15,42,69,0.10);
}

.two-col{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:12px;
}
@media(max-width:520px){
    .two-col{ grid-template-columns:1fr; }
}

.btn-primary{
    width:100%;
    display:inline-flex;
    justify-content:center;
    align-items:center;
    gap:10px;
    padding:12px 14px;
    border-radius:12px;
    border:1px solid rgba(0,0,0,0.12);
    background:#0f2a45;
    color:#fff;
    font-weight:900;
    cursor:pointer;
}
.btn-primary:hover{ filter:brightness(0.98); }

.helper{
    margin-top:12px;
    color:#6b7280;
    font-weight:700;
    text-align:center;
}
.helper a{
    font-weight:900;
    color:#667eea;
    text-decoration:none;
}

.alert-success{
    background:#ecfdf5;
    border:1px solid #10b98133;
    color:#065f46;
    padding:10px;
    border-radius:12px;
    margin-bottom:10px;
    font-weight:700;
    text-align:center;
}
.alert-danger{
    background:#fef2f2;
    border:1px solid #ef444433;
    color:#991b1b;
    padding:10px;
    border-radius:12px;
    margin-bottom:10px;
    font-weight:700;
    text-align:center;
}
.footer{ margin-top:0; }
</style>
</head>

<body>

<section class="auth-hero">
    <div class="auth-container">
        <div class="auth-grid">

            <div class="intro-card">
                <h1>Create your business account</h1>
                <p>Join Local Treasure Terengganu to share your business, manage your profile, and reach more explorers.</p>

                <div class="intro-points">
                    <div class="point">
                        <i class="fas fa-store"></i>
                        <div><strong>List Your Business</strong><br>Show your shop and services to locals and tourists.</div>
                    </div>

                    <div class="point">
                        <i class="fas fa-image"></i>
                        <div><strong>Upload Images</strong><br>Attract visitors with photos of your place.</div>
                    </div>

                    <div class="point">
                        <i class="fas fa-star"></i>
                        <div><strong>Get Reviews</strong><br>Receive ratings and feedback to improve visibility.</div>
                    </div>
                </div>
            </div>

            <div class="form-card">
                <h2>Business Sign Up</h2>
                <p class="sub">Fill in all required information below.</p>

                <% if("1".equals(request.getParameter("success"))){ %>
                    <div class="alert-success">Registration successful! Please log in.</div>
                <% } %>

                <% if(request.getParameter("error") != null){ %>
                    <div class="alert-danger"><%= request.getParameter("error") %></div>
                <% } %>

                <form action="businessSignup" method="post" enctype="multipart/form-data">

                    <div class="form-row">
                        <label>Username *</label>
                        <input type="text" name="username" required>
                    </div>

                    <div class="form-row">
                        <label>Email *</label>
                        <input type="email" name="email" required>
                    </div>

                    <div class="two-col">
                        <div class="form-row">
                            <label>Password *</label>
                            <input type="password" name="password" required minlength="6">
                        </div>

                        <div class="form-row">
                            <label>Confirm Password *</label>
                            <input type="password" name="confirmPassword" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <label>Business Name *</label>
                        <input type="text" name="businessName" required>
                    </div>

                    <div class="form-row">
                        <label>Business Image</label>
                        <input type="file" name="businessImage" accept="image/*">
                    </div>

                    <div class="form-row">
                        <label>Description *</label>
                        <textarea name="description" rows="3" required></textarea>
                    </div>

                    <div class="form-row">
                        <label>Address *</label>
                        <input type="text" name="address" required>
                    </div>

                    <div class="form-row">
                        <label>Phone Number *</label>
                        <input type="tel" name="contactPhone" required>
                    </div>

                    <div class="form-row">
                        <label>Operating Hours *</label>
                        <input type="text" name="operatingHours" required>
                    </div>

                    <div class="form-row">
                        <label>Category *</label>
                        <select name="categoryId" required>
                            <option value="">-- Select Category --</option>
                            <%
                                try (Connection conn = util.DBConnection.getConnection()) {
                                    String sql = "SELECT category_id, name FROM categories ORDER BY name ASC";
                                    try(Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)){
                                        while(rs.next()){
                            %>
                                            <option value="<%= rs.getInt("category_id") %>"><%= rs.getString("name") %></option>
                            <%
                                        }
                                    }
                                } catch(Exception e){}
                            %>
                        </select>
                    </div>

                    <button type="submit" class="btn-primary">
                        <i class="fas fa-user-plus"></i> Create Account
                    </button>

                    <div class="helper">
                        Already have an account? <a href="login.jsp">Login</a>
                    </div>

                </form>
            </div>

        </div>
    </div>
</section>

<%@ include file="footer.jsp" %>

</body>
</html>