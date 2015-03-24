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
		Integer lagernr = null;
		
		
		try { lagernr = new Integer( (String)request.getParameter("lagernr"));} catch (Exception e) { out.print(e.toString());		}
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Lista på order för samfakt</title>

	
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
		
		<h1 style="visibility: hidden"><sx-rubrik>Orderlista för samfakt</sx-rubrik></h1>
<DIV><form action="?" METHOD="GET" >Välj lager: <input type="number" name="lagernr"><button type="submit">Uppdatera</button>
	</form></div>
<%
		Statement st = con.createStatement();
		ResultSet rs;
		PreparedStatement ps;
		String q;
		q = 
"select o1.kundnr, o1.namn, o1.ordernr, o1.datum, o2.pos, o2.artnr, o2.namn, o2.lev, o2.enh, o2.pris, " 
+" o2.rab, o2.netto, a.minsaljpack, bn.bonus, rn.ranta, o2.summa, o1.lagernr, 0, 0, 0 " 
+" , case when o2.pris=0 and o2.artnr not like '*UD%' and o2.lev <> 0 "
+" and not o2.namn ~ '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\\\\-+)|([A-Za-z0-9]+\\\\.+)|([A-Za-z0-9]+\\\\++))*[A-Za-z0-9]+@((\\\\w+\\\\-+)|(\\\\w+\\\\.))*\\\\w{1,63}\\\\.[a-zA-Z]{2,6}$'  "
+" then 'Priset är 0'  else '' end || ' ' "
+" || case when o2.pris < o2.netto and o2.artnr not like '*UD%' and o2.netto>0 and not (o2.pris=0.01 and o2.rab=99) then 'Negativ täckning'  else '' end || ' ' || "
+" case when o2.lev::numeric % case when coalesce(a.minsaljpack,1) <= 0 then case when o2.lev=0 then 1 else o2.lev end else a.minsaljpack end::numeric <> 0   then 'Bruten odelbar förpackning'  else '' end as varning "
+" from order1 o1 left outer join order2 o2 on o2.ordernr=o1.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join kund k on k.nummer=o1.kundnr  "
+" left outer join (select kund as kundnr, sum(bonus) as bonus from bonus group by kund) bn on bn.kundnr=o1.kundnr "
+" left outer join (select kundnr as kundnr, sum(ranta) as ranta from ranta group by kundnr) rn on rn.kundnr = o1.kundnr "
+" where o1.status in ('Samfak','Hamt') and (o1.lagernr=? or 1=?) order by o1.kundnr, o1.ordernr, o2.pos ";

		ps = con.prepareStatement(q);
		ps.setInt(1,lagernr==null ? 0 : lagernr );
		ps.setInt(2,lagernr==null ? 1 : 0 );
		
		rs = ps.executeQuery();
		String tempKundnr = null;
		Double tempBonus = null;
		Double tempRanta = null;
		Double kundsumma=0.0;
		Double totalsumma = 0.0;
%>
	<table>
			<colgroup>
				<col style="width: 8em;">
				<col style="width: 15em;">
				<col style="width: 45em;">
				<col style="width: 10em; text-align: right;">
				<col style="width: 5em; ">
				<col style="width: 10em; text-align: right;">
				<col style="width: 5em; text-align: right;">
				<col style="width: 10em; text-align: right;">
				<col style="width: 10em; text-align: right;">
				<col style="width: 30em;">
			</colgroup>


<%		while (rs.next()) {	%>
<%		if (tempKundnr== null || !tempKundnr.equals(rs.getString(1))) { %>

<% if (tempKundnr!=null) { //Skriv footer %>
<tr><td colspan="2"></td><td colspan="7" style="text-align: right; font-weight: bold">Totalt ordervärde: <%= SXUtil.getFormatNumber(kundsumma) %></td><td></td></tr>
<tr><td colspan="2"></td><td colspan="7" style="text-align: right">Bonus att utbetala: <%= SXUtil.getFormatNumber(tempBonus) %><%= tempBonus > kundsumma && kundsumma>0 ? "<br>Bonus högre än orderbelopp" : "" %></td></tr>
	<% if (kundsumma.compareTo(1000000.0)>0){%>
		<tr><td colspan="2"></td><td class="notering" colspan="7" style="text-align: right; font-weight: bold">Stor fakturasumma</td><td></td></tr>
	<% } %>
		
<% } %>


<% // tempKundnr!=null ? "</table>" : "" %>			
<%			tempKundnr = rs.getString(1);  
			tempBonus = rs.getDouble(14);
			tempRanta = rs.getDouble(15);
			kundsumma=0.0;
%>

			<tr >
				<td colspan="2" class="kundrubrik"><%= rs.getString(1) %></td>
				<td colspan="3" class="kundrubrik"><%= rs.getString(2) %></td>
			</tr>
				<tr><th>Order</th><th>Artnr</th><th>Benämning</th><th class="right">Antal</th><th>Enh</th><th class="right">Brutto</th><th class="right">%</th><th class="right">Netto</th><th class="right">Inköpspris</th><TH>Not</th></tr>
<% }
	kundsumma+=rs.getDouble(16);
	totalsumma+=rs.getDouble(16);
	
%>
	<tr>
		<td><%= rs.getString(17) %>-<%= rs.getString(3) %></td>
		<td><%= rs.getString(6) %></td>
		<td><%= rs.getString(7) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(8),1) %></td>
		<td><%= rs.getString(9) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(10)) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(11),0) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(10) * (1-rs.getDouble(11)/100)) %></td>
		<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(12)) %></td>
		<td class="notering"><%= rs.getString(21) %></td>
	</tr>

<% } %>
<tr><td colspan="2"></td><td colspan="7" style="text-align: right; font-weight: bold">Totalt ordervärde: <%= SXUtil.getFormatNumber(kundsumma) %></td><td></td></tr>
<tr><td colspan="2"></td><td colspan="7" style="text-align: right">Bonus att utbetala: <%= SXUtil.getFormatNumber(tempBonus) %><%= tempBonus > kundsumma && kundsumma>0 ? "<br>Bonus högre än orderbelopp" : "" %></td></tr>
	<% if (kundsumma.compareTo(1000000.0)>0){%>
		<tr><td colspan="2"></td><td class="notering" colspan="7" style="text-align: right; font-weight: bold">Stor fakturasumma</td><td></td></tr>
	<% } %>

	<tr><td colspan="2"></td><td colspan="7" style="text-align: right; padding-top: 2em;">Totalt varuvärde: <%= SXUtil.getFormatNumber(totalsumma) %></td></tr>
	
	</table>
	
</div>				
	</body>
</html>

<%!
public void printKundFooter(Double kundsumma, Double tempBonus) { 
	} 

%>

<%!
public String getEnh(String s) {
		if ("ST".equals(s)) return "st";
		else if ("M".equals(s)) return "m";
		else if ("M2".equals(s)) return "m²";
		else if ("M3".equals(s)) return "m³";
		else if ("KG".equals(s)) return "Kg";
		else if ("PAR".equals(s)) return "Par";
		else if ("KG".equals(s)) return "Kg";
		return s;
	}
%>