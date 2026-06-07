<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CuraPharm — Secure System Access</title>
    <style>
        :root {
            --bg-gradient: linear-gradient(135deg, #0f766e, #1e293b);
            --card-bg: #ffffff;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --teal-accent: #0f766e;
            --teal-hover: #115e59;
            --border-color: #cbd5e1;
            --error-bg: #fef2f2;
            --error-text: #991b1b;
            --error-border: #fca5a5;
        }

        * { box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-gradient);
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .login-container {
            background-color: var(--card-bg);
            width: 100%;
            max-width: 420px;
            padding: 40px 35px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            animation: fadeIn 0.5s ease-out;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header h2 {
            margin: 0 0 8px 0;
            color: var(--teal-accent);
            font-size: 28px;
            letter-spacing: -0.5px;
        }

        .login-header p {
            margin: 0;
            color: var(--text-muted);
            font-size: 14px;
        }

        /* Error Alert Box Component */
        .error-alert {
            background-color: var(--error-bg);
            color: var(--error-text);
            border: 1px solid var(--error-border);
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 13.5px;
            line-height: 1.4;
            font-weight: 500;
        }

        .form-group {
            margin-bottom: 20px;
            position: relative;
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: var(--text-main);
            font-size: 13.5px;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 15px;
            color: var(--text-main);
            transition: all 0.2s ease;
            background-color: #f8fafc;
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: var(--teal-accent);
            background-color: #ffffff;
            box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.15);
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background-color: var(--teal-accent);
            color: #ffffff;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease;
            margin-top: 10px;
        }

        .btn-submit:hover {
            background-color: var(--teal-hover);
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Mobile Optimization Rules */
        @media (max-width: 480px) {
            .login-container {
                padding: 30px 20px;
            }
            .login-header h2 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>

    <div class="login-container">
        <div class="login-header">
            <h2>CuraPharm</h2>
            <p>Enter gateway keys to access management terminal</p>
        </div>

        <%-- Check if the Servlet appended an authorization exception text payload --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-alert">
                <strong>Access Blocked:</strong> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="form-group">
                <label for="username">Operator Username</label>
                <input type="text" id="username" name="username" placeholder="e.g., john_pharmacist" required autocomplete="username">
            </div>

            <div class="form-group">
                <label for="password">Security Password</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required autocomplete="current-password">
            </div>

            <button type="submit" class="btn-submit">Authenticate Account</button>
        </form>
    </div>

</body>
</html>