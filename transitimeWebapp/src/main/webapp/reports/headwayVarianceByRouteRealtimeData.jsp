<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.transitime.reports.GenericJsonQuery" %>
<%@ page import="org.transitime.reports.SqlUtils" %>
<%
// Get the params
String agencyId = request.getParameter("a");
String vehicleId = request.getParameter("v");
String routeId = request.getParameter("r");
String beginDate = request.getParameter("beginDate");
String numDays = request.getParameter("numDays");
String beginTime = request.getParameter("beginTime");
String endTime = request.getParameter("endTime");

String sql="select * from headway where routeid="+routeId;

String jsonString = GenericJsonQuery.getJsonString(agencyId, sql);

// Respond with the JSON string
response.setContentType("application/json");
response.setHeader("Access-Control-Allow-Origin", "*");
response.getWriter().write(jsonString);
%>