<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.pharmacymanagement.curapharm.DBConnection" %>
<%
    // Security Guard: Only allow logged-in Admin accounts to view this panel
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("username") == null || !"Admin".equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CuraPharm — User Provisioning Portal</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; }
        .navbar { background-color: #2c3e50; padding: 15px; color: white; display: flex; justify-content: space-between; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .layout-container { display: flex; padding: 30px; gap: 30px; }
        .card-form { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 35%; height: fit-content; }
        .card-table { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 65%; }
        h3 { color: #2c3e50; margin-top: 0; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #34495e; }
        input[type="text"], input[type="password"], select { width: 100%; padding: 8px; border: 1px solid #bdc3c7; border-radius: 4px; box-sizing: border-box; }
        button { background-color: #9b59b6; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 15px; width: 100%; font-weight: bold; }
        button:hover { background-color: #8e44ad; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; color: #2c3e50; }
        .role-badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .role-admin { background: #e8f8f5; color: #117a65; }
        .role-pharm { background: #eaf2f8; color: #2471a3; }
        .role-staff { background: #fef9e7; color: #b7950b; }
        .status-msg { padding: 10px; margin-bottom: 15px; border-radius: 4px; font-weight: bold; text-align: center; }
        .success { background-color: #d4edda; color: #155724; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — User Management Console</h2>
    <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
</div>

<div class="layout-container">
    <div class="card-form">
        <h3>Create Staff Account</h3>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="status-msg success"><%= request.getAttribute("message") %></div>
        <% } %>

        <form action="UserServlet" method="POST">
            <div class="form-group">
                <label for="username">System Username</label>
                <input type="text" id="username" name="username" required placeholder="e.g., jsmith">
            </div>
            <div class="form-group">
                <label for="password">Security Password</label>
                <input type="password" id="password" name="password" required placeholder="••••••••">
            </div>
            <div class="form-group">
                <label for="full_name">Employee Full Name</label>
                <input type="text" id="full_name" name="full_name" required placeholder="e.g., Jane Smith">
            </div>
            <div class="form-group">
                <label for="role">Organizational Access Role</label>
                <select id="role" name="role" required>
                    <option value="Pharmacist">Pharmacist</option>
                    <option value="Staff">Staff Support</option>
                    <option value="Admin">Administrator</option>
                </select>
            </div>
            <button type="submit">Provision User Account</button>
        </form>
    </div>

    <div class="card-table">
        <h3>Active System Operator Directory</h3>
        <table>
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Account Username</th>
                    <th>Employee Full Name</th>
                    <th>Assigned Clearance Role</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT user_id, username, full_name, role FROM Users ORDER BY user_id ASC")) {
                        
                        while(rs.next()) {
                            String userRole = rs.getString("role");
                            String badgeClass = "role-staff";
                            if("Admin".equalsIgnoreCase(userRole)) badgeClass = "role-admin";
                            else if("Pharmacist".equalsIgnoreCase(userRole)) badgeClass = "role-pharm";
                %>
                <tr>
                    <td><strong>#USR-0<%= rs.getInt("user_id") %></strong></td>
                    <td><code><%= rs.getString("username") %></code></td>
                    <td><%= rs.getString("full_name") %></td>
                    <td><span class="role-badge <%= badgeClass %>"><%= userRole %></span></td>
                </tr>
                <%
                        }
                    } catch(Exception e) {
                %>
                <tr>
                    <td colspan="4" style="color:red;">Roster deployment access exception: <%= e.getMessage() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>