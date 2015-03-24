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
		
		<h1><sx-rubrik>Översättningstabell H-Nummer</sx-rubrik></h1>
<%
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery("select a1.artnr, a1.namn, a2.nummer, a2.namn from heartmap m join heartikel a1 on a1.artnr=m.hartnr join artikel a2 on a2.nummer=m.artnr order by a1.artnr");
%>		
<table>
	<tr><th>H-Nummer</th><th>Benämning</th><th>Nytt nr</th><th>Benämning</th></tr>
	<% while (rs.next()) { %>
		<tr><td><%= rs.getString(1) %></td><td><%= rs.getString(2)%></td><td><%= rs.getString(3) %></td><td><%= rs.getString(4)%></td></tr>
	<% } %>
	
</table>

	
	</body>
</html>
