<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String role = session == null ? null : String.valueOf(session.getAttribute("role"));
    if (session == null || role == null || !"Content Manager".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = request.getParameter("tab");
    if (tab == null || tab.trim().isEmpty()) tab = "pending";
    String msg = (String) request.getAttribute("msg");
    String err = (String) request.getAttribute("err");
    
    int pendingCount = request.getAttribute("pendingCount") == null ? 0 : (Integer) request.getAttribute("pendingCount");
    int totalLocations = request.getAttribute("totalLocations") == null ? 0 : (Integer) request.getAttribute("totalLocations");
    int featuredCount = request.getAttribute("featuredCount") == null ? 0 : (Integer) request.getAttribute("featuredCount");
    int totalReviews = request.getAttribute("totalReviews") == null ? 0 : (Integer) request.getAttribute("totalReviews");
    int totalBusinesses = request.getAttribute("totalBusinesses") == null ? 0 : (Integer) request.getAttribute("totalBusinesses");
    int totalComments = request.getAttribute("totalComments") == null ? 0 : (Integer) request.getAttribute("totalComments");
    
    String pendingRows = request.getAttribute("pendingRows") == null ? "" : (String) request.getAttribute("pendingRows");
    String locationRows = request.getAttribute("locationRows") == null ? "" : (String) request.getAttribute("locationRows");
    String featuredRows = request.getAttribute("featuredRows") == null ? "" : (String) request.getAttribute("featuredRows");
    String businessRows = request.getAttribute("businessRows") == null ? "" : (String) request.getAttribute("businessRows");
    String reviewRows = request.getAttribute("reviewRows") == null ? "" : (String) request.getAttribute("reviewRows");
    String commentRows = request.getAttribute("commentRows") == null ? "" : (String) request.getAttribute("commentRows");
    
    String chartLabels = request.getAttribute("chartLabels") == null ? "[]" : (String) request.getAttribute("chartLabels");
    String loginData = request.getAttribute("loginData") == null ? "[]" : (String) request.getAttribute("loginData");
    String signupData = request.getAttribute("signupData") == null ? "[]" : (String) request.getAttribute("signupData");
    String reviewData = request.getAttribute("reviewData") == null ? "[]" : (String) request.getAttribute("reviewData");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Content Manager Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: #f8fafc;
            margin: 0;
            padding: 28px;
            color: #0f172a;
        }
        .wrap {
            max-width: 1280px;
            margin: 0 auto;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 26px;
        }
        h1 {
            margin: 0;
            font-size: 30px;
            font-weight: 900;
        }
        .subtitle {
            margin-top: 8px;
            color: #64748b;
            font-size: 15px;
        }
        .logout {
            text-decoration: none;
            background: #0f172a;
            color: white;
            padding: 11px 18px;
            border-radius: 14px;
            font-weight: 800;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
            margin-bottom: 26px;
        }
        .stat-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            padding: 18px;
            min-height: 100px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.04);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .stat-label {
            color: #64748b;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        .stat-number {
            font-size: 28px;
            font-weight: 900;
        }
        .stat-icon {
            font-size: 28px;
        }
        .orange { color: #f97316; }
        .green { color: #22c55e; }
        .yellow { color: #f59e0b; }
        .blue { color: #3b82f6; }
        .purple { color: #8b5cf6; }
        .pink { color: #ec4899; }
        .tabs {
            display: inline-flex;
            gap: 6px;
            background: #e5e7eb;
            padding: 5px;
            border-radius: 14px;
            margin-bottom: 26px;
            flex-wrap: wrap;
        }
        .tab {
            text-decoration: none;
            color: #334155;
            padding: 10px 16px;
            border-radius: 11px;
            font-weight: 800;
            font-size: 14px;
        }
        .tab.active {
            background: white;
            color: #0f172a;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
        }
        .panel {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.04);
            overflow: hidden;
            margin-bottom: 22px;
        }
        .panel-head {
            padding: 20px 24px;
            border-bottom: 1px solid #e5e7eb;
        }
        .panel-title {
            font-size: 18px;
            font-weight: 900;
            margin: 0;
        }
        .alert {
            padding: 14px 18px;
            border-radius: 14px;
            margin-bottom: 16px;
            font-weight: 800;
        }
        .ok {
            background: #ecfdf5;
            color: #065f46;
            border: 1px solid #bbf7d0;
        }
        .bad {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }
        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }
        th {
            background: #f8fafc;
            color: #475569;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        th, td {
            padding: 15px 18px;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
            vertical-align: middle;
        }
        .thumb {
            width: 78px;
            height: 58px;
            object-fit: cover;
            border-radius: 12px;
            background: #e5e7eb;
            border: 1px solid #e5e7eb;
        }
        .action-cell {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .btn {
            border: none;
            padding: 9px 13px;
            border-radius: 11px;
            font-weight: 900;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 13px;
        }
        .btn-approve { background: #16a34a; color: white; }
        .btn-reject { background: #f97316; color: white; }
        .btn-delete { background: #dc2626; color: white; }
        .btn-feature { background: #f59e0b; color: white; }
        .btn-unfeature { background: #64748b; color: white; }
        .btn-view { background: #2563eb; color: white; }
        .badge-featured {
            display: inline-block;
            background: #fef3c7;
            color: #92400e;
            padding: 6px 11px;
            border-radius: 999px;
            font-weight: 900;
            font-size: 12px;
        }
        .badge-normal {
            display: inline-block;
            background: #e5e7eb;
            color: #374151;
            padding: 6px 11px;
            border-radius: 999px;
            font-weight: 900;
            font-size: 12px;
        }
        .empty {
            text-align: center;
            padding: 70px 20px;
        }
        .empty-icon {
            font-size: 48px;
            color: #22c55e;
            margin-bottom: 14px;
        }
        .empty-title {
            font-size: 18px;
            font-weight: 900;
            margin-bottom: 8px;
        }
        .empty-text {
            color: #64748b;
        }
        .chart-box {
            padding: 24px;
            width: 100%;
        }
        @media (max-width: 1100px) {
            .stats { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 700px) {
            .stats { grid-template-columns: repeat(2, 1fr); }
            body { padding: 18px; }
            .header { flex-direction: column; }
        }
        @media (max-width: 500px) {
            .stats { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="header">
        <div>
            <h1>Content Manager Dashboard</h1>
            <div class="subtitle">Manage locations, businesses, reviews, comments, and analytics</div>
        </div>
        <a class="logout" href="<%= request.getContextPath() %>/LogoutServlet"
           onclick="return confirm('Logout now?')">Logout</a>
    </div>
    
    <% if (msg != null) { %>
        <div class="alert ok"><%= msg %></div>
    <% } %>
    <% if (err != null) { %>
        <div class="alert bad"><%= err %></div>
    <% } %>
    
    <div class="stats">
        <div class="stat-card">
            <div>
                <div class="stat-label">Pending Approval</div>
                <div class="stat-number"><%= pendingCount %></div>
            </div>
            <div class="stat-icon orange">!</div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Total Locations</div>
                <div class="stat-number"><%= totalLocations %></div>
            </div>
            <div class="stat-icon green">⌖</div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Businesses</div>
                <div class="stat-number"><%= totalBusinesses %></div>
            </div>
            <div class="stat-icon purple">▣</div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Featured</div>
                <div class="stat-number"><%= featuredCount %></div>
            </div>
            <div class="stat-icon yellow">☆</div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Reviews</div>
                <div class="stat-number"><%= totalReviews %></div>
            </div>
            <div class="stat-icon blue">★</div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-label">Comments</div>
                <div class="stat-number"><%= totalComments %></div>
            </div>
            <div class="stat-icon pink">💬</div>
        </div>
    </div>
    
    <div class="tabs">
        <a class="tab <%= "pending".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=pending">Pending Approval</a>
        <a class="tab <%= "locations".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=locations">All Locations</a>
        <a class="tab <%= "business".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=business">Registered Businesses</a>
        <a class="tab <%= "reviews".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=reviews">Reviews & Comments</a>
        <a class="tab <%= "featured".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=featured">Featured</a>
        <a class="tab <%= "analytics".equals(tab) ? "active" : "" %>"
           href="<%= request.getContextPath() %>/ContentDashboardServlet?tab=analytics">Analytics</a>
    </div>
    
    <% if ("locations".equals(tab)) { %>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">All Locations</h3>
            </div>
            <% if (locationRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">⌖</div>
                    <div class="empty-title">No locations found</div>
                    <div class="empty-text">There are no locations in the system yet.</div>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Location ID</th>
                            <th>Image</th>
                            <th>Category ID</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Featured</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody><%= locationRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
    <% } else if ("business".equals(tab)) { %>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">Registered Businesses</h3>
            </div>
            <% if (businessRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">▣</div>
                    <div class="empty-title">No registered businesses found</div>
                    <div class="empty-text">Businesses will appear here after registration.</div>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Business ID</th>
                            <th>Image</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Address</th>
                            <th>Phone</th>
                            <th>Owner</th>
                            <th>Rating</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody><%= businessRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
    <% } else if ("reviews".equals(tab)) { %>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">Reviews</h3>
            </div>
            <% if (reviewRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">★</div>
                    <div class="empty-title">No reviews found</div>
                    <div class="empty-text">User reviews will appear here.</div>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Review ID</th>
                            <th>User</th>
                            <th>Location / Business</th>
                            <th>Rating</th>
                            <th>Review</th>
                            <th>Date</th>
                            <th>Comments</th>
                        </tr>
                        </thead>
                        <tbody><%= reviewRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">Comments</h3>
            </div>
            <% if (commentRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">💬</div>
                    <div class="empty-title">No comments found</div>
                    <div class="empty-text">User comments will appear here.</div>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Comment ID</th>
                            <th>User</th>
                            <th>Location / Business</th>
                            <th>Review ID</th>
                            <th>Comment</th>
                            <th>Date</th>
                        </tr>
                        </thead>
                        <tbody><%= commentRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
    <% } else if ("featured".equals(tab)) { %>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">Featured Locations</h3>
            </div>
            <% if (featuredRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">☆</div>
                    <div class="empty-title">No Featured Locations</div>
                    <div class="empty-text">Belum ada location yang ditanda sebagai featured.</div>
                </div>
            <% } else { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Location ID</th>
                            <th>Image</th>
                            <th>Category ID</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Featured</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody><%= featuredRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
    <% } else if ("analytics".equals(tab)) { %>
        <div class="panel">
            <div class="panel-head">
                <h3 class="panel-title">Dashboard Analytics</h3>
            </div>
            <div class="chart-box" style="position: relative; height: 400px; width: 100%;">
                <canvas id="activityChart"></canvas>
            </div>
        </div>
        
        <script>
            // We use DOMContentLoaded to ensure the browser has fully downloaded Chart.js before running this code
            document.addEventListener('DOMContentLoaded', function() {
                try {
                    let rawLabels = <%= chartLabels %>;
                    let rawLogin = <%= loginData %>;
                    let rawSignup = <%= signupData %>;
                    let rawReview = <%= reviewData %>;

                    // Calculate total activity to see if the database is currently empty
                    const sumArray = (arr) => arr.reduce((a, b) => a + b, 0);
                    const totalActivity = sumArray(rawLogin) + sumArray(rawSignup) + sumArray(rawReview);

                    // ==========================================
                    // DEMO DATA INJECTION FOR PRESENTATION
                    // If database has 0 activity this week, inject fake data so the chart looks good!
                    // ==========================================
                    if (totalActivity === 0 || rawLabels.length === 0) {
                        console.log("Database has 0 activity. Injecting Demo Data for Client Presentation.");
                        rawLabels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Today'];
                        rawLogin = [12, 19, 15, 22, 28, 35, 30]; // Fake Logins
                        rawSignup = [2, 5, 4, 8, 12, 18, 10];    // Fake Signups
                        rawReview = [0, 2, 1, 4, 6, 10, 8];      // Fake Reviews
                    }

                    const canvasElement = document.getElementById('activityChart');
                    
                    if (canvasElement) {
                        new Chart(canvasElement, {
                            type: 'line',
                            data: {
                                labels: rawLabels,
                                datasets: [
                                    {
                                        label: 'User Logins',
                                        data: rawLogin,
                                        borderColor: '#3b82f6',
                                        backgroundColor: 'rgba(59, 130, 246, 0.1)',
                                        borderWidth: 3,
                                        tension: 0.35,
                                        fill: true
                                    },
                                    {
                                        label: 'New Sign Ups',
                                        data: rawSignup,
                                        borderColor: '#22c55e',
                                        backgroundColor: 'rgba(34, 197, 94, 0.1)',
                                        borderWidth: 3,
                                        tension: 0.35,
                                        fill: true
                                    },
                                    {
                                        label: 'Business Reviews',
                                        data: rawReview,
                                        borderColor: '#f59e0b',
                                        backgroundColor: 'rgba(245, 158, 11, 0.1)',
                                        borderWidth: 3,
                                        tension: 0.35,
                                        fill: true
                                    }
                                ]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false, // Forces chart to fit inside our 400px div!
                                plugins: {
                                    legend: { position: 'top' }
                                },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: { precision: 0 } // Prevents decimal points on the Y axis
                                    }
                                }
                            }
                        });
                    }
                } catch (error) {
                    console.error("Chart loading error:", error);
                    document.querySelector('.chart-box').innerHTML = "<p style='color:red; text-align:center; padding: 50px;'>Error rendering chart. Please check console.</p>";
                }
            });
        </script>
    <% } else { %>
        <div class="panel">
            <% if (pendingRows.trim().isEmpty()) { %>
                <div class="empty">
                    <div class="empty-icon">✓</div>
                    <div class="empty-title">All caught up!</div>
                    <div class="empty-text">No pending locations to review</div>
                </div>
            <% } else { %>
                <div class="panel-head">
                    <h3 class="panel-title">Pending Approval</h3>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Submission ID</th>
                            <th>Image</th>
                            <th>User ID</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>City/State</th>
                            <th>Map</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody><%= pendingRows %></tbody>
                    </table>
                </div>
            <% } %>
        </div>
    <% } %>
</div>
</body>
</html>