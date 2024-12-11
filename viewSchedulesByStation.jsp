<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>
<%
    String selectedStation = request.getParameter("stationName");
    List<String> stationList = new ArrayList<>();
    List<Map<String, Object>> scheduleList = new ArrayList<>();
    String message = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // Fetch all station names
        stmt = conn.prepareStatement("SELECT name FROM Station");
        rs = stmt.executeQuery();
        while (rs.next()) {
            stationList.add(rs.getString("name"));
        }
        rs.close();
        stmt.close();

        // Fetch schedules if a station is selected
        if (selectedStation != null && !selectedStation.trim().isEmpty()) {
            stmt = conn.prepareStatement(
                "SELECT Tschedule.schedule_id, Tschedule.transit_line, " +
                "Tschedule.origin_departure, Tschedule.destination_arrival " +
                "FROM Tschedule " +
                "JOIN Station ON (Station.sid = Tschedule.origin_id OR Station.sid = Tschedule.destination_id) " +
                "WHERE Station.name = ?"
            );
            stmt.setString(1, selectedStation);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> schedule = new HashMap<>();
                schedule.put("schedule_id", rs.getInt("schedule_id"));
                schedule.put("transit_line", rs.getString("transit_line"));
                schedule.put("origin_departure", rs.getTimestamp("origin_departure"));
                schedule.put("destination_arrival", rs.getTimestamp("destination_arrival"));
                scheduleList.add(schedule);
            }
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace(); // Log error for debugging
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Schedules by Station</title>
</head>
<body>
    <h1>View Schedules for a Station</h1>

    <!-- Dropdown to select station name -->
    <form method="GET" action="viewSchedulesByStation.jsp">
        <label for="stationName">Select a Station:</label>
        <select name="stationName" required>
            <option value="" disabled selected>Select Station</option>
            <% 
                for (String station : stationList) {
            %>
            <option value="<%= station %>" <%= selectedStation != null && selectedStation.equals(station) ? "selected" : "" %>><%= station %></option>
            <% 
                }
            %>
        </select><br>
        <input type="submit" value="Search">
    </form>

    <% 
        if (selectedStation != null && !selectedStation.trim().isEmpty()) {
            if (!scheduleList.isEmpty()) {
    %>
    <h3>Schedules for <%= selectedStation %></h3>
    <table border="1">
        <tr>
            <th>Schedule ID</th>
            <th>Transit Line</th>
            <th>Origin Departure</th>
            <th>Destination Arrival</th>
        </tr>
        <% 
            for (Map<String, Object> schedule : scheduleList) {
        %>
        <tr>
            <td><%= schedule.get("schedule_id") %></td>
            <td><%= schedule.get("transit_line") %></td>
            <td><%= schedule.get("origin_departure") %></td>
            <td><%= schedule.get("destination_arrival") %></td>
        </tr>
        <% 
            }
        %>
    </table>
    <% 
            } else {
    %>
    <p>No schedules found for this station.</p>
    <% 
            }
        }
    %>

    <% if (!message.isEmpty()) { %>
    <p style="color: red;"><%= message %></p>
    <% } %>
</body>
</html>
