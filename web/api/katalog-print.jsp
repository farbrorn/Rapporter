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
		String logoUrl="http://www.saljex.se/p/s250/logo-saljex.png";
		String VY_Kompakt = "kompakt";
		User user=null;
		Connection con=null;
		boolean prisetArDagspris;
		boolean klaseInnehallerDagsPris=false;
		
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

                
                //Filter för att sortera ut priser som är gamla och över ett visst belopp
		Integer prisdagarfilter = null;
		String prisdagarfilterStr = request.getParameter("prisdagarfilter");
		if (prisdagarfilterStr!=null) {
			try { prisdagarfilter = new Integer(prisdagarfilterStr); } catch (Exception e) {}
		}
		Integer prisdagarbeloppfilter = null;
		String prisdagarbeloppfilterStr = request.getParameter("prisdagarbeloppfilter");
		if (prisdagarbeloppfilterStr!=null) {
			try { prisdagarbeloppfilter = new Integer(prisdagarbeloppfilterStr); } catch (Exception e) {}
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
		
		int colBreakTreeLevel = 999999;
		String colBreakTreeLevelStr = request.getParameter("colbreaktreelevel");
		if (colBreakTreeLevelStr!=null) {
			try { colBreakTreeLevel = new Integer(colBreakTreeLevelStr); } catch (Exception e) {}
		}

		String footerHTML= request.getParameter("fothtml");

                String datumString = null;
                datumString = request.getParameter("datum");
                
		
%>			

<%
		Katalog katalog = KatalogHandler.getKatalog(con, rootGrupp, false, excludeGroups, lagernr, lev, includeGroups, excludeKlas, excludeArt, avtalsprisKundnr);
		String level;
		String klaseNotering = "";
		
		if (rubrik==null) rubrik = katalog.getGrupper().get(0).getRubrik();
		

		int rowHeight = 12;
		int sidHeight = 1020;
		int sidWidth = 650;
		int colWidth = 320;
		int sidHeaderHeight = 24;
		int sidFooterHeight = 40;
		int colHeight = sidHeight-sidHeaderHeight-sidFooterHeight-16;
		
%>		

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Säljex <%= Util.toHtml(huvudRubrik) %> <%= Util.toHtml(rubrik) %></title>
<style type="text/css">
			.sida {
				height: <%= sidHeight %>px;
				width: <%= sidWidth %>px;
				/*border: 1px black solid;*/
				overflow: hidden;
				position: relative;
				page-break-after: always;
			}
			
			.sida-no-page-break {
				page-break-after: auto;
			}
			
			.col {
				top: <%= ""+(sidHeaderHeight+8) %>px;
				width: <%= colWidth %>px;
				height: <%= colHeight %>px;
				display: inline-block;
				overflow: hidden;
				position: absolute;
				
				
			}
			.col1 {
				
			}
			.col2 {
				left: 320px;
			}
			.sida-header {
				position: absolute;
				width: 650px;
				height: <%= sidHeaderHeight %> px;
				border-bottom: 1px solid black;
			}
			.sida-footer {
				position: absolute;
				width: 650px;
				height: <%= sidFooterHeight %>px;
				border-top: 1px solid black;
				padding-top: 4px;
				bottom: 0px;
			}
			
			.sida-header-logo {
				
			}
                        .sida-footer-text {
                            text-align: center;
                        }
			.sida-header-logo img {
				max-width: 100px;
				max-heigt: 20px;
			}
					
/* @media print { */
.kat-frontpics				{ margin-top: 120px; min-height: <%= picAreaHeight %>px; max-height: <%= picAreaHeight %>px; vertical-align: middle; }
.kat-frontpic				{ margin: 10px; }

.kat-backfot				{ position: absolute; bottom: 0px; margin-top: 0px; font-size: 12px; border: solid black; border-radius: 10px; padding: 10px; width: 620px;}
.kat-backfot-www				{ font-size: 12px; font-weight: bold; text-align: center; marign-top: 40px; }
.kat-backfot-rubrik			{ font-weight: bold; }
.kat-backfot-hrubrik		{ font-size: 12px; text-decoration: underline; font-weight: bolder; text-align: center;}
/* } */
/*
@media screen {
.kat-frontpics				{ display: none; }
.kat-frontfot				{ display: none; }
}
*/

.kat-levvillkor				{ position: absolute; bottom: 0px; margin-top: 0px; font-size: 10px; border: 1px solid black; border-radius: 4px; padding: 10px; width: 620px;}
.kat-levvillkor	p			{ margin: 0px 0px 4px 0px; padding: 0px; width: 100%; }


.kontaktinfo { width: 100%; }
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
					
.kat-huvud h1 { font-weight: bolder; font-size: 300%;  margin: 0px 0px 0px 0px;  }
.kat-huvud h2 { font-weight: bolder; font-size: 200%;  margin: 0px 0px 0px 0px;  }


.kat-main				{ font-size: 12px; }
.kat-main img { margin-top: 0px;  }
a:link, a:active, a:visited, a:hover { color: black; text-decoration: none;  }
.kat-main h2 { font-weight: bold; font-size: 11px;  margin: 0px 0px 0px 0px;  }
.kat-main p			{ font-size: 11px; margin: 0px 0px 0px 0px; padding-left: 60px; }
					
.kat-grupp-l0				{ height: 15px; }
.kat-grupp-l1				{ height: 13px; }
.kat-grupp-l2				{ height: 12px; }
.kat-grupp-l0 h2		{ font-weight: bold; font-size: 14px; margin: 0px 0px 0px 0px;}
.kat-grupp-l1 h2		{ font-weight: bold; font-size: 12px; margin: 0px 0px 0px 0px;}
.kat-grupp-l2 h2		{ font-weight: bold; font-size: 11px; margin: 0px 0px 0px 0px;}



.right					{text-align: right; }
.left					{text-align: left; }



.t_row {
	display: block;
	width: 260px;
	overflow: hidden;
	font-size: 11px;
	padding: 0px 0px 0px 0px;
	position: relative;
	left: 60px;
}

.t_rsk {
    font-size: 6px;
}

.h12 {
	height: 12px;
}
.h8 {
	height: 8px;
}

.h22 {
	height: 22px;
}


.s						{
	display: table-cell;
	overflow: hidden;
}

.s_artnr						{ width: 50px; padding-right: 2px; }
.s_artnr_small                  { font-size: 80%; }
.s_typ						{ width: 120px; }
.s_pris						{ width: 40px;  }
.s_grupp						{ width: 14px;	font-size: 6px;  }
.s_enh						{ width: 34px; font-size: 8px;  }
.s_not						{ font-size: 6px; }

.s_rubrik					{ font-weight: bold; font-size:10px;}

.fint					{ font-weight: lighter; font-size: 10px; }
.extrafint			{ font-weight: lighter; font-size: 60%;}

.klase-pic			{ 
	width: 60px; text-align: center; float: left; max-height:60px;
	position: absolute;
	left: 0;
}


.sidnummer {
	font-size: 14px;
	
}

.klase-pic	img	{ max-width: 40px; max-height: 60px;}
.klase-tab			{ padding-left: 60px; }

</style>
		
	</head>
	<body style="-webkit-print-color-adjust:exact;">
		
<div class="sida">
<div class="kat-huvud">
	<table>
		<tr>
			<td>
				<img src="<%= logoUrl %>">
			</td>
			<td>
				<h1><%= huvudRubrik %></h1>
				<h2><% out.print(Util.toHtml(rubrik)); %> </h2>
			</td>
			<td>
                                <% if (datumString==null) datumString = "Datum: " + katalog.getDatumString(); %>
				<%= Util.toHtml(datumString) %>
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
				
			</td>
		</tr>
	</table>
</div>
</div>
<div class="sida"></div>


				
<%
	int huvudHojd = 24;
	int gruppHojd = 15;
	int radHojd = 12;
	int radHojd8 = 8;
        
	iw printHojd = new iw();
	iw aktivCol = new iw(1);
	iw sidraknare = new iw(0);
	int maxPrintHojd = colHeight;
	double minSaljpack = 0.0;
	
%>
				
<div class="kat-main">
	<div class="sida">
		<div class="sida-header"></div>
		<div class="col col1">
		<% int printedKlasar = 0; %>
		<% for (KatalogGrupp grupp : katalog.getGrupper()) { 
			if (grupp.getTreeLevel() == 1) level = "0";
			else if (grupp.getTreeLevel() == 2) level = "1";
			else level = "2";

					
			if (printedKlasar > 0 && grupp.getTreeLevel() >= colBreakTreeLevel) {
				out.print(forceColBreak(printHojd, maxPrintHojd, aktivCol, gruppHojd, sidraknare, logoUrl, footerHTML));
			}

					
			if (grupp.getTreeLevel() != 0) {  //Skriv inte ut info för Root-gruppen .- det 'r på förstasidan om det inte är 0%>
				<% out.print(checkBreak(printHojd, maxPrintHojd, aktivCol, gruppHojd, sidraknare, logoUrl, printHojd.get() > colHeight-120, footerHTML));	%>
				<div class="t_row kat-grupp-l<%= level %>" id="pg-<%= cntr.next() %>">
					<h2><%= Util.toHtml(Util.toStr(grupp.getRubrik())) + (printID ? (" G:" + grupp.getGrpId()) : "") %></h2>
				</div>
		<% } %>
		<% printedKlasar = 0; %>
		<% for (KatalogKlase klase : grupp.getKlasar()) { 
			
				klaseInnehallerDagsPris = false; %>
				<% printedKlasar++; %>		
				<% int hojd = new Double(huvudHojd + rowHeight * Math.ceil(Util.toStr(klase.getText()).length()/50)*1.1).intValue();
					
						out.print(checkBreak(printHojd, maxPrintHojd, aktivCol, hojd, sidraknare, logoUrl, footerHTML));	%>
					<div class="klase-pic"><% if(klase.getArtiklar().size() > 0) { %><img onerror="this.style.display='none';" src="http://www.saljex.se/p/s100/<%= klase.getArtiklar().get(0).getBildArtNr() %>.png"><% } %> </div>
					<h2 class="t_row"><%= Util.toHtml(klase.getRubrik()) + (printID ? (" K:" + klase.getId()) : "") %></h2>

					<% if (klase.getText()!=null) { %>
						<p><%= Util.toHtml(klase.getText()) %></p>
					<% } %>

					<div class="t_row h12">
						<div class="s s_artnr s_rubrik left">Artikel</div>
						<div class="s s_typ s_rubrik left">Typ</div>
						<div class="s s_pris s_rubrik right">
							<% if (hidePrice) { %>
                                                            <%= !rabatt.equals(0.0) || avtalsprisKundnr != null ? "Netto " + (valuta != null ? valuta : "") : "Pris " + (valuta != null ? valuta : "") %>
                                                        <% } %>
						</div>
						<div class="s s_enh s_rubrik left"></div>
						<div class="s s_grupp s_rubrik left"></div>
						<div class="s s_not s_rubrik left"></div>
					</div>
						
					<% for (KatalogArtikel artikel : klase.getArtiklar()) { %>
						<% out.print(checkBreak(printHojd, maxPrintHojd, aktivCol, radHojd, sidraknare, logoUrl, footerHTML));	%>
						<div class="t_row h12">
                                                    <div class="s s_artnr <%= Util.toStr(artikel.getArtnr()).length() >= 8 ? "s_artnr_small" : ""  %> left"><%= Util.toHtml(artikel.getArtnr()) %></div>
							<div class="s s_typ left"><%= Util.toHtml(artikel.getKatalogtext()) %></div>
							<div class="s s_pris right">
								<% prisetArDagspris = false;
									if (artikel.getPrisgiltighetstid() == null || artikel.getPrisgiltighetstid() < 180) {
											prisetArDagspris = true;
											klaseInnehallerDagsPris = true;
											out.print("*");
									} 
									minSaljpack = artikel.getMinSaljpack();
									if (minSaljpack == 0.0) minSaljpack = 1;
									double pris = artikel.getPris();
									if (minSaljpack != 1.0) {
										pris = artikel.getPris() * minSaljpack;
										if (pris >= 100) pris = java.lang.Math.ceil(pris);
									}
                                                                        if (hidePrice || ( artikel.isPrisOlder(prisdagarfilter) && (prisdagarbeloppfilter==null || prisdagarbeloppfilter < pris))) {
                                                                            
                                                                        } else {
                                                                            if (pris > 0.0 ) out.print(Util.getFormatPris(pris * ("NTO".equals(artikel.getRabkod()) ? 1.0 : 1-rabatt)));														
                                                                        }
								%>
							</div>
							<%
												long iPart;
												double fPart;
												iPart = (long) minSaljpack;
												fPart = minSaljpack - iPart;
							
							%>
							<div class="s s_enh left">/<%= minSaljpack != 1.0 ? Util.getFormatNumber(minSaljpack,fPart!=0.0 ? 2 : 0) : "" %> <%= Util.toHtml(artikel.getEnhet()) %></div>
							<div class="s s_grupp left"><%= Util.toHtml(artikel.getRabkod()) %></div>

							<%
								String fp = "";
								if (artikel.getFraktvillkor() == 1) {
									if(!fp.isEmpty()) { fp = fp + ",";	}
									fp  = fp+"1";
									if (!klaseNotering.contains("1-")) {
										if(!klaseNotering.isEmpty()) { klaseNotering = klaseNotering + " ";	}
										klaseNotering = klaseNotering + "1-Fraktvillkor: Skrymmande";
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
							<div class="s s_not"><%= Util.toHtml(fp) %></div>
						</div>

                                                
                                                <% if(printRsk && !SXUtil.isEmpty(artikel.getRsk())) { %>
                                                    <% out.print(checkBreak(printHojd, maxPrintHojd, aktivCol, radHojd8, sidraknare, logoUrl, footerHTML));	%>
                                                    <div class="t_row t_rsk h8">
                                                        <%= SXUtil.toHtml(artikel.getRsk()) %>
                                                    </div>
                                                <% } %>
                                                
                                                
                                                
                                                
					
					<% } //Artiklar%>
					<%	if (printHojd.get() < maxPrintHojd-radHojd ) { %>
						<%= checkBreak(printHojd, maxPrintHojd, aktivCol, huvudHojd, sidraknare,logoUrl, footerHTML)	%>
						<div class="t_row h12"></div>
					<% } %>
				<% } //Klasar %>
				
				<% if(klaseInnehallerDagsPris) klaseNotering = klaseNotering + " *-Pris på förfrågan/Dagspris"; %>
				<% if (!klaseNotering.isEmpty()) { %> 
					<%= checkBreak(printHojd, maxPrintHojd, aktivCol, huvudHojd, sidraknare, logoUrl, footerHTML) %>
					<div class="t_row h12 fint"><%= Util.toHtml(klaseNotering) %></div>
					<% klaseNotering = ""; %>
				<% } %>

				
			<% } //Grupper %>
		</div>
		<% sidraknare.add(1); %>
		<%= getHTMLSidaFooter(sidraknare, logoUrl, footerHTML) %>
	</div>	
</div>
	<%
		int sidorKvar = 4 - (sidraknare.get() % 4);
		if (sidorKvar >= 4) sidorKvar = 0;
	%>
	<% for (int cn=0; cn < sidorKvar; cn++) { %>
		<div class="sida">
			<%= getHTMLSidaHeader(sidraknare, logoUrl) %>
			<% sidraknare.add(1); %>
			<%= getHTMLSidaFooter(sidraknare, logoUrl,footerHTML) %>
		</div>
	<%	} %>

	<div class="sida">
		<div class="kat-levvillkor">
			<p><b>Allmänna leveransvillkor</b></p>
			<p>Samtliga priser anges exkl. moms och är dagsprisbaserade. Offerter gäller 30 dagar med reservation för ändringar utom vår kontroll.</p>
			<p>Frakt- och emballagekostnad tillkommer.</p>
			<p>Synliga skador eller avvikelser skall anmälas vid godsets mottagande och antecknas i transportdokumentet. Dolda skador skall anmälas senast sju dagar efter mottagandet av sändningen.</p>
			<p>För order under 2000:- tillkommer expeditionsavgift.</p>
			<p>Fakturor skickas per e-post. Papperskopia kan begäras mot avgift.</p>
			<p>Betalning skall vara oss tillhanda inom angiven kredittid. Påminnelseavgift utgår med fn 45:- per st. Vid ev inkasso tillkommer lagstadgade avgifter.
				Efter fakturans förfallodag debiteras ränta (fn. 18%) samt räntefaktureringsavgift.
			</p>
			<p>Returer krediteras med ett avdrag på 30% samt ev. kringkostnader. Returer skall ske i originalförpackning och varan skall vara i originalskick. Köparen bekostar återtransporten. 
			Ej lagerförda, specialbeställda, tillverkade eller kapade varor kan ej returneras.</p>
			<p>Garanti gäller enligt våra leverantörers villkor för respektive land. Säljex åtar sig inget garantiansvar utöver detta.</p>
			<p>Vi hjälper gärna till med tips och förslag på produkter. Slutgiltigt materielval och  dimensionering ansvarar dock alltid kunden för, och Säljex kan inte hållas 
			ansvarig för ev. felaktigheter i projektering eller rådgivning.</p>
		</div>
	</div>
	<div class="sida sida-no-page-break">
			<div class="kat-backfot">
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

				</table>
			<div class="kat-backfot-www"><%= Util.toHtml(frontWWW) %></div>
			</div>
	</div>


</body>
</html>

<%!
	public String forceColBreak(iw printHojd, int maxPrintHojd, iw aktivCol, int hojd, iw sidraknare, String logoUrl, String footerHTML) {
		return checkBreak(printHojd, maxPrintHojd, aktivCol, hojd, sidraknare, logoUrl, true, footerHTML);
	}
	public String checkBreak(iw printHojd, int maxPrintHojd, iw aktivCol, int hojd, iw sidraknare, String logoUrl, String footerHTML) {
		return checkBreak(printHojd, maxPrintHojd, aktivCol, hojd, sidraknare, logoUrl, false,footerHTML);
	}
	
	public String checkBreak(iw printHojd, int maxPrintHojd, iw aktivCol, int hojd, iw sidraknare, String logoUrl, boolean forceColBreak, String footerHTML) {
		
		String ret="";
					
					if (printHojd.add(hojd) >= maxPrintHojd || forceColBreak) {
						ret = ret+"</div>";
						if (aktivCol.add(1) > 2) { //Sidbrytnuing
							if (sidraknare!=null) sidraknare.add(1);
							aktivCol.set(1);
							ret=ret + getHTMLSidaFooter(sidraknare, logoUrl, footerHTML);
							ret = ret+"</div>";
							ret = ret + "<div class=\"sida\">";
							ret = ret+ getHTMLSidaHeader(sidraknare, logoUrl);
							//ret = ret+"</div><div class=\"sida\">";
						}
						ret = ret+"<div class=\"col col" + aktivCol.get() + "\">";
						printHojd.set(hojd);
					}
			return ret;
	}
	
	
	
	public String getHTMLSidaHeader(iw sidraknare, String logoUrl) {
		String ret;
		ret = "<div class=\"sida-header\">";
			ret = ret+"<div class=\"sida-header-logo "  + (sidraknare.get()%2 == 0 ? "right" : "left") + "\"><img src=\"" + logoUrl + "\"></div>"  ;
		ret = ret+ "</div>";
		return ret;
	}
	
	public String getHTMLSidaFooter(iw sidraknare, String logoUrl, String footerHTML) {
		String ret;
		ret = "<div class=\"sida-footer\">";
                
                if (!SXUtil.isEmpty(footerHTML)) {
                    ret = ret +  "<div class=\"sida-footer-text\">" + SXUtil.toHtml(footerHTML) + "</div>";
                    
                    
                }
                
        	ret = ret+"<div class=\"sidnummer " + (sidraknare.get()%2 == 0 ? "left" : "right") + "\">" + sidraknare.get() + "</div>";
		ret = ret+"</div>";
		
		return ret;
	}

	class iw {
		private int v=0;
		public iw() {
			
		}
		public iw(int v) {
			this.v=v;
					}
		
		public int get() { return v; }
		public void set(int v) {this.v=v;}
		public int add(int add) { this.v+=add; return get(); }
	
		
	}
%>