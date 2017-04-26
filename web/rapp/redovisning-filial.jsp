<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="se.saljex.sxlibrary.exceptions.SxInfoException"%>
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

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		Integer frAr = null;
		try { frAr = new Integer(request.getParameter("frar")); } catch (Exception e) { } ;
		Calendar cal = Calendar.getInstance();
		if (frAr==null) frAr = cal.get(Calendar.YEAR);
		if (!user.isBehorighet("L00-Ekonomi")) throw new SxInfoException("Ingen behörighet");
                
%>			

<%
/*
	String lev = request.getParameter("lev");
	Integer frAr = null;
	Integer tiAr = null;
	Integer frMan = null;
	Integer tiMan = null;
	Integer temp = null;
	try { frAr = new Integer( request.getParameter("frar") );} catch (Exception e) { out.print(e.toString());		}
	try { tiAr = new Integer( request.getParameter("tiar") );} catch (Exception e) { out.print(e.toString());		}
	try { frMan = new Integer( request.getParameter("frman") );} catch (Exception e) { out.print(e.toString());		}
	try { tiMan = new Integer( request.getParameter("timan") );} catch (Exception e) { out.print(e.toString());		}

	if (frAr==null) frAr = cal.get(Calendar.YEAR);
	if (tiAr==null) tiAr = cal.get(Calendar.YEAR);
	if (frAr>tiAr) { temp = frAr; frAr=tiAr; tiAr = temp; }
	if (frMan==null) frMan = cal.get(Calendar.YEAR);
	if (tiAr==null) tiAr = cal.get(Calendar.YEAR);
	if (frAr>tiAr) { temp = frAr; frAr=tiAr; tiAr = temp; }
	*/
%>

<%
	ResultSet rs=null;
	PreparedStatement ps=null;
	String q = 

"select st.period, st.ar, st.man, st.lagernr, totviktat, tbviktat, ll.namn , bok.summa  from "
+" ( select coalesce(h.ar, g.ar) || '-' || coalesce(h.man, g.man) as period, coalesce(h.ar, g.ar) as ar, coalesce(h.man, g.man) as man, coalesce(h.lagernr, g.saljarelagernr) as lagernr, "
+" coalesce(h.totalbelopp,0) as totalbeloppOdelat, coalesce(h.beloppavannanfilial,0) as beloppavannanfilial, coalesce(g.belopphosannanfilial,0) as belopphosannanfilial, round(coalesce(h.totalbelopp,0)-coalesce(h.beloppavannanfilial,0)*0.5+coalesce(g.belopphosannanfilial,0)*0.5) as totViktat,  "
+" coalesce(h.totaltb,0) as totaltbOdelat, coalesce(h.tbavannanfilial,0) as tbavannanfilial, coalesce(g.tbhosannanfilial,0) as tbhosannanfilial, round(coalesce(h.totaltb,0)-coalesce(h.tbavannanfilial,0)*0.5+coalesce(g.tbhosannanfilial,0)*0.5) as tbViktat from "
+" 	("
+" 	select ar, man , lagernr, "
+" 	coalesce(sum(belopp),0) as totalbelopp, "
+" 	coalesce(sum(tb),0) as totaltb, "
+" 	coalesce(sum(case when lagernr<>saljarelagernr then belopp else 0 end),0) as beloppAvAnnanFilial, "
+" 	coalesce(sum(case when lagernr<>saljarelagernr then tb else 0 end),0) as tbAvAnnanFilial "

+" 	from  "
+" 		( "
+" 		select year(f1.datum) as ar, month(f1.datum) as man , f1.lagernr, s.namn as saljare, coalesce(s.lagernr, f1.lagernr) as saljarelagernr, round(sum(t_netto)*1) as belopp, round(sum(t_netto-t_innetto)*1) as tb, count(*) as antal "
+" 		from faktura1 f1 left outer join  saljare s on s.namn = trim(substring(f1.saljare,0,30)) "
+" 		where year(f1.datum)>=2005 "
+" 		group by year(f1.datum), month(f1.datum), f1.lagernr, coalesce(s.lagernr, f1.lagernr), s.namn "
+" 		order by year(f1.datum), month(f1.datum), f1.lagernr, coalesce(s.lagernr, f1.lagernr), s.namn "

+" 		) f "
+" 	group by ar, man , lagernr "
+" 	order by ar, man , lagernr "
+" 	) h "
+" full outer join "
+" 	( "
+" 	select year(f1.datum) as ar, month(f1.datum) as man , "
+" 	coalesce(s.lagernr, f1.lagernr) as saljarelagernr,  "
+" 	coalesce(round(sum(t_netto)*1),0) as beloppHosAnnanFilial,  "
+" 	coalesce(round(sum(t_netto-t_innetto)*1),0) as tbHosAnnanFilial "
	
+" 	from faktura1 f1 left outer join saljare s on s.namn = trim(substring(f1.saljare,0,30)) "
+" 	where year(f1.datum)>=2005 and f1.lagernr <> coalesce(s.lagernr, f1.lagernr) "
+" 	group by year(f1.datum), month(f1.datum), coalesce(s.lagernr, f1.lagernr) "
+" 	order by year(f1.datum), month(f1.datum), coalesce(s.lagernr, f1.lagernr) "

+" 	) g "
+" on g.ar=h.ar and g.man=h.man and g.saljarelagernr = h.lagernr  "


+" order by coalesce(h.ar, g.ar), coalesce(h.man, g.man), coalesce(h.lagernr, g.saljarelagernr) ) st "

+" left outer JOIN lagerid ll on ll.lagernr=st.lagernr  "

+" full outer join	( "
+" 		SELECT AR, PER, coalesce(KST,'0') as kst, SUM(DEBET+KREDIT) AS SUMMA "
+" from (select ar, per, case when kst='' or kst is null then '0' else kst end as kst, debet, kredit from bokver2 where ft=1 and ver > 0 and kontonr > '5' and ar >=" + frAr + " ) tbv2"
+" 		where kst in (select distinct lagernr::varchar from faktura1 where year(datum)>=" + frAr + ") "
+" 		GROUP BY AR, PER, KST "
+" 	) bok	on bok.ar=st.ar and bok.per = st.man and bok.kst = st.lagernr::VARCHAR "

+" where coalesce(st.ar, BOK.AR) >= " +  frAr

+" order by st.LAGERNR, st.ar, st.man ";
	



	ps = con.prepareStatement(q);
	rs = ps.executeQuery();

%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Statistik</title>
	
<style type="text/css">
	.t-str {
		text-align: left;
		padding-right: 1em;
	}

	.t-nr {
		text-align: right;
		padding-right: 1em;
		
	}
	.fet {
		font-weight: bold;
	}
	
	.filialdiv {
		page-break-inside: avoid;
	}
	
</style>	
	</head>
	<body>
		<h1>Statistik</h1>

		<%
		Integer tempLagernr = null;	
		Double lopandeForsaljning = 0.0;
		Double lopandeResultat = 0.0;
		%>
			<%  while(rs.next()) { %>
			<% if (tempLagernr==null || !tempLagernr.equals(rs.getInt(4))) { %>
				<% if (tempLagernr!=null) { %>
					</table></div>
				<% } 
					tempLagernr = rs.getInt(4);
					lopandeForsaljning = 0.0;
					lopandeResultat = 0.0;
				%>
				<div id="d<%=rs.getInt(4) %>" class="filialdiv">
				<h2><%= rs.getString(7) %></h2>
				<table>
					<tr>
						<th>Period</th>
						<th>Försäljning</th>
						<th>Täckning</th>
						<th>Kostnad</th>
						<th>Resultat</th>
						<th>Löpande försäljning</th>
						<th>Löpande Resultat</th>
						
					</tr>

			<% }
					Double forsaljning = rs.getDouble(5);
					Double tb = rs.getDouble(6);
					Double kostnad = rs.getDouble(8);
					if (rs.getInt(2) <=2013) {	//Korrekt kostnadsfördelning startar först 2014
						if (rs.getInt(4) != 10 && rs.getInt(4) != 0) kostnad += forsaljning*0.1;		//Lägg till kostnader till filialer som saknar full bokföring av kostnader
						if (rs.getInt(4) == 6 || rs.getInt(4) == 11 || rs.getInt(4) == 80 ) kostnad += tb*0.45;	//Lägg till provisioner för ed, torsby och anders R
					}
					lopandeForsaljning += forsaljning;
					lopandeResultat += tb-kostnad;
			%>
					<tr>
						<td><%= rs.getString(1) %></td>
						<td><%= SXUtil.getFormatNumber(forsaljning/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(tb/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(kostnad/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber((tb-kostnad)/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(lopandeForsaljning/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(lopandeResultat/1000,0) %></td>
					</tr>
			<% }	%>

		</table></div>
	</body>
</html>


