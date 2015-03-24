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
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
		java.sql.Date datum = null;
		
		
		try { datum = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("datum"))).getTime() );} catch (Exception e) { out.print(e.toString());		}
		if (datum==null) datum = new java.sql.Date( (new Date()).getTime() );
		
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Fakturor</title>

	
<style type="text/css">
	
		
	
table {
	table-layout: fixed;
	border-collapse: collapse;
	font-size:12px; 
}

table th {
	font-size: 50%;
	font-weight: Bold;
	text-align: left;
}

.maindiv {
	width: 100%;
}

.kundrubrik {
	padding-top: 2em;
	font-weight: bold;
}

.notering {
	color: red;
}

.right {
	text-align: right;
}

</style>	
	</head>
	<body>
		<div class="maindiv">
		
		<h1 style="visibility: hidden"><sx-rubrik>Dagens fakturor</sx-rubrik></h1>
	</form></div>
<%
		Statement st = con.createStatement();
		ResultSet rs;
		PreparedStatement ps;
		String q;
		q = 
"select f1.faktnr, f1.kundnr, f1.namn, f1.t_netto, f1.t_attbetala, f1.t_moms, f2.artnr, f2.namn, f2.lev, f2.enh, f2.pris, f2.rab, f2.summa, f2.netto,f2.text,0,0,0,0,0 " 
+" , case when f2.pris=0 and f2.artnr not like '*UD%' and f2.lev <> 0 "
+" and not f2.namn ~ '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\\\\-+)|([A-Za-z0-9]+\\\\.+)|([A-Za-z0-9]+\\\\++))*[A-Za-z0-9]+@((\\\\w+\\\\-+)|(\\\\w+\\\\.))*\\\\w{1,63}\\\\.[a-zA-Z]{2,6}$'  "
+" then 'Priset är 0'  else '' end || ' ' "
+" || case when f2.pris < f2.netto and f2.artnr not like '*UD%' and f2.artnr<>'*BONUS*' and f2.netto>0 and not (f2.pris=0.01 and f2.rab=99) then 'Negativ täckning'  else '' end as varning"
+" from faktura1 f1 left outer join faktura2 f2 on f1.faktnr=f2.faktnr "
+" where f1.datum = ? "
+" order by f1.faktnr, f2.pos ";

		ps = con.prepareStatement(q);
		ps.setDate(1,datum );
		
		rs = ps.executeQuery();
		Integer tempFaktnr = null;
		Double tempTAttbetala = null;
		Double tempTNetto = null;
		Double tempTMoms = null;
		
%>
	<table>
			<colgroup>
				<col style="width: 8em;">
				<col style="width: 35em;">
				<col style="width: 6em;  text-align: right;">
				<col style="width: 3em;">
				<col style="width: 6em;  text-align: right; ">
				<col style="width: 3em; text-align: right;">
				<col style="width: 8em; text-align: right;">
				<col style="width: 8em; text-align: right;">
				<col style="width: 30em;">
			</colgroup>


<%		while (rs.next()) {	%>
			<%		if (tempFaktnr == null || !tempFaktnr.equals(rs.getInt(1))) { %>


<% // tempKundnr!=null ? "</table>" : "" %>			
<%			tempFaktnr = rs.getInt(1);  
			tempTAttbetala = rs.getDouble(5);
			tempTNetto = rs.getDouble(4);
			tempTMoms = rs.getDouble(6);
%>

			<tr >
				<td colspan="1" class="kundrubrik"><%= rs.getString(1) %></td>
				<td colspan="3" class="kundrubrik"><%= rs.getString(3) %></td>
				<td colspan="4" class="kundrubrik right"><%= SXUtil.getFormatNumber(rs.getDouble(5)) %></td>
			</tr>
				<tr><th>Artnr</th><th>Benämning</th><th class="right">Antal</th><th>Enh</th><th class="right">Pris</th><th class="right">%</th><th class="right">Summa</th><th class="right">Inköpspris</th><TH>Not</th></tr>
<% }
	
%>
	<tr>
		<td><%= rs.getString(7) %></td>
		<td><%= SXUtil.toStr(rs.getString(7)).isEmpty() && !SXUtil.toStr(rs.getString(15)).isEmpty() ? rs.getString(15) : rs.getString(8) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(9),1) %></td>
		<td><%= rs.getString(10) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(11),2) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(12),1) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(13),2) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(14),2) %></td>
		<td class="notering"><%= rs.getString(21) %></td>
	</tr>

<% } %>
	
	</table>
	
</div>				
	</body>
</html>
