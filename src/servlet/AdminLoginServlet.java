package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.AdminDao;
import beans.AdminDto;



@WebServlet(urlPatterns ="/admin/adminLogin.do")
public class AdminLoginServlet extends HttpServlet{
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			req.setCharacterEncoding("UTF-8");
			AdminDto adminDto = new AdminDto();
			
			adminDto.setAdmin_id(req.getParameter("admin_id"));
			adminDto.setAdmin_pw(req.getParameter("admin_pw"));
		
			
			
			
			AdminDao adminDao = new AdminDao();
			boolean login = adminDao.login(adminDto);
			
			if(login) {
				AdminDto ad = adminDao.find(adminDto.getAdmin_id());
				req.getSession().setAttribute("check", ad.getAdmin_no());
				req.getSession().setAttribute("auth", ad.getAdmin_auth());
				
				resp.sendRedirect("../index.jsp");
			}
			else {
				resp.sendRedirect("adminLogin.jsp?error");
			}
			
		}
		catch(Exception e) {
			e.printStackTrace();
			resp.sendError(500);
		}
	}
}
