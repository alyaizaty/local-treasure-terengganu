<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<%
    Map<String, Object> business = (Map<String, Object>) request.getAttribute("business");
    if (business == null) { response.sendRedirect("index.jsp"); return; }

    String bName = (String) business.get("name");
    String bDesc = (String) business.get("desc");
    String bAddr = (String) business.get("address");
    String bPhone = (String) business.get("phone");
    String bHours = (String) business.get("hours");
    String bImg = (String) business.get("image");
    String bCat = (String) business.get("category");
    Integer bId = (Integer) business.get("id");

    String waLink = "";
    if (bPhone != null && !bPhone.trim().isEmpty()) {
        String cleanPhone = bPhone.replaceAll("[^0-9]", "");
        if (cleanPhone.startsWith("0")) cleanPhone = "6" + cleanPhone;
        waLink = "https://wa.me/" + cleanPhone;
    }

    String gmapsLink = "https://www.google.com/maps/search/?api=1&query=" + URLEncoder.encode(bName + " " + bAddr, "UTF-8");

    String imgUrl = request.getContextPath() + "/image/background.jpg";
    if (bImg != null && !bImg.trim().isEmpty()) {
        if (bImg.startsWith("sub_")) imgUrl = request.getContextPath() + "/LocationImageServlet?file=" + URLEncoder.encode(bImg.trim(), "UTF-8");
        else if (bImg.startsWith("business_")) imgUrl = request.getContextPath() + "/uploads/" + URLEncoder.encode(bImg.trim(), "UTF-8");
        else imgUrl = request.getContextPath() + "/image/" + bImg.trim();
    }

    List<Map<String,Object>> promotionsList = (List<Map<String,Object>>) request.getAttribute("promotionsList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= bName %> | Business Details</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .wrap { max-width: 900px; margin: 30px auto; padding: 0 20px; }
        .back-btn { display: inline-flex; gap: 8px; align-items: center; color: #111; text-decoration: none; font-weight: 800; margin-bottom: 20px; }
        .biz-header { background: #fff; border-radius: 18px; overflow: hidden; box-shadow: 0 10px 24px rgba(0,0,0,0.08); border: 1px solid #eee; margin-bottom: 24px; }
        .biz-cover { width: 100%; height: 350px; object-fit: cover; display: block; }
        .biz-info { padding: 25px; }
        .biz-title { font-size: 32px; font-weight: 900; margin: 0 0 10px 0; }
        .biz-category { display: inline-block; background: #eef2ff; color: #4f46e5; padding: 6px 12px; border-radius: 999px; font-size: 13px; font-weight: 700; margin-bottom: 15px; }
        .biz-desc { font-size: 16px; color: #4b5563; line-height: 1.7; margin-bottom: 20px; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; background: #f9fafb; padding: 20px; border-radius: 12px; }
        .info-item { display: flex; align-items: flex-start; gap: 12px; }
        .info-item i { color: #667eea; font-size: 18px; margin-top: 3px; }
        .info-item div { font-size: 14px; color: #374151; font-weight: 500; }
        .action-btns { display: flex; gap: 15px; margin-top: 25px; flex-wrap: wrap; }
        .btn-wa { background: #25D366; color: white; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: 800; display: inline-flex; align-items: center; gap: 8px; }
        .btn-wa:hover { background: #20b858; }
        .btn-map { background: #111; color: white; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: 800; display: inline-flex; align-items: center; gap: 8px; }
        .btn-reviews { background: #667eea; color: white; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: 800; display: inline-flex; align-items: center; gap: 8px; }
        .promo-section { margin-top: 30px; }
        .promo-title { font-size: 24px; font-weight: 900; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; color: #111; }
        .promo-card { background: #fff; border: 2px dashed #f59e0b; border-radius: 16px; padding: 20px; margin-bottom: 15px; }
        .promo-card h4 { margin: 0 0 8px 0; font-size: 18px; color: #92400e; font-weight: 800; }
        .promo-card p { margin: 0 0 10px 0; color: #4b5563; font-size: 15px; }
        .promo-date { font-size: 13px; color: #6b7280; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; background: #fffbeb; padding: 4px 10px; border-radius: 6px; }

     @media screen and (max-width: 768px) {

    .wrap{
        max-width:100%;
        padding:15px;
        margin:20px auto;
    }

    .biz-header{
        border-radius:16px;
    }

    .biz-cover{
        width:100%;
        height:260px;
        object-fit:cover;
    }

    .biz-info{
        padding:20px;
    }

    .biz-title{
        font-size:26px;
    }

    .biz-category{
        font-size:12px;
        padding:6px 12px;
    }

    .biz-desc{
        font-size:15px;
        line-height:1.6;
    }

    /* KEKALKAN 2 COLUMN */
    .info-grid{
        grid-template-columns:repeat(2,1fr);
        gap:15px;
        padding:18px;
    }

    .info-item i{
        font-size:17px;
    }

    .info-item div{
        font-size:14px;
    }

    .action-btns{
        display:flex;
        flex-wrap:wrap;
        gap:12px;
    }

    .btn-wa,
    .btn-map,
    .btn-reviews{
        flex:1;
        justify-content:center;
        padding:12px;
        font-size:14px;
    }

    .promo-title{
        font-size:22px;
    }

    .promo-card{
        padding:18px;
    }

    .promo-card h4{
        font-size:18px;
    }

    .promo-card p{
        font-size:14px;
    }

}


@media screen and (max-width:480px){

    .biz-cover{
        height:220px;
    }

    .biz-title{
        font-size:22px;
    }

    .biz-desc{
        font-size:14px;
    }

    /* Masih kekal 2 column */
    .info-grid{
        grid-template-columns:repeat(2,1fr);
        gap:10px;
        padding:14px;
    }

    .info-item{
        gap:8px;
    }

    .info-item i{
        font-size:15px;
    }

    .info-item div{
        font-size:12px;
    }

    .action-btns{
        flex-direction:row;
        flex-wrap:wrap;
        gap:10px;
    }

    .btn-wa,
    .btn-map,
    .btn-reviews{
        flex:1 1 100%;
        font-size:14px;
        padding:12px;
    }

    .promo-title{
        font-size:20px;
    }

    .promo-card{
        padding:15px;
    }

}
    </style>
</head>
<body>


<div class="wrap">
    <a href="index.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> Back to Homepage</a>

    <div class="biz-header">
        <img src="<%= imgUrl %>" onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/image/background.jpg';" alt="<%= bName %>" class="biz-cover">
        <div class="biz-info">
            <span class="biz-category"><i class="fas fa-store"></i> <%= bCat %></span>
            <h1 class="biz-title"><%= bName %></h1>
            <p class="biz-desc"><%= bDesc != null ? bDesc : "No description available." %></p>
            <div class="info-grid">
                <div class="info-item"><i class="fas fa-location-dot"></i><div><%= bAddr != null ? bAddr : "-" %></div></div>
                <div class="info-item"><i class="fas fa-clock"></i><div><%= bHours != null ? bHours : "-" %></div></div>
                <div class="info-item"><i class="fas fa-phone"></i><div><%= bPhone != null ? bPhone : "-" %></div></div>
            </div>
            <div class="action-btns">
                <% if (!waLink.isEmpty()) { %>
                    <a href="<%= waLink %>" target="_blank" class="btn-wa"><i class="fab fa-whatsapp" style="font-size:18px;"></i> WhatsApp</a>
                <% } %>
                <a href="<%= gmapsLink %>" target="_blank" class="btn-map"><i class="fas fa-map-marker-alt"></i> Show in Maps</a>
                <a href="<%= request.getContextPath() %>/businessReviews?id=<%= bId %>" class="btn-reviews"><i class="fas fa-comments"></i> Read Reviews</a>
            </div>
        </div>
    </div>

    <div class="promo-section">
        <h2 class="promo-title"><i class="fas fa-fire" style="color:#ef4444;"></i> Current Promotions</h2>
        <% if (promotionsList != null && !promotionsList.isEmpty()) { %>
            <% for (Map<String,Object> promo : promotionsList) { %>
                <div class="promo-card">
                    <h4><%= promo.get("title") %></h4>
                    <p><%= promo.get("desc") %></p>
                    <div class="promo-date"><i class="fas fa-calendar-alt"></i> Valid: <%= promo.get("start") %> to <%= promo.get("end") %></div>
                </div>
            <% } %>
        <% } else { %>
            <div style="background:#fff; padding:20px; border-radius:12px; border:1px solid #eee; color:#6b7280; text-align:center; font-weight:600;">No active promotions at this time.</div>
        <% } %>
    </div>
</div>


</body>
</html>