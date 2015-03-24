<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>
<%@page import="se.saljex.rapporter.KatalogArtikel"%>
<%@page import="se.saljex.rapporter.KatalogKlase"%>
<%@page import="se.saljex.rapporter.Util"%>
<%@page import="se.saljex.rapporter.KatalogGrupp"%>
<%@page import="se.saljex.rapporter.KatalogHandler"%>
<%@page import="se.saljex.rapporter.Katalog"%>
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
		Integer rootGrupp = 0;
		String rootGruppStr = request.getParameter("root");
		if (rootGruppStr!=null) {
			try { rootGrupp = new Integer(rootGruppStr); } catch (Exception e) {}
		}
		
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Katalog</title>
<style type="text/css">
.kat-main				{ font-size: 12px; }
.kat-main td { vertical-align: top; padding: 0px 4px 0px 2px;}
.kat-main th { font-size: 80%; background-color: #eeeeee; text-align: left; padding: 0px 4px 0px 2px;}
.kat-main img { margin-top: 1em;  }
.kat-main table { 
						table-layout: fixed;
						border-collapse: collapse;
					}
					
.kat-huvud				{ font-size: 12px; 
								text-align: center;
							}
.kat-main-table td {   }
.kat-main-table tr { page-break-inside: avoid; }



.kat-huvud table { 
						table-layout: fixed;
						border-collapse: collapse;
					}
.kat-huvud h1 { font-weight: bolder; font-size: 400%;  margin: 0px 0px 0px 0px;  }
.kat-huvud h2 { font-weight: bolder; font-size: 300%;  margin: 0px 0px 0px 0px;  }


.kat-grupp					{   }
.kat-grupp-l0				{ margin-bottom: 2em;  page-break-before: always; page-break-inside: avoid;}
.kat-grupp-l1				{ margin-bottom: 0.5em;  page-break-inside: avoid; }
.kat-grupp-l2				{ margin-bottom: 0.5em; page-break-inside: avoid; }
.kat-grupp-l0 h2		{ font-weight: bolder; font-size: 200%; margin: 0px 0px 0px 0px;}
.kat-grupp-l1 h2		{ font-weight: bolder; font-size: 140%; margin: 0px 0px 0px 0px;}
.kat-grupp-l2 h2		{ font-weight: bolder; font-size: 120%; margin: 0px 0px 0px 0px;}

.kat-klase				{ margin: 0px 0px 4em 0px;  page-break-inside: avoid;}
.kat-klase h2			{ font-weight: bold; font-size: 100%;  margin: 0px 0px 0px 0px; }
.kat-klase td			{ height: auto; }

.right					{text-align: right; }

.s20, .n20				{ width: 17em; }
.s10, .n10				{ width: 8em; }
.s13						{ width: 10em; }
.s15, .n15				{ width: 13em; }
.s30						{ width: 25em; }
.s3						{ width: 2em; }
.s5						{ width: 4em; }

.t-pic						{ width: 110px; }
.t-pich						{ height: 160px;}
.t-cont						{ width: 70em; }

.fint					{ font-weight: lighter; font-size: 80%;}



</style>
		
	</head>
	<body>
		
<%
		Katalog katalog = KatalogHandler.getKatalog(con, rootGrupp);
		String level;
		String klaseNotering = "";
%>		

<div class="kat-huvud">
	<table>
		<tr>
			<td>
				<img src="http://www.saljex.se/p/s100/logo-saljex.png">
			</td>
			<td>
				<h1><%= Util.toHtml(katalog.getRubrik()) %> </h1>
				<h2><%= Util.toHtml(katalog.getUnderRubrik()) %> </h2>
			</td>
			<td>
				Datum: <%= Util.toHtml(katalog.getDatumString()) %>
			</td>
		</tr>
	</table>
</div>
<div class="kat-main">
	<table class="kat-main-table">
	<% for (KatalogGrupp grupp : katalog.getGrupper()) { 
		if (grupp.getTreeLevel() == 0) level = "0";
		else if (grupp.getTreeLevel() == 1) level = "1";
		else level = "2";
	%>
	<tr><td class="t-pic"></td><td class="t-cont">
		<div class="kat-grupp-l<%= level %>">
			<h2><%= Util.toHtml(grupp.getRubrik()) %></h2>
			
			<% if (grupp.getText()!=null) { %>
				<div><%= Util.toHtml(grupp.getText()) %></div>
			<% } %>
				
			<% if (grupp.getInfoUrl()!=null) { %>
				<div><a href="<%= Util.toHtml(grupp.getInfoUrl()) %>"><%= Util.toHtml(grupp.getInfoUrl()) %></a></div>
			<% } %>
		</div>
	</td></tr>
		
			<% for (KatalogKlase klase : grupp.getKlasar()) { %>
					<tr><td class="t-pic t-pich"> <% if(klase.getArtiklar().size() > 0) { %><img src="http://www.saljex.se/p/s100/<%= klase.getArtiklar().get(0).getBildArtNr() %>.png"><% } %>
					</td><td>
				<div class="kat-klase">
					<h2><%= Util.toHtml(grupp.getRubrik()) %> - <%= Util.toHtml(klase.getRubrik()) %></h2>
					
					<% if (klase.getText()!=null) { %>
						<div><%= Util.toHtml(klase.getText()) %></div>
					<% } %>
					
					<% if (klase.getInfourl()!=null) { %>
						<div><a href="<%= klase.getInfourl() %>"><%= Util.toHtml(klase.getInfourl()) %></a></div>				
					<% } %>
					
							<table>
								<thead>
									<tr><th class="s13">Artikel</th><th class="s30">Typ</th><th class="n10 right">Pris</th><th class="n10">Mängdpris</th><th class="n5">Antal</th><th class="s3">Enhet</th><th class="s3">Grupp</th><th class="s5">Förpack.</th><th class="s5"></th></tr>
								</thead>
								<tbody>
								<% for (KatalogArtikel artikel : klase.getArtiklar()) { %>
									<tr>
										<td><%= Util.toHtml(artikel.getArtnr()) %></td>
										<td><%= Util.toHtml(artikel.getKatalogtext()) %></td>
										<td class="right"><%= Util.getFormatNumber(artikel.getPris(),2) %></td>
										<td class="right">
											<% if (artikel.getAntalStaf1()!=null && artikel.getPrisStaf1()!=null && !artikel.getAntalStaf1().equals(0.0) && !artikel.getPrisStaf1().equals(0.0)				  ) { 	%>
												<%= Util.getFormatNumber(artikel.getPrisStaf1(),2) %>
											<%	} 	%> 
										</td>
										<td>
											<% if (artikel.getAntalStaf1()!=null && artikel.getPrisStaf1()!=null && !artikel.getAntalStaf1().equals(0.0) && !artikel.getPrisStaf1().equals(0.0)				  ) { 	%>
												<%= Util.getFormatNumber(artikel.getAntalStaf1(),0) %>
											<%	} 	%> 											
										</td>
										<td><%= Util.toHtml(artikel.getEnhet()) %></td>
										<td><%= Util.toHtml(artikel.getRabkod()) %></td>
										<% String fp="";
											if(artikel.getMinSaljpack() > 0) fp = Util.getFormatNumber(artikel.getMinSaljpack(),0);
											if (artikel.getForpackning() > 0 && artikel.getForpackning() != artikel.getMinSaljpack() ) {
												if (fp.length()>0) fp = fp + "/";
												fp = fp + Util.getFormatNumber(artikel.getForpackning(),0);
											}
										%>
										<td><%= fp %></td>
										<%
											fp = "";
											if (artikel.getFraktvillkor() == 1) {
												if(!fp.isEmpty()) { fp = fp + ",";	}
												fp  = fp+"1";
												if (!klaseNotering.contains("1-")) {
													if(!klaseNotering.isEmpty()) { klaseNotering = klaseNotering + " ";	}
													klaseNotering = klaseNotering + "1-Fraktvillkor: Fritt med turbil";
												}
											}
											if (artikel.getFraktvillkor() == 2) {
												if(!fp.isEmpty()) { fp = fp + ",";	}
												fp  = fp+"2";
												if (!klaseNotering.contains("2-")) {
													if(!klaseNotering.isEmpty()) { klaseNotering = klaseNotering + " ";	}
													klaseNotering = klaseNotering + "2-Fraktvillkor: Fritt fabrik";
												}
											}
											if (artikel.getUtgattdatum() != null) {
												if(!fp.isEmpty()) { fp = fp + ",";	}
												fp  = fp+"3";
												if (!klaseNotering.contains("3-")) {
													if(!klaseNotering.isEmpty()) { klaseNotering = klaseNotering + " ";	}
													klaseNotering = klaseNotering + "3-Produkten har utgått";
												}
											}
										%>
										<td class="fint"><%= Util.toHtml(fp) %></td>
									</tr>
								<% } %>
								<% if (!klaseNotering.isEmpty()) { %> 
								<tr><td colspan="8" class="fint"><%= Util.toHtml(klaseNotering) %></td></tr>
								<% klaseNotering = ""; %>
								<% } %>
								</tbody>
							</table>
				</td></tr>
				</div>
			<% } %>
	<% } %>	
</div>
</body>
</html>
