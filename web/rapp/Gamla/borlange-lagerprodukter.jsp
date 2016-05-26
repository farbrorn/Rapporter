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
		
		<h1><sx-rubrik>Lagerlagda produkter Borlänge</sx-rubrik></h1>
<%
		Statement st = con.createStatement();
		ResultSet rs = st.executeQuery("select a.nummer, a.namn, a.lev, a.bestnr, a.rsk, a.enhet, l.bestpunkt, l.maxlager, l.ilager from artikel a, lager l where a.nummer=l.artnr and l.lagernr=10 and l.maxlager > 0 and a.nummer not like 'H%' order by a.nummer");
%>		
<table>
	<tr><th>Nummer</th><th>Benämning</th><th>Leverantör</th><th>Bestnr</th><th>Rsk</th><th>Enhet</th><th>Best.punkt</th><th>Max lager</th><th>Lagersaldo</th></tr>
	<% while (rs.next()) { %>
		<tr><td><%= rs.getString(1) %></td><td><%= rs.getString(2)%></td><td><%= rs.getString(3) %></td><td><%= rs.getString(4)%></td><td><%= rs.getString(5)%></td><td><%= rs.getString(6)%></td>
			<td><%= rs.getDouble(7)%></td><td><%= rs.getDouble(8)%></td><td><%= rs.getDouble(9)%></td>
		</tr>
	<% } %>
	
</table>

	
	</body>
</html>
