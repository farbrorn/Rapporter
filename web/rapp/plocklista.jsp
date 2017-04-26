<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

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
		java.sql.Date utskrivenDatum = null;
		java.sql.Time utskrivenTid = null;
                String ac = request.getParameter("ac");
		try { utskrivenDatum = new java.sql.Date( (dateFormatter.parse((String)request.getParameter("utskrivendatum"))).getTime() );} catch (Exception e) { 		}
		try { utskrivenTid = new java.sql.Time((timeFormatter.parse((String)request.getParameter("utskriventid"))).getTime());} catch (Exception e) {}
                Integer lagernr = null;
                try { lagernr = Integer.parseInt(request.getParameter("lagernr")); } catch (Exception e) {}
                String linjenr = request.getParameter("linjenr");
                String lagerplatsString = request.getParameter("lagerplatser");
                String[] lagerplatsArr = null;
                try { lagerplatsArr = lagerplatsString.split(","); } catch (Exception e) {}
                
                String printAllaOrderraderStr = request.getParameter("printallarader");
                if (printAllaOrderraderStr==null) printAllaOrderraderStr="false";
                boolean printAllaOrderrader = "true".equals(printAllaOrderraderStr.toLowerCase());

%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Plocklista</title>

	
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
        <body <%= "ny".equals(ac) ? "onload=\"window.print();\"" : "" %>>
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
                                        <tr><td>Lagerplatser, separerade med komma</td><td><input type="text" name="lagerplatser" value="<%= SXUtil.toStr(lagerplatsString) %>"></td></tr>
                                        <tr><td>Turbilslinje</td><td>
                                                <select name="linjenr">
                                                    <% while (rs.next()) { %>
                                                        <option value="<%= rs.getString(1) %>" <%= SXUtil.toStr(rs.getString(1)).equals(linjenr) ? "selected" : "" %> ><%= SXUtil.toHtml(rs.getString(1)) + " - " + SXUtil.toHtml(rs.getString(2)) %></option>
                                                    <% } %>
                                                </select>
                                            </td></tr>
                                        <tr><td colspan="2"><input type="checkbox" name="printallarader" value="true" <%= printAllaOrderrader ? "checked" : "" %>> Skriv alla orderrader</td><td></td></tr>
                                        <tr><td><input type="submit" value="Ny lista"></td><td><button onclick="window.print();">Skriv ut</button></td></tr>
                                    </table>
                                        <% if ("ny".equals(ac)) { %><div style="margin-top: 6px; font-weight: bold;">Observera att listade order är markerade som utskrivna.</div><% } %>

                                    </td><td>
                                        <a href="?lagernr=0&lagerplatser=U&skrivallarader=false">Grums - Ute</a>
                                    </td></tr>
                            </table>
                            <input type="hidden" name="ac" value="ny">
                        </form>
                            
                    </div>
		<h1 style="display: none"><sx-rubrik>Plocklista</sx-rubrik></h1>
<%
if ("atertautskrift".equals(ac) && utskrivenDatum!=null && utskrivenTid!=null)        {
    q = "update order2 set utskrivendatum=null, utskriventid=null where utskrivendatum=? and utskriventid=?" ;
    ps = con.prepareStatement(q);
    ps.setDate(1, utskrivenDatum);
    ps.setTime(2, utskrivenTid);
    utskrivenDatum = null;
    utskrivenTid = null;
    ps.executeUpdate();
}

if ("ny".equals(ac) && lagerplatsString!=null && lagernr != null && linjenr!=null && !linjenr.isEmpty()) {
                //Date dagensDatum = new Date();
                Calendar dagensDatum = Calendar.getInstance();
                dagensDatum.set(Calendar.MILLISECOND, 0);
                utskrivenDatum = new java.sql.Date(dagensDatum.getTimeInMillis());
                utskrivenTid =  new java.sql.Time(dagensDatum.getTimeInMillis());
                
                    
                StringBuilder sb = new StringBuilder();
                if (lagerplatsString != null) for (String a : lagerplatsArr) {
                    sb.append(" l.lagerplats like ? or ");
                }
q="update order2 as o set " +
" utskrivendatum=?, utskriventid=? "+
" from ( " +
" SELECT o2.ordernr, o2.pos "+
" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join lager l on l.artnr=a.nummer and l.lagernr=? "+
" where o1.status in ('Sparad','Utskriven') and (o1.linjenr1 = ? or o1.linjenr2=? or o1.linjenr3=?) and o2.utskrivendatum is null "+
" and (" + sb.toString() +

" o2.artnr like '*%' or length(o2.text) > 0) and o1.lagernr=? and (o1.levdat is null or o1.levdat >= current_date-1) "+
") as u "+
" where o.ordernr=u.ordernr and o.pos = u.pos ";

                ps=con.prepareStatement(q);
                int paramcn = 1;
                ps.setDate(paramcn++, utskrivenDatum);
                ps.setTime(paramcn++, utskrivenTid);
                ps.setInt(paramcn++, lagernr);
                ps.setString(paramcn++, linjenr);
                ps.setString(paramcn++, linjenr);
                ps.setString(paramcn++, linjenr);
                if (lagerplatsString != null) for (String a : lagerplatsArr) {
                    ps.setString(paramcn++, a+"%");
                }
                ps.setInt(paramcn++, lagernr);
                ps.executeUpdate();
        
}

		if (utskrivenDatum == null || utskrivenTid == null) {
			rs = st.executeQuery("select distinct utskrivendatum, utskriventid from order2 where utskrivendatum is not null order by utskrivendatum desc, utskriventid desc");
%>		
			<table>
				<tr><th>Tidigare utskrivna</th></tr>
				<% while (rs.next()) { %>
					<tr>
						<td>
							<a href="?utskrivendatum=<%= URLEncoder.encode(dateFormatter.format(rs.getDate(1)), "ISO-8859-1")  + "&utskriventid=" + URLEncoder.encode(timeFormatter.format(rs.getTime(2)), "ISO-8859-1") %>">
							<%= rs.getDate(1).toString() + " " + rs.getTime(2).toString() %></a>
						</td>	
					</tr>
				<% } %>

			</table>
<%		} else {

			q = " select "
			+" o1.lagernr, o1.ordernr, o1.dellev, o1.datum, o1.kundnr, o1.namn, o1.adr1, o1.adr2, o1.adr3, o1.levadr1, "
			+" o1.levadr2, o1.levadr3, o1.marke,  o1.status, o1.levdat, o1.fraktbolag, o1.ordermeddelande, o1.linjenr1, o1.linjenr2, o1.linjenr3,  "
			+" o2.pos, o2.artnr, o2.namn, o2.best, o2.enh, o2.levnr, o2.text, o2.utskrivendatum, o2.utskriventid, o2.stjid, "
			+" a.refnr, a.rsk, a.enummer, a.plockinstruktion, l.ilager, l.iorder, l.best, l.lagerplats, a.minsaljpack, a.forpack, a.kop_pack"
			+" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr left outer join lager l on l.lagernr=0 and l.artnr=o2.artnr "
                                
                               
			+ (printAllaOrderrader ? " where o1.ordernr in (select ordernr from order2 where utskrivendatum=? and utskriventid=?) " 
                                                : " where o2.utskrivendatum=? and o2.utskriventid=? " )
                                
			+" order by o1.ordernr, l.lagerplats, o2.pos";
			 ps = con.prepareStatement(q);
			 ps.setDate(1, utskrivenDatum);
			 ps.setTime(2, utskrivenTid);
			 rs = ps.executeQuery();
			 
			 int prevOrdernr = 0;
			 int radCn=0;
                         int orderCn=0;
                         int tempCn=0;
%>
                <div class="noprint">
                <a href="?ac=atertautskrift&utskrivendatum=<%= URLEncoder.encode(dateFormatter.format(utskrivenDatum), "ISO-8859-1")  + "&utskriventid=" + URLEncoder.encode(timeFormatter.format(utskrivenTid), "ISO-8859-1") %>">
                Återta denna utskrift</a>

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
                                                            <div><img class="noscreen" SRC="https://www.saljex.se/p/s200/logo-saljex" style="margin-right: 60px;"><h2>Plocksedel</h2></div>
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

<%	} %>
	
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