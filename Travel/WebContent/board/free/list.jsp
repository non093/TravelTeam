<%@page import="travel.beans.FreeBoardDto"%>
<%@page import="java.util.List"%>
<%@page import="travel.beans.FreeBoardDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
	request.setCharacterEncoding("UTF-8");
	FreeBoardDao freeBoardDao = new FreeBoardDao(); 
	String type = request.getParameter("type"); 
	String key = request.getParameter("key");
	String board_head = request.getParameter("head");
	boolean isSearch = type != null && key != null;
	boolean isFilter = board_head != null;
%> 
  
<% 
	//페이지분할,마지막 페이지
	int boardSize;
	try{
		boardSize = Integer.parseInt(request.getParameter("size"));
	}
	catch(Exception e){
		boardSize = 15;
	}
	
	//목록개수
	int row;
	if(isSearch && isFilter){
		row = freeBoardDao.selectCount(type, key, board_head);
	}
	else if(isSearch && !isFilter){
		row = freeBoardDao.selectCount(type, key);
	}
	else if(!isSearch && isFilter){
		row = freeBoardDao.selectCount(board_head); 
	}
	else{
		row = freeBoardDao.selectCount();
	}
	int lastPage = (row + boardSize - 1)/boardSize;
	
	//페이지 정하기
	int p;
	try{
		p = Integer.parseInt(request.getParameter("p"));
		if(p<1) throw new Exception();
	}
	catch(Exception e){
			p=1;
	}
	int endRow = p*boardSize;
	int startRow = endRow - boardSize + 1;
	
	//페이지에 따른 네비게이터
	int block=10;
	int endBlock = (p + block - 1)/block*block;
	int startBlock = endBlock - block + 1;
	if(endBlock>lastPage){
		endBlock=lastPage;
	}
%>

<%
	//페이지 번호에 따른 게시글 목록 출력
	//검색
	List<FreeBoardDto> freeList;
	if(isSearch && isFilter){ 
		freeList = freeBoardDao.selectByPage(startRow, endRow, type, key, board_head); 
	}
	else if(isSearch && !isFilter){
		freeList = freeBoardDao.selectByPage(startRow, endRow, type, key); 
	}
	else if(!isSearch && isFilter){
		freeList = freeBoardDao.selectByPage(startRow, endRow, board_head); 
	}
	else{
		freeList = freeBoardDao.selectByPage(startRow, endRow);
	}
	
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/css/freeboard.css">
<style>
	.table{
		color: rgb(100, 100, 100);
	}
	.table>thead>tr>th{
		border-top:2px solid black;
		border-color: rgb(150, 150, 150);
		padding: 0 0.5rem 0.5rem;
		font-size: 0.8rem;
	}
	.table>tbody>tr>td{
		border-bottom:1px solid black;
		border-color: rgb(229, 229, 229);
		font-size: 0.9rem;
	}
	.table>tbody>tr:hover{
		background-color: #f5f5f5;
	}
	.table>tbody>tr>td>a{
		color: rgb(100, 100, 100);
		text-decoration:none;
	}
	.table>tbody>tr>td>a:hover{
		text-decoration: underline;
	}
	.head-color{
		color: rgb(150, 150, 150);
	}
	.input.input-select{
		border-radius: 5px;
		border-color: rgb(229, 229, 229);
		padding: 0.2rem;
		color: rgb(100, 100, 100);
		cursor: pointer;
	}
	.input.input-text{
		border-style: none none solid;
		border-color: rgb(150, 150, 150);
		padding: 0.2rem;
		color: rgb(100, 100, 100);
		width: 30%;
	}
	.input.input-sbtn{
		padding: 0.2rem 0.7rem;
		border:1px solid rgb(229, 229, 229);
		color: rgb(100, 100, 100);
		cursor: pointer;
		background-color:white;
		border-radius: 5px;
	}
	.input.write-btn{
		padding: 0.2rem 1rem;
		border:1px solid rgb(229, 229, 229);
		color: rgb(100, 100, 100);
		cursor: pointer;
		background-color:white;
		border-radius: 5px;
	}
	.input.input-sbtn:hover{
		background-color: #f5f5f5;
	}
	.input.write-btn:hover{
		background-color: #f5f5f5;
	}
	
	/*float*/
	.float-box::after{
		content: "";
		display: block;
		clear: both;
	}
	.float-right{
		float:right;
	}
	.overflow{
		overflow: auto;
	}
	.overflow span{
		vertical-align: bottom;
	}
	
	.outbox>.row.margin{
		margin:0;
	}
	.outbox>.row.div-search{
		margin: 1rem 0;
	}
	.title{
		font-size: 1.3rem;
		color: rgb(90, 90, 90);
	}
	
	/*드롭다운*/
	.dropdown {
	  display: inline-block;
	  color: rgb(100, 100, 100);
	  font-size: 0.8rem;
	  cursor:pointer;
	}
	
	.dropdown-content {
	  display: none;
	  position: absolute;
	  background-color: #f9f9f9;
	  max-width: auto;
	  box-shadow: 0px 0px 5px 0px rgba(0,0,0,0.2);
	  padding: 10px 12px;
	  z-index: 1;
	  font-size: 0.9rem;
	  cursor:pointer;
	}
	.dropdown-content a{
		color: rgb(100, 100, 100);
		text-decoration: none;
	}
	.dropdown:hover{
		text-decoration: underline;
	}
	.dropdown:hover .dropdown-content {
	  display: block;
	}
	.dropdown-content div:hover a {
	  text-decoration: underline;
	}
</style>
<script src="https://code.jquery.com/jquery-3.5.1.js"></script>
<script>
	$(function(){
		/*글쓰기 버튼 클릭이벤트*/
		$(".write-btn").click(function(){
			location.href="<%=request.getContextPath()%>/board/free/write.jsp";
		});
		
		/*네비게이터(이전, 다음) 클릭이벤트*/
		var p = <%=p%>;
		var block = <%=block%>;
		var lastPage = <%=lastPage%>;
		/*몫과 나머지 구하기(다음 클릭 제어 위해서)*/
		var share = parseInt(lastPage/block);
		var remain = lastPage%block;
		var startP;
		if(remain==0){
			startP = (share-1)*block+1;
		}
		else{
			startP = share*block+1;
		}
		
		if(p>=1&&p<=block){
			$(".previous").click(function(e) {e.preventDefault(); });
			$(".previous").css("text-decoration", "none").css("color", "rgb(229, 229, 229)").css("cursor", "default");
		}
		
		if(p>=startP && p<=lastPage){
			$(".next").click(function(e){e.preventDefault(); });
			$(".next").css("text-decoration", "none").css("color", "rgb(229, 229, 229)").css("cursor", "default");
		}
		
		/*검색버튼 이벤트*/
		$(".input-sbtn").click(function(e){
			if($(".input-text").val().trim()==""){
				alert("검색어를 입력해주세요.");
				return false;
			}
		});
		
	});
</script>
</head>
<body>

<div class="outbox" style="width:1000px">
	<!-- float로 묶음 -->
	<div class="row floatbox margin">
		<div class="overflow">
			<!-- 게시글 필터 -->
			<div class="float-right">
				<label>
				<input type="checkbox">
				공지숨기기
				</label>
				
				<div class="dropdown">
					<span>말머리&darr;</span>
					<div class="dropdown-content">
						<div>
							<a href="list.jsp?head=전체">전체</a>
						</div>
						<div>
							<a href="list.jsp?head=사담">사담</a>
						</div>
						<div>
							<a href="list.jsp?head=질문">질문</a>
						</div>
					</div>
				</div>
				
				<div class="dropdown">
					<span>목록개수&darr;</span>
					<div class="dropdown-content">
						<div>
							<a href="list.jsp?size=10">10개</a>
						</div>
						<div>
							<a href="list.jsp?size=15">15개</a>
						</div>
						<div>
							<a href="list.jsp?size=30">20개</a>
						</div>
						<div>
							<a href="list.jsp?size=30">30개</a>
						</div>
					</div>
				</div>
				
			</div>
			
			<span class="title">자유게시판</span>
		</div>
		
	</div>
	
	<!-- 게시글 목록 -->
	<div class="row margin">
		<table class="table">
		<thead>
			<tr>
			<th width="55%" colspan="2"></th>
			<th>글쓴이</th>
			<th>작성일</th>
			<th>조회</th>
			<th>추천</th>
			</tr>
		</thead>
		<tbody>
		
			<!-- 게시글 목록 출력 -->
			<%if(freeList.isEmpty()){ %>
				<tr><td colspan="6">검색결과가 존재하지 않습니다.</td></tr>
			<%}else{ %>
				<%for(FreeBoardDto freeDto : freeList){ %>
				<tr>
					<td class="head-color"><%=freeDto.getBoard_head() %></td>
					<td width="50%" class="left">
						<a href="detail.jsp?board_no=<%=freeDto.getBoard_no() %>"><%=freeDto.getBoard_title() %></a>
					</td>
					<td><%=freeDto.getBoard_nick() %></td>
					<td><%=freeDto.getBoard_date() %></td>
					<td><%=freeDto.getBoard_view() %></td>
					<td><%=freeDto.getBoard_like() %></td>
				</tr>
				<%} %>
			<%} %>
			
		</tbody>
		</table>
	</div>
	
	<!-- float으로 묶음 -->
	<div class="row floatbox">
		<!-- 글쓰기 버튼 -->
		<div class="float-right"><button class="input input-inline write-btn">글쓰기</button></div>
		
		<!-- 페이지 네비게이터 -->
		<div class="center">
			<ul class="pagination">
					<li><a href="list.jsp?p=<%=startBlock-1%>" class="previous">&lt;이전</a></li>
				  	
				  	<%for(int i=startBlock; i<=endBlock; i++) {%>
				  		<%if(i==p){ %>
							<li class="active">
				  		<%}else{ %>
				  			<li>
				  		<%} %>
				  		
				  		<%if(isSearch && isFilter){%>
							<a href="list.jsp?type=<%=type %>&key=<%=key %>&p=<%=i%>&head=<%=board_head%>"><%=i %></a>
				  		<%}else if(isSearch && !isFilter){ %>
							<a href="list.jsp?type=<%=type %>&key=<%=key %>&p=<%=i%>"><%=i %></a>
				  		<%}else if(!isSearch && isFilter){ %>
							<a href="list.jsp?p=<%=i%>&head=<%=board_head%>"><%=i %></a>
				  		<%}else{ %>
							<a href="list.jsp?p=<%=i%>"><%=i %></a>
				  		<%} %>
						</li>
				  	<%} %>
				 
					<li><a href="list.jsp?p=<%=endBlock+1%>" class="next">다음&gt;</a></li>
			</ul>
		</div>
	</div>
	
	<!-- 검색창 -->
	<div class="row center div-search">
	<form action="list.jsp" method="post">
		
		<select class="input input-inline input-select" name="head">
		<option <%if(isFilter && board_head.equals("전체")){ %>selected<%} %>>전체</option>
		<option <%if(isFilter && board_head.equals("사담")){ %>selected<%} %>>사담</option>
		<option <%if(isFilter && board_head.equals("질문")){ %>selected<%} %>>질문</option>
		</select>
		
		<select class="input input-inline input-select" name="type">
		<option value="board_title" <%if(isSearch && type.equals("board_title")){ %>selected<%} %>>제목</option>
		<option value="board_nick" <%if(isSearch && type.equals("board_nick")){ %>selected<%} %>>글쓴이</option>
		</select>
		
		<%if(isSearch) {%>
		<input type="text" class="input input-inline input-text" name="key" value="<%=key%>" placeholder="검색어를 입력해주세요.">
		<%}else{%>
		<input type="text" class="input input-inline input-text" name="key" placeholder="검색어를 입력해주세요.">
		<%} %>
		
		<input type="submit" class="input input-inline input-sbtn" value="검색">
	</form>
	</div>
	
</div>

</body>
</html>


















