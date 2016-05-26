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

		Date frDatum;
		try { //datum = new Date(request.getParameter("datum")); 
			frDatum = dateFormatter.parse(request.getParameter("frdat"));
		} catch (Exception e) { throw new SxInfoException("Felaktigt datum i parameter frdatum");} 
		Date tiDatum;
		try { //datum = new Date(request.getParameter("datum")); 
			tiDatum = dateFormatter.parse(request.getParameter("tidat"));
		} catch (Exception e) { throw new SxInfoException("Felaktigt datum i parameter tidatum");} 
		
                String kundnr = request.getParameter("kundnr");
                String sortorder = request.getParameter("sortorder");
                
                
//		if (!user.isBehorighet("Ekonomi")) throw new SxInfoException("Ingen behörighet");
		
%>			

<%
		  
	ResultSet rs=null;
	PreparedStatement ps=null;
	
	String q =
" select f1.faktnr, f1.datum, u1.marke, f2.artnr, f2.namn, f2.lev as antal, f2.pris, f2.rab, f2.summa " +
" from sxfakt.faktura1 f1 join sxfakt.faktura2 f2 on f1.faktnr=f2.faktnr left outer join sxfakt.utlev1 U1 ON U1.ORDERNr=f2.ordernr "+
" where f1.kundnr = ? and f1.datum between ? and ? and f2.artnr not in ('*RÄNTA*','*BONUS*') and f2.summa <> 0 "+
" order by "
			  ;
        
        if ("artnr".equals(sortorder))  q= q + " f2.artnr, f2.faktnr ";
        else if ("fakturanr".equals(sortorder))  q= q + " f2.faktnr, f2.artnr ";
        else q= q + " u1.marke, f2.faktnr, f2.artnr ";


	ps = con.prepareStatement(q);
        ps.setString(1, kundnr);
	ps.setDate(2, new java.sql.Date(frDatum.getTime()));
	ps.setDate(3, new java.sql.Date(tiDatum.getTime()));
	rs = ps.executeQuery();
	

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Försäljningsrapport</title>
	
<style type="text/css">
	.right { text-align: right;}
</style>	
	</head>
	<body>
		<h1><sx-rubrik>Försäljningsrapport per kund och period</sx-rubrik></h1>
                <form>
                    <table>
                        <tr><td>Kundnr</td><td><input name="kundnr" value="<%= SXUtil.toHtml(kundnr) %>"></td></tr>
                        <tr><td>Från datum</td><td><input name="frdat" value="<%= SXUtil.getFormatDate(frDatum) %>"></td></tr>
                        <tr><td>Till datum</td><td><input name="tidat" value="<%= SXUtil.getFormatDate(tiDatum) %>"></td></tr>
                        <tr><td>Sortera</td><td>
                            <option name="sortorder">
                                <select value="marke" <%= "marke".equals(sortorder) ? " selected" : "" %>>Ordermärke</select>
                                <select value="fakturanr" <%= "fakturanr".equals(sortorder) ? " selected" : "" %>>Fakturanummer</select>
                                <select value="artnr" <%= "artnr".equals(sortorder) ? " selected" : "" %>>Artikelnummer</select>
                            </option> 
                        </td>           </tr>
                    </table>
                            <div>
                                <input type="submit">
                            </div>
                               
                </form>
		<%
		Double tot = 0.0;
		%>
                <table>
                    <tr><td>Kundnr:</td><td><%= SXUtil.toHtml(kundnr) %></td></tr>
                    <tr><td>Period:</td><td><%= SXUtil.getFormatDate(frDatum) + " -- " + SXUtil.getFormatDate(tiDatum) %></td></tr>
                </table>
                
		<table>
                    <tr><th>Faktura</th><th>Datum</th><th>Märke</th><th>Artikelnr</th><th>Benämning</th><th>Antal</th><th>Pris</th><th>% </th><th>Summa</th></tr>
		<%  while(rs.next()) { %>
			<tr>
				<td><%= rs.getInt(1)  %></td>
                                <td><%= SXUtil.getFormatDate(rs.getDate(2))  %></td>
				<td><%= SXUtil.toHtml(rs.getString(3)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(4)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(5)) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(6),2) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(7),2) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(8),2) %></td>
                                
			</tr>
			<% tot += rs.getDouble(8); %>
		<% } %>
		</table>
		<div>
			<b>Totalt: <%= SXUtil.getFormatNumber(tot) %>
		</div>
			
	</body>
</html>


