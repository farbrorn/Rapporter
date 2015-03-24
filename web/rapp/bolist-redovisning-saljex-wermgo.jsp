<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

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
		try { con = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
%>			

<%
	Integer ar = Calendar.getInstance().get(Calendar.YEAR);
	try { ar = new Integer(request.getParameter("ar")); } catch(Exception e) {}
	Integer kvartal = 1;
	try { kvartal = new Integer(request.getParameter("kvartal")); } catch(Exception e) {}
	
%>

<%
	ResultSet rsSaljex=null;
	ResultSet rsWermgo=null;
	PreparedStatement psSaljex=null;
	PreparedStatement psWermgo=null;
	
		String qSaljex =
				 "select k.namn, sum(t_netto) "
				+ " from sxfakt.faktura1 f1 join sxfakt.kund k on k.nummer=f1.kundnr join  sxfakt.kundgrplank g on g.kundnr=k.nummer and g.grpnr='Bolist' "
				+ " where year(f1.datum)=?  and month(f1.datum) between ? and ? "
				+ " group by k.namn "
				+" order by k.namn"
		;		  

		String qWermgo =
				 "select f1.namn, sum(t_netto) "
				+ " from wgabfakt.faktura1 f1 "
				+ " where year(f1.datum)=?  and month(f1.datum) between ? and ? "
				+ " group by f1.namn "
				+" order by f1.namn"
		;		  

			psSaljex = con.prepareStatement(qSaljex);
			psSaljex.setInt(1, ar);
			psSaljex.setInt(2, 1+(kvartal-1)*3);
			psSaljex.setInt(3, 3+(kvartal-1)*3);
			rsSaljex = psSaljex.executeQuery();
			
			psWermgo = con.prepareStatement(qWermgo);
			psWermgo.setInt(1, ar);
			psWermgo.setInt(2, 1+(kvartal-1)*3);
			psWermgo.setInt(3, 3+(kvartal-1)*3);
			rsWermgo = psWermgo.executeQuery();
	
%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Bolist</title>


<style type="text/css">
	td { text-align: left;}
	.s5 {
		width: 4em;
		text-align: left;
	}
	.s10 {
		width: 8em;
		text-align: left;
	}
	.s15 {
		width: 12em;
		text-align: left;

	}
	.s20 {
		width: 20em;
		text-align: left;		
	}
	.s30 {
		width: 22em;
		text-align: left;
	}
	.dat {
		width: 6em;
	}
	.n10 {
		text-align: right;
		width: 7em;
		padding-right: 0.5em;
	}
	.n5 {
		text-align: right;
		width: 4em;
		padding-right: 0.5em;
	}
	
	.fet {
		font-weight: bold;
	}
	.odd {
		background-color:#ccffff;
	}
	.right {
		text-align: right;
	}
	
</style>	
	</head>
	<body>
		
		
		<h1>Bolist</h1>
		<form method="get">
			<table>
				<tr>
					<td>År</td>
					<td><input name="ar" value="<%= ar  %>"></td>
				</tr>
				<tr>
					<td>Kvartal</td>
					<td><input name="kvartal" value="<%= kvartal  %>"></td>
				</tr>
			</table>
			<button type="submit" >
		</form>
		
				

		<h2>Säljex</h2>
		<table style="table-layout: fixed;">
			<tr>
				<th class="s30">Kund</th><th class="n10">Summa</th>
			</tr>
			<% 
				boolean odd=false;
				String oddStr;
				while(rsSaljex.next()) {
					odd = !odd;
					if (odd) oddStr="class=\"odd\""; else oddStr="";
			%>
				
			<tr <%= oddStr %>  >	
				<td class="s30"><%= SXUtil.toHtml(rsSaljex.getString(1)) %></td>
				<td class="n10" ><%= SXUtil.getFormatNumber(rsSaljex.getDouble(2),0) %></td>
			</tr>
			<% 
				}
			%>
		</table>
		

		
		
		<h2>Wermgo - Samtliga kunder</h2>
		<table style="table-layout: fixed;">
			<tr>
				<th class="s30">Kund</th><th class="n10">Summa</th>
			</tr>
			<% 
				odd=false;
				while(rsWermgo.next()) {
					odd = !odd;
					if (odd) oddStr="class=\"odd\""; else oddStr="";
			%>
				
			<tr <%= oddStr %>  >	
				<td class="s30""><%= SXUtil.toHtml(rsWermgo.getString(1)) %></td>
				<td class="n10"><%= SXUtil.getFormatNumber(rsWermgo.getDouble(2),0) %></td>
			</tr>
			<% 
				}
			%>
		</table>
		
		
		
	</body>
</html>


