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
		Connection con=null;
                
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
                
                Integer inventId = null;
                String ac = null;
		
		try { inventId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { }
                ac = request.getParameter("ac");

                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Inventeringsinmatning</title>

                
<script>
function doKeyUp(event,row) {
    var key=event.keyCode;
    var char = event.which || event.keyCode;
    if (key==40 || key==13) { // Down/Enter
        event.preventDefault();
        row++;
        document.getElementById("i"+row).focus();
        document.getElementById("i"+row).select();
    } else if (key==38) { // Up
        event.preventDefault();
        row--;
        document.getElementById("i"+row).focus();
        document.getElementById("i"+row).select();
    }/* else if (!((char >= 38 && char <= 57) || char==44 || char==46) ) { // mellan 0-99 komma(,) eller punkt(.)
       event.preventDefault();
    } */
}


function doChange(event,row) {
    if (isNaN(document.getElementById("i"+row).value)) {
        document.getElementById("i"+row).value="";
        document.getElementById("i"+row).focus();
        alert("Ogiltigt antal");
    }
}



</script>
	
<style type="text/css">
	
		
	
table {
	border-collapse: collapse;
	font-size:12px; 
}

.ivt {
    width: 100%;
}
.ivt td {
    border: 1px solid lightgrey;
}

.underline {
    border-bottom: 1px solid grey;
}
.smt {
    font-size: 80%;
}
table th {
	font-size: 50%;
	font-weight: Bold;
	text-align: left;
}
table td {
	padding: 4px;
}

.maindiv {
	width: 100%;
}

.notering {
	color: red;
}

.i {
    width: 5em;
}

.right {
	text-align: right;
}
@media print {
.noprint { display: none; }
}


</style>	
	</head>
	<body>
		<div class="maindiv">
                    <%
		Statement st = con.createStatement();
                
		ResultSet rs;
		PreparedStatement ps;
		String q;
                Integer lagernr = null;
                java.sql.Date datum = null;
                String beskrivning = null;
                
                
                if (inventId!=null) {
		q = 
"select * "
+" from artinventlist1 "
+" where id=? " ;

		ps = con.prepareStatement(q);
		ps.setInt(1,inventId );
		
		rs = ps.executeQuery();
                if (rs.next()) {
                    lagernr = rs.getInt("lagernr");
                    datum = rs.getDate("datum");
                    beskrivning  = rs.getString("beskrivning");
                } else {
                    inventId = null; 
                }
                }
                

                %>                    
<div class="noprint">
    <form>
        ID:<input type="text" name="id" value="<%= SXUtil.noNull(inventId) %>">
        <input type="submit">
    </form>
        
</div>
        
        
                    <%

    boolean error=false;
    int updateCn=0;
if ("update".equals(ac) && inventId!=null) {
    
%>
<div>
<%
    String artnr;
    Double antal;
    
   
    q=
"insert into lagerhand (artnr, lagernr, datum, tid, anvandare, handelse, gammaltilager, nyttilager, forandring) "
+" values (?, " + lagernr + " , current_date, current_time, ?, 'Invent', coalesce((select coalesce(ilager,0) from lager where artnr=? and lagernr=" + lagernr + "),0), ?, ?-coalesce((select coalesce(ilager,0) from lager where artnr=? and lagernr=" + lagernr + "),0)); "

+" insert into lager (artnr, lagernr, ilager, bestpunkt, maxlager, best, iorder, lagerplats, hindrafilialbest)  "
+" select ?," + lagernr + ", 0, 0, 0, 0,0, '', 0 where not exists (select 1 from lager where artnr=? and lagernr=" + lagernr + "); "

+" update lager set ilager = ? where artnr=? and lagernr=" + lagernr + "; ";

ps=con.prepareStatement(q);

    try {
        for (int i=1; true ; i++ ) {
                artnr = request.getParameter("artnr[" + i + "]");
                if (artnr == null || i > 100000) break;
                try { antal = Double.parseDouble(request.getParameter("antal[" + i + "]")); } catch (Exception e) { antal=null; }
                if (antal != null) {
                    ps.setString(1, artnr);
                    ps.setString(2, user.getAnvandare());
                    ps.setString(3, artnr);
                    ps.setDouble(4, antal);
                    ps.setDouble(5, antal);
                    ps.setString(6, artnr);

                    ps.setString(7, artnr);                   
                    ps.setString(8, artnr);
                    
                    ps.setDouble(9, antal);
                    ps.setString(10, artnr);
                    
                    ps.executeUpdate();
                    updateCn++;

                }
            }
    } catch (Exception e) { 
        error=true;
        con.rollback();
        out.print(e.getMessage() + e.toString());
    } finally {
        con.setAutoCommit(true);
        ps.close();
    }
  
if (error) { %>
<h1>*Fel*</h1>
Inget sparat. försök igen.
    
<% } else { %>
<h2>Sparat!</h2>
Uppdaterade artiklar: <%= updateCn %>
<%
}
%>
</div>
<% } %>        
		
		<h1 style="display: none"><sx-rubrik>Inventering Inmatning</sx-rubrik></h1>
<%
if (inventId!=null && (ac==null || error)) { 
		q = 
"select "
+" l.lagerplats as lagerplats, a.nummer as artnr, a.namn as namn , l.ilager as ilager, o.antal as antalsamfakt, o2.antal as antalutskrivet,   a.enhet as enhet, a.bestnr as bestnr, a.refnr as refnr, a.rsk as rsk, a.enummer as enummer"
+" from artinventlist1 ai1 "
+" join artinventlist2 ai2 on ai1.id=ai2.id "
+" join artikel a on a.nummer=ai2.artnr "
+" left outer join lager l on l.artnr=a.nummer and l.lagernr= ai1.lagernr"
+" left outer join ("
+" select o2.artnr, o1.lagernr, sum(o2.lev) as antal"
+" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr"
+" and o1.status in ('Klar','Utlev','Samfak', 'Hämt') "
+" group by o2.artnr, o1.lagernr"
+" ) o on o.artnr=a.nummer and o.lagernr=ai1.lagernr"
+" left outer join ("
+" select o2.artnr, o1.lagernr, sum(o2.lev) as antal"
+" from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr"
+" and o1.status in ('Utskr') "
+" group by o2.artnr, o1.lagernr"
+" ) o2 on o2.artnr=a.nummer and o2.lagernr=ai1.lagernr"
+" where ai1.id=?"
+" order by l.lagerplats, a.nummer";
		ps = con.prepareStatement(q);
		ps.setInt(1,inventId );
		rs = ps.executeQuery();

                
                
                int decimaler=0;
                double antal;
%>

                
                    
<h2>Inventering</h2>
<table >
    <tr><td>ID</td><td><%= inventId %></td></tr>
    <tr><td>Lager</td><td><%= lagernr %></td></tr>
    <tr><td>Skapad</td><td><%= SXUtil.getFormatDate(datum)  %></td></tr>
    <tr><td>Beskrivning</td><td><%= SXUtil.toHtml(beskrivning)  %></td></tr>
</table>
<b>Glöm inte att spara ändringarna när du är klar!</b>
<form method="post">
    <input type="hidden" name="ac" value="update">
	<table class="ivt">
<tr class="underline">
    <th>Lagerplats</th><th>Art.nr</th><th>Benämning</th><th>I lager</th><th>Inventerat</th><th>Samfakt</th><th>Utskrivet</th><th>Enhet</th><th>Bestnr</th><th>Refnr</th><th>RSK</th><th>Enr</th>
</tr>

<%              int rowCn=0; %>
<%		while (rs.next()) {	%>
<%                  rowCn++; %>
	<tr >
            <td><%= SXUtil.toHtml(rs.getString("lagerplats")) %></td>
            <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
            <td><%= SXUtil.toHtml(rs.getString("namn")) %></td>
            
            <%
            decimaler=0;
            antal = rs.getDouble("ilager");
            //Kolla om antalet innehåller decimaler 
            if (((long)(antal-((long)antal))*100) != 0) decimaler = 2;
            %>
            <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("ilager"),decimaler) %></td>
 
<%
            String v;
            v= request.getParameter("antal[" + rowCn + "}");
%>            
            <td><input name="antal[<%= rowCn %>]" class="i" id="i<%= rowCn %>" onkeydown="doKeyUp(event, <%= rowCn %>)" onchange="doChange(event, <%= rowCn %>)" value="<%= v!=null ? v : "" %>"></td>
            <input type="hidden" name="artnr[<%= rowCn %>]" value="<%= rs.getString("artnr") %>" >
            
            <%
            decimaler=0;
            antal = rs.getDouble("antalsamfakt");
            //Kolla om antalet innehåller decimaler 
            if (((long)(antal-((long)antal))*100) != 0) decimaler = 2;
            %>
            <td class="smt right"><%= rs.getDouble("antalsamfakt")==0.0 ? "" : SXUtil.getFormatNumber(rs.getDouble("antalsamfakt"),decimaler) %></td>
            
            <%
            decimaler=0;
            antal = rs.getDouble("antalutskrivet");
            //Kolla om antalet innehåller decimaler 
            if (((long)(antal-((long)antal))*100) != 0) decimaler = 2;
            %>
            <td class="smt right"><%= rs.getDouble("antalutskrivet")==0.0 ? "" : SXUtil.getFormatNumber(rs.getDouble("antalutskrivet"),decimaler) %></td>
            <td class="smt"><%= SXUtil.toHtml(rs.getString("enhet")) %></td>
            <td class="smt"><%= SXUtil.toHtml(rs.getString("bestnr")) %></td>
            <td class="smt"><%= SXUtil.toHtml(rs.getString("refnr")) %></td>
            <td class="smt"><%= SXUtil.toHtml(rs.getString("rsk")) %></td>
            <td class="smt"><%= SXUtil.toHtml(rs.getString("enummer")) %></td>
        </tr>	
<% } %>
	</table>
        <input type="submit" value="Spara ändrade lagersaldo">
</form>        
<% } %>
	
</div>				
	</body>
</html>
