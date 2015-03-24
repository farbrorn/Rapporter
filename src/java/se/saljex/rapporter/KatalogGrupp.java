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
public class KatalogGrupp {
	private int grpId;
	private int prevGrpId;
	private int sortOrder;
	private int treeLevel;
	private String rubrik;
	private String text;
	private String infoUrl;
	private ArrayList<KatalogKlase> klasar = new ArrayList<KatalogKlase>();

	public int getTreeLevel() {
		return treeLevel;
	}

	public void setTreeLevel(int treeLevel) {
		this.treeLevel = treeLevel;
	}

	public int getGrpId() {
		return grpId;
	}

	public void setGrpId(int grpId) {
		this.grpId = grpId;
	}

	public String getInfoUrl() {
		return infoUrl;
	}

	public void setInfoUrl(String infoUrl) {
		this.infoUrl = infoUrl;
	}

	public ArrayList<KatalogKlase> getKlasar() {
		return klasar;
	}

	public void setKlasar(ArrayList<KatalogKlase> klasar) {
		this.klasar = klasar;
	}

	public int getPrevGrpId() {
		return prevGrpId;
	}

	public void setPrevGrpId(int prevGrpId) {
		this.prevGrpId = prevGrpId;
	}

	public String getRubrik() {
		return rubrik;
	}

	public void setRubrik(String rubrik) {
		this.rubrik = rubrik;
	}

	public int getSortOrder() {
		return sortOrder;
	}

	public void setSortOrder(int sortOrder) {
		this.sortOrder = sortOrder;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}
	
	
}
