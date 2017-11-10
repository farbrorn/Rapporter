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
                
		ResultSet rs;
		PreparedStatement ps;
//                Statement st;
		String q;

                User user=null;
		Connection con=null;
                
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
                
                Integer inventId = null;
		
		try { inventId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { }
                Integer listaLagernr = user.getLagernr();
		try { listaLagernr = Integer.parseInt(request.getParameter("listalagernr")); } catch (Exception e) { }
                if (listaLagernr==null) listaLagernr=0;
           
                
                boolean markeraUtskriven = false;
                Integer lagernr = null;
                java.sql.Date datum = null;
                String beskrivning = null;

                if (inventId!=null) {
                    if (request.getParameter("id").equals(request.getParameter("markerautskriven"))) markeraUtskriven = true;
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
                    listaLagernr = lagernr;
                } else {
//                    inventId = null; 
                }
                
                }

                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Inventeringslista</title>

	
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
                
                if (markeraUtskriven) {
                    q="update artinventlist1 set utskriftdat=current_date where id=?";
                    ps = con.prepareStatement(q);
                    ps.setInt(1, inventId);
                    
                    if (ps.executeUpdate() != 1) { %> <h1>*FEL* Kan inte markera som utskriven </h1> <% }
                }
		q = 
"select ai.*, l.bnamn as lagernamn "
+" from artinventlist1 ai join lagerid l on l.lagernr=ai.lagernr "
+" where datum >= current_date-60 and l.lagernr=" + listaLagernr + " order by ai.lagernr, ai.id desc " ;
		ps = con.prepareStatement(q);
		rs = ps.executeQuery();

                %>                    
<div class="noprint">
    <form>
        ID:<input type="text" name="id" value="<%= SXUtil.noNull(inventId) %>">
        Begränsa urvalslistan till Lagernr :<input type="text" name="listalagernr" value="<%= listaLagernr %>">
        <input type="submit">
    </form>
<%
q="select count(*) as antal from artinventlist1 i1 join artinventlist2 i2 on i1.id=i2.id and utskriftdat > current_date-365 and i1.lagernr="+listaLagernr;
rs = con.createStatement().executeQuery(q);
int antalInvent=0;
if (rs.next()) antalInvent = rs.getInt(1);
q="select count(*) as antal from lager where (ilager <> 0 or maxlager <> 0 ) and lagernr="+listaLagernr;
rs = con.createStatement().executeQuery(q);
int antalAttInvent=0;
if (rs.next()) antalAttInvent = rs.getInt(1);
%>    
<div>
Under senaste året har på lager <%= listaLagernr%> inventerats <%= antalInvent %> av <%= antalAttInvent %>.
</div>    
        
        <br>
        Tillgängliga listor senaste 60 dagarna
        <table>
            <tr><th>Lager</th><th>Id</th><th>Datum</th><th>Beskrivning</th><th>Utskriven</th><th></th></tr>
<%   while (rs.next()) { %>       
            <tr><td><%= rs.getString("lagernamn") %></td><td><a href="?id=<%= rs.getInt("id") %>"><%= rs.getInt("id") %></a></td><td><%= rs.getString("datum") %></td><td><%= SXUtil.toHtml(rs.getString("beskrivning")) %></td><td><%= SXUtil.toHtml(rs.getString("utskriftdat")) %></td>
                <td><a href="Inventering-inmatning.jsp?id=<%= rs.getInt("id") %>">Inmatning</a></td>
            </tr>
<% } %>
</table>
<div><ul>
        <li>
            Innan du skriver utlistan - kontrollera att alla inleveranser är gjorda och att alla ordrar är fakturerade (eller ligger på samfakt. Inga order får finnas oinslagna i systemet.
        </li>
        <li>
            Utskriven lista inmatas samma dag för att uppgifterna inte ska hinna bli gamla.
        </li>
        <li>
            Det antal som står i kolumnen "Samfak" avser artiklar som är utplockade från lagret men är ofakturerade.  
        </li>
        <li>
            Det antal som står i kolumnen "Utskrivet" avser artiklar som ligger utskrivet för plock. Varje sådan artikel måste kontrolelras om den är ploclkad eller inte. Om den är plockad ska antalet adderas till invnenteringen.
        </li>
        <li>
            Det antal som står som "Samfakt" <b>vid inmatningl</b> skall läggas till inventerat antal innan det matas in. (Det som står på den utskrivna listan är endast vägledande.)
        </li>
    </ul>
</div>
        <% if (inventId!=null) { %><br><a href="?id=<%= inventId %>&markerautskriven=<%= inventId %>">Markera visad lista (<%= inventId %>) som utskriven</a> <% } %>
</div>
		
		<h1 style="display: none"><sx-rubrik>Inventeringslista</sx-rubrik></h1>
<%
if (inventId!=null) { 
                
                
                
                
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

                <div>
                    <form>
                        
                    </form>
                </div>
<h2>Inventeringslista</h2>
<table >
    <tr><td>ID</td><td><%= inventId %></td></tr>
    <tr><td>Lager</td><td><%= lagernr %></td></tr>
    <tr><td>Skapad</td><td><%= SXUtil.getFormatDate(datum)  %></td></tr>
    <tr><td>Beskrivning</td><td><%= SXUtil.toHtml(beskrivning)  %></td></tr>
</table>
	<table class="ivt">
<tr class="underline">
    <th>Lagerplats</th><th>Art.nr</th><th>Benämning</th><th>I lager</th><th>Samfakt</th><th>Utskrivet</th><th>Enhet</th><th>Bestnr</th><th>Refnr</th><th>RSK</th><th>Enr</th>
</tr>

<%		while (rs.next()) {	%>
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
        
<% } %>
	
</div>				
	</body>
</html>
