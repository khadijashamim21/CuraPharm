<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.pharmacymanagement.curapharm.DBConnection" %>
<%
    String role = (String) session.getAttribute("role");
    if (session.getAttribute("username") == null || role == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Set permission flags based on your exact user requirements
    boolean canModifyStock = "Admin".equalsIgnoreCase(role) || "Pharmacist".equalsIgnoreCase(role);
    boolean isStaff = "Staff".equalsIgnoreCase(role);

    String editId = request.getParameter("edit_id");
    String editName = "", editPrice = "", editQty = "", editExpiry = "", editCatId = "", editSupId = "";
    boolean isEditMode = false;

    // Block non-authorized alterations attempt
    if (editId != null && !canModifyStock) {
        response.sendRedirect("medicines.jsp");
        return;
    }

    if (editId != null && canModifyStock) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM Medicines WHERE medicine_id = ?")) {
            ps.setInt(1, Integer.parseInt(editId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                editName = rs.getString("medicine_name");
                editCatId = String.valueOf(rs.getInt("category_id"));
                editSupId = String.valueOf(rs.getInt("supplier_id"));
                editPrice = String.valueOf(rs.getBigDecimal("price"));
                editQty = String.valueOf(rs.getInt("quantity"));
                editExpiry = String.valueOf(rs.getDate("expiry_date"));
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
    <title>CuraPharm — Stock Inventory</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; color: #334155; }
        .navbar { background-color: #2c3e50; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .layout-container { display: flex; padding: 30px; gap: 30px; flex-direction: column; }
        .card-form, .card-table { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        h3 { color: #2c3e50; margin-top: 0; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; }
        label { display: block; margin-bottom: 4px; font-weight: bold; font-size: 14px; }
        input, select { width: 100%; padding: 10px; border: 1px solid #bdc3c7; border-radius: 4px; }
        .btn-save { background-color: #2ecc71; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 15px; float: right; }
        .btn-update { background-color: #e67e22; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 15px; float: right; }
        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; font-size: 14px; }
        th { background-color: #f2f2f2; }
        .edit-link { color: #e67e22; font-weight: bold; text-decoration: none; margin-right: 10px; }
        .delete-link { color: #ef4444; font-weight: bold; text-decoration: none; }
        .alert-badge { background-color: #fee2e2; color: #b91c1c; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
        .good-badge { background-color: #dcfce7; color: #15803d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — Medicine Ledger Terminal</h2>
    <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
</div>

<div class="layout-container">

    <%-- Requirement: Only display the modification form block if user is Admin or Pharmacist --%>
    <% if (canModifyStock) { %>
    <div class="card-form">
        <h3><%= isEditMode ? "Modify Medication Batch" : "Log New Medication Stock" %></h3>
        <form action="<%= isEditMode ? "EditHandlerServlet" : "MedicineServlet" %>" method="POST">
            <input type="hidden" name="action_type" value="update_medicine">
            <input type="hidden" name="medicine_id" value="<%= editId %>">
            <div class="form-grid">
                <div><label>Medicine Name</label><input type="text" name="medicine_name" value="<%= editName %>" required></div>
                <div>
                    <label>Category</label>
                    <select name="category_id" required>
                        <% try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT * FROM Categories")) {
                            while(rs.next()) { String sel = String.valueOf(rs.getInt("category_id")).equals(editCatId) ? "selected" : ""; %>
                            <option value="<%= rs.getInt("category_id") %>" <%= sel %>><%= rs.getString("category_name") %></option>
                        <% }} catch(Exception e) {} %>
                    </select>
                </div>
                <div>
                    <label>Supplier Vendor</label>
                    <select name="supplier_id" required>
                        <% try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT * FROM Suppliers")) {
                                while(rs.next()) { String sel = String.valueOf(rs.getInt("supplier_id")).equals(editSupId) ? "selected" : ""; %>
                            <option value="<%= rs.getInt("supplier_id") %>" <%= sel %>><%= rs.getString("supplier_name") %></option>
                        <% }} catch(Exception e) {} %>
                    </select>
                </div>
                <div><label>Unit Price ($)</label><input type="number" name="price" step="0.01" value="<%= editPrice %>" required></div>
                <div><label>Stock Quantity</label><input type="number" name="quantity" value="<%= editQty %>" required></div>
                <div><label>Expiry Date</label><input type="date" name="expiry_date" value="<%= editExpiry %>" required></div>
            </div>
            <% if (isEditMode) { %>
                <button type="submit" class="btn-update">Update Batch</button>
            <% } else { %>
                <button type="submit" class="btn-save">Commit Stock</button>
            <% } %>
        </form>
    </div>
    <% } %>

    <div class="card-table">
        <h3>Current Medication Inventory Matrix</h3>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Medicine Name</th><th>Category</th><th>Price</th><th>Stock Status</th>
                        <%-- Requirement: Pharmacist/Alerts visibility metrics --%>
                        <% if (!isStaff) { %><th>Distribution Supplier</th><th>Expiry</th><% } %>
                        <% if (canModifyStock) {  %><th>Actions</th><% } %>
                    </tr>
                </thead>
                <tbody>
                    <% String query = "SELECT m.*, c.category_name, s.supplier_name FROM Medicines m LEFT JOIN Categories c ON m.category_id = c.category_id LEFT JOIN Suppliers s ON m.supplier_id = s.supplier_id ORDER BY m.medicine_id DESC";
                        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
                            while(rs.next()) { 
                                int qty = rs.getInt("quantity");
                    %>
                    <tr>
                        <td><strong><%= rs.getString("medicine_name") %></strong></td>
                        <td><%= rs.getString("category_name") %></td>
                        <td>$<%= rs.getBigDecimal("price") %></td>
                        
                        <%-- Requirement: Monitor Stock levels and display critical low alert indicators --%>
                        <td>
                            <% if (qty <= 10) { %>
                                <span class="alert-badge">LOW STOCK: <%= qty %> left</span>
                            <% } else { %>
                                <span class="good-badge">Available: <%= qty %> units</span>
                            <% } %>
                        </td>
                        
                        <% if (!isStaff) { %>
                            <td><%= rs.getString("supplier_name") %></td>
                            <td><%= rs.getDate("expiry_date") %></td>
                        <% } %>
                        
                        <%-- Requirement: Protect interactive row operations from Staff profiles --%>
                        <% if (canModifyStock) { %>
                        <td>
                            <a href="medicines.jsp?edit_id=<%= rs.getInt("medicine_id") %>" class="edit-link">Edit</a>
                            <a href="DeleteHandlerServlet?type=medicine&id=<%= rs.getInt("medicine_id") %>" class="delete-link" onclick="return confirm('Delete SKU?');">Delete</a>
                        </td>
                        <% } %>
                    </tr>
                    <% }} catch(Exception e) {} %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>