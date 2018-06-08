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
		Connection conSuper=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { conSuper = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");

                Integer faktnr=0;
                try { faktnr=Integer.parseInt(request.getParameter("faktnr")); } catch (Exception e) {}
                Integer totalVikt=0;
                try { totalVikt=Integer.parseInt(request.getParameter("vikt")); } catch (Exception e) {}
                Integer antalKolli=0;
                try { antalKolli=Integer.parseInt(request.getParameter("kolli")); } catch (Exception e) {}
                
                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Tulldeklaration fr�n faktura</title>
<style type="text/css">

table {
	table-layout: fixed;
	border-collapse: collapse;
}

table tr {
    vertical-align: top;
}

table th {
    text-align: left;
}




h2 {
    font-size: 150%;
    font-weight: bold;
    display: inline;
}


.sel {
    background-color: #ccffff;
}

.right {
    text-align: right;
}

</style>	
	</head>
	<body>
		
<%

    Statement stm;
    Statement stmF1;
    stm = con.createStatement();
    stmF1 = con.createStatement();
    ResultSet rsF1 = stmF1.executeQuery("select f1.*, k.regnr, FU.NAMN AS fu_namn, FU.ADR1 as fu_adr1, FU.ADR2 as fu_adr2, FU.ADR3 as fu_adr3 , fu.regnr as fu_regnr from faktura1 f1 left outer join kund k on k.nummer=f1.kundnr join fuppg fu on 1=1 where f1.faktnr=" + faktnr);
    if (rsF1.next()) {
%>
<div id="invoice" style="width: 54em; padding: 1em; margin:0.5em; border: 1px solid grey; font-size: 12px">                
<div id="invoice-header" style="width: 100%">
    <span style="font-size: 150%; font-weight:bold">Invoice</span>
    <table style="width: 100%">
        <tr>
            <td style="width: 50%">
               
            </td>
            <td style="width: 50%">
                Invoice #: <%= rsF1.getInt("faktnr") %><br>
                Date: <%= SXUtil.getFormatDate(rsF1.getDate("datum")) %><br>
                <br>
            </td>
        </tr>
        <tr>
            <td style="width: 50%">
                <b>Seller</b><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_namn")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr1")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr2")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr3")) %><br>
                VAT: <%= SXUtil.toHtml(rsF1.getString("fu_regnr")) %><br>
            </td>
            <td style="width: 50%">
                <b>Buyer</b><br>
                <%= SXUtil.toHtml(rsF1.getString("namn")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr1")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr2")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr3")) %><br>
                VAT: <%= SXUtil.toHtml(rsF1.getString("regnr")) %><br>
            </td>
        </tr>
    </table>


</div>

<%

String q = "select f2.artnr, f2.namn, f2.summa, coalesce(case when cn8='' then null else cn8 end, 'x') as cn8, a.vikt*f2.lev as vikt "
+ " from faktura2 f2 left outer join artikel a on a.nummer=f2.artnr "
+" where f2.faktnr= " + faktnr + " and f2.lev <> 0 order by cn8, artnr ";

String q2 = "select cn8, sum(summa) as summa, sum(vikt) as vikt  from ( " + q + " ) f group by cn8 order by cn8";

%>

<%         ResultSet rs = stm.executeQuery(q); %>
<table style="margin-top: 2em; width: 100%">
    <tr><th style="width: 10em">Itemcode</th><th style="width: 26em">Item</th><th style="width: 7em">CN8</th><th  style="text-align: right;">Value</th></tr>

<%        
    while (rs.next()) {
%>
<tr><td><%= rs.getString("artnr") %></td><td><%= rs.getString("namn") %></td><td style="width: 7em"><%= rs.getString("cn8") %></td><td  style="width: 7em; text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble("summa"),2) %></td></tr>
<%        
    }
%>
</table>


<%
    rs = stm.executeQuery(q2);
%>
<table style="margin-top: 2em">
    <tr><th>CN8</th><th style="text-align: right;">Value</th></tr>
    
<%        
    while (rs.next()) {
%>
    <tr><td style=""><%= rs.getString("cn8") %></td><td  style="width: 7em; text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble("summa")) %></td></tr>
<%        
    }
%>
    <tr><td> </td></tr>
    <tr><td>Number of packages:</td><td><%= antalKolli %></td></tr>
    <tr><td>Total weight (kg):</td><td><%= totalVikt %></td></tr>
</table>



<br>
<div id="invoice-footer" style="width: 100%">
    <table style="width: 100%">
        <tr>
            <td style="width: 50%"></td>
            <td style="width: 50%;">
        <table style="margin-left: auto; margin-right:0px">
            <tr>
                <td>Total net:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_netto")) %></td>
            </tr><tr>
                <td>Total VAT:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_moms")) %></td>
            </tr><tr>
                <td>Rounding:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_orut")) %></td>
            </tr><tr>
                <td>Total incl. VAT:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_attbetala")) %></td>
            </tr>
        </table>
            </td>
    </tr>
    </table>
</div>


</div>
<%        
    } else {
%>


<h2>Tulldeklaration</h2>
		<h1 style="visibility: hidden"><sx-rubrik>Tullfaktura fr�n faktura</sx-rubrik></h1>

                <form>
                    Fakturanr: <input name="faktnr" value="<%= SXUtil.noNull(faktnr) %>">
                    Antal kolli: <input name="kolli" value="<%= SXUtil.noNull(antalKolli) %>">
                    Total vikt: <input name="vikt" value="<%= SXUtil.noNull(totalVikt) %>">
                    <input type="submit">
                </form>




<% } %>

	</body>
</html>

