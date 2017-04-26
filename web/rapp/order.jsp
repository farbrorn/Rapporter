<%--  
    Document   : Order
    Created on : 2016-aug-12, 09:09:15
    Author     : Ulf Berg
--%>

<%@page import="java.util.ArrayList"%>
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

                
                
		Statement st = con.createStatement();
		ResultSet rs;
		PreparedStatement ps;
		String q;
                
		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
                String ac = request.getParameter("ac");
                
                String ordernrString = request.getParameter("ordernr");
                ArrayList<Integer> ordernrList = new ArrayList<Integer>();
                if (ordernrString!=null) {
                    String[] ordernrStringArr = ordernrString.split(",");
                    if (ordernrStringArr!=null) {
                        for (String s : ordernrStringArr) {
                            if (s!=null) try { ordernrList.add(Integer.parseInt(s)); } catch (Exception e) {}
                        }
                    }
                }
                
                String anvandare=request.getParameter("anvandare");
                boolean updateOrderStatus = "utskrift".equals(ac); //Det är en utskrift, och status skall uppdateras
                boolean anvandareKorrekt = false;
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Order</title>

<style type="text/css">

table {
	table-layout: fixed;
	border-collapse: collapse;
}

table tr {
    vertical-align: top;
}
.order { 
	width: 100%;
	
}	
.page-break-before { page-break-before: always; }
.order td {
	
}

.order tr {
}

.avoid_page_break {
	page-break-inside: avoid;	
}

.order th {
	text-align: left;
	vertical-align: text-top;
	font-size: 60%;
	font-weight: bold;
}

.orderhuvud {
	width: 100%;
}
.orderrader {
	width: 100%;
}

.border_btn {
	border-bottom: 1px solid black;
}

.maindiv {
	width: 700px;
}
.c-lp {
	width: 50px;
	padding-right: 4px;	
}
.c-bild {
	width: 34px;
	padding-right: 4px;	
}
.c-artnr {
	width: 100px;
	padding-right: 4px;	
}
.c-artnamn {
	width: 290px;
	padding-right: 4px;	
}
.c-antal {
	width: 120px;
	text-align: right;
	padding-right: 4px;	
}
.c-enh {
	width: 50px;
	padding-right: 4px;	
}
.c-levererat {
	width: 100px;
	padding-right: 4px;	
}
.pbild {
    max-width: 100%; 
    max-height: 70px;
}

h2 {
    font-size: 150%;
    font-weight: bold;
    display: inline;
}

.mellan-text {
    font-size: 80%;
}
.liten-text {
    font-size: 60%;
}
@media screen {
    .noscreen { display: none; }
}
@media print {
    .noprint { display: none; }
}

</style>	
	</head>
        <body>
<% if (updateOrderStatus) {
    if (anvandare!=null) {
        q = "select forkortning from saljare where forkortning=?";
        ps = con.prepareStatement(q);
        ps.setString(1, anvandare);
        rs = ps.executeQuery();
        if (rs.next()) {
            anvandareKorrekt = true;
        }
    }
        
}
%>

<% if (updateOrderStatus && !anvandareKorrekt) { %>
Felaktig användare!
<% } else { %>

		<div class="maindiv">
		<h1 style="display: none"><sx-rubrik>Order</sx-rubrik></h1>



<%
final String selectOrderHeader  =      
         " select "
        +" o1.lagernr as o1_lagernr, o1.ordernr as o1_ordernr, o1.dellev as o1_dellev, o1.datum as o1_datum, o1.kundnr as o1_kundnr, o1.namn as o1_namn, o1.adr1 as o1_adr1, o1.adr2 as o1_adr2, o1.adr3 as o1_adr3, o1.levadr1 as o1_levadr1, "
        +" o1.levadr2 as o1_levadr2, o1.levadr3 as o1_levadr3, o1.marke as o1_marke,  o1.status as o1_status, o1.levdat as o1_levdat, o1.fraktbolag as o1_fraktbolag, o1.ordermeddelande as o1_ordermeddelande, o1.linjenr1 as o1_linjenr1, o1.linjenr2 as o1_linjenr2, o1.linjenr3 as o1_linjenr3,  "
        +" o2.pos as o2_pos, o2.artnr as o2_artnr, o2.namn as o2_namn, o2.best as o2_best, o2.enh as o2_enh, o2.levnr as o2_levnr, o2.text as o2_text, o2.utskrivendatum as o2_utskrivendatum, o2.utskriventid as o2_utskriventid, o2.stjid as o2_stjid, "
        +" a.refnr as a_refnr, a.rsk as a_rsk, a.enummer as a_enummer, a.plockinstruktion as a_plockinstruktion, l.ilager as l_ilager, l.iorder as l_iorder, l.best as l_best, l.lagerplats as l_lagerplats, a.minsaljpack as a_minsaljpack, a.forpack as a_forpack, a.kop_pack as a_kop_pack"
        +" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join lager l on l.lagernr=o1.lagernr and l.artnr=o2.artnr ";

                                                    
                                                    
                                                    
    StringBuilder sb = new StringBuilder();

        sb.append(selectOrderHeader);

        sb.append("where o1.ordernr in (");
        boolean f = false;
        for(int ordernr : ordernrList) {
            if (f) sb.append(","); else f=true;
            sb.append(ordernr);
        }
        sb.append(") ");

        sb.append(" order by o1.ordernr, o2.pos");

        q=sb.toString();

         ps = con.prepareStatement(q);
         rs = ps.executeQuery();

         int prevOrdernr = 0;
         int radCn=0;
         int orderCn=0;
         int tempCn=0;
%>
        <div class="noprint">

        </div>
            <% while (rs.next()) { %>
                <% orderCn++; %>
                <% if (prevOrdernr==0 || rs.getInt(2) != prevOrdernr) { %>
                        <% if (prevOrdernr!=0) { %>
                                </table></div></div>
                        <% } %>
                        <% prevOrdernr = rs.getInt(2); 
                                radCn = 0;
                        %>
                        <div class="order <%= orderCn>1 ? "page-break-before" : "" %> ">
                            <div class="orderhuvud">
                                <div><img class="noscreen" SRC="https://www.saljex.se/p/s200/logo-saljex" style="margin-right: 60px;"><h2>Order <%= updateOrderStatus ? "" : " - Kopia" %></h2></div>
                        <table width="100%">
                            <tr>
                                <th>Ordernr</th>
                                <th>Datum</th>
                            </tr>
                            <tr>
                                <td><%= rs.getInt(1) + "-" + rs.getInt(2) %></td>
                                <td><%= SXUtil.getFormatDate(rs.getDate(4)) %></td>
                            </tr>

                            <tr>
                                <th>Kundnr</th>
                                <th>Kund</th>
                            </tr>
                            <tr>
                                <td><%= SXUtil.toHtml(rs.getString(5)) %></td>
                                <td><%= SXUtil.toHtml(rs.getString(6)) %></td>
                            </tr>
                            <tr>
                                <th>Adress</th><th>Leveransadress</th>
                            </tr>
                            <tr>
                                    <td><%=SXUtil.toHtml(rs.getString(7))%></td><td><b><%=SXUtil.toHtml(rs.getString(10))%></b></td>
                            </tr>
                            <tr>
                                    <td><%=SXUtil.toHtml(rs.getString(8))%></td><td><b><%=SXUtil.toHtml(rs.getString(11))%></b></td>
                            </tr>
                            <tr>
                                    <td><%=SXUtil.toHtml(rs.getString(9))%></td><td><b><%=SXUtil.toHtml(rs.getString(12))%></b></td>
                            </tr>
                            <tr>
                                    <th colspan="2">Märke</th>
                            </tr>
                            <tr>
                                    <td colspan="2"><%=SXUtil.toHtml(rs.getString(13))%></td>
                            </tr>
                            <tr>
                                    <th>Levdat</th><td><%=SXUtil.getFormatDate(rs.getDate(15))%></td>
                            </tr>
                            <tr>
                                    <th>Not</th><td><%=SXUtil.toHtml(rs.getString(17))%></td>
                            </tr>
                            <tr>
                                    <th colspan="2">Linjer</th>
                            </tr>
                            <tr>
                                    <td colspan="2"><%=SXUtil.toHtml(rs.getString(18)) + " " + SXUtil.toHtml(rs.getString(19)) + " " + SXUtil.toHtml(rs.getString(20)) %></td>
                            </tr>
                        </table>
                        </div>
                        <div class="orderrader">
                        <table width="100%">
                            <tfoot>
                                <TR><td colspan="6">
                                    <table class="noscreen" style="margin-top: 12px; width: 100%; border: 1px solid black; font-size: 50%;">
                                        <tr><td style="width: 80%">Antal kolli</td><td style="width:20%">Packat av</td></tr>
                                        <tr style="height: 60px;"><td colspan="2"></td></tr>
                                    </table>
                                </td></tr>
                            </tfoot>
                            <tr><th class="border_btn c-bild"></th><th class="border_btn c-lp">Lp/pos</th><th class="border_btn c-artnr">Nummer</th><th class="border_btn c-artnamn">Benämning</th><th class="border_btn c-antal">Antal</th><th class="border_btn">Levererat</th></tr>					
                    <% } %>
                    <% radCn++; %>
                    <% if (SXUtil.isEmpty(rs.getString(27))) { %>
                    <tr class="avoid_page_break">
                            <td colspan="6" class="avoid_page_break">
                                    <table width="100%">
                                            <tr>
                                                <% try { tempCn = SXUtil.toHtml(rs.getString(38)).length(); } catch (Exception e) {tempCn=0;}%>
                                                <td rowspan="3" class="border_btn c-bild"><img class="pbild" src="http://saljex.se/p/s200/<%= rs.getString(22) %>"></td>
                                                <td rowspan="3" class="border_btn c-lp"><div class="<%= tempCn>5 ? (tempCn>9 ? "liten-text" : "mellan-text") : "" %>"><%= SXUtil.toHtml(rs.getString(38)) %></div><div class="liten-text"><%= radCn %></div></td>
                                                    <td class="c-artnr"><%= SXUtil.toHtml(rs.getString(22)) %></td>
                                                    <td class="c-artnamn"><%= SXUtil.toHtml(rs.getString(23)) %></td>
                                                    <% 
                                                            long hela = 0;
                                                            double losa = 0.0;
                                                            double forpackStorlek = 0;
                                                            Double forpack = SXUtil.noNull(rs.getDouble(40));
                                                            Double kop_pack = SXUtil.noNull(rs.getDouble(41));
                                                            Double antal = SXUtil.noNull(rs.getDouble(24));
                                                            try {
                                                                    if (antal.compareTo(kop_pack) >= 0 && kop_pack > 0 && kop_pack != 1) {
                                                                            hela = (long)(antal/kop_pack);
                                                                            losa = antal%kop_pack;
                                                                            forpackStorlek = kop_pack;
                                                                    } else if (antal.compareTo(forpack) >= 0 && forpack > 0 && forpack != 1) {
                                                                            hela = (long)(antal/forpack);
                                                                            losa = antal%forpack;
                                                                            forpackStorlek = forpack;
                                                                    }
                                                            } catch (Exception e) {}			
                                                            String finnsILagerStr = "";
                                                            if (SXUtil.noNull(rs.getDouble(35)).compareTo(0.0) > 0) finnsILagerStr = "*";


                                                    %>
                                                    <td class="c-antal"><%= SXUtil.getFormatNumber(rs.getDouble(24)) + finnsILagerStr + " " + SXUtil.toHtml(getEnh(rs.getString(25))) %>
                                                    <% if (hela!=0) { %>
                                                            <br><small>(
                                                                    <b><%= hela %></b> <%= hela>1 ? "forp." : "förp."  %> om <%= SXUtil.getFormatNumber(forpackStorlek) %>
                                                                    <% if(losa!=0.0) { %>
                                                                            <br>+ <%= SXUtil.getFormatNumber(losa) %> <%= SXUtil.toHtml(getEnh(rs.getString(25))) %> lösa
                                                                    <% } %>
                                                            )</small>
                                                    <% } %>
                                                    </td>

                                            </tr><tr>
                                                <td colspan="4" width="100%"><span class="mellan-text"><%= SXUtil.toHtml(rs.getString(31)) + " " + SXUtil.toHtml(rs.getString(32)) + " " + SXUtil.toHtml(rs.getString(33))  %></span></td>
                                            </tr>		
                                            <tr>
                                                    <td colspan="5" class="border_btn" width="100%"><%= SXUtil.toHtml(rs.getString(34)) %></td>
                                            </tr>
                                    <% } else { %>
                                            <tr>
                                                    <td colspan="5"><%= SXUtil.toHtml(rs.getString(27)) %></td>					
                                            </tr>
                                    <% } %>
                                    </table>
                            </td></tr>
                <% } %>

        </table>
        </div></div>

	
</div>				
    <% if (updateOrderStatus && anvandareKorrekt)  {  
        ps = con.prepareStatement("update order1 set status = 'Utskr' where ordernr=?");
        PreparedStatement ps2 = con.prepareStatement("insert into orderhand (ordernr, datum, tid, anvandare, handelse) values (?, current_date, current_time, ?, 'Utskriven')");
        for (Integer ordernr : ordernrList) {
            ps.setInt(1, ordernr);
            ps.executeUpdate();

            ps2.setInt(1, ordernr);
            ps2.setString(2, anvandare);
            ps2.executeUpdate();
        }
    }
    %>
<% }  %>


	</body>
</html>

<%!
public String getEnh(String s) {
		if ("ST".equals(s)) return "st";
		else if ("M".equals(s)) return "m";
		else if ("M2".equals(s)) return "m²";
		else if ("M3".equals(s)) return "m³";
		else if ("KG".equals(s)) return "Kg";
		else if ("PAR".equals(s)) return "Par";
		else if ("KG".equals(s)) return "Kg";
		return s;
	}
%>
