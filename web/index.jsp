<%-- 
    Document   : index
    Created on : 2012-okt-29, 10:43:41
    Author     : Ulf
--%>

<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.util.Scanner"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Rapporter - Säljex</title>
    </head>
    <body>
        <h1>Rapporter</h1>
		<%
		final  String relPath = "rapp/";
		String path = request.getServletContext().getRealPath(relPath);
		try {
			java.io.File d = new java.io.File(path);
			java.io.File[] files = d.listFiles();

			String rubrik;
			if (files == null) {
				out.print("Hittar inga filer");
			} else {
				for(java.io.File f : files) {
					if (f.getName()!= null && f.getName().endsWith(".jsp") && !f.getName().equals("index.jsp")) {
						String text = null;
						try {
							int len;
							char[] chr = new char[4096]; 
							final StringBuilder buffer = new StringBuilder();
							final FileInputStream stream = new FileInputStream(f);
							final InputStreamReader r = new InputStreamReader(stream,"ISO-8859-1");
							try {
								
								while ((len = r.read(chr)) > 0) {
									buffer.append(chr, 0, len);
								}
							} finally {
								r.close();
								stream.close();
							}
							text = buffer.toString();
						} catch (Exception ee)		  { out.print(ee.toString()); }
						
						
						int start = text.indexOf("<sx-rubrik>");
						int end = text.indexOf("</sx-rubrik>");
						if (start>-1 && end>1 && end>start) {
							rubrik = text.substring(start, end);
						} else {
							rubrik=f.getName();
						}
						out.print("<a href=\"" + relPath + f.getName() + "\">" + rubrik + "</a><br>");
					}
				}
			}
		
		} catch (NullPointerException e) { e.printStackTrace();}
		
		
%>		
    </body>
</html>
