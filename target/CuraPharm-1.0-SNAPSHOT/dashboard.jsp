<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security Check: Verify if a generic Staff or Pharmacist is logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CuraPharm - Staff Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; }
        .navbar { background-color: #16a085; padding: 15px; color: white; display: flex; justify-content: space-between; }
        .container { padding: 30px; }
        .welcome-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 25px; }
        .menu-card { background: #1abc9c; color: white; padding: 20px; text-align: center; border-radius: 6px; text-decoration: none; font-size: 18px; font-weight: bold; }
        .menu-card:hover { background: #16a085; }
        .logout-btn { color: #d35400; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — Operations Desk</h2>
    <div>
        <span>User: <strong><%= session.getAttribute("fullName") %></strong> (<%= session.getAttribute("role") %>)</span> | 
        <a href="index.jsp" class="logout-btn">Logout</a>
    </div>
</div>

<div class="container">
    <div class="welcome-box">
        <h3>Standard Operations Dashboard</h3>
        <p>Access active counter duties below. Use these links to build standard customer bills and look up system inventory configurations.</p>
    </div>

    <div class="menu-grid">
        <a href="#" class="menu-card">Medicine Directory</a>
        <a href="#" class="menu-card">Billing Counter</a>
        <a href="#" class="menu-card">Low-Stock Warnings</a>
    </div>
</div>

</body>
</html>