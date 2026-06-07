package com.pharmacymanagement.curapharm;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet(name = "MedicineServlet", urlPatterns = {"/MedicineServlet"})
public class MedicineServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Capture form values
        String medicineName = request.getParameter("medicine_name");
        String categoryIdStr = request.getParameter("category_id");
        String supplierIdStr = request.getParameter("supplier_id");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");
        String expiryDateStr = request.getParameter("expiry_date");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // 2. Parse string data types into database-compatible formats
            int categoryId = Integer.parseInt(categoryIdStr);
            int supplierId = Integer.parseInt(supplierIdStr);
            BigDecimal price = new BigDecimal(priceStr);
            int quantity = Integer.parseInt(quantityStr);

            // 3. Establish database server link instance
            conn = DBConnection.getConnection();
            
            // 4. Compile parameterized transaction query string
            String sql = "INSERT INTO Medicines (medicine_name, category_id, supplier_id, price, quantity, expiry_date) VALUES (?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, medicineName);
            ps.setInt(2, categoryId);
            ps.setInt(3, supplierId);
            ps.setBigDecimal(4, price);
            ps.setInt(5, quantity);
            ps.setString(6, expiryDateStr);
            
            // 5. Fire database tracking execution commit
            ps.executeUpdate();
            
            // 6. Return context response loop
            request.setAttribute("message", "Medication '" + medicineName + "' logged into inventory!");
            request.getRequestDispatcher("medicines.jsp").forward(request, response);

        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Medicine module database inventory integration execution failure.", e);
        } finally {
            // Teardown resource leak allocations
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}