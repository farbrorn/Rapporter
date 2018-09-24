<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>
<%@page import="se.saljex.rapporter.Counter"%>
<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.util.ArrayList"%>
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
		String VY_Kompakt = "kompakt";
		User user=null;
		Connection con=null;
		boolean prisetArDagspris;
		boolean klaseInnehallerDagsPris;
		
		Counter cntr = new Counter();
		
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}
		Integer rootGrupp = 0;
		String rootGruppStr = request.getParameter("root");
		if (rootGruppStr!=null) {
			try { rootGrupp = new Integer(rootGruppStr); } catch (Exception e) {}
		}

		String frontKontaktNamn = request.getParameter("frontkontaktnamn");
		String frontKontaktTel = request.getParameter("frontkontakttel");
		String frontKontaktEPost = request.getParameter("frontkontaktepost");
		String frontWWW = request.getParameter("frontwww");

		String kompaktvy = request.getParameter("kompaktvy");
		
                boolean hidePrice = "true".equals(request.getParameter("hideprice"));

			
		if (SXUtil.isEmpty(frontKontaktNamn)) {
			frontKontaktNamn = "Grums,Arvika,Borlänge,Sunne,Åmål";
			frontKontaktTel = "0555-61610,0570-13010,0243-257170,0565-13280,0532-608140";
			frontKontaktEPost = "info@saljex.se,arvika@saljex.se,borlange@saljex.se,sunne@saljex.se,amal@saljex.se";
		}
		
		if (frontWWW==null) frontWWW="www.saljex.se";
		
		String[] frontKontaktNamnArr =null;
		String[] frontKontaktTelArr =null;
		String[] frontKontaktEPostArr =null;
		
		try { frontKontaktNamnArr = frontKontaktNamn.split(","); } catch (Exception e) {}
		try { frontKontaktTelArr = frontKontaktTel.split(","); } catch (Exception e) {}
		try { frontKontaktEPostArr = frontKontaktEPost.split(","); } catch (Exception e) {}

		Integer picAreaHeight = 950;
		try {
			picAreaHeight = new Integer(request.getParameter("frontpicareaheight"));
		} catch (Exception e) {}
			
						
		String frontPicStr = request.getParameter("frontpics");
		Integer frontPicSize = 400;
		try {
			frontPicSize = new Integer(request.getParameter("frontpicsize"));
		} catch (Exception e) {}
		String[] ss;
		
		String excludeGruppStr = request.getParameter("exclude");
		ArrayList<Integer> excludeGroups = new ArrayList<Integer>();
		if (excludeGruppStr!=null) {
			ss = excludeGruppStr.split(",");
			for (String s : ss) {
				try { excludeGroups.add(new Integer(s)); } catch (Exception e) {}
			}
		}


		String includeGruppStr = request.getParameter("include");
		ArrayList<Integer> includeGroups = new ArrayList<Integer>();
		if (includeGruppStr!=null) {
			ss = includeGruppStr.split(",");
			for (String s : ss) {
				try { includeGroups.add(new Integer(s)); } catch (Exception e) {}
			}
		}

		String excludeKlasStr = request.getParameter("excludeklas");
		ArrayList<Integer> excludeKlas = new ArrayList<Integer>();
		if (excludeKlasStr!=null) {
			ss = excludeKlasStr.split(",");
			for (String s : ss) {
				try { excludeKlas.add(new Integer(s)); } catch (Exception e) {}
			}
		}
		
			

		String excludeArtStr = request.getParameter("excludeart");
		ArrayList<String> excludeArt = new ArrayList<String>();
		if (excludeArtStr!=null) {
			ss = excludeArtStr.split(",");
			for (String s : ss) {
				try { excludeArt.add(s); } catch (Exception e) {}
			}
		}
		
					
		Integer lagernr = null;
		String lagernrStr = request.getParameter("lagernr");
		if (lagernrStr!=null) {
			try { lagernr = new Integer(lagernrStr); } catch (Exception e) {}
		}
		
		String rubrik = request.getParameter("rubrik");
		String lev = request.getParameter("lev");
		
		ArrayList<String> frontPics = new ArrayList<String>();
		if (frontPicStr!=null) {
			ss = frontPicStr.split(",");
			for (String s : ss) {
				try { frontPics.add(s); } catch (Exception e) {}
			}
		}

		boolean printRsk=false;
		boolean printEnr=false;
		boolean printBestnr=false;
		boolean printRefnr=false;
		boolean printID=false;
		
		try {
			ss = request.getParameter("print").split(",");
			for (String s : ss) {
				if ("rsk".equals(s)) printRsk = true;
				if ("enr".equals(s)) printEnr = true;
				if ("refnr".equals(s)) printRefnr = true;
				if ("bestnr".equals(s)) printBestnr = true;
				if ("id".equals(s)) printID = true;
			}
		} catch (Exception e) {}




					
		String valuta = null;
		valuta = request.getParameter("valuta");
		if (valuta != null) {
			valuta = valuta.toUpperCase();
			if (!(valuta.equals("NOK") || valuta.equals("SEK")) ) valuta = null;
		}
		
		Double rabatt = 0.0;
		String rabattStr = request.getParameter("rabatt");
		if (rabattStr!=null) {
			try { rabatt = new Double(rabattStr); } catch (Exception e) {}
		}
		rabatt = rabatt/100;
		
		String avtalsprisKundnr = null;
		if (rabatt==0.0)	avtalsprisKundnr = request.getParameter("avtalspriskundnr");	//Ta inte avtalspris om vi har rabattsats
		if (SXUtil.isEmpty(avtalsprisKundnr)) avtalsprisKundnr=null;	//Sätt till null om det är en tom sträng
		
		String huvudRubrik= request.getParameter("huvudrubrik");
		if (SXUtil.isEmpty(huvudRubrik)) huvudRubrik="Katalog";
		
%>			

<%
		Katalog katalog = KatalogHandler.getKatalog(con, rootGrupp, false, excludeGroups, lagernr, lev, includeGroups, excludeKlas, excludeArt, avtalsprisKundnr);
		String level;
		String klaseNotering = "";
		
		if (rubrik==null) rubrik = katalog.getGrupper().get(0).getRubrik();
%>		

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Säljex <%= Util.toHtml(huvudRubrik) %> <%= Util.toHtml(rubrik) %></title>
<style type="text/css">

@media print {
.kat-main				{ font-size: 16px; }
}
@media screen {
.kat-main				{ font-size: 14px; }
}
.kat-main td { vertical-align: top; padding: 0px 4px 0px 2px;}
.kat-main th { font-size: 80%; background-color: #eeeeee; padding: 0px 4px 0px 2px; }
.kat-main img { margin-top: 0px;  }
a:link, a:active, a:visited, a:hover { color: black; text-decoration: none;  }

.kat-main table { 
						table-layout: fixed;
						border-collapse: collapse;
					}
					
@media print {
.kat-frontpics				{ margin-top: 120px; min-height: <%= picAreaHeight %>px; max-height: <%= picAreaHeight %>px; vertical-align: middle; }
.kat-frontpic				{ margin: 40px; }
.kat-frontfot				{ margin-top: 0px; font-size: 30px; border: solid black; border-radius: 10px; padding: 10px;}
.kat-frontfot-www				{ font-size: 120%; font-weight: bold; text-align: center; marign-top: 40px; }
.kat-frontfot-rubrik			{ font-weight: bold; }
.kat-frontfot-hrubrik			{ font-size: 120%; text-decoration: underline; font-weight: bolder; text-align: center;}
}
@media screen {
.kat-frontpics				{ display: none; }
.kat-frontfot				{ display: none; }
}

.kontaktinfo td {
							text-align: left;
}
.kat-huvud				{ font-size: 12px; 
								text-align: center;
							}



.kat-huvud table { 
						table-layout: fixed;
						border-collapse: collapse;
						width: 100%;
					}
					
.kat-huvud h1 { font-weight: bolder; font-size: 400%;  margin: 0px 0px 0px 0px;  }
.kat-huvud h2 { font-weight: bolder; font-size: 300%;  margin: 0px 0px 0px 0px;  }


.kat-grupp					{   }
.kat-grupp-l0				{ page-break-before: always; page-break-inside: avoid; padding-left: 120px;}
@media print {
.kat-grupp-l0				{ margin-bottom: 1em;}
}
@media screen {
.kat-grupp-l0				{ margin-bottom: 2em;}
}

.kat-grupp-l1				{ margin-bottom: 0.5em;  page-break-inside: avoid; padding-left: 120px;}
.kat-grupp-l2				{ margin-bottom: 0.5em; page-break-inside: avoid; padding-left: 120px; }
.kat-grupp-l0 h2		{ font-weight: bolder; font-size: 200%; margin: 0px 0px 0px 0px;}
.kat-grupp-l1 h2		{ font-weight: bolder; font-size: 140%; margin: 0px 0px 0px 0px;}
.kat-grupp-l2 h2		{ font-weight: bolder; font-size: 120%; margin: 0px 0px 0px 0px;}

.kat-klase				{ margin: 0px 0px 2em 0px;  page-break-inside: avoid; }
.kat-klase h2			{ font-weight: bold; font-size: 100%;  margin: 0px 0px 0px 0px; padding-left: 120px; width: 60em;}
.kat-klase p			{ font-size: 100%; margin: 0px 0px 0px 0px; padding-left: 120px; width: 60em;}
.kat-klase table 		{ padding-left: 120px; width: 60em;}


.right					{text-align: right; }
.left					{text-align: left; }

.s20, .n20				{ width: 17em; }
.s10, .n10				{ width: 8em; }
.s13						{ width: 8em; }
.s15, .n15				{ width: 13em; }
.s30						{ width: 22em; }
.s3						{ width: 2.5em; }
.s5, .n5						{ width: 4em; }
.s_forp						{ width: 6em; }
.s_artnr						{ width: 7em; }
.s_typ						{ width: 14em; }
.s_pris						{ width: 6em; }
.s_antal						{ width: 4em; }
.s_enh						{ width: 3em; }
.s_grupp						{ width: 4em; }

.fint					{ font-weight: lighter; font-size: 80%;}
.extrafint			{ font-weight: lighter; font-size: 60%;}

@media print {
.klase-cont			{ min-height: 80px; }
}
@media screen {
.klase-cont			{ min-height: 112px; }
}

.klase-pic			{ width: 110px; text-align: center; float: left;}
.klase-tab			{ padding-left: 120px; }

</style>
		
	</head>
	<body style="-webkit-print-color-adjust:exact;">
		

<div class="kat-huvud">
	<table>
		<tr>
			<td>
				<img src="http://www.saljex.se/p/s250/logo-saljex.png">
			</td>
			<td>
				<h1><%= huvudRubrik %></h1>
				<h2><% out.print(Util.toHtml(rubrik)); %> </h2>
			</td>
			<td>
				Datum: <%= Util.toHtml(katalog.getDatumString()) %>
				<%= valuta != null ? "<br>Valuta " + valuta : "" %>
				<%= rabatt != 0 ? "<br><b>Lista NT" + SXUtil.getFormatNumber( rabatt*100*2,0) + "</b>" : "" %>
				<%= avtalsprisKundnr != null ? "<br><b>Kundavtal: " + SXUtil.toHtml(avtalsprisKundnr) + "</b>" : "" %>
			</td>
		</tr>
		<tr>
			<td colspan="3"><div class="kat-frontpics">
				<% if (!frontPics.isEmpty()) { 
						for (String ss1: frontPics) {
					%>
							<img onerror="this.style.display='none';" class="kat-frontpic" src="http://www.saljex.se/p/s<%= frontPicSize %>/<%= ss1 %>.png">
				<%		}
					} %>
				</div>
				<div class="kat-frontfot">
					<table class="kontaktinfo">
						<tr><td class="kat-frontfot-hrubrik" colspan="3">Kontaktuppgifter</td></tr>
						<%
						String tNamn=null;
						String tTel=null;
						String tEpost=null;
						for (int cn = 0; cn < frontKontaktNamnArr.length; cn++) {
							tNamn = ""; tTel=""; tEpost="";
							try {tNamn = frontKontaktNamnArr[cn];} catch (Exception e) {}
							try {tTel = frontKontaktTelArr[cn];} catch (Exception e) {}
							try {tEpost = frontKontaktEPostArr[cn];} catch (Exception e) {}
							
							%> 
							<tr>
								<td class="kat-frontfot-rubrik"> <%= SXUtil.toHtml(tNamn) %></td>
								<td> <%= SXUtil.toHtml(tTel) %></td>
								<td> <%= SXUtil.toHtml(tEpost) %></td>
							</tr>
							<%
						}
						%>
						
						
<% /*						
						<tr>
							<td class="kat-frontfot-rubrik">Grums</td>
							<td class="kat-frontfot-rubrik">Arvika</td>
							<td class="kat-frontfot-rubrik">Borlänge</td>
							<td class="kat-frontfot-rubrik">Sunne</td>
							<td class="kat-frontfot-rubrik">Åmål</td>
						</tr>
						<tr>
							<td>0555-61610</td>
							<td>0570-13010</td>
							<td>0243-257170</td>
							<td>0565-13280</td>
							<td>0532-608140</td>
						</tr>
 * */ 
%>
					</table>
				<div class="kat-frontfot-www"><%= Util.toHtml(frontWWW) %></div>
				</div>
				
			</td>
		</tr>
	</table>
</div>

<div class="kat-main">
	<% for (KatalogGrupp grupp : katalog.getGrupper()) { 
		if (grupp.getTreeLevel() == 1) level = "0";
		else if (grupp.getTreeLevel() == 2) level = "1";
		else level = "2";
	%>
	
	<% if (grupp.getTreeLevel() != 0) {  //Skriv inte ut info för Root-gruppen .- det 'r på förstasidan om det inte är 0%>
	<div class="kat-grupp-l<%= level %>" id="pg-<%= cntr.next() %>">
			<h2><%= Util.toHtml(grupp.getRubrik()) + (printID ? (" G:" + grupp.getGrpId()) : "") %></h2>
			
			<% if (grupp.getText()!=null) { %>
				<div><%= Util.toHtml(grupp.getText()) %></div>
			<% } %>
				
			<% if (grupp.getInfoUrl()!=null) { %>
				<div><a href="<%= Util.toHtml(grupp.getInfoUrl()) %>"><%= Util.toHtml(grupp.getInfoUrl()) %></a></div>
			<% } %>
		</div>
	<% } %>
		
			<% for (KatalogKlase klase : grupp.getKlasar()) { %>
			<% klaseInnehallerDagsPris = false; %>
				<div class="kat-klase" id="pg-<%= cntr.next() %>">
			<div class="klase-cont">
					<div class="klase-pic"><% if(klase.getArtiklar().size() > 0) { %><img onerror="this.style.display='none';" src="http://www.saljex.se/p/s100/<%= klase.getArtiklar().get(0).getBildArtNr() %>.png"><% } %> </div>
					
					<h2><%= Util.toHtml(grupp.getRubrik()) %> - <%= Util.toHtml(klase.getRubrik()) + (printID ? (" K:" + klase.getId()) : "") %></h2>
					
					<% if (klase.getText()!=null) { %>
						<p><%= Util.toHtml(klase.getText()) %></p>
					<% } %>
					
					<% if (klase.getInfourl()!=null) { %>
						<p><a href="<%= klase.getInfourl() %>"><%= Util.toHtml(klase.getInfourl()) %></a></p>
					<% } %>
					<div class="klase-tab">
							<table>
								<thead>
									<tr><th class="s_artnr left">Artikel</th><th class="s_typ left">Typ</th>
                                                                            <% if(!hidePrice) { %>
										<th class="s_pris right">
											<%= !rabatt.equals(0.0) || avtalsprisKundnr != null ? "Netto " + (valuta != null ? valuta : "") : "Pris " + (valuta != null ? valuta : "") %>
										</th>
										<% if (!VY_Kompakt.equals(kompaktvy)) { %> 
											<th class="s_pris right">Mängdpris</th> 
											<th class="s_antal left">Antal</th>
										<% } %>
                                                                            <% } %>
										<th class="s_enh left">Enhet</th>
										<% if (!VY_Kompakt.equals(kompaktvy)) { %> 
											<th class="s_grupp">Grupp</th>
											<th class="s_forp left">Förpack.</th>
										<% } %>
										<th class="left"></th>
									</tr>
								</thead>
								<tbody>
								<% for (KatalogArtikel artikel : klase.getArtiklar()) { %>
									<tr>
										<td><%= Util.toHtml(artikel.getArtnr()) %></td>
										<td><%= Util.toHtml(artikel.getKatalogtext()) %></td>
                                                                            <% if(!hidePrice) { %>
										<td class="right"><% 
														prisetArDagspris = false;
														if (artikel.getPrisgiltighetstid() == null || artikel.getPrisgiltighetstid() < 180) {
																prisetArDagspris = true;
																klaseInnehallerDagsPris = true;
																out.print("*");
														} 
														if (artikel.getPris() > 0) out.print(Util.getFormatNumber(artikel.getPris()* ("NTO".equals(artikel.getRabkod()) ? 0.0 : 1-rabatt),2));														
												  %>
										</td>
										<% if (!VY_Kompakt.equals(kompaktvy)) { %> 
											<td class="right">
												<% if (artikel.getAntalStaf1()!=null && artikel.getPrisStaf1()!=null && !artikel.getAntalStaf1().equals(0.0) && !artikel.getPrisStaf1().equals(0.0)				  ) { 	%>
													<%= (prisetArDagspris ? "*" : "") + Util.getFormatNumber(artikel.getPrisStaf1()* ("NTO".equals(artikel.getRabkod()) ? 0.0 : 1-rabatt),2) %>
												<%	} 	%> 
											</td>
											<td>
												<% if (artikel.getAntalStaf1()!=null && artikel.getPrisStaf1()!=null && !artikel.getAntalStaf1().equals(0.0) && !artikel.getPrisStaf1().equals(0.0)				  ) { 	%>
													<%= Util.getFormatNumber(artikel.getAntalStaf1(),0) %>
												<%	} 	%> 											
											</td>
										<% } %>
                                                                            <% } %>
										
										<td><%= Util.toHtml(artikel.getEnhet()) %></td>
										
										<% if (!VY_Kompakt.equals(kompaktvy)) { %> 
											<td><%= Util.toHtml(artikel.getRabkod()) %><%= Util.isEmpty(artikel.getKod1()) ? "" : "<span class=\"extrafint\">-"+artikel.getKod1()+"</span>"  %></td>
											<% String fp="";
												double minSaljPack = artikel.getMinSaljpack();
												if(minSaljPack < 0.01) minSaljPack=1;
												long iPart;
												double fPart;
												iPart = (long) minSaljPack;
												fPart = minSaljPack - iPart;
												if (fPart != 0) fp = Util.getFormatNumber(minSaljPack,2); else fp = Util.getFormatNumber(minSaljPack,0);
												if (artikel.getForpackning() > 0 && artikel.getForpackning() > minSaljPack ) {
													if (fp.length()>0) fp = fp + "/";
													if (fPart != 0) fp = fp + Util.getFormatNumber(artikel.getForpackning(),2); else fp = fp + Util.getFormatNumber(artikel.getForpackning(),0);
												}
											%>
											<td><%= fp %></td>
										<% } %>
										
										<%
											String fp = "";
											if (artikel.getFraktvillkor() == 1) {
												if(!fp.isEmpty()) { fp = fp + ",";	}
												fp  = fp+"1";
												if (!klaseNotering.contains("1-")) {
													if(!klaseNotering.isEmpty()) { klaseNotering = klaseNotering + " ";	}
													klaseNotering = klaseNotering + "1-Fraktvillkor: Skrymme";
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
													klaseNotering = klaseNotering + "3-Produkten är utgående";
												}
											}
										%>
										<td class="fint"><%= Util.toHtml(fp) %></td>
									</tr>
									<% if((printBestnr && !Util.isEmpty(artikel.getBestnr())) || (printEnr && !Util.isEmpty(artikel.getEnr())) || (printRefnr && !Util.isEmpty(artikel.getRefnr())  ) || (printRsk && !Util.isEmpty(artikel.getRsk()) )) {%>
									<tr>
										<td colspan="9" class="extrafint">
											<%= printBestnr  && !SXUtil.isEmpty(artikel.getBestnr()) ? "Lev-nr: " + Util.toHtml(artikel.getBestnr()) + " " : "" %>
											<%= printRefnr && !SXUtil.isEmpty(artikel.getRefnr()) ? "Ref: " + Util.toHtml(artikel.getRefnr()) + " " : "" %>
											<% 
												String rskFormatted;
												int al = Util.toStr(artikel.getRsk()).length();
												if (al>6) {
													rskFormatted = artikel.getRsk().substring(0,3 ) + " " + artikel.getRsk().substring(3,5 ) + " " + artikel.getRsk().substring(5,7 );
												} else {
													rskFormatted = artikel.getRsk();
												}
											%>
											<%= printRsk && !SXUtil.isEmpty(artikel.getRsk()) ? "RSK: " + Util.toHtml(rskFormatted) + " " : "" %>
											<%= printEnr && !SXUtil.isEmpty(artikel.getEnr()) ? "E: " + Util.toHtml(artikel.getEnr()) + " " : "" %>
										</td>
									</tr>
									
									<% } %>
								<% } %>
								<% if(klaseInnehallerDagsPris) klaseNotering = klaseNotering + " *-Pris på förfrågan/Dagspris"; %>
								<% if (!klaseNotering.isEmpty()) { %> 
								<tr><td colspan="8" class="fint"><%= Util.toHtml(klaseNotering) %></td></tr>
								<% klaseNotering = ""; %>
								<% } %>
								</tbody>
							</table>
					</div>
				</div> </div>
			<% } %>
	<% } %>	
</div>
</body>
</html>
