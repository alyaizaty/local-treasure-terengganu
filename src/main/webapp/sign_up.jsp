<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Local Treasure Terengganu</title>

    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <style>
    :root{
        --black:#111;
        --white:#fff;
        --bg:#f3f4f6;
        --muted:#6b7280;
        --shadow:0 12px 28px rgba(0,0,0,.14);
        --shadow2:0 6px 0 #111;
        --accent:#0f2a45;
        --accent2:#ff4757;
    }
    body{ margin:0; font-family:Arial,sans-serif; background:linear-gradient(135deg,#f3f4f6 0%,#e9eef5 100%); min-height:100vh; }
    .hero{ background:linear-gradient(120deg,var(--accent) 0%,#111 100%); color:#fff; padding:48px 18px 70px; position:relative; overflow:hidden; }
    .hero::after{ content:""; position:absolute; inset:-80px -80px auto auto; width:220px; height:220px; background:rgba(255,255,255,.10); border-radius:999px; }
    .hero .inner{ max-width:1100px; margin:0 auto; display:flex; justify-content:space-between; align-items:flex-start; gap:18px; flex-wrap:wrap; }
    .hero h1{ margin:0; font-size:32px; font-weight:1000; letter-spacing:0.5px; }
    .hero p{ margin:10px 0 0; max-width:650px; opacity:.92; font-weight:700; line-height:1.6; }
    .hero .mini-actions{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
    .btnTop{ display:inline-flex; align-items:center; gap:10px; padding:10px 14px; border-radius:14px; border:2px solid rgba(255,255,255,.35); color:#fff; text-decoration:none; font-weight:900; background:rgba(255,255,255,.08); backdrop-filter:blur(10px); }
    .btnTop:hover{ background:rgba(255,255,255,.16); }
    .wrap{ max-width:1100px; margin:-44px auto 30px; padding:0 16px; position:relative; z-index:10; }
    .card{ background:#fff; border:2px solid var(--black); border-radius:18px; box-shadow:var(--shadow); overflow:hidden; }
    .cardHead{ padding:18px; border-bottom:2px solid var(--black); display:flex; justify-content:space-between; align-items:center; gap:10px; flex-wrap:wrap; }
    .cardHead .title{ display:flex; align-items:center; gap:10px; font-weight:1000; font-size:18px; }
    .badge{ display:inline-flex; align-items:center; gap:8px; padding:7px 12px; border-radius:999px; border:2px solid var(--black); background:#fff; font-weight:1000; font-size:12px; }
    .cardBody{ padding:18px; background:#f7f7f7; }
    .grid{ display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:16px; }
    .roleBox{ background:#fff; border:2px solid var(--black); border-radius:16px; padding:18px; box-shadow:var(--shadow2); transition:0.2s; display:flex; flex-direction:column; gap:10px; }
    .roleBox:hover{ transform:translateY(-2px); box-shadow:0 10px 0 #111; }
    .roleTop{ display:flex; align-items:flex-start; justify-content:space-between; gap:10px; }
    .roleIcon{ width:44px; height:44px; border-radius:14px; border:2px solid var(--black); display:grid; place-items:center; font-size:18px; background:#fff; }
    .roleName{ margin:0; font-size:18px; font-weight:1000; }
    .roleTag{ display:inline-flex; align-items:center; gap:8px; padding:6px 10px; border-radius:999px; border:2px solid var(--black); font-weight:1000; font-size:12px; background:#f3f4f6; }
    .roleDesc{ margin:0; color:var(--muted); font-weight:800; line-height:1.6; }
    .roleList{ margin:0; padding-left:18px; color:#111; font-weight:800; }
    .roleList li{ margin:7px 0; }
    .btnSignup{ margin-top:6px; display:inline-flex; align-items:center; justify-content:center; gap:10px; padding:12px 16px; border-radius:14px; border:2px solid var(--black); background:#fff; color:#111; font-weight:1000; text-decoration:none; box-shadow:0 6px 0 #111; transition:0.2s; }
    .btnSignup:hover{ transform:translateY(-2px); box-shadow:0 10px 0 #111; }
    .btnPrimary{ background:var(--accent); color:#fff; }
    .btnDanger{ background:var(--accent2); color:#fff; }
    .bottomLink{ margin-top:18px; text-align:center; font-weight:900; color:var(--muted); }
    .bottomLink a{ color:#111; text-decoration:underline; font-weight:1000; }

    @media(max-width:480px){
        .grid{ grid-template-columns:1fr; gap:12px; }
        .wrap{ padding:0 20px; margin:-30px auto 20px; }
        .roleBox{ padding:14px; gap:8px; }
        .roleName{ font-size:16px; }
        .roleTag{ font-size:11px; padding:4px 8px; }
        .roleDesc{ font-size:13px; }
        .roleList{ font-size:12px; padding-left:16px; }
        .roleList li{ margin:4px 0; }
        .btnSignup{ padding:10px 14px; font-size:13px; }
        .roleIcon{ width:38px; height:38px; font-size:16px; }
        .hero{ padding:30px 20px 50px; }
        .hero h1{ font-size:22px; }
        .hero p{ font-size:13px; }
        .cardHead{ padding:14px; }
        .cardBody{ padding:14px; }
    }
</style>
</head>

<body>

<!-- ===== HERO ===== -->
<section class="hero">
    <div class="inner">
        <div>
            <h1>Join Local Treasure Terengganu ✨</h1>
            <p>Choose your account type to get started. Explore hidden gems, bookmark favourites, and contribute new locations for approval.</p>
        </div>

        <div class="mini-actions">
            <a class="btnTop" href="index.jsp">
                <i class="fas fa-arrow-left"></i> Back to Home
            </a>
            <a class="btnTop" href="login.jsp">
                <i class="fas fa-right-to-bracket"></i> Login
            </a>
        </div>
    </div>
</section>

<!-- ===== MAIN CARD ===== -->
<div class="wrap">
    <div class="card">

        <div class="cardHead">
            <div class="title">
                <i class="fas fa-user-plus"></i>
                Choose Account Type
            </div>
            <div class="badge">
                <i class="fas fa-shield-halved"></i> Secure Signup
            </div>
        </div>

        <div class="cardBody">

            <div class="grid">

                <!-- Tourist Account -->
                <div class="roleBox">
                    <div class="roleTop">
                        <div style="display:flex; gap:12px; align-items:flex-start;">
                            <div class="roleIcon">
                                <i class="fas fa-map-location-dot"></i>
                            </div>
                            <div>
                                <h3 class="roleName">Tourist Account</h3>
                                <div class="roleTag"><i class="fas fa-compass"></i> Explore & Discover</div>
                            </div>
                        </div>
                    </div>

                    <p class="roleDesc">
                        Perfect for visitors who want to explore, review places, and share hidden gems with others.
                    </p>

                    <ul class="roleList">
                        <li>Browse and explore attractions</li>
                        <li>Write reviews and ratings</li>
                        <li>Bookmark favourite locations</li>
                        <li>Submit new locations (approval required)</li>
                        <li>Interact with the community</li>
                    </ul>

                    <a href="tourist_signup.jsp" class="btnSignup btnPrimary">
                        <i class="fas fa-plane-departure"></i> Sign up as Tourist
                    </a>
                </div>

                <!-- Business Account -->
                <div class="roleBox">
                    <div class="roleTop">
                        <div style="display:flex; gap:12px; align-items:flex-start;">
                            <div class="roleIcon">
                                <i class="fas fa-store"></i>
                            </div>
                            <div>
                                <h3 class="roleName">Business Account</h3>
                                <div class="roleTag"><i class="fas fa-bullhorn"></i> Promote Your Business</div>
                            </div>
                        </div>
                    </div>

                    <p class="roleDesc">
                        For local businesses who want to promote their places, engage with tourists, and grow visibility.
                    </p>

                    <ul class="roleList">
                        <li>Create business profile</li>
                        <li>Upload promotional content</li>
                        <li>Respond to reviews</li>
                        <li>Add special offers & events</li>
                        <li>Manage business information</li>
                    </ul>

                    <a href="business_signup.jsp" class="btnSignup btnDanger">
                        <i class="fas fa-briefcase"></i> Sign up as Business
                    </a>
                </div>

            </div>

            <div class="bottomLink">
                Already signed up? <a href="login.jsp">Log in</a>
            </div>

        </div>
    </div>
</div>



</body>
</html>
