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
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
                
                Integer ar = Calendar.getInstance().get(Calendar.YEAR);
                Integer frman = 1;
                Integer timan = Calendar.getInstance().get(Calendar.MONTH);
                Integer lagernr= 0;
                try { ar = Integer.parseInt(request.getParameter("ar")); } catch (Exception e) {}
                try { frman = Integer.parseInt(request.getParameter("frman")); } catch (Exception e) {}
                try { timan = Integer.parseInt(request.getParameter("timan")); } catch (Exception e) {}
                try { lagernr = Integer.parseInt(request.getParameter("lagernr")); } catch (Exception e) {}
                
                
%>			


<%
	ResultSet rs=null;
	PreparedStatement ps=null;
        String q;
q="select kundnr, namn, inkopar1, inkopar2, inkopar3, inkopar4 "
+ " from( "
+" select k.nummer as kundnr, k.namn, "
+" round(sum(case when year(f1.datum) = b.ar then f1.t_netto else 0 end)) as inkopar1, "
+ " round(sum(case when year(f1.datum) = b.ar-1 then f1.t_netto else 0 end)) as inkopar2, "
+" round(sum(case when year(f1.datum) = b.ar-2 then f1.t_netto else 0 end)) as inkopar3, "
+ " round(sum(case when year(f1.datum) = b.ar-3 then f1.t_netto else 0 end)) as inkopar4 "
+ " from faktura1 f1 join kund k on k.nummer=f1.kundnr join (select ? as ar, ? as frman, ? as timan) b on 1=1 "
//+ " where k.nummer in (select kundnr from faktura1 where lagernr=?) and year(f1.datum) between b.ar-3 and b.ar and month(f1.datum) between b.frman and b.timan and f1.lagernr=?"
+ " where year(f1.datum) between b.ar-3 and b.ar and month(f1.datum) between b.frman and b.timan and f1.lagernr=?"
+ " group by k.nummer, k.namn "
+ " ) bb "
+ " order by inkopar1 desc, inkopar2 desc, inkopar3 desc, inkopar4 desc; ";

        ps = con.prepareStatement(q);
        ps.setInt(1, ar);
        ps.setInt(2, frman);
        ps.setInt(3, timan);
        ps.setInt(4, lagernr);
        //ps.setInt(5, lagernr);
        
        rs = ps.executeQuery();
	

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Inköpsstatistik för kunder på lager</title>

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
		<h1>Inköpsstatistik för kunder på lager</h1>
                Visar lista med kundinköp på angivet lager, samt inköp för angiven period med jämförelsetal för föregående år.
                <div>
                    <form>
                        <table>
                            <tr><td>År</td><td><input name="ar" value="<%= ar %>"</td></tr>
                            <tr><td>Lager</td><td><input name="lagernr" value="<%= lagernr %>"</td></tr>
                            <tr><td>Från månad</td><td><input name="frman" value="<%= frman %>"</td></tr>
                            <tr><td>Till månad</td><td><input name="timan" value="<%= timan %>"</td></tr>
                        </table>
                        <input type="submit">
                    </form>
                    
                </div>
                
                <div>
                    Lagernr: <%= lagernr %> År: <%= ar %> Period: <%= frman %>-<%= timan %>
                </div>
        <table>
            <tr>
                <th>Kundnr</th><th>Namn</th><th class="right">Inköp <%= ar %></th><th class="right">Inköp <%= ar-1 %></th><th class="right">Inköp <%= ar-2 %></th><th class="right">Inköp <%= ar-3 %></th>
            </tr>
            <%
            boolean odd = true;
            %>
            <% while (rs.next()) { 
                odd=!odd;
            %>
                <tr>
                    <td class="<%= odd ? "odd" : "" %>"><%= SXUtil.toHtml(rs.getString("kundnr")) %></td>
                    
                    <td class="<%= odd ? "odd" : "" %>"><%= SXUtil.toHtml(rs.getString("namn")) %></td>
                    <td class="right <%= odd ? "odd" : "" %>"><%= SXUtil.getFormatNumber(rs.getDouble("inkopar1"),0) %></td>
                    
                    <td class="right <%= odd ? "odd" : "" %>"><%= SXUtil.getFormatNumber(rs.getDouble("inkopar2"),0) %></td>
                    <td class="right <%= odd ? "odd" : "" %>"><%= SXUtil.getFormatNumber(rs.getDouble("inkopar3"),0) %></td>
                    <td class="right <%= odd ? "odd" : "" %>"><%= SXUtil.getFormatNumber(rs.getDouble("inkopar4"),0) %></td>
                </tr>
                <% } %>
        </table>          
                    
		
	</body>
</html>


