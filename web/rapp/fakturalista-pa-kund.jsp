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
                String databaseSchema = "sxfakt";
                
                if ("no".equals(request.getParameter("land"))) { databaseSchema="sxasfakt"; }
                
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
		java.sql.Date frdat = null;
                String kundnr = null;
		
		kundnr = request.getParameter("kundnr");
		try { frdat = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("frdat"))).getTime() );} catch (Exception e) { out.print(e.toString());		}
		if (frdat==null) frdat = new java.sql.Date( (new Date()).getTime() - 365*24*3600*1000 );
                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Fakturalista</title>

	
<style type="text/css">
	
		
	
table {
	table-layout: fixed;
	border-collapse: collapse;
	font-size:14px; 
}

table th {
	font-size: 50%;
	font-weight: Bold;
	text-align: left;
}
table td {
	padding: 4px;
}

.maindiv {
	width: 100%;
}

.notering {
	color: red;
}

.right {
	text-align: right;
}
@media print {
.noprint { display: none; }
}
</style>	
	</head>
	<body>
		<div class="maindiv">
		
		<h1 style="display: none"><sx-rubrik>Fakturalista på kund</sx-rubrik></h1>
	
<%
		Statement st = con.createStatement();
		ResultSet rs;
		PreparedStatement ps;
		String q;
		q = 
"select f1.faktnr, f1.datum, f1.t_attbetala, bj.betdat, bj.bet, bj.betsatt "
+" from " + databaseSchema + ".faktura1 f1 "
+" left outer join " + databaseSchema + ".betjour bj on bj.faktnr=f1.faktnr "
+" where f1.kundnr=? and f1.datum >= ? "
+" order by f1.faktnr, bj.betdat";

		ps = con.prepareStatement(q);
		ps.setString(1,kundnr );
		ps.setDate(2,frdat );
		
		rs = ps.executeQuery();
		Integer tempFaktnr = null;
		
%>

<h2>Fakturalista</h2>
<div class="noprint">
    <form>
        Kundnr:<input type="text" name="kundnr" value="<%= SXUtil.toStr(kundnr) %>">
        Från datum: <input type="text" name="frdat" value="<%= SXUtil.getFormatDate(frdat) %>">
        <input type="radio" name="land" value="se" checked> Sverige &nbsp;&nbsp;&nbsp; <input type="radio" name="land" value="no"> Norge
        <input type="submit">
    </form>
</div>
<table>
    <tr><td>Kundnr</td><td><%= SXUtil.toHtml(kundnr) %></td></tr>
    <tr><td>Från datum</td><td><%= SXUtil.getFormatDate(frdat)  %></td></tr>
</table>
	<table>
<tr>
    <th>Fakturanr</th><th>Datum</th><th>Belopp</th><th>Betaldatum</th><th>Betalt</th><th>Typ</th>
</tr>

<%		while (rs.next()) {	%>
	<tr >
			<%		if (tempFaktnr == null || !tempFaktnr.equals(rs.getInt(1))) { %>

<%			tempFaktnr = rs.getInt(1);  
%>
                            <td><%= rs.getString(1) %></td>
                            <td><%= rs.getString(2) %></td>
                            <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(3)) %></td>
<% } else { %>
                            <td colspan="3"> </td>
<% } %>
                            <td><%= SXUtil.toStr(rs.getString(4)) %></td>
                            <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(5)) %></td>
                            <td><%= SXUtil.toStr(rs.getString(6)) %></td>

        </tr>	
<% } %>
	</table>
	
</div>				
	</body>
</html>
