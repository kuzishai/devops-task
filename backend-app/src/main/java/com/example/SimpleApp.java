package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class SimpleApp extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        String jsonResponse = String.format(
            "{\n" +
            "  \"status\": \"OK\",\n" +
            "  \"message\": \"Backend service is running\",\n" +
            "  \"timestamp\": \"%s\",\n" +
            "  \"hostname\": \"%s\"\n" +
            "}",
            new Date().toString(),
            System.getenv("HOSTNAME")
        );
        
        out.print(jsonResponse);
        out.flush();
    }
}