/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.rapporter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.annotation.security.RunAs;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.sql.DataSource;
import se.saljex.sxlibrary.SXUtil;

/**
 *
 * @author Ulf
 */



/**
 *
 * @author Ulf
 */
@WebFilter(filterName = "MainFilter", urlPatterns = {"/*"})
public class MainFilter extends se.saljex.loginservice.LoginServiceFilter {
	
	@Resource(mappedName = "sxadm")
	private DataSource sxadm;
	@Resource(mappedName = "sxsuperuser")
	private DataSource sxsuperuser;
	
	public MainFilter() {
		super();
	}	
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		Connection con=null;
		Connection con2=null;
		try {
			con = sxadm.getConnection();
			request.setAttribute("sxconnection", con);
			con2 = sxsuperuser.getConnection();
			request.setAttribute("sxsuperuserconnection", con2);
			super.doFilter(request,response,chain);
		} catch (SQLException e) {
			Logger.getLogger("sx-logger").severe("SQL-Fel:" + e.getMessage()); e.printStackTrace();
		} finally { try {con.close(); con2.close();} catch (Exception eee) {}}		
	}
	
}
