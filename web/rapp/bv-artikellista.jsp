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
		try { con = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
%>			

<%
	String lev = request.getParameter("lev");
%>

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
	
	String orderByStr = "a.nummer, ba.nummer";
		String q =
"select a.nummer, a.namn, n.pris*coalesce(ba.inp_enhetsfaktor,1), a.utgattdatum, ba.nummer, ba.bestnr, ba.namn, ba.utpris,  "+
" case when n.pris <> 0 then (ba.utpris-n.pris*coalesce(ba.inp_enhetsfaktor,1)) else 0 end as tb, "+
" case when ba.utpris <> 0 then (ba.utpris-n.pris*coalesce(ba.inp_enhetsfaktor,1))/ba.utpris else 0 end as tbproc, "+
" coalesce(BA.INP_ENHETSFAKTOR,0), a.inpdat "+
" from bvfakt.artikel ba   " +
" left outer join sxfakt.artikel a  on ba.bestnr=a.nummer "+
" left outer join sxfakt.nettopri n on n.artnr=a.nummer and n.lista='BILLIGT' "+
//" where a.nummer not like 'H%' "+
" order by "+orderByStr;
		;		  


			ps = con.prepareStatement(q);
			rs = ps.executeQuery();
	
%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>BV - Artikellista</title>

	
<style type="text/css">
	
	.s5 {
		width: 4em;
	}
	.s10 {
		width: 8em;
	}
	.s15 {
		width: 12em;
	}
	.s20 {
		width: 20em;
	}
	.s30 {
		width: 22em;
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
		
		
		<h1>BV Artikellista</h1>
		<table style="table-layout: fixed; width: 100%">
			<tr>
				<th class="s10">SX-Nr</th><th class="s30">SX-Benämning</th><th class="s10">In-pris</th><th class="dat">Prisdatum</th><th class="dat">Utgått</th><th class="s10">BV-Nr</th><th class="s10">Bestnr</th><th class="s30">BV Benämning</th><th class="n10">BV Utpris</th><th class="n10">Marginal</th><th class="n5">Marginal %</th><th class="s10">Enhetsfaktor</th>
			</tr>
			<% 
				boolean odd=false;
				String oddStr;
				while(rs.next()) {
					odd = !odd;
					if (odd) oddStr="class=\"odd\""; else oddStr="";
			%>
				
			<tr itemscope <%= oddStr %>  >	
				
				<td itemprop="sxartnr"><%= SXUtil.toHtml(rs.getString(1)) %></td>
				<td itemprop="sxbenamning"><%= SXUtil.toHtml(rs.getString(2)) %></td>
				<td itemprop="nettopris" class="right"><%= SXUtil.getFormatNumber(rs.getDouble(3)) %></td>
				<td itemprop="prisdatum"><%= SXUtil.toHtml(rs.getString(12)) %></td>
				<td itemprop="utgattdatum"><%= SXUtil.toHtml(rs.getString(4)) %></td>
				<td itemprop="artnr"><%= SXUtil.toHtml(rs.getString(5)) %></td>
				<td itemprop="benamning"><%= SXUtil.toHtml(rs.getString(6)) %></td>
				<td itemprop="bestnr"><%= SXUtil.toHtml(rs.getString(7)) %></td>
				<td itemprop="utpris" class="right"><%= SXUtil.getFormatNumber(rs.getDouble(8)) %></td>
				<td itemprop="marginal" class="right"><%= SXUtil.getFormatNumber(rs.getDouble(9)) %></td>
				<td itemprop="marginalproc" class="right"><%= SXUtil.getFormatNumber(rs.getDouble(10)*100,0) %>%</td>
				<td itemprop="enhetsfaktor" class="right"><%= SXUtil.getFormatNumber(rs.getDouble(11),4) %></td>
			</tr>
			<% 
				}
			%>
		</table>
	</body>
</html>


