<%-- 
    Document   : statistikgenerator
    Created on : 2014-jan-28, 12:41:25
    Author     : Ulf
--%>

<%@page import="java.net.URL"%>
<%@page import="com.google.gdata.data.spreadsheet.SpreadsheetEntry"%>
<%@page import="java.util.List"%>
<%@page import="com.google.gdata.data.spreadsheet.SpreadsheetFeed"%>
<%@page import="se.saljex.rapporter.SpreadsheetBudget"%>
<%@page import="com.google.gdata.client.spreadsheet.SpreadsheetService"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>JSP Page</title>
	</head>
	<body>
		<h1>Test för att generera statistik.</h1>
		<%
				SpreadsheetService s = SpreadsheetBudget.getService();
				SpreadsheetFeed feed = s.getFeed(new URL("https://spreadsheets.google.com/feeds/spreadsheets/private/full"),SpreadsheetFeed.class);
				List<SpreadsheetEntry> spreadsheets = feed.getEntries();
				%>
				Titlar<br>
				<%
				for (SpreadsheetEntry e : spreadsheets) {
							%>Titel:<%=  e.getTitle().getPlainText() + "id:" + e.getId()  %><br><% 
					
					
				}
				
		%>
		
		
		
	</body>
</html>

