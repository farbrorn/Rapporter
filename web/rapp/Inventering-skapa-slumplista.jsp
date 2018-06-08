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
                
                Integer lagernr = user.getLagernr();
		try { lagernr = Integer.parseInt(request.getParameter("lagernr")); } catch (Exception e) { }
                Integer antalArtiklar = null;
		try { antalArtiklar = Integer.parseInt(request.getParameter("antalartiklar")); } catch (Exception e) { }
                if (antalArtiklar==null) antalArtiklar=10;
                
                String ac = request.getParameter("ac");
           
                
                
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
		Statement st = con.createStatement();
                
		ResultSet rs;
		PreparedStatement ps;
		String q;
                
                %>                    
<div>
<h1 style="display: none"><sx-rubrik>Inventering Skapa slumplista</sx-rubrik></h1>
 
<h2>Inventering skapa slumplista</h2>
<form>
    <input type="hidden" name="ac" value="skapa">
    Lagernr: <input name="lagernr" value="<%= lagernr %>"> Antal artiklar: <input name="antalartiklar" value="<%= antalArtiklar %>"> <input type="submit" value="Skapa lista">
</form>

<%
q="select count(*) as antal from artinventlist1 i1 join artinventlist2 i2 on i1.id=i2.id and utskriftdat > current_date-365 and i1.lagernr="+lagernr;
rs = con.createStatement().executeQuery(q);
int antalInvent=0;
if (rs.next()) antalInvent = rs.getInt(1);
q="select count(*) as antal from lager where (ilager <> 0 or maxlager <> 0 ) and lagernr="+lagernr;
rs = con.createStatement().executeQuery(q);
int antalAttInvent=0;
if (rs.next()) antalAttInvent = rs.getInt(1);
%>    
<div>
Under senaste året har inventerats <%= antalInvent %> av <%= antalAttInvent %>.
</div>    
<%
if (lagernr!=null && "skapa".equals(ac) && antalArtiklar!=null) { 
%>



<%
q=
"create temporary table i on commit drop as select coalesce(max(id),0)+1 as id, ? as lagernr, current_date as datum from artinventlist1; "
+" insert into artinventlist2 (id, artnr)  "
+" select (select i.id from i),  a.nummer "
+" from artikel a join lager l on l.artnr=a.nummer and l.lagernr=(select lagernr from i) "
//where a.nummer in (select artnr from lagerhand where lagernr=(select lagernr from i) and forandring <> 0 and datum > current_date-365 group by artnr having count(*) >1)
+" and a.nummer not in (select artnr from artinventlist2 ai2 join artinventlist1 ai1 on ai1.id=ai2.id and ai1.datum > current_date-180 where ai1.lagernr=(select lagernr from i)) "
+" and l.lagerplats >= "
+" (select lagerplats  "
+" from lager where (ilager <> 0 or maxlager<>0) and lagernr=(select lagernr from i) and artnr not in (select artnr from artinventlist2 ai2 join artinventlist1 ai1 on ai1.id=ai2.id and ai1.datum > current_date-180 where ai1.lagernr=(select lagernr from i)) "
+" order by random() limit 1 ) "
+" order by l.lagerplats, random() "
+" limit ?; "
+" insert into artinventlist1 (id, lagernr, datum, beskrivning) values ( (select id from i), (select lagernr from i), (select datum from i), "
+" 'Slumpad, Artiklar: ' || (select count(*) from artinventlist2 where id=(select i.id from i))); ";
//+" select id, beskrivning from artinventlist1 where id=(select id from i);";
    ps = con.prepareStatement(q);
    ps.setInt(1, lagernr);
    ps.setInt(2, antalArtiklar);
    ps.executeUpdate();
%>
Listan är skapad! <a href="Inventering-inmatning.jsp?visalagernr=<%= lagernr %>"> Klicka här för att visa!</a>
        
<% } %>

	
</div>

</body>
</html>
