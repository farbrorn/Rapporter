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

                Calendar cal = Calendar.getInstance();

		User user=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");

		Date frDatum = null;
		try { //datum = new Date(request.getParameter("datum")); 
			frDatum = dateFormatter.parse(request.getParameter("frdatum"));
		} catch (Exception e) { } 
		if (frDatum==null) {
                    frDatum = new Date();
                    cal.setTime(frDatum);
                    cal.add(Calendar.DATE, -365);
                    frDatum = cal.getTime();
                }
                String sok = null;
                sok = request.getParameter("sok");
		
		
%>			

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
if (sok != null)		 {
	
	String q = 
"select u1.ordernr, u1.namn, u1.adr1, u1.adr2, u1.adr3, u1.levadr1, u1.levadr2, u1.levadr3, u1.marke, max(f2.faktnr) as faktura, u1.datum " 
+ " from utlev1 u1 join (select upper('%' || ? || '%') as sok) a on 1=1 "
+ " left outer join faktura2 f2 on f2.ordernr=u1.ordernr "
+ " where datum > ? "
+ " and ( upper(adr1) like a.sok or upper(adr2) like a.sok or upper(adr3) like a.sok or upper(levadr1) like a.sok or upper(levadr2) like a.sok or upper(levadr3) like a.sok or upper(marke) like a.sok ) "
+ " group by u1.ordernr order by u1.ordernr"  ;

			  
	ps = con.prepareStatement(q);
	ps.setString(1, sok);
	ps.setDate(2, new java.sql.Date(frDatum.getTime()));
	rs = ps.executeQuery();
	
}
%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Sök utleverans</title>
	
<style type="text/css">
	.right { text-align: right;}
        table, th, td {
           border-collapse: collapse;
           border: 1px solid gray;
           text-align: left;
        }
        
        th, td {
            padding: 2px 4px 2px 4px;
        }
</style>	
	</head>
	<body>
            <form>
		<h1>Sök utleverans</h1>
                <table>
                    <tr>
                        <td>Sök adress/märke</td>
                        <td><input type="text" name="sok" value="<%= SXUtil.toStr(sok) %>"></td>
                        
                    </tr>
                    <tr>
                        <td>Från Datum</td>
                        <td><input type="text" name="frdatum" value="<%= dateFormatter.format(frDatum) %>"></td>
                    </tr>
                </table>
                    <input type="submit">
            </form>
<% if (rs!=null) { %>
		<table>
                    <tr><th rowspan="2">Ordernr</th><th rowspan="2">Orderdatum</th><th rowspan="2">Fakturanr</th><th>Kund</th><th colspan="3">Kundadress</th></tr><tr><th>Märke</th><th colspan="3">Leveransadress</th></tr>
		<%  while(rs.next()) { %>
			<tr>
                            <td rowspan="2"><%= rs.getInt(1) %> </td>
                            <td rowspan="2"><%= SXUtil.toHtml(rs.getString(11)) %> </td>
                            <td rowspan="2"><%= SXUtil.toHtml(rs.getString(10)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(2)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(3)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(4)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(5)) %> </td>
                        </tr><tr>
                            <td><%= SXUtil.toHtml(rs.getString(9)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(6)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(7)) %> </td>
                            <td><%= SXUtil.toHtml(rs.getString(8)) %> </td>
			</tr>
		<% } %>
		</table>
<% } %>

	</body>
</html>


