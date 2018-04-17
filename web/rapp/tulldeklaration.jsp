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
                
                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Tulldeklaration från faktura</title>
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
		
<h2>Tulldeklaration</h2>
		<h1 style="visibility: hidden"><sx-rubrik>Tulldeklaration från faktura</sx-rubrik></h1>

                <form>
                    Fakturanr: <input name="faktnr" value="<%= SXUtil.noNull(faktnr) %>"><input type="submit">
                </form>
<%

String q = "select f2.artnr, f2.namn, f2.summa, coalesce(case when cn8='' then null else cn8 end, '*Saknas*') as cn8, a.vikt*f2.lev as vikt "
+ " from faktura2 f2 left outer join artikel a on a.nummer=f2.artnr "
+" where f2.faktnr= " + faktnr + " order by cn8, artnr ";

String q2 = "select cn8, sum(summa) as summa, sum(vikt) as vikt  from ( " + q + " ) f group by cn8 order by cn8";

    Statement stm;
    stm = con.createStatement();
    ResultSet rs = stm.executeQuery(q2);
%>
<h4>Sammanställning</h4>
<table>
    <tr><th>Tullkod</th><th>Varuvärde</th><th>Vikt</th></tr>
<%        
    while (rs.next()) {
%>
    <tr><td  style="width: 7em"><%= rs.getString("cn8") %></td><td  style="width: 7em" class="right"><%= SXUtil.getFormatNumber(rs.getDouble("summa")) %></td><td  style="width: 7em" class="right"><%= SXUtil.getFormatNumber(rs.getDouble("vikt")) %></td></tr>
<%        
    }
%>
</table>
<%        
    
    rs = stm.executeQuery(q);
%>
<h4>Detaljer</h4>
<table>
    <tr><th>Artnr</th><th>Benämning</th><th>Tullkod</th><th class="right">Varuvärde</th><th class="right">Vikt</th></tr>

<%        
    while (rs.next()) {
%>
<tr><td><%= rs.getString("artnr") %></td><td><%= rs.getString("namn") %></td><td style="width: 7em"><%= rs.getString("cn8") %></td><td  style="width: 7em" class="right"><%= SXUtil.getFormatNumber(rs.getDouble("summa"),2) %></td><td  style="width: 7em" class="right"><%= SXUtil.getFormatNumber(rs.getDouble("vikt"),2) %></td></tr>
<%        
    }
%>
</table>
<%        
    


%>

	</body>
</html>

