/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.rapporter;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.loginservice.LoginServiceConstants;
import se.saljex.loginservice.User;

/**
 *
 * @author Ulf
 */
@WebServlet(name = "finfofil", urlPatterns = {"/finfofil"})
public class finfofil extends HttpServlet {

	/**
	 * Processes requests for both HTTP
	 * <code>GET</code> and
	 * <code>POST</code> methods.
	 *
	 * @param request servlet request
	 * @param response servlet response
	 * @throws ServletException if a servlet-specific error occurs
	 * @throws IOException if an I/O error occurs
	 */
	protected void processRequest(HttpServletRequest request, HttpServletResponse response)
			  throws ServletException, IOException {
		User user=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		ByteArrayOutputStream w = new ByteArrayOutputStream();
		try {
			ResultSet rs = con.prepareStatement("select * from finfofil order by textrad").executeQuery();
			while (rs.next()) {
	//				w.println(new String(rs.getString(1).getBytes(),"ISO-8859-1"));
				w.write(rs.getString(1).getBytes("ISO-8859-1"));
				w.write("\n".getBytes());
				w.flush();

			}
		} catch (Exception e) { 
			response.setContentType("text/html");
			response.getWriter().print(e.toString()); 
		}
		
		
		ServletOutputStream o = response.getOutputStream();
		try {
			response.setContentType("text/plain");
			response.setHeader("Content-Disposition", "attachment;filename=INFIL04.txt");
			w.writeTo(o);
		} finally {			
			o.close();
		}
	}

	// <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
	/**
	 * Handles the HTTP
	 * <code>GET</code> method.
	 *
	 * @param request servlet request
	 * @param response servlet response
	 * @throws ServletException if a servlet-specific error occurs
	 * @throws IOException if an I/O error occurs
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			  throws ServletException, IOException {
		processRequest(request, response);
	}

	/**
	 * Handles the HTTP
	 * <code>POST</code> method.
	 *
	 * @param request servlet request
	 * @param response servlet response
	 * @throws ServletException if a servlet-specific error occurs
	 * @throws IOException if an I/O error occurs
	 */
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			  throws ServletException, IOException {
		processRequest(request, response);
	}

	/**
	 * Returns a short description of the servlet.
	 *
	 * @return a String containing servlet description
	 */
	@Override
	public String getServletInfo() {
		return "Short description";
	}// </editor-fold>
}
