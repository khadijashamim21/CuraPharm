<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.pharmacymanagement.curapharm.DBConnection" %>
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
    <title>CuraPharm — Point of Sale Billing</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; }
        .navbar { background-color: #2c3e50; padding: 15px; color: white; display: flex; justify-content: space-between; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .layout-container { display: flex; padding: 30px; gap: 30px; }
        .card-form { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 40%; height: fit-content; }
        .card-table { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); width: 60%; }
        h3 { color: #2c3e50; margin-top: 0; border-bottom: 2px solid #ecf0f1; padding-bottom: 10px; }
        .form-group { margin-bottom: 12px; }
        label { display: block; margin-bottom: 4px; font-weight: bold; color: #34495e; font-size: 14px; }
        input, select { width: 100%; padding: 8px; border: 1px solid #bdc3c7; border-radius: 4px; box-sizing: border-box; }
        .calc-box { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-top: 15px; border: 1px dashed #2ecc71; }
        .calc-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }
        button { background-color: #e67e22; color: white; padding: 12px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; font-weight: bold; margin-top: 10px; }
        button:hover { background-color: #d35400; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; color: #2c3e50; }
        .status-msg { padding: 10px; margin-bottom: 15px; border-radius: 4px; font-weight: bold; text-align: center; }
        .success { background-color: #d4edda; color: #155724; }
    </style>
    <script>
        // Real-time automatic total calculation engine
        function calculateGrandTotal() {
            var medicineSelect = document.getElementById("medicine_id");
            var selectedOption = medicineSelect.options[medicineSelect.selectedIndex];
            
            var price = parseFloat(selectedOption.getAttribute("data-price") || 0);
            var quantity = parseInt(document.getElementById("quantity").value || 0);
            var discount = parseFloat(document.getElementById("discount").value || 0);
            
            var subtotal = price * quantity;
            var tax = subtotal * 0.05; // Fixed 5% medical tax calculation rate
            var grandTotal = (subtotal + tax) - discount;
            if(grandTotal < 0) grandTotal = 0;
            
            document.getElementById("lbl_subtotal").innerText = "$" + subtotal.toFixed(2);
            document.getElementById("lbl_tax").innerText = "$" + tax.toFixed(2);
            document.getElementById("lbl_grand").innerText = "$" + grandTotal.toFixed(2);
            
            document.getElementById("total_amount").value = subtotal.toFixed(2);
            document.getElementById("tax_amount").value = tax.toFixed(2);
            document.getElementById("grand_total").value = grandTotal.toFixed(2);
        }
    </script>
</head>
<body>

<div class="navbar">
    <h2>CuraPharm — Checkout Point of Sale</h2>
    <a href="admin_dashboard.jsp" class="back-link">← Back to Dashboard</a>
</div>

<div class="layout-container">
    <div class="card-form">
        <h3>Generate Customer Invoice</h3>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="status-msg success"><%= request.getAttribute("message") %></div>
        <% } %>

        <form action="BillingServlet" method="POST">
            <input type="hidden" id="total_amount" name="total_amount" value="0.00">
            <input type="hidden" id="tax_amount" name="tax_amount" value="0.00">
            <input type="hidden" id="grand_total" name="grand_total" value="0.00">

            <div class="form-group">
                <label for="customer_name">Patient / Customer Full Name</label>
                <input type="text" id="customer_name" name="customer_name" required placeholder="e.g., Jane Smith">
            </div>
            <div class="form-group">
                <label for="customer_phone">Contact Phone Number</label>
                <input type="text" id="customer_phone" name="customer_phone" placeholder="e.g., +15550234">
            </div>
            
            <div class="form-group">
                <label for="medicine_id">Medication Prescribed</label>
                <select id="medicine_id" name="medicine_id" required onchange="calculateGrandTotal()">
                    <option value="" data-price="0">-- Select Stock Item --</option>
                    <% 
                        try (Connection conn = DBConnection.getConnection();
                             Statement st = conn.createStatement();
                             ResultSet rs = st.executeQuery("SELECT medicine_id, medicine_name, price, quantity FROM Medicines WHERE quantity > 0 ORDER BY medicine_name ASC")) {
                            while(rs.next()) {
                    %>
                        <option value="<%= rs.getInt("medicine_id") %>" data-price="<%= rs.getBigDecimal("price") %>">
                            <%= rs.getString("medicine_name") %> [In Stock: <%= rs.getInt("quantity") %>] - ($<%= rs.getBigDecimal("price") %>/unit)
                        </option>
                    <%      }
                        } catch(Exception e) {}
                    %>
                </select>
            </div>

            <div class="form-group">
                <label for="quantity">Quantity Dispensed</label>
                <input type="number" id="quantity" name="quantity" min="1" required placeholder="0" oninput="calculateGrandTotal()">
            </div>

            <div class="form-group">
                <label for="discount">Discount Flat Deductible ($)</label>
                <input type="number" id="discount" name="discount" min="0" step="0.01" value="0.00" oninput="calculateGrandTotal()">
            </div>

            <div class="calc-box">
                <div class="calc-row"><span>Items Subtotal:</span><span id="lbl_subtotal" style="font-weight:bold;">$0.00</span></div>
                <div class="calc-row"><span>Sales Tax Addon (5%):</span><span id="lbl_tax" style="font-weight:bold;">$0.00</span></div>
                <hr style="border: 0; border-top: 1px solid #ddd;">
                <div class="calc-row" style="font-size:16px; color:#c0392b;"><span><strong>Grand Total Due:</strong></span><span id="lbl_grand" style="font-weight:bold;">$0.00</span></div>
            </div>

            <button type="submit">Process Payment & Log Invoice</button>
        </form>
    </div>

    <div class="card-table">
        <h3>Historical Sales Audit Ledger</h3>
        <table>
            <thead>
                <tr>
                    <th>Invoice ID</th>
                    <th>Customer Name</th>
                    <th>Subtotal</th>
                    <th>Tax / Disc</th>
                    <th>Grand Total</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT * FROM Billing ORDER BY bill_id DESC")) {
                        
                        boolean hasBills = false;
                        while(rs.next()) {
                            hasBills = true;
                %>
                <tr>
                    <td><strong>#INV-2026-<%= rs.getInt("bill_id") %></strong></td>
                    <td><%= rs.getString("customer_name") %><br><small style="color:#7f8c8d;"><%= rs.getString("customer_phone") != null ? rs.getString("customer_phone") : "-" %></small></td>
                    <td>$<%= rs.getBigDecimal("total_amount") %></td>
                    <td>+<small style="color: green;">$<%= rs.getBigDecimal("tax_amount") %></small> / -<small style="color: red;">$<%= rs.getBigDecimal("discount") %></small></td>
                    <td><strong style="color:#27ae60;">$<%= rs.getBigDecimal("grand_total") %></strong></td>
                    <td><span style="color: #7f8c8d; font-size:11px;"><%= rs.getTimestamp("billing_date") %></span></td>
                </tr>
                <%
                        }
                        if(!hasBills) {
                %>
                <tr>
                    <td colspan="6" style="text-align: center; color: #7f8c8d; padding: 20px;">No transaction entries logged across terminal nodes yet.</td>
                </tr>
                <%
                        }
                    } catch(Exception e) {
                %>
                <tr>
                    <td colspan="6" style="color:red;">Audit log mapping runtime exception: <%= e.getMessage() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>