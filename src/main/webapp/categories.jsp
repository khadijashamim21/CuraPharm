<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.pharmacymanagement.curapharm.DBConnection" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("username") == null || 
        (!"Admin".equalsIgnoreCase(role) && !"Pharmacist".equalsIgnoreCase(role) && !"Staff".equalsIgnoreCase(role))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String editId = request.getParameter("edit_id");
    String editName = "", editContact = "", editPhone = "", editEmail = "", editAddress = "", editBank = "";
    boolean isEditMode = false;

    if (editId != null) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM Suppliers WHERE supplier_id = ?")) {
            ps.setInt(1, Integer.parseInt(editId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                editName = rs.getString("supplier_name");
                editContact = rs.getString("contact_name");
                editPhone = rs.getString("phone");
                editEmail = rs.getString("email");
                editAddress = rs.getString("address");
                editBank = rs.getString("bank_details");
                isEditMode = true;
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CuraPharm — Suppliers</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; color: #334155; }
        .navbar { background-color: #2c3e50; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
        .navbar h2 { margin: 0; font-size: 20px; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        
        .layout-container { display: flex; padding: 30px; gap: 30px; align-items: flex-start; }
        .card-form { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 35%; }
        .card-table { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 65%; }
        
        h3 { color: #2c3e50; margin-top: 0; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        .form-group { margin-bottom: 12px; }
        label { display: block; margin-bottom: 4px; font-weight: bold; font-size: 14px; }
        input[type="text"], input[type="email"], textarea { width: 100%; padding: 10px; border: 1px solid #bdc3c7; border-radius: 4px; font-size: 14px; }
        
        .btn-save { background-color: #3498db; color: white; padding: 12px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%; }
        .btn-update { background-color: #e67e22; color: white; padding: 12px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%; }
        
        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; font-size: 14px; }
        th { background-color: #f2f2f2; }
        .edit-link { color: #e67e22; font-weight: bold; text-decoration: none; margin-right: 10px; }
        .delete-link { color: #ef4444; font-weight: bold; text-decoration: none; }

        @media (max-width: 992px) {
            .layout-container { flex-direction: column; padding: 20px; }
            .card-form, .card-table { width: 100%; }
        }
        @media (max-width: 576px) {
            .navbar { flex-direction: column; align-items: flex-start; padding: 15px; }
        }
    </style>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — Vendor Registry</h2>
    <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
</div>

<div class="layout-container">
    <div class="card-form">
        <h3><%= isEditMode ? "Modify Supplier Profile" : "Register New Supplier" %></h3>
        <form action="<%= isEditMode ? "EditHandlerServlet" : "SupplierServlet" %>" method="POST">
            <input type="hidden" name="action_type" value="update_supplier">
            <input type="hidden" name="supplier_id" value="<%= editId %>">
            <div class="form-group"><label>Company Name</label><input type="text" name="supplier_name" value="<%= editName %>" required></div>
            <div class="form-group"><label>Contact Representative</label><input type="text" name="contact_name" value="<%= editContact %>"></div>
            <div class="form-group"><label>Phone Number</label><input type="text" name="phone" value="<%= editPhone %>"></div>
            <div class="form-group"><label>Corporate Email</label><input type="email" name="email" value="<%= editEmail %>"></div>
            <div class="form-group"><label>Office Address</label><textarea name="address" rows="2"><%= editAddress %></textarea></div>
            <div class="form-group"><label>Payment / Bank Details</label><input type="text" name="bank_details" value="<%= editBank %>"></div>
            <% if (isEditMode) { %>
                <button type="submit" class="btn-update">Update Record</button>
                <p style="text-align:center;"><a href="suppliers.jsp" style="color:#7f8c8d; font-size:13px;">Cancel Edit</a></p>
            <% } else { %>
                <button type="submit" class="btn-save">Save Supplier Record</button>
            <% } %>
        </form>
    </div>

    <div class="card-table">
        <h3>Cataloged Distribution Partners</h3>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr><th>Company</th><th>Agent</th><th>Contact</th><th>Payment Route</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <% try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT * FROM Suppliers ORDER BY supplier_id DESC")) {
                        while(rs.next()) { %>
                    <tr>
                        <td><strong><%= rs.getString("supplier_name") %></strong></td>
                        <td><%= rs.getString("contact_name") %></td>
                        <td><%= rs.getString("phone") %><br><small><%= rs.getString("email") %></small></td>
                        <td><%= rs.getString("bank_details") %></td>
                        <td>
                            <a href="suppliers.jsp?edit_id=<%= rs.getInt("supplier_id") %>" class="edit-link">Edit</a>
                            <a href="DeleteHandlerServlet?type=supplier&id=<%= rs.getInt("supplier_id") %>" class="delete-link" onclick="return confirm('Remove profile?');">Delete</a>
                        </td>
                    </tr>
                    <% }} catch(Exception e) {} %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>