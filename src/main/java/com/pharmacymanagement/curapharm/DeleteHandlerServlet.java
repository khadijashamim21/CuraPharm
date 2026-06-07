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

@WebServlet(name = "DeleteHandlerServlet", urlPatterns = {"/DeleteHandlerServlet"})
public class DeleteHandlerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String type = request.getParameter("type");
        String idStr = request.getParameter("id");
        String redirectPage = "admin_dashboard.jsp";

        if (type != null && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Connection conn = DBConnection.getConnection();
                String sql = "";

                switch (type.toLowerCase()) {
                    case "category":
                        sql = "DELETE FROM Categories WHERE category_id = ?";
                        redirectPage = "categories.jsp";
                        break;
                    case "supplier":
                        sql = "DELETE FROM Suppliers WHERE supplier_id = ?";
                        redirectPage = "suppliers.jsp";
                        break;
                    case "medicine":
                        sql = "DELETE FROM Medicines WHERE medicine_id = ?";
                        redirectPage = "medicines.jsp";
                        break;
                }

                if (!sql.isEmpty()) {
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, id);
                    ps.executeUpdate();
                    ps.close();
                }
                conn.close();
            } catch (SQLException | NumberFormatException e) {
                throw new ServletException("Relational integrity protection rule restriction. Cannot delete active records.", e);
            }
        }
        response.sendRedirect(redirectPage);
    }
}