<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="com.sun.xml.rpc.processor.modeler.j2ee.xml.javaIdentifierType"%>
<%@page import="java.util.Calendar"%>
<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.Date"%>
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
	String kundnr = request.getParameter("kundnr");
        Date frDat;
        Date tiDat;
        String dbuser = "sxfakt";
        try {
            frDat = (java.sql.Date)dateFormatter.parse(request.getParameter("frdat"));
        } catch (Exception e) { frDat=new java.sql.Date(SXUtil.addDate(new java.util.Date(),-365).getTime()); }
        
        
        try {
            tiDat = (java.sql.Date)dateFormatter.parse(request.getParameter("tidat"));
        } catch (Exception e) { tiDat=new java.sql.Date(new java.util.Date().getTime()); }

        String land = request.getParameter("land");
        if ("no".equals(land)) dbuser= "sxasfakt";

        boolean gruppera = false;
        if ("true".equals(request.getParameter("gruppera"))) gruppera=true;
        
        boolean visaTB = false;
        if ("true".equals(request.getParameter("visatb"))) visaTB=true;

        String levNr = request.getParameter("levnr");
       
%>

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
        String q;
        String kundNamn = "";
        if (!SXUtil.isEmpty(kundnr)) {
                        q="select namn from " + dbuser + ".kund where nummer=?";
			ps = con.prepareStatement(q);
                        ps.setString(1, kundnr);
			rs = ps.executeQuery();
                        if (rs.next()) kundNamn = rs.getString(1);
        }
        String levNamn = "";
    if (!SXUtil.isEmpty(levNr)) {
                        q="select namn from " + dbuser + ".lev where nummer=?";
			ps = con.prepareStatement(q);
                        ps.setString(1, levNr);
			rs = ps.executeQuery();
                        if (rs.next()) levNamn = rs.getString(1); else levNamn = levNr;        
    }
    String levnrFilter = "";
    if (!SXUtil.isEmpty(levNr)) levnrFilter = " and a.lev=? ";
    
    if (!gruppera) {
    q = "select u1.marke as marke, f1.datum, f2.artnr, coalesce(a.namn,f2.namn) as artnamn, f2.lev, f2.enh, f2.pris, f2.rab, f2.pris*(1-f2.rab/100)-f2.netto-(f2.pris*(1-f2.rab/100)*case when f1.bonus <> 0 then fu.bonusproc1/100 else 0 end) as tb "
+" from " + dbuser + ".faktura1 f1 join " + dbuser + ".faktura2 f2 on f1.faktnr=f2.faktnr left outer join " + dbuser + ".artikel a on a.nummer=f2.artnr left outer join " + dbuser +".utlev1 u1 on u1.ordernr=f2.ordernr join " + dbuser + ".fuppg fu on 1=1 "
 +" where f2.artnr not in ('*BONUS*','*RÄNTA*') and f1.kundnr=? and f1.datum between ? and ? and f2.lev<>0 " + levnrFilter
+" order by f2.artnr, f2.faktnr desc";
    } else {
    q= "select count(*) as antalkop, f2.artnr, coalesce(a.namn,f2.namn) as artnamn, sum(f2.lev) as lev, f2.enh, case when sum(f2.lev)<>0 then sum(f2.pris*(1-f2.rab/100)*f2.lev)/sum(f2.lev) else 0 end as pris, case when sum(f2.lev)<>0 then sum(f2.lev*(f2.pris*(1-f2.rab/100)-f2.netto-(f2.pris*(1-f2.rab/100)*case when f1.bonus <> 0 then fu.bonusproc1/100 else 0 end)))/sum(f2.lev) else 0 end as tb "
+" from " + dbuser + ".faktura1 f1 join " + dbuser + ".faktura2 f2 on f1.faktnr=f2.faktnr left outer join " + dbuser + ".artikel a on a.nummer=f2.artnr left outer join " + dbuser + ".utlev1 u1 on u1.ordernr=f2.ordernr join " + dbuser + ".fuppg fu on 1=1 "
+" where f2.artnr not in ('*BONUS*','*RÄNTA*') and f1.kundnr=? and f1.datum between ? and ? and f2.lev<>0 " + levnrFilter
+" group by f2.artnr, f2.enh, coalesce(a.namn,f2.namn) "
+" order by f2.artnr";
    }   
			ps = con.prepareStatement(q);
                        ps.setString(1, kundnr);
                        ps.setDate(2, (java.sql.Date)frDat);
                        ps.setDate(3, (java.sql.Date)tiDat);
                        if (!SXUtil.isEmpty(levNr)) ps.setString(4, levNr);
			rs = ps.executeQuery();
	

    Double inkopTotal=0.0;
    Double tbTotal=0.0;
%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Kundinköp</title>

<style type="text/css">

        td { 
            padding: 1px 2px 2px 2px; 
        }
        th {
            font-size: 60%;
            padding: 1px 2px 2px 2px;
            text-align: left;
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
		
		
		<h1>Kundinköp</h1>
        <div>
            <form>
                <table>
                    <tr>
                        <td>Kundnr: </td><td><input type="text" name="kundnr" value="<%= SXUtil.toHtml(kundnr) %>"></td>
                    </tr>
                    <tr>
                        <td>Datum: </td><td><input type="text" name="frdat" value="<%= SXUtil.getFormatDate(frDat) %>"> -- <input type="text" name="tidat" value="<%= SXUtil.getFormatDate(tiDat) %>"></td>
                    </tr>
                    <tr>
                        <td>Leverantörsnr: </td><td><input type="text" name="levnr" value="<%= SXUtil.toHtml(levNr) %>"> </td>
                    </tr>
                    <tr>
                        <td><input type="checkbox" name="land" value="no" <%= "no".equals(land) ? "checked" : ""%>> Norge</td>
                        <td><input type="checkbox" name="gruppera" value="true" <%= gruppera ? "checked" : "" %>> Gruppera på artikel</td>
                        <td><input type="checkbox" name="visatb" value="true" <%= visaTB ? "checked" : "" %>> Utökad lista</td>
                    </tr>
                    <tr>
                        <td><input type="submit"></td>
                    </tr>
                </table>
            </form>
        </div>
        
        <div>Kund: <%= kundnr!=null ? SXUtil.toHtml(kundnr) : "" %> <%= SXUtil.toHtml(kundNamn) %> Intervall: <%= SXUtil.getFormatDate(frDat) %> -- <%= SXUtil.getFormatDate(tiDat) %> 
        <% if (!SXUtil.isEmpty(levNr)) { %>
            Leverantör: <%= SXUtil.toStr(levNamn) %>        
        <% } %>
        </div>
		<table>
			<tr>
    <% if (!gruppera) { %>
        <th>Märke</th><th>Datum</th><th>Artnr</th><th>Benämning</th><th>Antal</th><th>Enh</th><th>Pris</th><th>%</th>
        <% if (visaTB) { %>
            <th>TB</th><th>tb %</th>
        <% } %>
        
    <% } else { %>
        <th>Artnr</th><th>Benämning</th><th>Antal</th><th>Enh</th><th>Snittpris</th>
        <% if (visaTB) { %>
            <th>Snittäckning</th><th>tb %</th>
        <% } %>
        <th>Antal köp</th>    
    <% } %>
			</tr>
			<% 
				boolean odd=false;
				String oddStr;
				while(rs.next()) {
					odd = !odd;
                                        
			%>
				
			<tr <%= odd ? "class=\"odd\"" : "" %>  >	
				
    <% if (!gruppera) { %>
    <% 
        inkopTotal += rs.getDouble("pris")*rs.getDouble("lev")*(1-rs.getDouble("rab")/100);
        tbTotal += rs.getDouble("tb")*rs.getDouble("lev");
    %>
				<td ><%= SXUtil.toHtml(rs.getString("marke")) %></td>
				<td ><%= SXUtil.getFormatDate(rs.getDate("datum")) %></td>
				<td ><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
				<td ><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("lev")).replace(",","").replace(".", ",") %></td>
				<td ><%= SXUtil.toHtml(rs.getString("enh")) %></td>
                                <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("pris")).replace(",","").replace(".", ",") %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("rab"),0) %></td>
                                <% if (visaTB) { %>
                                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("tb")).replace(",","").replace(".", ",") %></td>
                                    <td class="right"><%= rs.getDouble("pris")!=0.0 ? SXUtil.getFormatNumber(rs.getDouble("tb")/(rs.getDouble("pris")*(1-rs.getDouble("rab")/100))*100,1).replace(",","").replace(".", ",") : "" %>%</td>
                                <% } %>
    <% } else { %>
    <% 
        inkopTotal += rs.getDouble("pris")*rs.getDouble("lev");
        tbTotal += rs.getDouble("tb")*rs.getDouble("lev");
    %>
				<td ><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
				<td ><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
				<td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("lev")).replace(",","").replace(".", ",") %></td>
				<td ><%= SXUtil.toHtml(rs.getString("enh")) %></td>
                                <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("pris")).replace(",","").replace(".", ",") %></td>
                                <% if (visaTB) { %>
                                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("tb")).replace(",","").replace(".", ",") %></td>
                                    <td class="right"><%= rs.getDouble("pris")!=0.0 ? SXUtil.getFormatNumber(rs.getDouble("tb")/(rs.getDouble("pris"))*100,1).replace(",","").replace(".", ",") : "" %>%</td>
                                <% } %>
  
                                <td class="right"><%= rs.getInt("antalkop") %></td>
                                
    <% } %>
			</tr>
			<% 
				}
			%>
		</table>
                <b><table>
                    <tr>
                        <td>Totalt inköp netto</td><td><%= SXUtil.getFormatNumber(inkopTotal) %></td>
                    </tr>
                    <% if(visaTB) { %>
                    <tr>
                        <td>Total TB</td><td><%= SXUtil.getFormatNumber(tbTotal) %></td>                        
                    </tr>
                    <% } %>
                    </table></b>
	</body>
</html>


