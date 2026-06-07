package com.pharmacymanagement.curapharm;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet(name = "SupplierServlet", urlPatterns = {"/SupplierServlet"})
public class SupplierServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Gather form input parameters
        String supplierName = request.getParameter("supplier_name");
        String contactName = request.getParameter("contact_name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String bankDetails = request.getParameter("bank_details");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // 2. Fetch database server instance
            conn = DBConnection.getConnection();
            
            // 3. Compile transaction insert strings
            String sql = "INSERT INTO Suppliers (supplier_name, contact_name, phone, email, address, bank_details) VALUES (?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, supplierName);
            ps.setString(2, contactName);
            ps.setString(3, phone);
            ps.setString(4, email);
            ps.setString(5, address);
            ps.setString(6, bankDetails);
            
            // 4. Fire database commit sequence
            ps.executeUpdate();
            
            // 5. Send back operation message badge
            request.setAttribute("message", "Supplier '" + supplierName + "' successfully registered!");
            request.getRequestDispatcher("suppliers.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Supplier management data processing failure.", e);
        } finally {
            // Safe teardown allocation pools
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}