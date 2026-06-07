<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.math.BigDecimal, com.pharmacymanagement.curapharm.DBConnection" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CuraPharm — Executive Intelligence Reports</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; }
        .navbar { background-color: #2c3e50; padding: 15px; color: white; display: flex; justify-content: space-between; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .container { padding: 30px; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-left: 5px solid #3498db; }
        .metric-card.revenue { border-left-color: #2ecc71; }
        .metric-card.alert { border-left-color: #e74c3c; }
        .metric-title { font-size: 14px; color: #7f8c8d; text-transform: uppercase; font-weight: bold; }
        .metric-value { font-size: 28px; font-weight: bold; color: #2c3e50; margin-top: 5px; }
        .report-section { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 30px; }
        h3 { color: #2c3e50; margin-top: 0; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 14px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; color: #2c3e50; }
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge.danger { background: #fce4e4; color: #c0392b; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — Reports & Operational Intelligence</h2>
    <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
</div>

<div class="container">

    <%
        // Initialize dynamic calculations variables
        BigDecimal totalRevenue = BigDecimal.ZERO;
        int transactionCount = 0;
        int lowStockCount = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Query 1: Calculate Total Financial Gross Revenue
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT SUM(grand_total) AS total, COUNT(bill_id) AS cnt FROM Billing")) {
                if (rs.next()) {
                    totalRevenue = rs.getBigDecimal("total") != null ? rs.getBigDecimal("total") : BigDecimal.ZERO;
                    transactionCount = rs.getInt("cnt");
                }
            }
            // Query 2: Calculate Active Critical Low Stock Count
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) AS low_cnt FROM Medicines WHERE quantity < 10")) {
                if (rs.next()) {
                    lowStockCount = rs.getInt("low_cnt");
                }
            }
    %>

    <!-- Real-time Dashboard Summary Cards -->
    <div class="metrics-grid">
        <div class="metric-card revenue">
            <div class="report-section-title">Gross Total Sales Revenue</div>
            <div class="metric-value">$<%= totalRevenue.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
        </div>
        <div class="metric-card">
            <div class="report-section-title">Invoices Issued</div>
            <div class="metric-value"><%= transactionCount %> Orders</div>
        </div>
        <div class="metric-card alert">
            <div class="report-section-title">Critical Low-Stock Risks</div>
            <div class="metric-value"><%= lowStockCount %> Warning Batches</div>
        </div>
    </div>

    <!-- Live System Exception Warnings Table -->
    <div class="report-section">
        <h3>Critical Inventory Exceptions & Low Stock Run-out Logs</h3>
        <p style="color: #7f8c8d; font-size: 14px;">The following medication entries have fallen below the standard safety threshold level (10 units) and require immediate supply procurement intervention orders.</p>
        <table>
            <thead>
                <tr>
                    <th>Medication Name</th>
                    <th>Current Stock Balance</th>
                    <th>Supply Vendor Source</th>
                    <th>System Tracking Action Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String queryAlerts = "SELECT m.medicine_name, m.quantity, s.supplier_name FROM Medicines m " +
                                         "LEFT JOIN Suppliers s ON m.supplier_id = s.supplier_id " +
                                         "WHERE m.quantity < 10 ORDER BY m.quantity ASC";
                    try (Statement stAlerts = conn.createStatement();
                         ResultSet rsAlerts = stAlerts.executeQuery(queryAlerts)) {
                        
                        boolean hasAlerts = false;
                        while(rsAlerts.next()) {
                            hasAlerts = true;
                %>
                <tr>
                    <td><strong><%= rsAlerts.getString("medicine_name") %></strong></td>
                    <td style="color:#c0392b; font-weight:bold;"><%= rsAlerts.getInt("quantity") %> units remaining</td>
                    <td><%= rsAlerts.getString("supplier_name") != null ? rsAlerts.getString("supplier_name") : "No Vendor Tied" %></td>
                    <td><span class="badge danger">Restock Urgently</span></td>
                </tr>
                <%
                        }
                        if(!hasAlerts) {
                %>
                <tr>
                    <td colspan="4" style="text-align: center; color: #2ecc71; padding: 15px; font-weight:bold;">✓ All inventory items are sitting safely above minimum stock safety parameters.</td>
                </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
    </div>

    <% 
        } catch (Exception e) { 
    %>
        <div style="background:#fce4e4; color:#c0392b; padding:15px; border-radius:6px;">
            <strong>System Telemetry Read Exception:</strong> <%= e.getMessage() %>
        </div>
    <% 
        } 
    %>

</div>

</body>
</html>