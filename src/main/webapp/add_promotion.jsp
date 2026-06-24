<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Promotion | Local Treasure</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    
    <style>
        body { background-color: #f4f7f6; font-family: 'Poppins', sans-serif; padding: 40px 0; }
        .promo-card { 
            background: #ffffff; 
            border-radius: 24px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.06); 
            padding: 40px; 
            border: 1px solid #f0f0f0;
        }
        .header-section { margin-bottom: 30px; text-align: center; }
        .header-section i { font-size: 40px; color: #f59e0b; margin-bottom: 15px; }
        .header-section h2 { font-weight: 800; color: #111; }
        
        .form-label { font-weight: 600; color: #374151; margin-bottom: 8px; font-size: 14px; }
        .form-control {
            border: 2px solid #e5e7eb;
            border-radius: 14px;
            padding: 14px;
            font-size: 15px;
            transition: all 0.3s ease;
        }
        .form-control:focus { border-color: #111; box-shadow: 0 0 0 4px rgba(0,0,0,0.05); }
        
        .btn-save {
            background-color: #111;
            color: #fff;
            padding: 14px;
            border-radius: 14px;
            font-weight: 700;
            border: none;
            width: 100%;
            margin-top: 10px;
            transition: 0.3s;
        }
        .btn-save:hover { background-color: #333; color: #fff; transform: translateY(-2px); }
        .btn-back {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #6b7280;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
        }
        .btn-back:hover { color: #111; }
        .alert { border-radius: 12px; font-weight: 500; }
    </style>
</head>
<body>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="promo-card">
                <div class="header-section">
                    <i class="fas fa-tag"></i>
                    <h2>Add New Promotion</h2>
                    <p class="text-muted">Fill in the details below to launch your promotion.</p>
                </div>

                <%-- Feedback Messages --%>
                <% if ("1".equals(request.getParameter("success"))) { %>
                    <div class="alert alert-success">Promotion added successfully!</div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="addPromotion" method="post">
                    <div class="mb-3">
                        <label class="form-label">Promotion Title</label>
                        <input type="text" name="title" class="form-control" placeholder="e.g. 50% Off Lunch Special" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="3" placeholder="What are the details of the offer?" required></textarea>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label">Start Date</label>
                            <input type="date" name="startDate" class="form-control" required>
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label">End Date</label>
                            <input type="date" name="endDate" class="form-control" required>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-save">Save Promotion</button>
                    <a href="business_dashboard.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>