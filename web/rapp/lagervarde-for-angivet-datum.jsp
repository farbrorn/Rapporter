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
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
%>			

<%
	java.sql.Date datum = null;
	try { datum = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("datum"))).getTime() );} catch (Exception e) { 		}
	if (datum==null) datum = new java.sql.Date(new Date().getTime());
%>

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
	String  levStr=null;
	String q = "select l.lagernr, sum(a.inpris*(1-rab/100)*(l.ilager-ll.forandring)) "
+" from lager l   join artikel a on a.nummer=l.artnr "
+" left outer join ( "
+" select l.lagernr as lagernr, l.artnr as artnr, sum(coalesce(lh.forandring,0)) as forandring "
+" from lager l left outer join lagerhand lh on lh.artnr=l.artnr and lh.lagernr=l.lagernr and lh.datum > ? "
+" group by l.lagernr, l.artnr "
+" ) ll on ll.lagernr=l.lagernr and ll.artnr=l.artnr"
+" group by l.lagernr "
+" order by l.lagernr ";


	ps = con.prepareStatement(q);
	ps.setDate(1, datum);

	rs = ps.executeQuery();

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Lagervärde</title>

	
<style type="text/css">
	.t-str {
		text-align: left;
		padding-right: 1em;
	}

	.t-nr {
		text-align: right;
		padding-right: 1em;
		
	}
	.fet {
		font-weight: bold;
	}
</style>	
	</head>
	<body>
		

		<h1>Lagervärde för <%= SXUtil.getFormatDate(datum) %></h1>
		<table>
			<tr>
				<th>Lagernr</th>
				<th>Varuvärde</th>
			</tr>
			<% 
				while(rs.next()) {
			%>
			<tr>
				<td><%= rs.getInt(1) %></td>
				<td style="text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble(2),0) %></td>
			</tr>			
			<% } %>			
		</table>
		
		<div><form>
			Annat datum: <input type="text" name="datum" value="<%= SXUtil.getFormatDate(datum) %>"> &nbsp; <input type="submit">
		</form></div>
		
	</body>
</html>


