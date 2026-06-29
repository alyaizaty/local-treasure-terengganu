<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login - Local Treasure Terengganu</title>

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
      --accent2:#111;
      --danger:#ff4757;
    }

    *{ box-sizing:border-box; }
    body{
      margin:0;
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #f3f4f6 0%, #e9eef5 100%);
      min-height:100vh;
    }

    /* ===== HERO ===== */
    .hero{
      background: linear-gradient(120deg, var(--accent) 0%, #111 100%);
      color:#fff;
      padding:48px 18px 70px;
      position:relative;
      overflow:hidden;
    }
    .hero::after{
      content:"";
      position:absolute;
      inset:-90px -90px auto auto;
      width:240px; height:240px;
      background: rgba(255,255,255,.10);
      border-radius:999px;
    }
    .hero .inner{
      max-width:980px;
      margin:0 auto;
      display:flex;
      justify-content:space-between;
      align-items:flex-start;
      gap:16px;
      flex-wrap:wrap;
    }
    .hero h1{
      margin:0;
      font-size:32px;
      font-weight:1000;
      letter-spacing:.5px;
    }
    .hero p{
      margin:10px 0 0;
      max-width:650px;
      opacity:.92;
      font-weight:700;
      line-height:1.6;
    }
    .hero .actions{
      display:flex;
      gap:10px;
      flex-wrap:wrap;
      align-items:center;
    }
    .btnTop{
      display:inline-flex;
      align-items:center;
      gap:10px;
      padding:10px 14px;
      border-radius:14px;
      border:2px solid rgba(255,255,255,.35);
      color:#fff;
      text-decoration:none;
      font-weight:900;
      background: rgba(255,255,255,.08);
      backdrop-filter: blur(10px);
    }
    .btnTop:hover{ background: rgba(255,255,255,.16); }

    /* ===== CARD ===== */
    .wrap{
      max-width:980px;
      margin:-44px auto 34px;
      padding:0 16px;
      position:relative;
      z-index:10;
    }
    .card{
      background:#fff;
      border:2px solid var(--black);
      border-radius:18px;
      box-shadow: var(--shadow);
      overflow:hidden;
      max-width:520px;
      margin:0 auto;
    }
    .cardHead{
      padding:18px;
      border-bottom:2px solid var(--black);
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:10px;
      flex-wrap:wrap;
      background:#fff;
    }
    .cardHead .title{
      display:flex;
      align-items:center;
      gap:10px;
      font-weight:1000;
      font-size:18px;
    }
    .pill{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding:7px 12px;
      border-radius:999px;
      border:2px solid var(--black);
      background:#fff;
      font-weight:1000;
      font-size:12px;
    }

    .cardBody{
      padding:18px;
      background:#f7f7f7;
    }

    .error{
      background:#fef2f2;
      border:2px solid #111;
      border-radius:14px;
      padding:12px 14px;
      color:#991b1b;
      font-weight:900;
      margin-bottom:12px;
      box-shadow: var(--shadow2);
    }

    .field{ margin:12px 0; }
    .label{
      font-weight:1000;
      margin-bottom:6px;
      display:block;
      color:#111;
    }
    .input{
      width:100%;
      padding:12px 12px;
      border-radius:12px;
      border:2px solid #111;
      background:#fff;
      outline:none;
      font-weight:900;
    }
    .input:focus{
      box-shadow: 0 0 0 4px rgba(15,42,69,.14);
    }

    .btn{
      width:100%;
      margin-top:10px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:10px;
      padding:12px 16px;
      border-radius:14px;
      border:2px solid #111;
      background:#111;
      color:#fff;
      font-weight:1000;
      cursor:pointer;
      box-shadow: 0 6px 0 #111;
      transition: .2s;
    }
    .btn:hover{
      transform: translateY(-2px);
      box-shadow: 0 10px 0 #111;
    }

    .foot{
      margin-top:12px;
      text-align:center;
      font-weight:900;
      color:var(--muted);
    }
    .foot a{
      color:#111;
      font-weight:1000;
      text-decoration:underline;
    }

    /* small helper */
    .hint{
      font-size:13px;
      color:var(--muted);
      font-weight:800;
      margin-top:6px;
    }
    @media screen and (max-width: 480px) {
    .hero { padding: 30px 14px 50px; }
    .hero h1 { font-size: 22px; }
    .hero p { font-size: 13px; }
    .hero .actions { gap: 8px; }
    .btnTop { padding: 8px 12px; font-size: 13px; }
    
    .wrap { padding: 0 16px; margin: -30px auto 20px; }
    .card { border-radius: 14px; }
    .cardHead { padding: 14px; }
    .cardBody { padding: 14px; }
    
    .input { padding: 10px 12px; font-size: 14px; }
    .btn { padding: 10px 14px; font-size: 14px; }
    .label { font-size: 14px; }
    .hint { font-size: 12px; }
    .foot { font-size: 13px; }
}
  </style>
</head>

<body>

<section class="hero">
  <div class="inner">
    <div>
      <h1>Welcome Back 👋</h1>
      <p>Sign in to bookmark locations, submit hidden gems, and join the community.</p>
    </div>
    <div class="actions">
      <a class="btnTop" href="index.jsp"><i class="fas fa-arrow-left"></i> Back to Home</a>
      <a class="btnTop" href="sign_up.jsp"><i class="fas fa-user-plus"></i> Sign Up</a>
    </div>
  </div>
</section>

<div class="wrap">
  <div class="card">

    <div class="cardHead">
      <div class="title"><i class="fas fa-right-to-bracket"></i> Login</div>
      <div class="pill"><i class="fas fa-lock"></i> Secure</div>
    </div>

    <div class="cardBody">

      <% String err = (String) request.getAttribute("errorMessage"); %>
      <% if (err != null) { %>
        <div class="error"><i class="fas fa-triangle-exclamation"></i> <%= err %></div>
      <% } %>

      <form method="post" action="<%= request.getContextPath() %>/LoginServlet">
        <div class="field">
          <label class="label">Email</label>
          <input class="input" type="email" name="email" placeholder="e.g. name@email.com" required>
        </div>

        <div class="field">
          <label class="label">Password</label>
          <input class="input" type="password" name="password" placeholder="Enter your password" required>
          <div class="hint">Tip: Make sure Caps Lock is off.</div>
        </div>

        <button class="btn" type="submit">
          <i class="fas fa-right-to-bracket"></i> Sign In
        </button>
      </form>

      <div class="foot">
        Don’t have an account? <a href="sign_up.jsp">Sign up</a>
      </div>

    </div>
  </div>
</div>

</body>
</html>
