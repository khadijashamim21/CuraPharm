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

@WebServlet(name = "BillingServlet", urlPatterns = {"/BillingServlet"})
public class BillingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Collect point-of-sale parameter configurations
        String customerName = request.getParameter("customer_name");
        String customerPhone = request.getParameter("customer_phone");
        String medicineIdStr = request.getParameter("medicine_id");
        String quantityStr = request.getParameter("quantity");
        String totalAmountStr = request.getParameter("total_amount");
        String taxAmountStr = request.getParameter("tax_amount");
        String discountStr = request.getParameter("discount");
        String grandTotalStr = request.getParameter("grand_total");

        Connection conn = null;
        PreparedStatement psInsertBill = null;
        PreparedStatement psUpdateStock = null;

        try {
            int medicineId = Integer.parseInt(medicineIdStr);
            int quantityPurchased = Integer.parseInt(quantityStr);
            BigDecimal totalAmount = new BigDecimal(totalAmountStr);
            BigDecimal taxAmount = new BigDecimal(taxAmountStr);
            BigDecimal discount = new BigDecimal(discountStr);
            BigDecimal grandTotal = new BigDecimal(grandTotalStr);

            conn = DBConnection.getConnection();
            // Start local safety commit transaction block
            conn.setAutoCommit(false);

            // 2. Insert invoice details into Billing ledger log table
            String sqlInsertBill = "INSERT INTO Billing (customer_name, customer_phone, total_amount, tax_amount, discount, grand_total) VALUES (?, ?, ?, ?, ?, ?)";
            psInsertBill = conn.prepareStatement(sqlInsertBill);
            psInsertBill.setString(1, customerName);
            psInsertBill.setString(2, customerPhone);
            psInsertBill.setBigDecimal(3, totalAmount);
            psInsertBill.setBigDecimal(4, taxAmount);
            psInsertBill.setBigDecimal(5, discount);
            psInsertBill.setBigDecimal(6, grandTotal);
            psInsertBill.executeUpdate();

            // 3. Deduct stock balance count from Medicines matching ID parameter row
            String sqlUpdateStock = "UPDATE Medicines SET quantity = quantity - ? WHERE medicine_id = ? AND quantity >= ?";
            psUpdateStock = conn.prepareStatement(sqlUpdateStock);
            psUpdateStock.setInt(1, quantityPurchased);
            psUpdateStock.setInt(2, medicineId);
            psUpdateStock.setInt(3, quantityPurchased);
            psUpdateStock.executeUpdate();

            // Commit transaction events concurrently
            conn.commit();

            request.setAttribute("message", "Invoice successfully processed for " + customerName + "!");
            request.getRequestDispatcher("billing.jsp").forward(request, response);

        } catch (SQLException | NumberFormatException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            throw new ServletException("Point of Sale billing automation framework breakdown rollback executed.", e);
        } finally {
            try { if (psInsertBill != null) psInsertBill.close(); } catch (SQLException e) {}
            try { if (psUpdateStock != null) psUpdateStock.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}