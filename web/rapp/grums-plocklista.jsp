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
		java.sql.Date utskrivenDatum = null;
		java.sql.Time utskrivenTid = null;
		try { utskrivenDatum = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("utskrivendatum"))).getTime() );} catch (Exception e) { out.print(e.toString());		}
		try { utskrivenTid = new java.sql.Time((timeFormatter.parse((String)request.getParameter("utskriventid"))).getTime());} catch (Exception e) {out.print(e.toString());		}
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Plocklista</title>

	
<style type="text/css">

table {
	table-layout: fixed;
	border-collapse: collapse;
}

.order { 
	page-break-after: always;
	width: 100%;
	
}	
.order td {
	
}

.order tr {
}

.avoid_page_break {
	page-break-inside: avoid;	
}

.order th {
	text-align: left;
	vertical-align: text-top;
	font-size: 60%;
	font-weight: bold;
}

.orderhuvud {
	width: 100%;
}
.orderrader {
	width: 100%;
}

.border_btn {
	border-bottom: 1px solid black;
}

.maindiv {
	width: 100%
}
.c-lp {
	width: 5%;
	padding-right: 4px;	
}
.c-artnr {
	width: 16%;
	padding-right: 4px;	
}
.c-artnamn {
	width: 40%;
	padding-right: 4px;	
}
.c-antal {
	width: 16%;
	text-align: right;
	padding-right: 4px;	
}
.c-enh {
	width: 8%;
	padding-right: 4px;	
}
.c-levererat {
	width: 15%;
	padding-right: 4px;	
}


</style>	
	</head>
	<body>
		<div class="maindiv">
		
		<h1 style="visibility: hidden"><sx-rubrik>Plocklista Grums</sx-rubrik></h1>
<%
if (utskrivenDatum!=null) out.print(utskrivenDatum.toString()); else out.print("inget datum");
		Statement st = con.createStatement();
		ResultSet rs;
		PreparedStatement ps;
		String q;
		if (utskrivenDatum == null || utskrivenTid == null) {
			rs = st.executeQuery("select distinct utskrivendatum, utskriventid from order2 where utskrivendatum is not null order by utskrivendatum desc, utskriventid desc");
%>		
			<table>
				<tr><th>Utskriven</th></tr>
				<% while (rs.next()) { %>
					<tr>
						<td>
							<a href="?utskrivendatum=<%= URLEncoder.encode(dateFormatter.format(rs.getDate(1)), "ISO-8859-1")  + "&utskriventid=" + URLEncoder.encode(timeFormatter.format(rs.getTime(2)), "ISO-8859-1") %>">
							<%= rs.getDate(1).toString() + " " + rs.getTime(2).toString() %></a>
						</td>	
					</tr>
				<% } %>

			</table>
<%		} else {

			q = " select "
			+" o1.lagernr, o1.ordernr, o1.dellev, o1.datum, o1.kundnr, o1.namn, o1.adr1, o1.adr2, o1.adr3, o1.levadr1, "
			+" o1.levadr2, o1.levadr3, o1.marke,  o1.status, o1.levdat, o1.fraktbolag, o1.ordermeddelande, o1.linjenr1, o1.linjenr2, o1.linjenr3,  "
			+" o2.pos, o2.artnr, o2.namn, o2.best, o2.enh, o2.levnr, o2.text, o2.utskrivendatum, o2.utskriventid, o2.stjid, "
			+" a.refnr, a.rsk, a.enummer, a.plockinstruktion, l.ilager, l.iorder, l.best, l.lagerplats, a.minsaljpack, a.forpack, a.kop_pack"
			+" from order1 o1 left outer join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join lager l on l.lagernr=0 and l.artnr=o2.artnr "
			+" where o1.ordernr in (select ordernr from order2 where utskrivendatum=? and utskriventid=?) "
			+" order by o1.ordernr, o2.pos, l.lagerplats, o2.pos";
			 ps = con.prepareStatement(q);
			 ps.setDate(1, utskrivenDatum);
			 ps.setTime(2, utskrivenTid);
			 rs = ps.executeQuery();
			 
			 int prevOrdernr = 0;
			 int radCn=0;
%>
				<% while (rs.next()) { %>
					<% if (prevOrdernr==0 || rs.getInt(2) != prevOrdernr) { %>
						<% if (prevOrdernr!=0) { %>
							</table></div></div>
						<% } %>
						<% prevOrdernr = rs.getInt(2); 
							radCn = 0;
						%>
						<div class="order">
							<div class="orderhuvud">
								<div><b>Plocksedel</b></div>
						<table width="100%">
							<tr>
								<th>Ordernr</th>
								<th>Datum</th>
							</tr>
							<tr>
								<td><%= rs.getInt(2) %></td>
								<td><%= SXUtil.getFormatDate(rs.getDate(4)) %></td>
							</tr>
							
							<tr>
								<th>Kundnr</th>
								<th>Kund</th>
							</tr>
							<tr>
								<td><%= SXUtil.toHtml(rs.getString(5)) %></td>
								<td><%= SXUtil.toHtml(rs.getString(6)) %></td>
							</tr>
							<tr>
								<th>Adress</th><th>Leveransadress</th>
							</tr>
							<tr>
								<td><%=SXUtil.toHtml(rs.getString(7))%></td><td><b><%=SXUtil.toHtml(rs.getString(10))%></b></td>
							</tr>
							<tr>
								<td><%=SXUtil.toHtml(rs.getString(8))%></td><td><b><%=SXUtil.toHtml(rs.getString(11))%></b></td>
							</tr>
							<tr>
								<td><%=SXUtil.toHtml(rs.getString(9))%></td><td><b><%=SXUtil.toHtml(rs.getString(12))%></b></td>
							</tr>
							<tr>
								<th colspan="2">Märke</th>
							</tr>
							<tr>
								<td colspan="2"><%=SXUtil.toHtml(rs.getString(13))%></td>
							</tr>
							<tr>
								<th>Levdat</th><td><%=SXUtil.getFormatDate(rs.getDate(15))%></td>
							</tr>
							<tr>
								<th>Not</th><td><%=SXUtil.toHtml(rs.getString(17))%></td>
							</tr>
							<tr>
								<th colspan="2">Linjer</th>
							</tr>
							<tr>
								<td colspan="2"><%=SXUtil.toHtml(rs.getString(18)) + " " + SXUtil.toHtml(rs.getString(19)) + " " + SXUtil.toHtml(rs.getString(20)) %></td>
							</tr>
						</table>
							</div>
							<div class="orderrader">
						<table width="100%">
							<tr><th class="border_btn c-lp">Lp/pos</th><th class="border_btn c-artnr">Nummer</th><th class="border_btn c-artnamn">Benämning</th><th class="border_btn c-antal">Antal</th><th class="border_btn c-enh">Enhet</th><th class="border_btn">Levererat</th></tr>					
					<% } %>
					<% radCn++; %>
					<% if (SXUtil.isEmpty(rs.getString(27))) { %>
					<tr class="avoid_page_break">
						<td colspan="6" class="avoid_page_break">
							<table width="100%">
								<tr>
									<td rowspan="3" class="border_btn c-lp"><%= SXUtil.toHtml(rs.getString(38)) %><br><small><%= radCn %></small></td>
									<td class="c-artnr"><%= SXUtil.toHtml(rs.getString(22)) %></td>
									<td class="c-artnamn"><%= SXUtil.toHtml(rs.getString(23)) %></td>
									<% 
										long hela = 0;
										double losa = 0.0;
										double forpackStorlek = 0;
										Double forpack = SXUtil.noNull(rs.getDouble(40));
										Double kop_pack = SXUtil.noNull(rs.getDouble(41));
										Double antal = SXUtil.noNull(rs.getDouble(24));
										try {
											if (antal.compareTo(kop_pack) >= 0 && kop_pack > 0 && kop_pack != 1) {
												hela = (long)(antal/kop_pack);
												losa = antal%kop_pack;
												forpackStorlek = kop_pack;
											} else if (antal.compareTo(forpack) >= 0 && forpack > 0 && forpack != 1) {
												hela = (long)(antal/forpack);
												losa = antal%forpack;
												forpackStorlek = forpack;
											}
										} catch (Exception e) {}			
										String finnsILagerStr = "";
										if (SXUtil.noNull(rs.getDouble(35)).compareTo(0.0) > 0) finnsILagerStr = "*";
										

									%>
									<td class="c-antal"><%= SXUtil.getFormatNumber(rs.getDouble(24)) + finnsILagerStr %>
									<% if (hela!=0) { %>
										<br><small>(
											<b><%= hela %></b> <%= hela>1 ? "forp." : "förp."  %> om <%= SXUtil.getFormatNumber(forpackStorlek) %>
											<% if(losa!=0.0) { %>
												<br>+ <%= SXUtil.getFormatNumber(losa) %> <%= SXUtil.toHtml(getEnh(rs.getString(25))) %> lösa
											<% } %>
										)</small>
									<% } %>
									</td>
									<td class="c-enh"><%= SXUtil.toHtml(getEnh(rs.getString(25))) %></td>
								</tr><tr>
									<td colspan="4" width="100%"><%= SXUtil.toHtml(rs.getString(31)) + " " + SXUtil.toHtml(rs.getString(32)) + " " + SXUtil.toHtml(rs.getString(33))  %></td>
								</tr>		
								<tr>
									<td colspan="5" class="border_btn" width="100%"><%= SXUtil.toHtml(rs.getString(34)) %></td>
								</tr>
							<% } else { %>
								<tr>
									<td colspan="5"><%= SXUtil.toHtml(rs.getString(27)) %></td>					
								</tr>
							<% } %>
							</table></td></tr>
				<% } %>

			</table>
			</div></div>

<%	} %>
	
</div>				
	</body>
</html>


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