/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.rapporter;

import java.util.ArrayList;

/**
 *
 * @author Ulf
 */
public class KatalogKlase {
	private int id;
	private int sortOrder;
	private String rubrik;
	private String text;
	private String infourl;
	private ArrayList<KatalogArtikel> artiklar = new ArrayList<KatalogArtikel>();

	public int getSortOrder() {
		return sortOrder;
	}

	public void setSortOrder(int sortOrder) {
		this.sortOrder = sortOrder;
	}

	public ArrayList<KatalogArtikel> getArtiklar() {
		return artiklar;
	}

	public void setArtiklar(ArrayList<KatalogArtikel> artiklar) {
		this.artiklar = artiklar;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getInfourl() {
		return infourl;
	}

	public void setInfourl(String infourl) {
		this.infourl = infourl;
	}

	public String getRubrik() {
		return rubrik;
	}

	public void setRubrik(String rubrik) {
		this.rubrik = rubrik;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}
	
}
