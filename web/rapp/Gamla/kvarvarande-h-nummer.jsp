<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>
<%@page import="se.saljex.loginservice.LoginServiceConstants"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.loginservice.User"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%
		User user=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>JSP Page</title>
	</head>
	<body>
		
		<h1><sx-rubrik>Lista på kvaravarande H-Nummer</sx-rubrik></h1>
<%
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery("select nummer, namn, bestnr, rsk, ilager-iorder as lager, enhet from sxfakt.artikel join sxfakt.lager on nummer=artnr and lagernr = 10 and ilager-iorder >0 where nummer like 'H%' order by nummer");
%>		
<table>
	<tr><th>Artikelnr</th><th>Benämning</th><th>Best.nr</th><th>RSK</th><th>Lagersaldo</th><th>Enhet</th></tr>
	<% while (rs.next()) { %>
		<tr><td><%= rs.getString(1) %></td><td><%= rs.getString(2)%></td><td><%= rs.getString(3) %></td><td><%= rs.getString(4)%></td><td style="text-align: right;"><%= rs.getDouble(5) %></td><td><%= rs.getString(6) %></td></tr>
	<% } %>
	
</table>

	
	</body>
</html>
