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
	String lev = request.getParameter("lev");
	java.sql.Date frDat = null;
	java.sql.Date tiDat = null;
	try { frDat = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("frdat"))).getTime() );} catch (Exception e) { out.print(e.toString());		}
	try { tiDat = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("tidat"))).getTime() );} catch (Exception e) { out.print(e.toString());		}
%>

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
	String  levStr=null;
	if (tiDat!=null && frDat != null && lev != null)	{
		String q =
		"select f1.kundnr, f1.namn, f2.artnr, a.rsk, f2.namn, sum(f2.lev), sum(f2.summa), sum(f2.lev*f2.netto) " +
		" from faktura1 f1 join faktura2 f2 on f1.faktnr=f2.faktnr " +
		" left outer join artikel a on a.nummer = f2.artnr " +
		" left outer join stjarnrad s on s.stjid=f2.stjid and s.stjid<>0 " +
		" where  f1.kundnr like '081336%' and f1.datum between ? and ? "+
		" and (a.lev = ? or s.levnr = ?) "+
		" group by f1.kundnr, f1.namn, f2.artnr, a.rsk, f2.namn "+
		" order by f1.kundnr, f1.namn, f2.artnr, a.rsk, f2.namn ";


			ps = con.prepareStatement(q);
			ps.setDate(1, frDat);
			ps.setDate(2, tiDat);
			ps.setString(3, lev);
			ps.setString(4, lev);

			rs = ps.executeQuery();

			if ("BRA".equals(lev)) levStr = "IFÖ*";
			else if ("FMM".equals(lev)) levStr = "FMM";
			else levStr = lev;
	}
%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Titania redovisning</title>

	
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
		
		<% 
			Double tSumma = 0.0;
			Double tInNetto = 0.0;
		%>
		
	<% if (tiDat!=null && frDat != null && lev != null)	{ %>
		<h1>Titania inköp <%= levStr %></h1>
		Period: <%= dateFormatter.format(frDat) %> - <%= dateFormatter.format(tiDat) %><br>
		<table>
			<tr>
				<th class="t-str">Kundnr</th><th class="t-str">Kund</th><th class="t-str">Artikelnr</th><th class="t-str">RSK</th><th class="t-str">Benämning</th><th class="t-nr">Antal</th><th class="t-nr">Summa</th><th>Säljex Inköpspris</th>
			</tr>
			<% 
				while(rs.next()) {
					tSumma += SXUtil.noNull(rs.getDouble(7));
					tInNetto += SXUtil.noNull(rs.getDouble(8));
			%>
			<tr>
				<td class="t-str"><%= rs.getString(1) %></td>
				<td class="t-str"><%= rs.getString(2) %></td>
				<td class="t-str"><%= rs.getString(3) %></td>
				<td class="t-str"><%= rs.getString(4) %></td>
				<td class="t-str"><%= rs.getString(5) %></td>
				<td class="t-nr"><%= SXUtil.getFormatNumber(rs.getDouble(6)) %></td>
				<td class="t-nr"><%= SXUtil.getFormatNumber(rs.getDouble(7)) %></td>
				<td class="t-nr"><%= SXUtil.getFormatNumber(rs.getDouble(8)) %></td>
			</tr>
			<% 
				}
			%>
			<tr><td colspan="6" style="text-align: right; padding-right: 1em; font-weight: bold">Totaler: </td><td class="t-nr fet"><%= SXUtil.getFormatNumber(tSumma) %></td><td class="t-nr fet"><%= SXUtil.getFormatNumber(tInNetto) %></td></tr>
		</table>
	<% } else { %>
		<h1>Titania-rapport</h1>
		<form>
			<table>
				<tr>
					<td>Leverantör</td>
					<td><input type="text" name="lev" value="FMM"></td>
				</tr>
				<tr>
					<td>Från Datum</td>
					<td><input type="text" name="frdat"></td>
				</tr>
				<tr>
					<td>Till Datum</td>
					<td><input type="text" name="tidat"></td>
				</tr>
				<tr>
					<td><input type="submit"</td>
				</tr>
			</table>
		</form>
	<% } %>
	</body>
</html>


