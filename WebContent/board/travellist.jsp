<%@page import="beans.BoardReplyVO"%>
<%@page import="java.util.Objects"%>
<%@page import="beans.BoardDto"%>
<%@page import="java.util.List"%>
<%@page import="beans.BoardDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
%>
<jsp:include page="/template/header.jsp"></jsp:include>
<jsp:include page="/template/side.jsp"></jsp:include>
<%
	BoardDao travelBoardDao = new BoardDao();
	//카테고리 지정
	String cate = request.getParameter("cate");
	if(Objects.nonNull(cate)){
		session.setAttribute("cate", request.getParameter("cate"));
	}
	else{
		if(Objects.isNull(session.getAttribute("cate"))){//세션 만료시 재설정
			cate="여행";
			session.setAttribute("cate", cate);
		}
		else{
			cate = (String)session.getAttribute("cate");
		}
	}
	travelBoardDao.setCate(cate);
	
	//공지사항 목록 구하기, 공지사항 개수 확인
	List<BoardDto> noticeList = travelBoardDao.selectedNotice();
	int noticeNum = travelBoardDao.selectedNoticeNum();
	
	String type = request.getParameter("type"); 
	String key = request.getParameter("key");
	String board_head = request.getParameter("head");
	boolean isSearch = type != null && key != null;
	boolean isFilter = board_head != null;
	//url로 이상한 값 들어온 경우 처리
	if(travelBoardDao.checkIsNotHead(board_head)){
		board_head = "전체";
	}
%> 
  
<%
   	//페이지분할,마지막 페이지
   	int boardSize;
   	if(session.getAttribute("size") == null){ //초기 기본페이지 개수 설정하기
   		boardSize=15;
   		session.setAttribute("size", boardSize);
   	} 
   	try{
   		boardSize = Integer.parseInt(request.getParameter("size"));
   		session.setAttribute("size", boardSize);
   	}
   	catch(Exception e){
   		boardSize = (int)session.getAttribute("size");
   	}
   	
   	//목록개수
   	int row;
   	if(isSearch){
   		row = travelBoardDao.selectCount(type, key, board_head);
   	}
   	else{
   		row = travelBoardDao.selectCount(board_head); 
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
	List<BoardReplyVO> travelList;
	if(isSearch){ 
		travelList = travelBoardDao.selectByPage(startRow, endRow, type, key, board_head); 
	}
	else{
		travelList = travelBoardDao.selectByPage(startRow, endRow, board_head); 
	}
%>


<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/board1.css">
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/board2.css">
<script src="https://code.jquery.com/jquery-3.5.1.js"></script>
<script>
	$(function(){
		/*글쓰기 버튼 클릭이벤트*/
		$(".write-btn").click(function(){
			location.href="<%=request.getContextPath()%>/board/write.jsp";
		});
		
		/*네비게이터(이전, 다음) 클릭이벤트*/
		let row = <%=row%>;
		if(row == 0){ /*조회 결과가 없을 시 페이지 네이게이터 비활성화*/
			$(".nav").click(function(e) {e.preventDefault(); });
			$(".nav").css("text-decoration", "none").css("color", "rgb(229, 229, 229)").css("cursor", "default");
		}
		else{
			let p = <%=p%>; /*현재 페이지*/
			let block = <%=block%>; /*페이지 블럭 개수*/
			let lastPage = <%=lastPage%>; /*마지막 페이지*/
			/*몫과 나머지 구하기('다음' 클릭 제어 위해서)*/
			let share = parseInt(lastPage/block);
			let remain = lastPage%block;
			let startP;/*마지막 페이지가 포함된 페이지 네이게이터의 첫번째 페이지 블럭*/
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
		}
		
		
		/*검색버튼 이벤트*/
		$(".input-sbtn").click(function(e){
			if($(".input-text").val().trim()==""){/*띄어쓰기만 있는 경우도 포함*/
				alert("검색어를 입력해주세요.");
				return false;
			}
		});

		/*공지숨기기 이벤트*/
		$(".noticeHide").change(function(e){
			$(".noticeBlock").toggle();
			sessionStorage.setItem("notice", $(this).prop("checked"));
		});
		
		if(sessionStorage.getItem("notice") == "true"){
			$(".noticeHide").prop("checked", true);
			$(".noticeBlock").hide();
		}
		
		
		let isSearch = <%=isSearch%>;
		
		/*말머리 글자변경 */
		let filter = <%=isFilter%>; /*말머리 선택하지 않았을 시에는 '말머리' 나오도록 설정*/
		if(filter){
			let head = "<%=board_head%>";
			$(".headFilter").text(head);
		}
		
		/*말머리 클릭 이벤트*/
		$(".headHref").click(function(e){
			let href="";
			let target = $(this).text();
			if(isSearch){
				href="travellist.jsp?type=<%=type%>&key=<%=key%>&head="+target;
			}
			else{
				href="travellist.jsp?head="+target;
			}
			location.href=href;
		});
		
		/*글개수 글자변경 */
		let listSize = <%=boardSize%>;
		let text = listSize + "개 보기";
		$(".listSize").text(text);
		
		/*글개수 변경 클릭 이벤트*/
		$(".listSizeHref").click(function(e){
			let href="";
			let target = $(this).text().substr(0,2);
			if(isSearch){
				href="travellist.jsp?type=<%=type%>&key=<%=key%>&head=<%=board_head%>&size="+target;
			}
			else{
				href="travellist.jsp?head=<%=board_head%>&size="+target;
			}
			location.href=href;
		});
		
		/*검색일 경우 숨김처리*/
		$(".searchResult").hide();
		if(isSearch){
			$(".noSearch").hide();
			$(".searchResult").show();
		}
		
		/*검색창 선택 처리*/
		let head = '<%=board_head%>';
		$(".searchHead option").each(function(index, item){
			if(head == $(item).text()){
				$(item).prop("selected", true);	
			}
		});
		
	});
</script>

<body>
<div class="outbox" style="width:1000px">
	<!-- float로 묶음 -->
	<div class="row floatbox margin">
		<div class="overflow">
			<div class="float-right noSearch">
				<!--검색일 경우에는 숨김처리 -->
				<label class="noticelbl">
				<input type="checkbox" class="noticeHide">
				공지숨기기
				</label>
				
				<div class="dropdown center">
					<span class="headFilter">말머리&darr;</span>
					<div class="dropdown-content">
						<div>
							<a class="headHref">전체</a>
						</div>
						<div>
							<a class="headHref">서울</a>
						</div>
						<div>
							<a class="headHref">부산</a>
						</div>
						<div>
							<a class="headHref">대구</a>
						</div>
						<div>
							<a class="headHref">인천</a>
						</div>
						<div>
							<a class="headHref">광주</a>
						</div>
						<div>
							<a class="headHref">대전</a>
						</div>
						<div>
							<a class="headHref">울산</a>
						</div>
						<div>
							<a class="headHref">세종</a>
						</div>
						<div>
							<a class="headHref">경기도</a>
						</div>
						<div>
							<a class="headHref">강원도</a>
						</div>
						<div>
							<a class="headHref">충북</a>
						</div>
						<div>
							<a class="headHref">충남</a>
						</div>
						<div>
							<a class="headHref">경북</a>
						</div>
						<div>
							<a class="headHref">경남</a>
						</div>
						<div>
							<a class="headHref">전북</a>
						</div>
						<div>
							<a class="headHref">전남</a>
						</div>
					</div>
				</div>
				
				<div class="dropdown">
					<span class="listSize">목록개수&darr;</span>
					<div class="dropdown-content">
						<div>
							<a class="listSizeHref">10개</a>
						</div>
						<div>
							<a class="listSizeHref">15개</a>
						</div>
						<div>
							<a class="listSizeHref">20개</a>
						</div>
						<div>
							<a class="listSizeHref">30개</a>
						</div>
					</div>
				</div>
				
			</div>
			
			<span class="title">여행게시판</span>
		</div>
		
	</div>
	
	<div class="row floatbox margin searchResult">
		<div class="overflow">
			<div class="float-right">
				<label class="noticelbl">
				<input type="checkbox" class="noticeHide">
				공지숨기기
				</label>
				
				<div class="dropdown">
					<span class="listSize">목록개수&darr;</span>
					<div class="dropdown-content">
						<div>
							<a class="listSizeHref">10개</a>
						</div>
						<div>
							<a class="listSizeHref">15개</a>
						</div>
						<div>
							<a class="listSizeHref">20개</a>
						</div>
						<div>
							<a class="listSizeHref">30개</a>
						</div>
					</div>
				</div>
				
			</div>
			
			<span class="resultNum">자유게시판 '<%=key%>' 검색결과 : <%=row%>건</span>
		</div>
		
	</div>
	
	<!-- 게시글 목록 -->
	<div class="row margin">
		<table class="table">
		<thead>
			<tr>
			<th width="90%" colspan="2"></th>
			<th>글쓴이</th>
			<th>작성일</th>
			<th>조회</th>
			<th>추천</th>
			</tr>
		</thead>
		
		<!-- 공지 출력 -->
		<tbody class="noticeBlock">
			<%
				if(noticeNum != 0) {
			%>
				<%
					for(BoardDto notice : noticeList){
				%>
					<tr>
						<td width="10%" class="notice-head-color">공지</td>
						<td width="50%" class="left notice-color">
							<a href="detail.jsp?board_no=<%=notice.getBoard_no()%>"><%=notice.getBoard_title()%></a>
						</td>
						<td><%=notice.getBoard_nick()%></td>
						<td><%=notice.getBoard_date()%></td>
						<td><%=notice.getBoard_view()%></td>
						<td><%=notice.getBoard_like()%></td>
					</tr>
				<%
					}
				%>
			<%
				}
			%>
		</tbody>
			
		<!-- 게시글 목록 출력 -->
		<tbody class="listBlock">
			<%
				if(travelList.isEmpty()){
					if(isSearch){ %>
						<tr><td colspan="6">검색결과가 존재하지 않습니다.</td></tr>
					<%}else{ %>
						<tr><td colspan="6">게시물이 존재하지 않습니다.</td></tr>
					<%} %>
			
			<%
				}else{
			%>
				<%
					for(BoardReplyVO travelDto : travelList){
				%>
				<tr>
					<td width="10%" class="head-color"><%=travelDto.getBoard_head() %></td>
					<td width="50%" class="left">
						<a href="detail.jsp?board_no=<%=travelDto.getBoard_no() %>#cl"><%=travelDto.getBoard_title() %></a>
						[<a href="detail.jsp?board_no=<%=travelDto.getBoard_no() %>#rl"><%=travelDto.getReplynum() %></a>]
					</td>
					<td><%=travelDto.getBoard_nick() %></td>
					<td><%=travelDto.getBoard_date() %></td>
					<td><%=travelDto.getBoard_view() %></td>
					<td><%=travelDto.getBoard_like() %></td>
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
					<%if(isSearch){ %>
						<li><a href="travellist.jsp?type=<%=type %>&key=<%=key %>&p=<%=startBlock-1%>&head=<%=board_head %>" class="previous nav">&lt;이전</a></li>
					<%}else { %>
						<li><a href="travellist.jsp?p=<%=startBlock-1%>&head=<%=board_head %>" class="previous nav">&lt;이전</a></li>
					<%} %>
				  	
				  	<%for(int i=startBlock; i<=endBlock; i++) {%>
				  		<%if(i==p){ %>
							<li class="active">
				  		<%}else{ %>
				  			<li>
				  		<%} %>
				  		
				  		<%if(isSearch){%>
							<a href="travellist.jsp?type=<%=type %>&key=<%=key %>&p=<%=i%>&head=<%=board_head%>"><%=i %></a>
				  		<%}else{ %>
							<a href="travellist.jsp?p=<%=i%>&head=<%=board_head%>"><%=i %></a>
				  		<%} %>
						</li>
				  	<%} %>
				 	
				 	<%if(isSearch){ %>
						<li><a href="travellist.jsp?type=<%=type %>&key=<%=key %>&p=<%=endBlock+1%>&head=<%=board_head %>" class="next nav">다음&gt;</a></li>
				 	<%}else{ %>
						<li><a href="travellist.jsp?p=<%=endBlock+1%>&head=<%=board_head %>" class="next nav">다음&gt;</a></li>
				 	<%} %>
			</ul>
		</div>
	</div>
	
	<!-- 검색창 -->
	<div class="row center div-search">
	<form action="travellist.jsp" method="post">
		
		<select class="input input-inline input-select searchHead" name="head">
		<option>전체</option>
		<option>서울</option>
		<option>부산</option>
		<option>대구</option>
		<option>인천</option>
		<option>광주</option>
		<option>대전</option>
		<option>울산</option>
		<option>세종</option>
		<option>경기도</option>
		<option>강원도</option>
		<option>충북</option>
		<option>충남</option>
		<option>경북</option>
		<option>경남</option>
		<option>전북</option>
		<option>전남</option>
		</select>
		
		<select class="input input-inline input-select" name="type">
		<option value="board_title" <%if(isSearch && type.equals("board_title")){ %>selected<%} %>>제목</option>
		<option value="board_nick" <%if(isSearch && type.equals("board_nick")){ %>selected<%} %>>글쓴이</option>
		</select>
		
		<%if(isSearch) {%>
		<input type="search" class="input input-inline input-text" name="key" value="<%=key%>" placeholder="검색어를 입력해주세요." maxlength="20">
		<%}else{%>
		<input type="search" class="input input-inline input-text" name="key" placeholder="검색어를 입력해주세요." maxlength="20">
		<%} %>
		
		<input type="submit" class="input input-inline input-sbtn" value="검색">
		<%if(isSearch){ %>
			<a href="travellist.jsp" class="reset">초기화&#10226;</a>
		<%} %>
	</form>
	</div>
	
</div>

</body>
<jsp:include page="/template/footer.jsp"></jsp:include>

















