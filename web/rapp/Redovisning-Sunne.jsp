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

	Double roligKostnadProcent = 0.015;
	Double fastKostnad = 0.0;
	Double lagerProcent = 0.07;
	Double tbProcent = 0.15;
	Integer lagernr = 4;
	

		User user=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");

		try { lagernr = new Integer(request.getParameter("lagernr")); } catch (Exception e) { } ;
		try { roligKostnadProcent = new Double(request.getParameter("rorligpromille")); roligKostnadProcent = roligKostnadProcent/1000; } catch (Exception e) { } ;
		try { tbProcent = new Double(request.getParameter("tbpromille")); tbProcent = tbProcent/1000; } catch (Exception e) { } ;
		try { lagerProcent = new Double(request.getParameter("lagerpromille")); lagerProcent = lagerProcent/1000; } catch (Exception e) { } ;
		try { fastKostnad = new Double(request.getParameter("fastkostnad")); } catch (Exception e) { } ;

		Integer frAr = null;
		try { frAr = new Integer(request.getParameter("frar")); } catch (Exception e) { } ;
		Calendar cal = Calendar.getInstance();
		if (frAr==null) frAr = cal.get(Calendar.YEAR);
		
		if (!user.isBehorighet("L" + lagernr + "-Ekonomi")) throw new SxInfoException("Ingen behörighet");
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
	ResultSet rsLagervarde=null;
	PreparedStatement ps=null;
	PreparedStatement psLagervarde=null;
	String q = "select  lagerid.lagernr, year(aa.faktdatum), month(aa.faktdatum), "
+" round(sum("
+" case when f2.netto<>0 then case when aa.bonus=0 then (f2.summa-f2.netto*f2.lev) else ((f2.summa-f2.netto*f2.lev)-(f2.summa*f.bonusproc2::numeric/100)) end else case when f2.summa<0 then f2.summa else 0 end end"
+" * aa.fordelninglagernr "
+" )) as tb, "
+" round(sum(f2.summa* aa.fordelninglagernr * case when aa.bonus=0 then 1 else 1-(f.bonusproc2::numeric/100) end) )  as summa "
+" , lagerid.namn "
+" from "
+" ( "
+" select f1.faktnr as faktnr, f1.datum as faktdatum, f1.lagernr as faktlagernr, s.namn as saljare, coalesce(s.lagernr ,f1.lagernr) as saljarelagernr, f1.bonus as bonus , "
+" case when f1.lagernr = coalesce(s.lagernr ,f1.lagernr) then 1 else 0.5 end as fordelninglagernr "
+" from faktura1 f1 left outer join saljare s on s.namn = trim(substring(f1.saljare,0,30)) "
+" ) aa "
+" join faktura2 f2 on f2.faktnr=aa.faktnr  "
+" left outer join artikel a on a.nummer=f2.artnr "
+" left outer join lev l on l.nummer = a.lev "
+" , fuppg f, lagerid  "
+" where  lagerid.lagernr=? and year(aa.faktdatum)>=? "
+" and f2.artnr not in ('*RÃNTA*','*BONUS*') and f2.lev<> 0 "
+" and (aa.faktlagernr=lagerid.lagernr or aa.saljarelagernr=lagerid.lagernr) "
+" group by year(aa.faktdatum), month(aa.faktdatum), lagerid.lagernr, lagerid.namn"
+" order by year(aa.faktdatum), month(aa.faktdatum) "
+" ";

			  
/*
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

+" where coalesce(st.ar, BOK.AR) >= " +  frAr + " and st.lagernr=" + lagernr

+" order by st.LAGERNR, st.ar, st.man ";
	
*/
	
String qLagervarde =
"select sum(a.inpris*(1-rab/100)*(l.ilager-ll.forandring)) "
+" from lager l   join artikel a on a.nummer=l.artnr "
+" left outer join ( "
+" select l.lagernr as lagernr, l.artnr as artnr, sum(coalesce(lh.forandring,0)) as forandring "
+" from lager l left outer join lagerhand lh on lh.artnr=l.artnr and lh.lagernr=l.lagernr and lh.datum > ? "
+" group by l.lagernr, l.artnr "
+" ) ll on ll.lagernr=l.lagernr and ll.artnr=l.artnr "
+" where l.lagernr=?";		  
	
	
	psLagervarde = con.prepareStatement(qLagervarde);


	ps = con.prepareStatement(q);
	ps.setInt(1, lagernr);
	ps.setInt(2, frAr);
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

	td, th { 
		padding: 2px 4px 2px 4px; 
		text-align: right;
		width: 4em;
	}
	th { 
		border-bottom: 1px solid black; 
		font-size: 60%;
	}
	
	.odd {}

	
	.even {
		background-color: #eeeeee;
	}
	
	
</style>	
	</head>
	<body>
		<h1>Statistik</h1>

		<%
		Integer tempLagernr = null;	
		Double lopandeForsaljning = 0.0;
		Double lopandeProvision = 0.0;
		Double provision = 0.0;
		Double lagerVarde = 0.0;
		boolean even = false;
		%>
			<%  while(rs.next()) { %>
			<% if (tempLagernr==null || !tempLagernr.equals(rs.getInt(1))) { %>
				<% if (tempLagernr!=null) { %>
					</table></div>
				<% } 
					tempLagernr = rs.getInt(1);
					lopandeForsaljning = 0.0;
					lopandeProvision = 0.0;
				%>
				<div id="d<%=rs.getInt(1) %>" class="filialdiv">
				<h2><%= rs.getString(6) %></h2>
				<table class="t-grp">
					<tr>
						<th style="WIDTH: 3EM; text-align: left">Period</th>
						<th style="">Försäljning</th>
						<th style="">Täckning</th>
						<th style="">Rörlig kostnad (<%= SXUtil.getFormatNumber(roligKostnadProcent*100,2) %>%)</th>
						<th style="">Rörlig kostnad på TB (<%= SXUtil.getFormatNumber(tbProcent*100,2) %>%)</th>
						<th style="">Fast kostnad</th>
						<th style="">Lagerkostnad (<%= SXUtil.getFormatNumber(lagerProcent*100,2) %>%) </th>
						<th style="">Provision</th>
						<th style="">Lagervärde ca</th>
						<th style="">Löpande Försäljning</th>
						<th style="">Löpande Provision</th>
						
					</tr>

			<% }
					cal.set(rs.getInt(2), rs.getInt(3), 1);
					java.sql.Date da = new java.sql.Date(cal.getTime().getTime());
					psLagervarde.setDate(1, da );
					psLagervarde.setInt(2, lagernr);
					
					rsLagervarde = psLagervarde.executeQuery();
					if (rsLagervarde.next()) {
						lagerVarde = rsLagervarde.getDouble(1);
					} else {
						lagerVarde=0.0;
					}
			
					Double forsaljning = rs.getDouble(5);
					Double tb = rs.getDouble(4);
					lopandeForsaljning += forsaljning;
					provision = tb - (forsaljning*roligKostnadProcent + fastKostnad + lagerProcent*lagerVarde/12 + tb*tbProcent);
					lopandeProvision += provision;
					
					even = !even;
			%>
			
					<tr class="<%= even ? "even" : "odd"  %>">
						<td style="text-align: left;"><%= "" + rs.getInt(2) + "-" + rs.getInt(3) %></td>
						<td><%= SXUtil.getFormatNumber(forsaljning/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(tb/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(forsaljning*roligKostnadProcent/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(tb*tbProcent/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(fastKostnad/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber((lagerProcent*lagerVarde/12)/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(provision/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(lagerVarde/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(lopandeForsaljning/1000,0) %></td>
						<td><%= SXUtil.getFormatNumber(lopandeProvision/1000,0) %></td>
					</tr>
			<% }	%>

		</table>
			
			<div style ="font-size: 60%; font-weight: lighter; font: italic">
				Lagervärde beräknas efter dagens inköpspriser, och kan därför variera vid olika utskriftsdatum.
			</div>
			
				</div>
	</body>
</html>


