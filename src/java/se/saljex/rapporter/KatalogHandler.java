/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.rapporter;

import java.sql.*;
import java.util.ArrayList;
import se.saljex.sxlibrary.SXUtil;

/**
 *
 * @author Ulf
 */
public class KatalogHandler {

	
	public static Katalog getKatalog(Connection con, int rootId) throws SQLException {
		return getKatalog(con, rootId, false, null,null, null);
	}
	
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups) throws SQLException {
		return getKatalog(con, rootId, onlyGroups, null,null, null);
	}
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups, ArrayList<Integer> excludeGroups) throws SQLException {
		return getKatalog(con, rootId, onlyGroups, excludeGroups,null, null);
	}
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups, ArrayList<Integer> excludeGroups, Integer lagernr) throws SQLException {
		return getKatalog(con, rootId, onlyGroups, excludeGroups,lagernr, null);
	}
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups, ArrayList<Integer> excludeGroups, Integer lagernr, String lev) throws SQLException {
		return getKatalog(con, rootId, onlyGroups, excludeGroups,lagernr, lev, null, null, null);
	}
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups, ArrayList<Integer> excludeGroups, Integer lagernr, String lev, ArrayList<Integer> includeGroups, ArrayList<Integer> excludeKlas, ArrayList<String> excludeArt ) throws SQLException {
		return getKatalog(con, rootId, onlyGroups, excludeGroups,lagernr, lev, includeGroups, excludeKlas, excludeArt, null);
	}
	
	public static Katalog getKatalog(Connection con, int rootId, boolean onlyGroups, ArrayList<Integer> excludeGroups, Integer lagernr, String lev, ArrayList<Integer> includeGroups, ArrayList<Integer> excludeKlas, ArrayList<String> excludeArt , String avtalsPrisKundnr ) throws SQLException {
		Katalog kat = new Katalog();
		String sqlExcludeGroups=null;
		if (excludeGroups!=null) {
			for (Integer i : excludeGroups) {
				if (i!=null) {
					if (sqlExcludeGroups==null) sqlExcludeGroups="";
					if (!sqlExcludeGroups.isEmpty()) sqlExcludeGroups = sqlExcludeGroups + ",";
					sqlExcludeGroups = sqlExcludeGroups+i.toString();
				}
			}
		}

		
		String sqlIncludeGroups=null;
		if (includeGroups!=null) {
			for (Integer i : includeGroups) {
				if (i!=null) {
					if (sqlIncludeGroups==null) sqlIncludeGroups="";
					if (!sqlIncludeGroups.isEmpty()) sqlIncludeGroups = sqlIncludeGroups + ",";
					sqlIncludeGroups = sqlIncludeGroups+i.toString();
				}
			}
		}

		String sqlExcludeKlas=null;
		if (excludeKlas!=null) {
			for (Integer i : excludeKlas) {
				if (i!=null) {
					if (sqlExcludeKlas==null) sqlExcludeKlas="";
					if (!sqlExcludeKlas.isEmpty()) sqlExcludeKlas = sqlExcludeKlas + ",";
					sqlExcludeKlas = sqlExcludeKlas+i.toString();
				}
			}
		}


		
		fillGrupp(con, kat, rootId, 0, onlyGroups, sqlExcludeGroups, lagernr, lev, sqlIncludeGroups, sqlExcludeKlas, excludeArt, avtalsPrisKundnr);
		
		if (lagernr != null && lagernr >= 0) {
			
		}

		return kat;
	}
	
	public static int fillGrupp(Connection con, Katalog kat, int grpId, int treeLevel, boolean onlyGroups, String sqlExcludeGroups, Integer lagernr, String lev, String sqlIncludeGroups, String sqlExcludeKlas, ArrayList<String> excludeArt, String avtalsprisKundnr) throws SQLException {
		String artOn = "(a.lev=? or 1=1) ";
		if (lev!=null && !lev.isEmpty()) artOn="a.lev=? ";
		
		if (excludeArt != null && !excludeArt.isEmpty()) {
			artOn += " and a.nummer not in (";
			for (int cn = 0; cn < excludeArt.size(); cn++) {
				if (cn>0) artOn += ",? "; else artOn +="? ";
			}
			artOn += " ) ";
		}		
		
		String klaseOn = "";
		if (sqlExcludeKlas != null && !sqlExcludeKlas.isEmpty()) {
			klaseOn = " and gl.klasid not in (" + sqlExcludeKlas + ")";
		}
		
		String q_select = 
		"select g.grpid, g.prevgrpid, g.rubrik, g.text, g.infourl, g.sortorder, k.klasid, gl.sortorder, k.rubrik, k.text, " +
		" k.infourl, kl.sortorder, a.nummer, a.namn, a.enhet, a.utpris, a.staf_pris1, a.staf_pris2, a.staf_antal1, a.staf_antal2, " +
		" a.rabkod, a.kod1, a.prisdatum, a.vikt, a.volym, a.forpack, a.kop_pack, a.inprisny, 0, 0, " +
		" a.utprisnydat, a.rsk, a.enummer, a.fraktvillkor, a.dagspris, a.utgattdatum,  a.minsaljpack, a.katnamn, a.bildartnr , l.maxlager, a.refnr, a.bestnr, prisgiltighetstid, " +
	   " COALESCE(kun.basrab,0) as kundbasrab, COALESCE(r2.rab, 0::real) AS gruppbasrab, COALESCE(r.rab, 0::real) AS undergrupprab, COALESCE(n.pris, 0::real) AS nettopris , a.rabkod, " +
                " a.inpdat as inpdat, a.prisdatum as prisdatum , a.kop_pack as kop_pack"         +
		" from artgrp g " +
		" left outer join artgrplank gl on gl.grpid = g.grpid " +
		" left outer join artklase k on k.klasid=gl.klasid " + klaseOn + " " +
		" left outer join artklaselank kl on kl.klasid = k.klasid " +
		" left outer join artikel a on  a.nummer = kl.artnr and "  + artOn +
		" left outer join lager l on l.artnr=kl.artnr and l.lagernr=? " +
		" LEFT JOIN kund kun ON kun.nummer=? " +
		" LEFT JOIN kunrab r2 ON r2.kundnr = kun.nummer AND COALESCE(r2.rabkod, ''::character varying)::text = COALESCE(a.rabkod, ''::character varying)::text AND COALESCE(r2.kod1, ''::character varying)::text = ''::text " +
		" LEFT JOIN kunrab r ON r.kundnr = kun.nummer AND COALESCE(r.rabkod, ''::character varying)::text = COALESCE(a.rabkod, ''::character varying)::text AND COALESCE(r.kod1, ''::character varying)::text = COALESCE(a.kod1, ''::character varying)::text " +
 	   " LEFT JOIN nettopri n ON n.lista = kun.nettolst AND n.artnr = a.nummer";

		
		String q_where_1 = 
		" where (g.prevgrpid = ? )";
		String q_where_2 = 
		" where (g.grpid = ?)";


		String q_orderby = 
		" order by g.sortorder, g.grpid, gl.sortorder, gl.klasid, kl.sortorder, kl.artnr";

		PreparedStatement stm;
		StringBuilder q_groups = new StringBuilder();
		int antalArtiklarTotaltDennaRootGrupp = 0;
		int antalArtiklarDennaGrupp = 0;
		int antalArtiklarSubGrupp = 0;
		int antalArtiklarDennaKlase = 0;
		
		if (sqlExcludeGroups != null && !sqlExcludeGroups.isEmpty()) {
			q_groups.append( " and g.grpid not in ("); q_groups.append(sqlExcludeGroups); q_groups.append(") ");
		}
		
		if (sqlIncludeGroups != null && !sqlIncludeGroups.isEmpty()) {
			q_groups.append( " and g.grpid in ("); q_groups.append(sqlIncludeGroups); q_groups.append(") ");
		}
		
		
		q_groups.append(" ");
		
		
		if (treeLevel==0 && grpId!=0) {			
			stm = con.prepareStatement(q_select + q_where_2 + q_groups.toString() + q_orderby);
		} else {
			stm = con.prepareStatement(q_select + q_where_1 + q_groups.toString() + q_orderby);
		}
		
		
		int paramPos = 1;
		stm.setString(paramPos++, lev);
		if (excludeArt!=null && !excludeArt.isEmpty()) {	
			for (String s : excludeArt) {
				stm.setString(paramPos++, s);		
			}
		} 
		
		stm.setInt(paramPos++, lagernr==null ? -1 : lagernr);
		stm.setString(paramPos++, avtalsprisKundnr);
		stm.setInt(paramPos++, grpId);
		
		

				  
		KatalogGrupp grupp = null;
		
		
		if (treeLevel==0 && grpId==0) { //Här har vi sökt efter rootgruppen, som inte går att slå upp i databasen, och därför sätter vi värdena manuellt.
			grupp = new KatalogGrupp();
			grupp.setGrpId(0);
			grupp.setPrevGrpId(0);
			grupp.setSortOrder(0);
			grupp.setTreeLevel(0);
			grupp.setRubrik("Huvudsortiment");
			kat.getGrupper().add(grupp);
			treeLevel++;
			grupp = null;
		}

		ResultSet rs = stm.executeQuery();
		KatalogKlase klase = null;
		KatalogArtikel artikel = null;

		while (rs.next()) {
			if (grupp==null || grupp.getGrpId() != rs.getInt(1)) {
				if (grupp != null && antalArtiklarSubGrupp <= 0 && antalArtiklarDennaGrupp <= 0 && lagernr != null) kat.getGrupper().remove(grupp);
				if (klase!=null && antalArtiklarDennaKlase <=0 && lagernr != null) grupp.getKlasar().remove(klase);
				
				antalArtiklarSubGrupp=0;					
				antalArtiklarDennaGrupp=0;
				antalArtiklarDennaKlase=0;
				//Nollställ klasen
				klase=null;
				
				grupp = new KatalogGrupp();
				kat.getGrupper().add(grupp);
				grupp.setGrpId(rs.getInt(1));
				grupp.setInfoUrl(rs.getString(5));
				grupp.setPrevGrpId(rs.getInt(2));
				grupp.setRubrik(rs.getString(3));
				grupp.setSortOrder(rs.getInt(6));
				grupp.setText(rs.getString(5));
				grupp.setTreeLevel(treeLevel);
				
				antalArtiklarSubGrupp = fillGrupp(con, kat, grupp.getGrpId(), treeLevel+1, onlyGroups, sqlExcludeGroups, lagernr, lev, sqlIncludeGroups, sqlExcludeKlas, excludeArt, avtalsprisKundnr);
				antalArtiklarTotaltDennaRootGrupp += antalArtiklarSubGrupp;
			}
			if ((klase==null || klase.getId() != rs.getInt(7)) && !onlyGroups) {
				if (klase!=null && antalArtiklarDennaKlase <=0 && lagernr != null) grupp.getKlasar().remove(klase);
				antalArtiklarDennaKlase=0;
				klase=null;		//Nollställ under alla händelser
				if (rs.getInt(7) > 0 ) { //Om vi har en klase
					klase = new KatalogKlase();
					grupp.getKlasar().add(klase);
					klase.setId(rs.getInt(7));
					klase.setInfourl(rs.getString(11));
					klase.setRubrik(rs.getString(9));
					klase.setSortOrder(rs.getInt(8));
					klase.setText(rs.getString(10));

				}
			}
			if(rs.getString(13)!=null && !onlyGroups && (lagernr==null || rs.getDouble(40) > 0)) {	//Om vi har artikel
				artikel = new KatalogArtikel();
				klase.getArtiklar().add(artikel);
				antalArtiklarDennaGrupp++;
				antalArtiklarTotaltDennaRootGrupp++;
				antalArtiklarDennaKlase++;
				artikel.setAntalStaf1(rs.getDouble(19));
				artikel.setAntalStaf2(rs.getDouble(20));
				artikel.setArtnr(rs.getString(13));
				if (rs.getString(39)!= null && rs.getString(39).length()>0)	artikel.setBildArtNr(rs.getString(39)); else artikel.setBildArtNr(rs.getString(13));
				artikel.setEnhet(convertEnhet2Readable(rs.getString(15)));
				artikel.setForpackning(rs.getDouble(26));
				artikel.setFraktvillkor(rs.getInt(34));
				artikel.setKatalogtext(rs.getString(38));
				artikel.setMinSaljpack(rs.getDouble(37));
				artikel.setPris(rs.getDouble(16));
				artikel.setPrisStaf1(rs.getDouble(17));
				artikel.setPrisStaf2(rs.getDouble(18));
				artikel.setRabkod(rs.getString(21));
				artikel.setKod1(rs.getString(22));
				artikel.setSortOrder(rs.getInt(12));			
				artikel.setUtgattdatum(rs.getDate(36));		
				artikel.setMaxlager(rs.getDouble(40));
				artikel.setRefnr(rs.getString(41));
				artikel.setBestnr(rs.getString(42));
				artikel.setRsk(rs.getString(32));
				artikel.setEnr(rs.getString(33));
				artikel.setPrisgiltighetstid(rs.getInt(43));
                                artikel.setInpdat(rs.getDate("inpdat"));
                                artikel.setPrisdatum(rs.getDate("prisdatum"));
				artikel.setKopPack(rs.getDouble("kop_pack"));
				if (avtalsprisKundnr!=null) {
					double rab=0.0;

					Double noll = new Double(0.0);
					//Är det rabatt på gruppnivå så gäller den
					if (!noll.equals(rs.getDouble(46)) ) rab = rs.getDouble(46);
					else if (!noll.equals(rs.getDouble(45)) ) rab = rs.getDouble(45);	//Rabatt på basgruppnivå
					else if (!noll.equals(rs.getDouble(44)) && !"NTO".equals(rs.getString(48)) ) rab = rs.getDouble(44);	//Rabatt på basgruppnivå

					if (!noll.equals(rs.getDouble(47)) ) { //Om nettoprislista
						artikel.setPris(rs.getDouble(47));
						artikel.setPrisStaf1(0.0);
						artikel.setPrisStaf2(0.0);

					} else {
						artikel.setPris(artikel.getPris()*(1-rab/100));
						artikel.setPrisStaf1(artikel.getPrisStaf1()*(1-rab/100));
						artikel.setPrisStaf2(artikel.getPrisStaf2()*(1-rab/100));
					}
				}
			}
		}
		
		if (grupp != null && antalArtiklarSubGrupp <= 0 && antalArtiklarDennaGrupp <= 0 && lagernr != null) kat.getGrupper().remove(grupp);
		if (klase!=null && antalArtiklarDennaKlase <=0 && lagernr != null) grupp.getKlasar().remove(klase);
		
		return antalArtiklarTotaltDennaRootGrupp;
		
	}


	public static String convertEnhet2Readable(String enh) {
		if (enh==null) return null;
		String e = enh.toLowerCase();
		if ("m2".equals(e)) e = "m²";
		else if ("m3".equals(e)) e = "m³";
		else if ("kg".equals(e)) e = "Kg³";
		return e;
	}
	
	
	
	
	
	
	
	
	
	
	
	
}
