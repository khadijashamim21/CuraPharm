package com.pharmacymanagement.curapharm;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String usernameInput = request.getParameter("username");
        String passwordInput = request.getParameter("password");

        if (usernameInput == null || passwordInput == null || usernameInput.trim().isEmpty() || passwordInput.trim().isEmpty()) {
            request.setAttribute("error", "Username and password fields cannot be empty.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        String sqlQuery = "SELECT username, password, role, full_name FROM Users WHERE username = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlQuery)) {
            
            ps.setString(1, usernameInput.trim());
            ps.setString(2, passwordInput.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String dbUsername = rs.getString("username");
                    String dbRole = rs.getString("role");
                    String dbFullName = rs.getString("full_name");

                    HttpSession session = request.getSession(true);
                    session.setAttribute("username", dbUsername);
                    session.setAttribute("role", dbRole);
                    session.setAttribute("fullName", dbFullName != null ? dbFullName : dbUsername);

                    response.sendRedirect("admin_dashboard.jsp");
                    return;
                    
                } else {
                    request.setAttribute("error", "Invalid credentials or unmapped clearance key.");
                    request.getRequestDispatcher("index.jsp").forward(request, response);
                    return;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database connection gateway failure: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("index.jsp");
    }
}