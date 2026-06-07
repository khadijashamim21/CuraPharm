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

@WebServlet(name = "EditHandlerServlet", urlPatterns = {"/EditHandlerServlet"})
public class EditHandlerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String actionType = request.getParameter("action_type");
        Connection conn = null;
        PreparedStatement ps = null;
        String redirectPage = "admin_dashboard.jsp";

        try {
            conn = DBConnection.getConnection();

            if ("update_category".equalsIgnoreCase(actionType)) {
                int id = Integer.parseInt(request.getParameter("category_id"));
                String name = request.getParameter("category_name");
                String desc = request.getParameter("description");
                
                ps = conn.prepareStatement("UPDATE Categories SET category_name=?, description=? WHERE category_id=?");
                ps.setString(1, name);
                ps.setString(2, desc);
                ps.setInt(3, id);
                redirectPage = "categories.jsp";
                
            } else if ("update_supplier".equalsIgnoreCase(actionType)) {
                int id = Integer.parseInt(request.getParameter("supplier_id"));
                String name = request.getParameter("supplier_name");
                String contact = request.getParameter("contact_name");
                String phone = request.getParameter("phone");
                String email = request.getParameter("email");
                String address = request.getParameter("address");
                String bank = request.getParameter("bank_details");
                
                ps = conn.prepareStatement("UPDATE Suppliers SET supplier_name=?, contact_name=?, phone=?, email=?, address=?, bank_details=? WHERE supplier_id=?");
                ps.setString(1, name);
                ps.setString(2, contact);
                ps.setString(3, phone);
                ps.setString(4, email);
                ps.setString(5, address);
                ps.setString(6, bank);
                ps.setInt(7, id);
                redirectPage = "suppliers.jsp";
                
            } else if ("update_medicine".equalsIgnoreCase(actionType)) {
                int id = Integer.parseInt(request.getParameter("medicine_id"));
                String name = request.getParameter("medicine_name");
                int catId = Integer.parseInt(request.getParameter("category_id"));
                int supId = Integer.parseInt(request.getParameter("supplier_id"));
                BigDecimal price = new BigDecimal(request.getParameter("price"));
                int qty = Integer.parseInt(request.getParameter("quantity"));
                String expiry = request.getParameter("expiry_date");
                
                ps = conn.prepareStatement("UPDATE Medicines SET medicine_name=?, category_id=?, supplier_id=?, price=?, quantity=?, expiry_date=? WHERE medicine_id=?");
                ps.setString(1, name);
                ps.setInt(2, catId);
                ps.setInt(3, supId);
                ps.setBigDecimal(4, price);
                ps.setInt(5, qty);
                ps.setString(6, expiry);
                ps.setInt(7, id);
                redirectPage = "medicines.jsp";
            }

            if (ps != null) {
                ps.executeUpdate();
            }
        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Data modification update engine failed.", e);
        } finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
        }
        response.sendRedirect(redirectPage);
    }
}