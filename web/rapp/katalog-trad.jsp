<%-- 
    Document   : katalog-vvs
    Created on : 2013-jan-28, 10:30:04
    Author     : Ulf
--%>
<%@page import="se.saljex.rapporter.KatalogArtikel"%>
<%@page import="se.saljex.rapporter.KatalogKlase"%>
<%@page import="se.saljex.rapporter.Util"%>
<%@page import="se.saljex.rapporter.KatalogGrupp"%>
<%@page import="se.saljex.rapporter.KatalogHandler"%>
<%@page import="se.saljex.rapporter.Katalog"%>
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
		
		Katalog katalog = KatalogHandler.getKatalog(con, 0, true);		
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>


<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	</head>
	<h1><sx-rubrik>Katalog</sx-rubrik></h1>
	<p>Klicka på önskad katalog</p>
	<% String marg=""; %>
	<% Integer prevLevel = null; %>
	<% for (KatalogGrupp grupp : katalog.getGrupper()) { %>
		<% if (prevLevel==null || prevLevel < grupp.getTreeLevel()) { // Ny grupp %>
			<% prevLevel = grupp.getTreeLevel(); %>
		<% } %>
		<% if (prevLevel > grupp.getTreeLevel()) { %>
			<% prevLevel = grupp.getTreeLevel(); %>
			<% marg = "margin-top: 0.5em;"; %>
		<% } else marg = ""; %>
		<div style ="padding-left: <%= (grupp.getTreeLevel()*2)+"em; " + marg %> "><a href="../api/katalog.jsp?root=<%= grupp.getGrpId() %>"><%= Util.toHtml(grupp.getRubrik() + "(" + grupp.getGrpId() + ")" ) %></a></div>
	<% } %>
	</li></ul>
</html>
