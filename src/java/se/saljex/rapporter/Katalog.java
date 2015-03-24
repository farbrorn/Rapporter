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
public class Katalog {
	private String datumString;
	private String logoUrl;

	public Katalog() {
		datumString = Util.getFormatDate();
	}
	
	


	public String getDatumString() {
		return datumString;
	}

	public void setDatumString(String datumString) {
		this.datumString = datumString;
	}

	public String getLogoUrl() {
		return logoUrl;
	}

	public void setLogoUrl(String logoUrl) {
		this.logoUrl = logoUrl;
	}

	private ArrayList<KatalogGrupp> grupper = new ArrayList<KatalogGrupp>();

	public ArrayList<KatalogGrupp> getGrupper() {
		return grupper;
	}

	public void setGrupper(ArrayList<KatalogGrupp> grupper) {
		this.grupper = grupper;
	}
	
}
