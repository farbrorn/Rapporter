<%-- 
    Document   : Order
    Created on : 2016-aug-12, 13:50:15
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
                Integer lagernr = 0;
                try { lagernr = Integer.parseInt(request.getParameter("lagernr")); } catch (Exception e) {}
                String linjenr = request.getParameter("linjenr");
                
              

%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Dagens Order</title>

                <script>
function sel_order(ordernr) {
    var e = document.getElementById("o"+ordernr);
    document.getElementById("ordercontent").innerHTML=e.innerHTML;
    var ot = document.getElementById("ordertable");
    for (var r = 0, row; row= ot.rows[r]; r++) { //clear
        row.classList.remove('sel');
        //row.className.replace( /(?:^|\s)sel(?!\S)/g , '' );
    }
    document.getElementById("r"+ordernr).classList.add("sel");
    
}                    
function t_visibel(id) {
    var e = document.getElementById(id);
    if(e.style.display=='block') e.style.display='none'; else e.style.display='block';
}          

function loadAndPrint(ordernr) {
//    var w = window.open("order.jsp?ordernr="+ordernr,"PrintWindow", "width=750,height=650,top=50,left=50,toolbars=no,scrollbars=yes,status=no,resizable=yes");
    var w = window.open("order.jsp?ordernr="+ordernr,"PrintWindow", "width=750,height=650,top=50,left=50");
    w.document.close();
    w.focus();
    
    w.print();
    //w.close();
    setTimeout(function(){w.close();},2000);
    
}
                    </script>


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
.page-break-before { page-break-before: always; }

.border_btn {
	border-bottom: 1px solid black;
}

.maindiv {
	width: 700px;
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
.c-linjenr {
    width: 60px;
}
.c-ordernr {
    width: 80px;
}
.c-datum {
    width: 80px;
}
.c-kundnr {
    width: 80px;
}
.c-kundnamn {
    width: 250px;
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

.sel {
    background-color: #ccffff;
}

#orderlista {
    border: 1px solid black;
    margin-top: 8px;
    padding: 4px;
    height: 300px;
    overflow: scroll;
}

#ordercontent {
    border: 1px solid black;
    margin-top: 8px;
    padding: 4px;
    height: 250px;
    overflow: scroll;
    
}
</style>	
	</head>
        <body>
		<h1 style="display: none"><sx-rubrik>Dagens Order</sx-rubrik></h1>
		<div class="maindiv">
                    <div class="noprint" style="margin-bottom: 12px;">
                        <%
                q="select linjenr, namn from turlinje order by linjenr";
                ps=con.prepareStatement(q);
                rs=ps.executeQuery();

%>                        
                        <form>
                            <table>
                                <tr><td>
                                    <table>
                                        <tr><td>Lagernr</td><td><input type="number" name="lagernr" value="<%= lagernr==null ? "" : ""+lagernr %>"></td></tr>
                                        <tr><td>Turbilslinje</td><td>
                                                <select name="linjenr">
                                                    <% while (rs.next()) { %>
                                                        <option value="<%= rs.getString(1) %>" <%= SXUtil.toStr(rs.getString(1)).equals(linjenr) ? "selected" : "" %> ><%= SXUtil.toHtml(rs.getString(1)) + " - " + SXUtil.toHtml(rs.getString(2)) %></option>
                                                    <% } %>
                                                </select>
                                            </td></tr>
                                        <tr><td><input type="submit" value="Uppdatera"></td></tr>
                                    </table>
                            </table>
                        </form>
                            
                    </div>
<%


                                                    
final String selectOrderHeader  =      
         " select "
        +" o1.lagernr as o1_lagernr, o1.ordernr as o1_ordernr, o1.dellev as o1_dellev, o1.datum as o1_datum, o1.kundnr as o1_kundnr, o1.namn as o1_namn, o1.adr1 as o1_adr1, o1.adr2 as o1_adr2, o1.adr3 as o1_adr3, o1.levadr1 as o1_levadr1, "
        +" o1.levadr2 as o1_levadr2, o1.levadr3 as o1_levadr3, o1.marke as o1_marke,  o1.status as o1_status, o1.levdat as o1_levdat, o1.fraktbolag as o1_fraktbolag, o1.ordermeddelande as o1_ordermeddelande, o1.linjenr1 as o1_linjenr1, o1.linjenr2 as o1_linjenr2, o1.linjenr3 as o1_linjenr3,  "
        +" o2.pos as o2_pos, o2.artnr as o2_artnr, o2.namn as o2_namn, o2.best as o2_best, o2.enh as o2_enh, o2.levnr as o2_levnr, o2.text as o2_text, o2.utskrivendatum as o2_utskrivendatum, o2.utskriventid as o2_utskriventid, o2.stjid as o2_stjid, "
        +" a.refnr as a_refnr, a.rsk as a_rsk, a.enummer as a_enummer, a.plockinstruktion as a_plockinstruktion, l.ilager as l_ilager, l.iorder as l_iorder, l.best as l_best, l.lagerplats as l_lagerplats, a.minsaljpack as a_minsaljpack, a.forpack as a_forpack, a.kop_pack as a_kop_pack"
        +" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join lager l on l.lagernr=o1.lagernr and l.artnr=o2.artnr ";

%>                                                    
<div id="orderlista">

<table id="ordertable">
    <tr><th class="c-linjenr">Linjenr</th><th class="c-ordernr">Ordernr</th><th class="c-datum">Datum</th><th class="c-kundnamn">Kund</th><th class="c-datum">Levdat</th></tr>

<%
        q = selectOrderHeader
                + " where o1.lagernr=? and (linjenr1=? or linjenr2=? or linjenr3=? or 1=?) and status in (?,?) order by o1.ordernr desc";
       
        ps = con.prepareStatement(q);
        ps.setInt(1, lagernr);
        ps.setString(2, linjenr);
        ps.setString(3, linjenr);
        ps.setString(4, linjenr);
        ps.setInt(5, linjenr==null ? 1 : 0);
        ps.setString(6, "Sparad");
        ps.setString(7, "Sparad");

        rs = ps.executeQuery();

         int prevOrdernr = 0;
         int radCn=0;
         int orderCn=0;
         int tempCn=0;
         

         while(rs.next()) {
             orderCn++;
             if (prevOrdernr==0 || rs.getInt(2) != prevOrdernr) { 
                 if (prevOrdernr!=0) {%> </table></td></tr> <% }
                prevOrdernr = rs.getInt(2); 
                radCn = 0;
%>
            <tr id="r<%= rs.getInt("o1_ordernr") %>">
                
                <td onclick="sel_order('<%= rs.getInt("o1_ordernr") %>')">
                    <%=SXUtil.toHtml(rs.getString(18)) + " " + SXUtil.toHtml(rs.getString(19)) + " " + SXUtil.toHtml(rs.getString(20)) %>    </td>
                <td onclick="sel_order('<%= rs.getInt("o1_ordernr") %>')"><%= rs.getInt("o1_lagernr") + "-" + rs.getInt("o1_ordernr") %></td>
                <td onclick="sel_order('<%= rs.getInt("o1_ordernr") %>')"><%= SXUtil.getFormatDate(rs.getDate(4)) %></td>
                <td onclick="sel_order('<%= rs.getInt("o1_ordernr") %>')"><%= SXUtil.toHtml(rs.getString(6)) %></td>
                <td><%=SXUtil.getFormatDate(rs.getDate(15))%></td>
                
                <td>
                    <a href="order.jsp?ordernr=<%= rs.getInt("o1_ordernr") %>">Kopia</a>
                </td>
            </tr>
            <tr>
                <td id="o<%= rs.getInt("o1_ordernr") %>" style="display: none;">
                    <a onclick="loadAndPrint(<%= rs.getInt("o1_ordernr") %>)">Skriv ut </a>
                    <table style="width: 100%; margin-bottom: 4px;">
                        <tr></tr>
                        <tr><td style="width: 70px">Ordernr</td><td><%= rs.getInt("o1_lagernr") + "-" + rs.getInt("o1_ordernr") %></td></tr>
                        <tr><td>Datum</td><td><%= SXUtil.getFormatDate(rs.getDate(4)) %></td></tr>
                        <tr><td>Kund</td><td><%= SXUtil.toHtml(rs.getString(6)) %></td></tr>
                        <tr><td colspan="2"><%= SXUtil.toHtml(rs.getString("o1_ordermeddelande")) %></td></tr>
                    </table>
                    <table >
                        
<%          } %>           
                        <% radCn++; %>
                        <% if (SXUtil.isEmpty(rs.getString(27))) { %>
                        <tr>
                            <td class="c-artnr"><%= SXUtil.toHtml(rs.getString(22)) %></td>
                            <td class="c-artnamn"><%= SXUtil.toHtml(rs.getString(23)) %></td>
                            <td><%= SXUtil.noNull(rs.getDouble(24)) %></td>
                            <td><%= SXUtil.toHtml(getEnh(rs.getString(25))) %></td>
                        </tr>
                        <% } else { %>
                        <tr>
                            <td colspan="5"><%= SXUtil.toHtml(rs.getString(27)) %></td>
                        </tr>
                        <% } %>

            <% } %>
            </table></td></tr>
        </table>
        
        


</div>	
<div id="ordercontent"></div>
            
            
                </div>
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
