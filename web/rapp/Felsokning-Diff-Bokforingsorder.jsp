<%-- 
    Document   : Felsokning-Diff-Bokforingsorder
    Created on : 2016-aug-08, 10:21:13
    Author     : Ulf Berg
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

		Integer ar = null;
		try { //datum = new Date(request.getParameter("datum")); 
			ar = Integer.parseInt(request.getParameter("man"));
		} catch (Exception e) { } 
		Integer man = null;
		try { //datum = new Date(request.getParameter("datum")); 
			man = Integer.parseInt(request.getParameter("man"));
		} catch (Exception e) { } 
                
               Calendar idag = Calendar.getInstance();
               
               if (man==null || man > 12 || man < 1) man = idag.get(Calendar.MONTH);
               if (ar==null ) ar = idag.get(Calendar.YEAR);
		boolean odd = true;
                
       		if (!user.isBehorighet("Ekonomi")) throw new SxInfoException("Ingen behörighet");

%>			

<%
		  
	ResultSet rs=null;
	PreparedStatement ps=null;
	
	String q =
"select b1.faktnr, b1.summa as diff, b2.konto, b2.summa, b2.kundnr, b2.namn, b2.typ from "+
" ( select faktnr, -sum(summa) as summa from bokord b1 "+
" where b1.ar=? and b1.man = ?  "+
" group by b1.faktnr having sum(b1.summa) not between -0.1 and 0.1 "+
" ) b1 "+
" left outer join bokord b2 on b2.faktnr = b1.faktnr  "+
" order by b1.faktnr, b2.typ, b2.konto "
			  ;
       
	ps = con.prepareStatement(q);
        ps.setInt(1, ar);
        ps.setInt(2, man);
	rs = ps.executeQuery();
	

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Felsökning bokföringsorder</title>
	
<style type="text/css">
	td, th { 
		padding: 2px 4px 2px 4px; 
		text-align: left;
	}
	th { 
		border-bottom: 1px solid black; 
		font-size: 60%;
	}
	
	.odd {}

	
	.even {
		background-color: #eeeeee;
	}
        
	.right { text-align: right;}
</style>	
	</head>
	<body>
		<h1><sx-rubrik>Felsökning diff i bokföringsorder</sx-rubrik></h1>
                <form>
                    <table>
                        <tr><td>År</td><td><input name="ar" value="<%= SXUtil.noNull(ar) %>"></td></tr>
                        <tr><td>Månad</td><td><input name="man" value="<%= SXUtil.noNull(man) %>"></td></tr>
                    </table>
                            <div>
                                <input type="submit">
                            </div>
                               
                </form>
		<%
		Double tot = 0.0;
		%>
                <table>
                    <tr><td>Period:</td><td><%= SXUtil.noNull(ar)-SXUtil.noNull(man) %></td></tr>
                </table>
                
                <div>
                    <b>Fakturor med diff</b><br>
                    Visar de fakturor som har diff i bokföringsorder som är större än 0,10 kr, samt alla konteringar som finns på fakturan. Felet kan hittas i missad kontering.
                    <br>Konteringstyp: F=Fakturerat, B=Betalt
                </div>
		<table>
                    <tr><th>Faktura</th><th>Total diff</th><th>Konteringstyp</th><th>Konto</th><th>Summa</th><th>Kundnr</th><th>Namn</th></tr>
		<%  while(rs.next()) { %>
                    <% odd=!odd; %>
			<tr class="<%= odd ? "odd" : "even" %>">
				<td><%= rs.getInt(1)  %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(2),2) %></td>
				<td><%= SXUtil.toHtml(rs.getString(6)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(3)) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(4),2) %></td>
				<td><%= SXUtil.toHtml(rs.getString(5)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(6)) %></td>
                                
			</tr>
			<% tot += rs.getDouble(4); %>
		<% } %>
		</table>
		<div>
                    <b>Total diff: <%= SXUtil.getFormatNumber(tot) %></b>
		</div>

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
<%
		  
	rs=null;
	ps=null;
	
	q =
"select f1.faktnr, f1.kundnr, f1.namn, f1.t_netto, f1.t_attbetala, b.typ, b.konto, b.summa "+
" from faktura1 f1 join bokord b on b.faktnr=f1.faktnr "+
" where f1.moms = 0 and b.ar=? and b.man=? "+
" order by f1.faktnr, b.typ, b.konto"
			  ;
       
	ps = con.prepareStatement(q);
        ps.setInt(1, ar);
        ps.setInt(2, man);
	rs = ps.executeQuery();
	tot=0.0;

%>
                
                
                <div style="margin-top: 2em;">
                    <b>Fakturor utan moms</b><br>
                    Visar alla fakturor utan moms. Även korrekta.
                </div>
		<table>
                    <tr><th>Faktura</th><th>Kundnr</th><th>Kund</th><th>Fakturanetto</th><th>Att betala</th><th>Konteringstyp</th><th>Konto</th><th>Summa</th><th>Kundnr</th><th>Namn</th></tr>
		<%  while(rs.next()) { %>
                    <% odd=!odd; %>
			<tr class="<%= odd ? "odd" : "even" %>">
				<td><%= rs.getInt(1)  %></td>
				<td><%= SXUtil.toHtml(rs.getString(2)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(3)) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(4),2) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(5),2) %></td>
				<td><%= SXUtil.toHtml(rs.getString(6)) %></td>
				<td><%= SXUtil.toHtml(rs.getString(7)) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble(8),2) %></td>
			</tr>
			<% tot += rs.getDouble(4); %>
		<% } %>
		</table>
                
                
	</body>
</html>


