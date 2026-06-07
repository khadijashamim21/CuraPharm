package com.pharmacymanagement.curapharm;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Restored standard port 3306 
    private static final String URL = "jdbc:mysql://localhost:3306/curapharm_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";    private static final String USER = "root";
    private static final String PASSWORD = "root"; // <-- REPLACE THIS with your actual local MySQL root password

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver missing in classpath stack!");
            e.printStackTrace();
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}