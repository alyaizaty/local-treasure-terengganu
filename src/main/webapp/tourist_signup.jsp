<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up | Local Treasure Terengganu</title>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- CSS (guna yang sama macam page lain) -->
        <link rel="stylesheet" href="css/styles.css">
        <link rel="stylesheet" href="css/home.css">

        <style>
            /* ===== Guest badge (sama macam home) ===== */
            .nav-guest{
                display:inline-flex;
                align-items:center;
                gap:8px;
                color:#fff;
                font-weight:700;
            }
            .guest-badge{
                width:32px;
                height:32px;
                border-radius:50%;
                display:grid;
                place-items:center;
                background:rgba(255,255,255,0.18);
                border:2px solid #f8c471;
                font-weight:800;
            }
            .guest-text{
                opacity:.9;
            }

            /* ===== Page hero / background vibe ===== */
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
                max-width: 980px;
                margin: 0 auto;
                padding: 0 16px;
            }
            .auth-grid{
                display:grid;
                grid-template-columns: 1.2fr 1fr;
                gap: 18px;
                align-items: start;
            }
            @media (max-width: 900px){
                .auth-grid{
                    grid-template-columns: 1fr;
                }
            }

            /* ===== Left intro card ===== */
            .intro-card{
                color:#fff;
                padding: 22px;
                border-radius: 18px;
                border: 1px solid rgba(255,255,255,0.18);
                background: rgba(255,255,255,0.10);
                backdrop-filter: blur(12px);
                -webkit-backdrop-filter: blur(12px);
                box-shadow: 0 10px 24px rgba(0,0,0,0.18);
            }
            .intro-card h1{
                margin:0 0 10px;
                font-size: 30px;
                font-weight: 900;
            }
            .intro-card p{
                margin:0;
                opacity:.92;
                line-height: 1.6;
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
                background: rgba(255,255,255,0.10);
                border: 1px solid rgba(255,255,255,0.14);
                padding: 12px 12px;
                border-radius: 14px;
            }
            .point i{
                margin-top:2px;
            }

            /* ===== Form card ===== */
            .form-card{
                background:#fff;
                border-radius: 18px;
                padding: 18px;
                box-shadow: 0 10px 24px rgba(0,0,0,0.12);
            }
            .form-card h2{
                margin: 0 0 6px;
                font-size: 22px;
                font-weight: 900;
                color:#111827;
            }
            .form-card .sub{
                margin: 0 0 14px;
                color:#6b7280;
                font-weight: 700;
                line-height: 1.5;
            }

            .form-row{
                display:grid;
                gap: 10px;
                margin-bottom: 12px;
            }
            .form-row label{
                font-weight: 900;
                color:#111827;
                font-size: 13px;
            }
            .form-row input,
            .form-row select{
                width:100%;
                padding: 11px 12px;
                border-radius: 12px;
                border: 1px solid #e5e7eb;
                outline:none;
                font-weight: 700;
                background:#fff;
            }
            .form-row input:focus,
            .form-row select:focus{
                border-color: rgba(15,42,69,0.45);
                box-shadow: 0 0 0 3px rgba(15,42,69,0.10);
            }

            .two-col{
                display:grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
            }
            @media (max-width: 520px){
                .two-col{
                    grid-template-columns: 1fr;
                }
            }

            .btn-primary{
                width:100%;
                display:inline-flex;
                justify-content:center;
                align-items:center;
                gap:10px;
                padding: 12px 14px;
                border-radius: 12px;
                border: 1px solid rgba(0,0,0,0.12);
                background:#0f2a45;
                color:#fff;
                font-weight: 900;
                cursor:pointer;
            }
            .btn-primary:hover{
                filter: brightness(0.98);
            }

            .helper{
                margin-top: 12px;
                color:#6b7280;
                font-weight: 700;
                text-align:center;
            }
            .helper a{
                font-weight: 900;
            }

            /* Footer spacing fix */
            .footer{
                margin-top: 0;
            }
        </style>
    </head>

    <body>

        <!-- ===== NAVBAR ===== -->
        <nav class="navbar">
            <div class="container navbar-container">

                <div class="navbar-left">
                    <a href="index.jsp" class="nav-link">Explore</a>
                    <a href="bookmark.jsp" class="nav-link">Bookmark</a>
                    <a href="treasures.jsp" class="nav-link">Treasures</a>
                </div>

                <a href="index.jsp" class="navbar-brand">
                    <div class="brand-main">Local Treasure Terengganu</div>
                    <div class="brand-sub">DISCOVER THE HIDDEN GEMS</div>
                </a>

                <div class="navbar-right">
                    <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>
                    <a href="about.jsp" class="nav-link">About</a>

                    <% if (loggedIn) {%>
                    <a href="user_profile.jsp" class="nav-profile">
                        <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                        <span><%= (username == null ? "Profile" : username)%></span>
                    </a>
                    <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
                    <% } else { %>
                    <div class="nav-guest">
                        <div class="guest-badge">G</div>
                        <span class="guest-text">Guest</span>
                    </div>
                    <a href="login.jsp" class="nav-link">Login</a>
                    <a href="sign_up.jsp" class="nav-link active">Sign Up</a>
                    <% } %>
                </div>

                <button class="navbar-toggle" id="navbarToggle" type="button">
                    <i class="fas fa-bars"></i>
                </button>
            </div>

            <div class="navbar-mobile-menu" id="navbarMobileMenu">
                <a href="index.jsp" class="nav-link">Explore</a>
                <a href="bookmark.jsp" class="nav-link">Bookmark</a>
                <a href="treasures.jsp" class="nav-link">Treasures</a>
                <a href="plan-visit.jsp" class="nav-link">Plan Visit</a>
                <a href="about.jsp" class="nav-link">About</a>

                <% if (loggedIn) {%>
                <a href="user_profile.jsp" class="nav-profile">
                    <img src="<%= profileImgUrl%>" alt="Profile" class="nav-profile-img">
                    <span><%= (username == null ? "Profile" : username)%></span>
                </a>
                <a href="<%= request.getContextPath()%>/LogoutServlet" class="nav-link">Logout</a>
                <% } else { %>
                <div class="nav-guest" style="padding:10px 0;">
                    <div class="guest-badge">G</div>
                    <span class="guest-text">Guest</span>
                </div>
                <a href="login.jsp" class="nav-link">Login</a>
                <a href="sign_up.jsp" class="nav-link active">Sign Up</a>
                <% }%>
            </div>
        </nav>

        <!-- ===== CONTENT ===== -->
        <section class="auth-hero">
            <div class="auth-container">
                <div class="auth-grid">

                    <!-- LEFT: intro -->
                    <div class="intro-card">
                        <h1>Create your account</h1>
                        <p>
                            Join Local Treasure Terengganu to bookmark places, share reviews, and discover hidden gems.
                        </p>

                        <div class="intro-points">
                            <div class="point">
                                <i class="fas fa-bookmark"></i>
                                <div>
                                    <div style="font-weight:900;">Save bookmarks</div>
                                    <div style="opacity:.9; line-height:1.45;">Keep your favourite locations and view them anytime.</div>
                                </div>
                            </div>
                            <div class="point">
                                <i class="fas fa-star"></i>
                                <div>
                                    <div style="font-weight:900;">Write reviews</div>
                                    <div style="opacity:.9; line-height:1.45;">Share experience + upload photos in one post.</div>
                                </div>
                            </div>
                            <div class="point">
                                <i class="fas fa-map-marker-alt"></i>
                                <div>
                                    <div style="font-weight:900;">Explore more</div>
                                    <div style="opacity:.9; line-height:1.45;">Discover new spots recommended by locals.</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT: form -->
                    <div class="form-card">
                        <h2>Sign Up</h2>
                        <p class="sub">Choose your account type and fill in the details.</p>

                        <form action="UserSignUpServlet" method="post" enctype="multipart/form-data">
                            <div class="form-row">
                                <label for="username">Username *</label>
                                <input type="text" id="username" name="username" required>
                            </div>

                            <div class="form-row">
                                <label for="email">Email Address *</label>
                                <input type="email" id="email" name="email" required>
                            </div>

                            <div class="two-col">
                                <div class="form-row">
                                    <label for="password">Password *</label>
                                    <input type="password" id="password" name="password" required minlength="6">
                                </div>

                                <div class="form-row">
                                    <label for="confirmPassword">Confirm Password *</label>
                                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                                </div>
                            </div>

                            <div class="form-row">
                                <label for="role">Role *</label>
                                <select id="role" name="role" required>
                                    <option value="Tourist">Tourist</option>
                                  
                                </select>
                            </div>

                            <div class="form-row">
                                <label for="profilePicture">Profile Picture *</label>
                                <input type="file" id="profilePicture" name="profilePicture" accept="image/*" required>
                            </div>

                            <button class="btn-primary" type="submit">
                                <i class="fas fa-user-plus"></i>
                                Create Account
                            </button>

                            <div class="helper">
                                Already have an account? <a href="login.jsp">Login</a>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </section>

        <!-- ===== FOOTER (ikut template kau) ===== -->
        <footer class="footer">
            <div class="container">
                <div class="footer-inner">
                    <div class="footer-logo">
                        <h1>Local Treasure Terengganu</h1>
                        <p>Your guide to discovering the best local treasures in Terengganu. Explore hidden gems, cultural sites, and natural wonders.</p>
                    </div>

                    <div class="footer-links">
                        <a href="index.jsp">Home</a>
                        <a href="treasures.jsp">Treasures</a>
                        <a href="about.jsp">About Us</a>
                        <a href="plan-visit.jsp">Plan Your Visit</a>
                        <a href="bookmark.jsp">Bookmarks</a>
                        <a href="contact.jsp">Contact Us</a>
                    </div>

                    <div class="footer-contact">
                        <strong>Contact Information</strong>
                        <address>Kompleks Yayasan Islam Terengganu, 20200 Kuala Terengganu, Terengganu, Malaysia</address>
                        <p><i class="fas fa-phone"></i> +60 9-622 1433</p>
                        <p><i class="fas fa-envelope"></i> info@terengganu-treasure.my</p>
                    </div>
                </div>

                <div class="footer-bottom">
                    <span>© <%= java.time.Year.now()%> Local Treasure Terengganu. All rights reserved.</span>
                </div>
            </div>
        </footer>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const navbarToggle = document.getElementById('navbarToggle');
                const navbarMobileMenu = document.getElementById('navbarMobileMenu');

                if (navbarToggle && navbarMobileMenu) {
                    navbarToggle.addEventListener('click', function (e) {
                        e.stopPropagation();
                        navbarMobileMenu.classList.toggle('active');
                    });
                }

                document.addEventListener('click', function (event) {
                    if (!event.target.closest('.navbar-container') && !event.target.closest('.navbar-mobile-menu')) {
                        navbarMobileMenu.classList.remove('active');
                    }
                });

                // simple password confirm check (frontend)
                const pass = document.getElementById('password');
                const confirm = document.getElementById('confirmPassword');
                function validate() {
                    if (confirm.value && pass.value !== confirm.value) {
                        confirm.setCustomValidity("Password not match");
                    } else {
                        confirm.setCustomValidity("");
                    }
                }
                pass.addEventListener('input', validate);
                confirm.addEventListener('input', validate);
            });
        </script>

    </body>
</html>
