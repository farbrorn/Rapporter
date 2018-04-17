<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="se.saljex.loginservice.LoginServiceConstants"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.loginservice.User"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>


<%
		User user=null;
		Connection conSuper=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { conSuper = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Överför lagersaldo till Norge</title>

	</head>
	<body>
		
		<h1 style="visibility: hidden"><sx-rubrik>Överför lagersaldo till Norge</sx-rubrik></h1>
<%
		String q;
		q = 
		"delete from sxasfakt.lager; " +
		" insert into sxasfakt.lager select * from sxfakt.lager;";
		Statement st = conSuper.createStatement();
			st.executeUpdate(q);
			out.print("Uppdatering klar!");
		
%>

	</body>
</html>

