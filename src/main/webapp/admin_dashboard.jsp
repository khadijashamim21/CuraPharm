<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");

    // Clear unauthorized anonymous guests
    if (username == null || role == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Explicit Role Boolean Logic Handles
    boolean isAdmin = "Admin".equalsIgnoreCase(role);
    boolean isPharmacist = "Pharmacist".equalsIgnoreCase(role);
    boolean isStaff = "Staff".equalsIgnoreCase(role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CuraPharm — Dashboard</title>
    <style>
        :root {
            --bg-main: #f8fafc; --panel-dark: #1e293b; --panel-light: #ffffff;
            --teal-accent: #0f766e; --text-dark: #334155; --text-muted: #64748b;
            --border-color: #e2e8f0; --alert-red: #ef4444;
        }
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; margin: 0; background-color: var(--bg-main); color: var(--text-dark); display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background-color: var(--panel-dark); color: #ffffff; display: flex; flex-direction: column; position: fixed; top: 0; bottom: 0; left: 0; padding: 20px 0; z-index: 100; }
        .sidebar-brand { padding: 0 25px 25px 25px; border-bottom: 1px solid #334155; margin-bottom: 20px; }
        .sidebar-brand h2 { margin: 0; font-size: 22px; color: #2dd4bf; }
        .sidebar-menu { display: flex; flex-direction: column; gap: 4px; padding: 0 15px; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; color: #cbd5e1; text-decoration: none; padding: 12px 15px; border-radius: 6px; font-size: 14px; font-weight: 500; }
        .nav-item:hover, .nav-item.active { background-color: var(--teal-accent); color: #ffffff; }
        .logout-box { padding: 0 15px; border-top: 1px solid #334155; padding-top: 15px; }
        .logout-btn { display: block; text-align: center; background-color: rgba(239, 68, 68, 0.1); color: #f87171; text-decoration: none; padding: 10px; border-radius: 6px; font-size: 14px; font-weight: 600; }
        .logout-btn:hover { background-color: var(--alert-red); color: #ffffff; }
        
        .main-viewport { margin-left: 260px; flex-grow: 1; padding: 40px; width: calc(100% - 260px); }
        .header-profile { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; background: var(--panel-light); padding: 20px 30px; border-radius: 10px; border: 1px solid var(--border-color); }
        .header-profile h1 { margin: 0; font-size: 24px; }
        .user-badge { font-size: 14px; background: #f1f5f9; padding: 6px 14px; border-radius: 20px; border: 1px solid var(--border-color); }
        
        .welcome-hero { background: linear-gradient(135deg, #0f766e, #134e4a); color: #ffffff; padding: 30px; border-radius: 12px; margin-bottom: 35px; }
        .welcome-hero h3 { margin: 0 0 10px 0; }
        .welcome-hero p { margin: 0; color: #ccfbf1; font-size: 15px; }
        
        .interactive-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px; }
        .control-card { background: var(--panel-light); border: 1px solid var(--border-color); border-radius: 10px; padding: 25px; text-decoration: none; color: inherit; display: flex; flex-direction: column; justify-content: space-between; min-height: 150px; transition: transform 0.2s; }
        .control-card:hover { transform: translateY(-4px); box-shadow: 0 12px 20px rgba(0,0,0,0.05); }
        .card-meta h4 { margin: 0 0 8px 0; font-size: 18px; }
        .card-meta p { margin: 0; font-size: 13.5px; color: var(--text-muted); line-height: 1.4; }
        .card-action-indicator { align-self: flex-end; font-size: 13px; font-weight: 600; color: var(--teal-accent); margin-top: 15px; }

        @media (max-width: 992px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; position: relative; height: auto; padding: 15px 0; }
            .sidebar-menu { flex-direction: row; flex-wrap: wrap; padding: 0 20px; }
            .logout-box { border-top: none; padding: 0 20px; margin-left: auto; }
            .main-viewport { margin-left: 0; width: 100%; padding: 20px; }
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand"><h2>CuraPharm</h2></div>
        <div class="sidebar-menu">
            <a href="admin_dashboard.jsp" class="nav-item active">Dashboard Home</a>
            <% if(isAdmin) { %><a href="user_management.jsp" class="nav-item">User Controls</a><% } %>
            <% if(isAdmin || isPharmacist) { %><a href="categories.jsp" class="nav-item">Medicine Categories</a><% } %>
            <% if(isAdmin) { %><a href="suppliers.jsp" class="nav-item">Supplier Records</a><% } %>
            <a href="medicines.jsp" class="nav-item">Stock Inventory</a>
            <a href="billing.jsp" class="nav-item">Billing & Invoices</a>
        </div>
        <div class="logout-box"><a href="index.jsp" class="logout-btn">Logout</a></div>
    </div>

    <div class="main-viewport">
        <div class="header-profile">
            <h1>Operational Cockpit</h1>
            <div class="user-badge">Role Clearance Level: <strong><%= role %></strong></div>
        </div>

        <div class="welcome-hero">
            <h3>System Terminal Initialization</h3>
            <p>Welcome back, <%= fullName %>. Your active working directory options have been adjusted to match your system clearance.</p>
        </div>

        <div class="interactive-grid">
            <%-- Requirement: Admin Account Control Management --%>
            <% if(isAdmin) { %>
            <a href="user_management.jsp" class="control-card">
                <div class="card-meta">
                    <h4>User Account Management</h4>
                    <p>Provision operator privileges, modify profiles, and deactivate staff registries.</p>
                </div>
                <div class="card-action-indicator">Open Directory →</div>
            </a>
            
            <a href="reports.jsp" class="control-card">
                <div class="card-meta">
                    <h4>System-Wide Business Analytics</h4>
                    <p>View consolidated live application statistics, transaction logs, and financial charts.</p>
                </div>
                <div class="card-action-indicator">Analyze Metrics →</div>
            </a>
            <% } %>

            <%-- Requirement: Admin configuration / Pharmacist view category blocks --%>
            <% if(isAdmin || isPharmacist) { %>
            <a href="categories.jsp" class="control-card">
                <div class="card-meta">
                    <h4>Medicine Category Mapping</h4>
                    <p><%= isAdmin ? "Configure, create, and modify system classification headers." : "View authorized medicine categories and system groups." %></p>
                </div>
                <div class="card-action-indicator">View Groupings →</div>
            </a>
            <% } %>

            <%-- Requirement: Stock Management (All Roles have custom view permissions) --%>
            <a href="medicines.jsp" class="control-card">
                <div class="card-meta">
                    <h4>Stock Inventory Ledger</h4>
                    <p><%= isStaff ? "Check active medicine availability lists and search SKU quantities." : "Add, update, modify, or delete pharmaceutical batches and monitor reserve thresholds." %></p>
                </div>
                <div class="card-action-indicator">Initialize Ledger →</div>
            </a>

            <%-- Requirement: Billing Operations (Pharmacist Independent / Staff Supervised) --%>
            <a href="billing.jsp" class="control-card">
                <div class="card-meta">
                    <h4>Billing & Invoice Generation</h4>
                    <p><%= isStaff ? "Assist with customer point-of-sale checkout operations under supervisor authorization." : "Generate customer bills, process invoices, and review transaction ledgers." %></p>
                </div>
                <div class="card-action-indicator">Launch Billing Engine →</div>
            </a>
        </div>
    </div>
</body>
</html>