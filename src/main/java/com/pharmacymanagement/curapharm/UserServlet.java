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

@WebServlet(name = "UserServlet", urlPatterns = {"/UserServlet"})
public class UserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Gather account parameters from post submission
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("full_name");
        String role = request.getParameter("role");

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // 2. Query data link utility
            conn = DBConnection.getConnection();
            
            // 3. Compile target entry transaction parameters
            String sql = "INSERT INTO Users (username, password, full_name, role) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);
            ps.setString(4, role);
            
            // 4. Commit security record parameters
            ps.executeUpdate();
            
            // 5. Echo back loop update
            request.setAttribute("message", "Account for '" + fullName + "' successfully provisioned!");
            request.getRequestDispatcher("user_management.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Identity tracking configuration commit failure.", e);
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}