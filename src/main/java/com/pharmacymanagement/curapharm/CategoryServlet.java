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

@WebServlet(name = "CategoryServlet", urlPatterns = {"/CategoryServlet"})
public class CategoryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoryName = request.getParameter("category_name");
        String description = request.getParameter("description");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO Categories (category_name, description) VALUES (?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, categoryName);
            ps.setString(2, description);
            
            ps.executeUpdate();
            
            request.setAttribute("message", "Category '" + categoryName + "' added successfully!");
            request.getRequestDispatcher("categories.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Database process failed", e);
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}