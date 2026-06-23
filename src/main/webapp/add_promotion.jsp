<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Promotion</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #ffffff;
            color: #111;
            font-family: Arial, sans-serif;
        }

        .form-container {
            max-width: 850px;
            margin: 50px auto;
        }

        h2 {
            font-weight: 700;
            margin-bottom: 25px;
        }

        .form-box {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 18px;
            background-color: #fafafa;
        }

        label {
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            border: 1px solid #bbb;
            border-radius: 5px;
        }

        .btn-primary {
            background-color: #111;
            border-color: #111;
        }

        .btn-primary:hover {
            background-color: #333;
            border-color: #333;
        }

        .btn-secondary {
            background-color: #fff;
            color: #111;
            border: 1px solid #111;
        }

        .btn-secondary:hover {
            background-color: #f2f2f2;
            color: #111;
        }
    </style>
</head>

<body>
<div class="container">
    <div class="form-container">
        <h2>Add New Promotion</h2>

        <% if ("1".equals(request.getParameter("success"))) { %>
            <div class="alert alert-success">Promotion added successfully!</div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="addPromotion" method="post">
            <div class="form-box">
                <label>Promotion Title</label>
                <input type="text" name="title" class="form-control" required>
            </div>

            <div class="form-box">
                <label>Description</label>
                <textarea name="description" class="form-control" rows="4" required></textarea>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-box">
                        <label>Start Date</label>
                        <input type="date" name="startDate" class="form-control" required>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-box">
                        <label>End Date</label>
                        <input type="date" name="endDate" class="form-control" required>
                    </div>
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Save Promotion</button>
            <a href="business_dashboard.jsp" class="btn btn-secondary">Back</a>
        </form>
    </div>
</div>
</body>
</html>