<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Business" %>
<%
    Business business = (Business) request.getAttribute("business");
    if (business == null) {
        response.sendRedirect("home.jsp");
        return;
    }

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    boolean loggedIn = (userId != null);

    String gmapsLink = business.getGmapsLink();
    if (gmapsLink == null || gmapsLink.trim().isEmpty()) {
        gmapsLink = "https://gs.jurieo.com/gemini/official/maps/search/?api=1&query=" + 
                    java.net.URLEncoder.encode(business.getBusinessName() + ", Terengganu", "UTF-8");
    }

    List<String> galleryImages = (List<String>) request.getAttribute("galleryImages");
    List<Map<String,Object>> reviewsList = (List<Map<String,Object>>) request.getAttribute("reviewsList");
%>

<h1><%= business.getBusinessName() %></h1>
<p><%= business.getDescription() %></p>
<p>Address: <%= business.getAddress() %></p>
<p>Phone: <%= business.getContactPhone() %></p>
<p>Hours: <%= business.getOperatingHours() %></p>
<a href="<%= gmapsLink %>" target="_blank">Show in Google Maps</a>

<%-- Gallery --%>
<% if (galleryImages != null) { %>
    <div>
        <% for(String img : galleryImages) { %>
            <img src="uploads/<%= img %>" width="200" />
        <% } %>
    </div>
<% } %>

<%-- Reviews --%>
<% if (reviewsList != null) { %>
    <h3>Reviews</h3>
    <% for(Map<String,Object> r : reviewsList) { %>
        <div>
            <strong><%= r.get("username") %></strong> 
            (<%= r.get("rating") %>★) - <%= r.get("date") %>
            <p><%= r.get("text") %></p>
        </div>
    <% } %>
<% } %>