<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="se.saljex.sxlibrary.exceptions.SxInfoException"%>
<%@page import="se.saljex.sxlibrary.SXConstant"%>
<%@page import="java.util.Calendar"%>
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
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");

		Date datum;
		try { //datum = new Date(request.getParameter("datum")); 
			datum = dateFormatter.parse(request.getParameter("datum"));
		} catch (Exception e) { throw new SxInfoException("Felaktigt datum i parameter datum");} 
		
		
		if (!user.isBehorighet("Ekonomi")) throw new SxInfoException("Ingen behörighet");
		
%>			

<%
		  
	ResultSet rs=null;
	PreparedStatement ps=null;
	
	String q =
" select aa.faktnr, NAMN, aa.reskontra from ( " +
" select a.faktnr,  sum(kundres+betalt-fakturerat) as reskontra " +

" from ( " +
" select faktnr, null as filterdatum, round(tot::numeric,2) as kundres, " +
" 0 as betalt,0 as fakturerat from kundres " +
" union select faktnr, betdat as filterdatum, 0 as kundres, " +
" round(bet::numeric,2) as betalt,0 as fakturerat from betjour " +
" union select faktnr, datum as filterdatum, 0 as kundres, 0 as betalt, round(t_attbetala::numeric,2) as fakturerat from faktura1 "+
" ) a " +
" where (a.filterdatum is null or a.filterdatum > ?) "+ 
" group by a.faktnr "+
" having sum(a.kundres+a.betalt-a.fakturerat) <> 0 "+ 
" order by a.faktnr"+ 
" ) aa "+
" left outer join faktura1 f1 on f1.FAKTNR = aa.faktnr"

			  ;

			  

	ps = con.prepareStatement(q);
	ps.setDate(1, new java.sql.Date(datum.getTime()));
	rs = ps.executeQuery();
	

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Kundreskontra</title>
	
<style type="text/css">
	.right { text-align: right;}
</style>	
	</head>
	<body>
		<h1>Kundreskontra <%= dateFormatter.format(datum) %></h1>

		<%
		Double tot = 0.0;
		%>
		<table>
		<tr><th>Faktura</th><th>Kund</th><th>Belopp</th></tr>
		<%  while(rs.next()) { %>
			<tr>
				<td><%= rs.getString(1)  %></td>
				<td><%= SXUtil.toHtml(rs.getString(2)) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(3)) %></td>
			</tr>
			<% tot += rs.getDouble(3); %>
		<% } %>
		</table>
		<div>
			<b>Totalt: <%= SXUtil.getFormatNumber(tot) %>
		</div>
			
	</body>
</html>


